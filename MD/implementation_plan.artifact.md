# Implementation Plan - Leaderboard & History Enhancements

Redesigning the Home screen leaderboard to prioritize Rapid rankings, refreshing the history logic for real-time updates, and upgrading the profile with a professional "Insights" style including custom classification icons.

## User Review Required

> [!IMPORTANT]
> The classification icons will be loaded from local assets (`assets/classification/*.png`). Ensure these files are correctly bundled in the project.

- **Move Quality Data**: Since the public Chess.com API does not provide a move quality breakdown (Brilliant, Great, etc.) for all historical games, I will use aggregated local data for the "Insights" profile to provide a realistic feel.
- **shiliaiwei Rank**: I will ensure the leaderboard fetch specifically highlights or correctly positions this user if they are in the top ranks fetched.

## Proposed Changes

### Data Layer

#### [chess_com_api.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/data/sources/chess_com_api.dart)
- No changes needed (already supports leaderboards).

#### [player_repository.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/data/repositories/player_repository.dart)
- Update `getTopPlayers` to ensure it fetches the most up-to-date data.

---

### Home & History

#### [app_router.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/core/router/app_router.dart)
- Update the bottom navigation icon for "Games" to `Icons.sports_esports_outlined`.

#### [home_screen.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/features/home/home_screen.dart)
- Remove the "My Games" toggle/button.
- Make the "Rapid" leaderboard the default priority.
- Add a beautiful tap animation effect to leaderboard items.

#### [history_screen.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/features/history/history_screen.dart)
- Ensure history fetches real-time data from Chess.com.
- Implement a `RefreshIndicator` for manual updates.
- Ensure `shiliaiwei` history is correctly updated by forcing a cache refresh.

---

### Profile & Insights

#### [profile_screen.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/features/profile/profile_screen.dart)
- Redesign the "Move Quality" section to match the provided "Insights" screenshot.
- Integrate tap effects for every metric block.
- Add sections for Game Results, Game Phases, Openings, etc. (High-fidelity placeholders where API data is limited).

---

### Board & UI

#### [chess_board_widget.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/features/review/board/chess_board_widget.dart)
- Replace standard Material icons with custom PNG icons from `assets/classification/`.
- Update `_ClassificationIcon` to use `Image.asset`.

#### [review_screen.dart](file:///Users/Apple16/Desktop/brilliant_movee/lib/features/review/review_screen.dart)
- Update the bottom analysis panel labels to use the new PNG icons.

## Verification Plan

### Manual Verification
- **Leaderboard**: Open Home screen and verify "Rapid" is selected by default and ranks are correct.
- **History**: Connect as `shiliaiwei` and verify games are fetched and can be refreshed.
- **Profile**: Navigate to Profile and verify the "Insights" layout and tap animations.
- **Board Icons**: Open a game review and verify that Brilliant/Great/Blunder icons are now using the custom PNG assets.
