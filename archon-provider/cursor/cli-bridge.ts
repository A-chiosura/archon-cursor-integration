import { spawn } from 'node:child_process';

import type { CursorProviderDefaults } from './config';

export interface RunCursorCliOptions {
  binaryPath: string;
  cwd: string;
  prompt: string;
  config: CursorProviderDefaults;
  model?: string;
  resumeSessionId?: string;
  env?: Record<string, string>;
  abortSignal?: AbortSignal;
}

export interface RunCursorCliResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

export async function runCursorCli(options: RunCursorCliOptions): Promise<RunCursorCliResult> {
  const args: string[] = [
    '-p',
    '--output-format',
    options.config.outputFormat ?? 'stream-json',
  ];

  if (options.config.forceAllowTools !== false) args.push('--force');
  if (options.config.trustWorkspace !== false) args.push('--trust');
  if (options.config.approveMcps !== false) args.push('--approve-mcps');
  if (options.config.sandbox === 'enabled') args.push('--sandbox', 'enabled');
  if (options.config.sandbox === 'disabled') args.push('--sandbox', 'disabled');
  if (options.model) args.push('--model', options.model);
  if (options.resumeSessionId) args.push('--resume', options.resumeSessionId);
  args.push('--workspace', options.cwd);
  args.push(options.prompt);

  const env = { ...process.env, ...(options.env ?? {}) };

  return new Promise((resolve, reject) => {
    const child = spawn(options.binaryPath, args, {
      cwd: options.cwd,
      env,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (buf: Buffer) => {
      stdout += buf.toString('utf-8');
    });
    child.stderr.on('data', (buf: Buffer) => {
      stderr += buf.toString('utf-8');
    });

    const onAbort = () => {
      child.kill('SIGTERM');
    };
    options.abortSignal?.addEventListener('abort', onAbort, { once: true });

    child.on('error', err => {
      options.abortSignal?.removeEventListener('abort', onAbort);
      reject(err);
    });

    child.on('close', code => {
      options.abortSignal?.removeEventListener('abort', onAbort);
      resolve({ stdout, stderr, exitCode: code ?? 1 });
    });
  });
}
