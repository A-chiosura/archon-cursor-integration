import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

function probeAgentStatus(env: Record<string, string>): boolean {
  const binary = env.CURSOR_BINARY?.trim() || 'agent';
  try {
    const out = execFileSync(binary, ['status'], {
      encoding: 'utf-8',
      stdio: ['ignore', 'pipe', 'pipe'],
      timeout: 10_000,
      env: env as NodeJS.ProcessEnv,
    });
    return /logged\s+in/i.test(out);
  } catch {
    return false;
  }
}

export function resolveCursorAuth(env: Record<string, string> = process.env as Record<string, string>): {
  ok: boolean;
  reason?: string;
} {
  if (env.CURSOR_API_KEY?.trim()) return { ok: true };

  const authMarkers = [
    join(homedir(), '.cursor', 'auth.json'),
    join(homedir(), '.config', 'cursor', 'auth.json'),
  ];

  for (const path of authMarkers) {
    if (existsSync(path)) {
      try {
        const raw = readFileSync(path, 'utf-8');
        if (raw.trim().length > 2) return { ok: true };
      } catch {
        // continue
      }
    }
  }

  if (probeAgentStatus(env)) return { ok: true };

  return {
    ok: false,
    reason:
      'Cursor is not authenticated. Run `agent login` or set CURSOR_API_KEY before running cursor provider workflows.',
  };
}
