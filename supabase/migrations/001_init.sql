create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now(),
  total_study_time integer not null default 0,
  total_exp integer not null default 0
);

create table if not exists monsters (
  id text primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  name text not null,
  level integer not null default 1,
  exp integer not null default 0,
  required_exp integer not null default 100
);

create table if not exists study_sessions (
  id text primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  start_time timestamptz not null,
  end_time timestamptz not null,
  duration integer not null,
  exp_gained integer not null default 0
);

create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, coalesce(new.email, 'unknown@studymon.app'))
  on conflict (id) do update
  set email = excluded.email;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user_profile();

alter table profiles enable row level security;
alter table monsters enable row level security;
alter table study_sessions enable row level security;

drop policy if exists "profiles_select_own" on profiles;
create policy "profiles_select_own"
  on profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on profiles;
create policy "profiles_insert_own"
  on profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on profiles;
create policy "profiles_update_own"
  on profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "profiles_delete_own" on profiles;
create policy "profiles_delete_own"
  on profiles for delete
  using (auth.uid() = id);

drop policy if exists "monsters_select_own" on monsters;
create policy "monsters_select_own"
  on monsters for select
  using (auth.uid() = user_id);

drop policy if exists "monsters_insert_own" on monsters;
create policy "monsters_insert_own"
  on monsters for insert
  with check (auth.uid() = user_id);

drop policy if exists "monsters_update_own" on monsters;
create policy "monsters_update_own"
  on monsters for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "monsters_delete_own" on monsters;
create policy "monsters_delete_own"
  on monsters for delete
  using (auth.uid() = user_id);

drop policy if exists "study_sessions_select_own" on study_sessions;
create policy "study_sessions_select_own"
  on study_sessions for select
  using (auth.uid() = user_id);

drop policy if exists "study_sessions_insert_own" on study_sessions;
create policy "study_sessions_insert_own"
  on study_sessions for insert
  with check (auth.uid() = user_id);

drop policy if exists "study_sessions_update_own" on study_sessions;
create policy "study_sessions_update_own"
  on study_sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "study_sessions_delete_own" on study_sessions;
create policy "study_sessions_delete_own"
  on study_sessions for delete
  using (auth.uid() = user_id);
