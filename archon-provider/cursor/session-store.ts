import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

export interface CursorSessionRecord {
  sessionId: string;
  updatedAt: string;
}

function sessionPath(cwd: string, scopeKey: string): string {
  const dir = join(cwd, '.archon', 'cursor-sessions');
  mkdirSync(dir, { recursive: true });
  const safe = scopeKey.replace(/[^a-zA-Z0-9._-]+/g, '_');
  return join(dir, `${safe}.json`);
}

export function loadCursorSession(cwd: string, scopeKey: string): string | undefined {
  const path = sessionPath(cwd, scopeKey);
  try {
    const raw = readFileSync(path, 'utf-8');
    const parsed = JSON.parse(raw) as CursorSessionRecord;
    return typeof parsed.sessionId === 'string' ? parsed.sessionId : undefined;
  } catch {
    return undefined;
  }
}

export function saveCursorSession(cwd: string, scopeKey: string, sessionId: string): void {
  const path = sessionPath(cwd, scopeKey);
  const record: CursorSessionRecord = { sessionId, updatedAt: new Date().toISOString() };
  writeFileSync(path, JSON.stringify(record, null, 2));
}
