import type { MessageChunk } from '../../types';

export interface ParsedCursorStream {
  chunks: MessageChunk[];
  sessionId?: string;
  exitCode: number;
  stderr: string;
}

/**
 * Best-effort parser for `agent --output-format stream-json` lines.
 * Falls back to plain text aggregation when JSON lines are absent.
 */
export function parseCursorStream(stdout: string, stderr: string, exitCode: number): ParsedCursorStream {
  const chunks: MessageChunk[] = [];
  let sessionId: string | undefined;
  let textBuffer = '';

  const lines = stdout.split(/\r?\n/).filter(Boolean);

  for (const line of lines) {
    let event: Record<string, unknown> | undefined;
    try {
      event = JSON.parse(line) as Record<string, unknown>;
    } catch {
      textBuffer += (textBuffer ? '\n' : '') + line;
      continue;
    }

    const type = typeof event.type === 'string' ? event.type : undefined;

    if (type === 'session' && typeof event.session_id === 'string') {
      sessionId = event.session_id;
      continue;
    }

    if (type === 'assistant' || type === 'text' || type === 'message') {
      const content =
        (typeof event.text === 'string' && event.text) ||
        (typeof event.content === 'string' && event.content) ||
        (typeof event.delta === 'string' && event.delta) ||
        '';
      if (content) {
        chunks.push({ type: 'assistant', content });
        textBuffer += content;
      }
      continue;
    }

    if (type === 'tool_call' || type === 'tool') {
      chunks.push({
        type: 'tool',
        toolName: String(event.tool ?? event.name ?? 'tool'),
        toolInput: (event.input as Record<string, unknown>) ?? undefined,
        toolCallId: typeof event.id === 'string' ? event.id : undefined,
      });
      continue;
    }

    if (type === 'tool_result') {
      chunks.push({
        type: 'tool_result',
        toolName: String(event.tool ?? event.name ?? 'tool'),
        toolOutput: String(event.output ?? event.result ?? ''),
        toolCallId: typeof event.id === 'string' ? event.id : undefined,
      });
      continue;
    }

    if (type === 'result' || type === 'final') {
      if (typeof event.session_id === 'string') sessionId = event.session_id;
      const finalText = typeof event.result === 'string' ? event.result : textBuffer;
      if (finalText) textBuffer = finalText;
    }
  }

  if (textBuffer && !chunks.some(c => c.type === 'assistant')) {
    chunks.push({ type: 'assistant', content: textBuffer });
  }

  chunks.push({
    type: 'result',
    sessionId,
    isError: exitCode !== 0,
  });

  return { chunks, sessionId, exitCode, stderr };
}

export function chunksFromPlainText(stdout: string, stderr: string, exitCode: number): ParsedCursorStream {
  const text = stdout.trim();
  const chunks: MessageChunk[] = [];
  if (text) chunks.push({ type: 'assistant', content: text });
  chunks.push({ type: 'result', isError: exitCode !== 0 });
  return { chunks, exitCode, stderr };
}
