import type { ProviderCapabilities } from '../../types';

/**
 * Cursor provider capabilities — start honest; flip to true only when wired.
 * Hooks/skills load from the repo cwd automatically when `agent` runs.
 */
export const CURSOR_CAPABILITIES: ProviderCapabilities = {
  sessionResume: true,
  mcp: true,
  hooks: true,
  skills: true,
  agents: false,
  toolRestrictions: false,
  structuredOutput: 'best-effort',
  envInjection: true,
  costControl: false,
  effortControl: false,
  thinkingControl: false,
  fallbackModel: false,
  sandbox: true,
  nativeTools: false,
};
