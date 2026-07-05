import { createLogger } from '@archon/paths';

import type { IAgentProvider, MessageChunk, ProviderCapabilities, SendQueryOptions } from '../../types';

import { resolveCursorAuth } from './auth-resolver';
import { resolveCursorBinaryPath } from './binary-resolver';
import { runCursorCli } from './cli-bridge';
import { CURSOR_CAPABILITIES } from './capabilities';
import { parseCursorConfig, type CursorProviderDefaults } from './config';
import { chunksFromPlainText, parseCursorStream } from './event-bridge';
import { loadCursorSession, saveCursorSession } from './session-store';

let cachedLog: ReturnType<typeof createLogger> | undefined;
function getLog(): ReturnType<typeof createLogger> {
  if (!cachedLog) cachedLog = createLogger('provider.cursor');
  return cachedLog;
}

function scopeKey(options?: SendQueryOptions): string {
  return options?.nodeConfig?.nodeId ?? 'default';
}

export class CursorProvider implements IAgentProvider {
  async *sendQuery(
    prompt: string,
    cwd: string,
    resumeSessionId?: string,
    options?: SendQueryOptions,
  ): AsyncGenerator<MessageChunk> {
    const auth = resolveCursorAuth();
    if (!auth.ok) {
      throw new Error(auth.reason ?? 'Cursor authentication failed');
    }

    const assistantRaw = options?.assistantConfig?.cursor ?? options?.assistantConfig?.['cursor'];
    const config: CursorProviderDefaults = parseCursorConfig(assistantRaw);
    const binaryPath = resolveCursorBinaryPath(config.cursorBinaryPath);

    const scope = scopeKey(options);
    const storedSession = resumeSessionId ?? loadCursorSession(cwd, scope);
    const requestedResume = Boolean(resumeSessionId ?? storedSession);

    getLog().info(
      { cwd, model: options?.model ?? config.model, resume: requestedResume },
      'cursor.sendQuery.start',
    );

    const run = await runCursorCli({
      binaryPath,
      cwd,
      prompt,
      config,
      model: options?.model ?? config.model,
      resumeSessionId: storedSession,
      env: options?.env,
      abortSignal: options?.abortSignal,
    });

    const parsed =
      (config.outputFormat ?? 'stream-json') === 'stream-json'
        ? parseCursorStream(run.stdout, run.stderr, run.exitCode)
        : chunksFromPlainText(run.stdout, run.stderr, run.exitCode);

    const resumed = requestedResume ? Boolean(storedSession) : undefined;

    for (const chunk of parsed.chunks) {
      if (chunk.type === 'result') {
        yield {
          ...chunk,
          sessionId: parsed.sessionId ?? chunk.sessionId,
          resumed: requestedResume ? Boolean(storedSession) : undefined,
        };
      } else {
        yield chunk;
      }
    }

    if (parsed.sessionId) {
      saveCursorSession(cwd, scope, parsed.sessionId);
    }

    if (run.exitCode !== 0) {
      const detail = run.stderr.trim() || run.stdout.trim() || `Cursor CLI exited with code ${run.exitCode}`;
      getLog().error({ exitCode: run.exitCode }, 'cursor.sendQuery.failed');
      throw new Error(`Cursor provider failed: ${detail}`);
    }
  }

  getType(): string {
    return 'cursor';
  }

  getCapabilities(): ProviderCapabilities {
    return CURSOR_CAPABILITIES;
  }
}
