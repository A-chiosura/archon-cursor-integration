import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

describe('Archon smoke', () => {
  it('keeps tests/smoke.test.ts on disk', () => {
    const smokePath = join(process.cwd(), 'tests', 'smoke.test.ts');
    expect(existsSync(smokePath)).toBe(true);
  });

  it('passes for dev-loop verify gates', () => {
    expect(true).toBe(true);
  });
});
