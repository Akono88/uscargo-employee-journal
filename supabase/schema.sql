-- =============================================================
-- US Cargo · Confidential Employee Journal
-- Supabase schema + Row Level Security (RLS)
-- =============================================================
-- Run this entire file ONCE in the Supabase SQL Editor against
-- your new project.
--
-- What it creates:
--   - public.journal_submissions table (one row per employee submission)
--   - Indexes for fast filtering by date / role
--   - RLS policies:
--        * Anyone (anon role) can INSERT a submission
--        * Only authenticated users can SELECT submissions
--        * No one can UPDATE or DELETE via the API
--          (only Supabase service_role can — i.e. you, via dashboard)
--
-- This is the security model: employees push data in, only
-- you (after logging in to admin.html) can read it back out.
-- =============================================================

-- Drop if re-running (safe; comment out in production)
-- drop table if exists public.journal_submissions cascade;

create table if not exists public.journal_submissions (
  id            uuid        primary key default gen_random_uuid(),
  submitted_at  timestamptz not null    default now(),

  -- Optional metadata extracted from payload for filtering / stats.
  -- These are convenience columns — the source of truth is `payload`.
  alias               text,
  role                text,
  tenure              text,
  shift               text,
  week_grade          text,
  week_mood           int,
  week_nps            int,
  considered_leaving  text,

  -- Full structured response, exactly as the journal saves it.
  payload       jsonb       not null
);

create index if not exists journal_submissions_submitted_at_idx
  on public.journal_submissions (submitted_at desc);

create index if not exists journal_submissions_role_idx
  on public.journal_submissions (role);

create index if not exists journal_submissions_grade_idx
  on public.journal_submissions (week_grade);

-- =============================================================
-- Row Level Security
-- =============================================================
alter table public.journal_submissions enable row level security;

-- Drop any existing policies (idempotent re-run)
drop policy if exists "Anyone can submit"        on public.journal_submissions;
drop policy if exists "Authenticated can read"   on public.journal_submissions;

-- Anonymous users can INSERT only.
create policy "Anyone can submit"
  on public.journal_submissions
  for insert
  to anon
  with check (true);

-- Authenticated users can SELECT all rows.
-- (To restrict to specific admin emails, change the using() clause to:
--    using (auth.jwt() ->> 'email' in ('adam@uscargobrokers.com', 'luke@uscargobrokers.com'))
--  )
create policy "Authenticated can read"
  on public.journal_submissions
  for select
  to authenticated
  using (true);

-- No UPDATE or DELETE policy is created — meaning the API will
-- reject all attempts. To clear data, do it from the Supabase
-- dashboard with your service_role key.

-- =============================================================
-- Done.
-- =============================================================
-- To verify:
--   select count(*) from public.journal_submissions;
--   select * from pg_policies where tablename = 'journal_submissions';
