import { isRegisteredProvider, registerProvider } from '../../registry';

import { CURSOR_CAPABILITIES } from './capabilities';
import { CursorProvider } from './provider';

export function registerCursorProvider(): void {
  if (isRegisteredProvider('cursor')) return;
  registerProvider({
    id: 'cursor',
    displayName: 'Cursor (community)',
    factory: () => new CursorProvider(),
    capabilities: CURSOR_CAPABILITIES,
    builtIn: false,
    credentials: {
      kind: 'static',
      specs: [
        {
          vendor: 'cursor',
          displayName: 'Cursor',
          kinds: ['api_key', 'subscription'],
        },
      ],
    },
  });
}
