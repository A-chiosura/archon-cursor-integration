const GREETING_PREFIX = 'Hello, ';

export function greet(name: string): string {
  return `${GREETING_PREFIX}${name}`;
}
