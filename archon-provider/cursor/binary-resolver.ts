import { accessSync, constants as fsConstants, existsSync, statSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { homedir } from 'node:os';
import { join } from 'node:path';

function isExecutableFile(path: string): boolean {
  try {
    const stat = statSync(path);
    if (!stat.isFile()) return false;
    if (process.platform === 'win32') return true;
    accessSync(path, fsConstants.X_OK);
    return true;
  } catch {
    return false;
  }
}

function resolveFromPath(): string | undefined {
  const lookupCmd = process.platform === 'win32' ? 'where' : 'which';
  try {
    const output = execFileSync(lookupCmd, ['agent'], {
      encoding: 'utf-8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    return output.split(/\r?\n/)[0]?.trim() || undefined;
  } catch {
    return undefined;
  }
}

const CANDIDATE_PATHS = [
  join(homedir(), '.local', 'bin', 'agent'),
  join(homedir(), '.cursor', 'bin', 'agent'),
  '/opt/homebrew/bin/agent',
  '/usr/local/bin/agent',
];

export function resolveCursorBinaryPath(configPath?: string): string {
  const envPath = process.env.CURSOR_BIN_PATH ?? process.env.AGENT_BIN_PATH;
  if (envPath) {
    if (!isExecutableFile(envPath)) {
      throw new Error(`CURSOR_BIN_PATH is not executable: ${envPath}`);
    }
    return envPath;
  }

  if (configPath) {
    if (!isExecutableFile(configPath)) {
      throw new Error(`assistants.cursor.cursorBinaryPath is not executable: ${configPath}`);
    }
    return configPath;
  }

  for (const candidate of CANDIDATE_PATHS) {
    if (isExecutableFile(candidate)) return candidate;
  }

  const fromPath = resolveFromPath();
  if (fromPath && isExecutableFile(fromPath)) return fromPath;

  throw new Error(
    'Cursor CLI (`agent`) not found.\n\n' +
      'Install: curl https://cursor.com/install -fsS | bash\n' +
      'Then: agent login  OR  export CURSOR_API_KEY=...\n' +
      'Optional: set CURSOR_BIN_PATH or assistants.cursor.cursorBinaryPath in .archon/config.yaml',
  );
}

export function assertCursorBinaryExists(configPath?: string): void {
  resolveCursorBinaryPath(configPath);
}
