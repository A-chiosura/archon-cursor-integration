# Story 34: Add Notes To Watchlist Symbols

## Story

As a market researcher, I want to add a short note to each watchlist symbol so that I can remember why the symbol is being tracked.

## Acceptance Criteria

- A note can be added to a watchlist symbol.
- A note can be edited after creation.
- A note can be removed without deleting the symbol from the watchlist.
- Empty notes are treated the same as no note.
- Notes are persisted across application restarts.

## Out Of Scope

- Rich text formatting.
- Collaboration or shared notes.
- Automatic note generation.

## Verification

- Unit test note create, update, clear, and persistence behavior.
- Add one integration test that reloads stored watchlist data and verifies the note remains attached to the correct symbol.

