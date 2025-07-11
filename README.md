# Budget Tracker App

A personal budgeting app built with Flutter. Track your budgets, expenses, and manage your finances easily.

## Features
- Create and manage multiple budgets
- Add and track expenses for each budget
- View dashboard with budget summaries
- Persistent storage using Hive

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio, VS Code, or any preferred IDE
- Enable Developer Mode on Windows for desktop builds (required for plugins):
  - Open PowerShell and run: `start ms-settings:developers`
  - Enable "Developer Mode"

### Setup Instructions
1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd Budget-Tracker-App---PLP-Final-Project
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Generate Hive TypeAdapters:**
   ```sh
   flutter pub run build_runner build
   ```

4. **Run the app:**
   ```sh
   flutter run
   ```
   - Select your target device (Android, iOS, Windows, Chrome, etc.)

## How the App Works
- **Budgets:** Create a budget by specifying a name and amount. Each budget is stored locally.
- **Expenses:** Add expenses to a specific budget. The app tracks how much you have spent and how much remains.
- **Dashboard:** View all budgets, their total amounts, spent, and remaining balances.
- **Persistence:** All data is stored locally using Hive, so your budgets and expenses are saved between sessions.

## Project Structure
- `lib/models/` - Data models for budgets, expenses, and users
- `lib/pages/` - UI pages (dashboard, add budget, add expense, etc.)
- `lib/services/` - Local storage and user services
- `lib/widgets/` - Reusable UI components
- `lib/theme/` - App theming

## Wireframes / UI Layout

Below are rough wireframes to illustrate the main screens of the app:

### Dashboard Page

```
---------------------------------------------------
| AppBar: Budget Dashboard                        |
---------------------------------------------------
| [Budget Card]  [Budget Card]  [Budget Card]     |
| [Budget Name]  [Budget Name]  [Budget Name]     |
| $Amount       $Amount       $Amount             |
| $Spent/$Total $Spent/$Total $Spent/$Total       |
---------------------------------------------------
| + Add Budget                                    |
---------------------------------------------------
```

### Add Budget Page

```
---------------------------------------------------
| AppBar: Create Budget                           |
---------------------------------------------------
| [Form: Budget Name]                             |
| [Form: Amount]                                  |
| [Create Budget Button]                          |
---------------------------------------------------
```

### Budget Detail Page

```
---------------------------------------------------
| AppBar: [Budget Name]                           |
---------------------------------------------------
| $Total Budget                                   |
| $Spent / $Remaining                             |
|-------------------------------------------------|
| Expenses:                                       |
|  - [Expense Tile]                               |
|  - [Expense Tile]                               |
|  - ...                                          |
|-------------------------------------------------|
| + Add Expense                                   |
---------------------------------------------------
```

### Add Expense Page

```
---------------------------------------------------
| AppBar: Add Expense                             |
---------------------------------------------------
| [Form: Expense Name]                            |
| [Form: Amount]                                  |
| [Create Expense Button]                         |
---------------------------------------------------
```

---

## Troubleshooting
- If you see errors about missing files like `budget.g.dart`, make sure to run the build runner command above.
- For plugin/symlink errors on Windows, ensure Developer Mode is enabled.

## Useful Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)

---
Happy budgeting!
