# StudyMon

Study timer + monster growth productivity app built with Flutter.

## Supabase Auth Setup

Auth is enabled only when both Dart defines are provided:

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

AI planner uses OpenAI when `OPENAI_API_KEY` is set:

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY --dart-define=OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

## Focus Mode (Android)

Study timer includes Android app blocking MVP for selected apps.

1. Turn on `Focus Mode (App Blocking)` in timer screen.
2. Select blocked apps (Instagram/YouTube/TikTok/X/Facebook).
3. On first run, grant `Usage Access` permission when prompted.

When a blocked app comes to foreground during a running timer, StudyMon reopens automatically.

## Required Supabase Tables

Run the SQL in [supabase/migrations/001_init.sql](C:\Users\mamekuma\Desktop\StudyMon\supabase\migrations\001_init.sql).  
It includes table creation, RLS policies for user-isolated access, and an `auth.users` -> `profiles` auto-create trigger.
