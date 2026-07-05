export interface CursorProviderDefaults {
  [key: string]: unknown;
  /** Default model passed to `agent --model`. Omit for Cursor default. */
  model?: string;
  /** Path to Cursor CLI (`agent` binary). */
  cursorBinaryPath?: string;
  /** Maps to `agent --trust` for headless workflow runs. @default true */
  trustWorkspace?: boolean;
  /** Maps to `agent --force` so file edits proceed without prompts. @default true */
  forceAllowTools?: boolean;
  /** `enabled` | `disabled` → `agent --sandbox` */
  sandbox?: 'enabled' | 'disabled';
  /** Auto-approve MCP servers in headless mode. @default true */
  approveMcps?: boolean;
  /** CLI output format for streaming bridge. @default stream-json */
  outputFormat?: 'text' | 'json' | 'stream-json';
}

export function parseCursorConfig(raw: unknown): CursorProviderDefaults {
  if (!raw || typeof raw !== 'object') return {};
  const o = raw as Record<string, unknown>;
  return {
    model: typeof o.model === 'string' ? o.model : undefined,
    cursorBinaryPath: typeof o.cursorBinaryPath === 'string' ? o.cursorBinaryPath : undefined,
    trustWorkspace: o.trustWorkspace !== false,
    forceAllowTools: o.forceAllowTools !== false,
    sandbox: o.sandbox === 'enabled' || o.sandbox === 'disabled' ? o.sandbox : undefined,
    approveMcps: o.approveMcps !== false,
    outputFormat:
      o.outputFormat === 'text' || o.outputFormat === 'json' || o.outputFormat === 'stream-json'
        ? o.outputFormat
        : 'stream-json',
  };
}
