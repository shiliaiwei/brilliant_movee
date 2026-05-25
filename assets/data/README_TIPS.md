Tips data — schema and editing guide

This file explains the JSON schema used by the app for tips and how to manage a single canonical tips file.

File used by the app
- assets/data/tips.json

Goal
- Keep a single source of truth: `tips.json`. Do NOT maintain multiple versions (`tips_v2.json`) — the provider reads `assets/data/tips.json` only.

Schema (per entry)
- id: unique integer
- category: one of the TipCategory names (see lib/features/tips/tip_model.dart)
  - opening
  - middlegame
  - endgame
  - tactics
  - mindset
  - stoic
  - openingNames
- title: object or string. If object, keys are language codes (e.g. "en").
  - Example: "title": { "en": "Ruy Lopez" }
- explanation: object or string. Same language mapping as title.
  - Example: "explanation": { "en": "1.e4 e5 2.Nf3 Nc6 3.Bb5 - Classic development." }
- imageUrl: OPTIONAL; used historically for opening diagrams (string). We removed cover images from the UI — you can keep this for future use but it's not required.
- authorImageUrl: OPTIONAL; previously used for small author avatars. Not required.

Example entry (minimal):
{
  "id": 401,
  "category": "openingNames",
  "title": { "en": "Ruy Lopez" },
  "explanation": { "en": "1.e4 e5 2.Nf3 Nc6 3.Bb5. Classic opening with long-term strategic play." }
}

How to add a new tip
1. Pick a new unique `id` (int). Keep ids contiguous if you like but uniqueness is the only requirement.
2. Set `category` to one of the enum values (see above). Use `openingNames` for the "OPENINGS" tab; `opening` corresponds to the "CONCEPTS" tab.
3. Provide `title` and `explanation` as objects keyed by language code. If you only need English, use `{"en": "..."}`.
4. Save the file and restart the app (or call the provider reload action in debug). The app reads `assets/data/tips.json` at startup.

Notes
- We removed the visual "cover" and the strategic quote from the tips UI to simplify the design. The `imageUrl`/`authorImageUrl` fields remain supported in the model but are not shown by default in the compact UI.
- If you still have `tips_v2.json` in the repo, treat it as legacy. Consolidate any unique entries into `tips.json` and remove the extra file from version control (git rm) to avoid confusion.
- To extend categories or translations: update `lib/features/tips/tip_model.dart` if you need new categories; otherwise add entries with existing category names.

Quick pasteable template for adding one tip:

{
  "id": 501,
  "category": "middlegame",
  "title": { "en": "Activate Your Worst Piece" },
  "explanation": { "en": "Identify and improve your least active piece before launching new plans." }
}

That's it — keep `tips.json` as the single source of truth for tips content.

