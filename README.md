# US Cargo · Confidential Employee Journal

A week-long, brand-themed reflection journal for US Cargo Brokers employees during the company-wide structural overhaul. Each employee fills out daily check-ins and deeper topical reflections privately in their browser, then submits the whole thing to a locked-down Supabase database that only authenticated leadership can read.

---

## What's in this repo

| File | Purpose |
| --- | --- |
| `index.html` | The journal itself. This is what employees open. Single-file HTML (CSS + JS embedded). |
| `admin.html` | The admin dashboard for reviewing submissions. Login-gated. |
| `config.js` | Supabase URL + anon key. **Edit this before deploying.** |
| `supabase/schema.sql` | Database table + Row Level Security policies. Run once in Supabase. |
| `DEPLOYMENT.md` | Step-by-step setup guide. |
| `.gitignore` | Standard hygiene. |

---

## How confidentiality works

Three layers:

1. **In the browser.** While an employee is filling out the journal, every keystroke is saved only to that browser's `localStorage`. Nothing is sent over the network. Closing the tab? Their work waits there. No autosave-to-cloud, no analytics, no telemetry.
2. **In transit.** When they hit "Submit", the journal posts a single row to Supabase over HTTPS. That request carries the journal data and nothing else — no IP logging by us, no user agent stored, no email or session ID attached.
3. **At rest.** The Supabase table has Row Level Security (RLS) enabled. The anonymous (employee) role can only `INSERT`. Only authenticated admin users can `SELECT`. Even if someone got the anon key, they could not read existing submissions. Only the people who can sign in to the admin dashboard can.

The anon key in `config.js` is **safe to commit publicly** — that's by design in Supabase. It cannot bypass RLS.

---

## Quick start

1. Create a free Supabase project: https://supabase.com
2. In Supabase SQL Editor, paste and run `supabase/schema.sql`.
3. Open Settings → API in Supabase. Copy the **Project URL** and the **anon public** key.
4. Edit `config.js` — replace `YOUR_SUPABASE_URL` and `YOUR_ANON_KEY` with those values.
5. Create an admin user in Supabase Authentication → Users → "Add user" (email + password). Confirm the email.
6. Push to GitHub. Enable GitHub Pages on `main` branch.
7. Test:
   - Visit `https://YOUR-USERNAME.github.io/REPO-NAME/` → fill out a tiny journal → submit.
   - Visit `https://YOUR-USERNAME.github.io/REPO-NAME/admin.html` → log in with your admin user → confirm the test submission appears.
8. Share the journal URL with the team.

Detailed instructions in [DEPLOYMENT.md](DEPLOYMENT.md).

---

## Recommended hand-off process

To preserve confidentiality once submissions arrive, decide upfront who has admin login credentials. Suggestion:

- **Adam** has full admin access.
- **One trusted neutral party** (e.g. an HR consultant, or your accountant Rob Grooms) optionally has read-only admin access.
- **No one else** has the Supabase login.
- When you discuss findings with the team, share aggregate themes — not individual submissions — unless the employee chose to attach their name.

---

## Tech stack

- **Frontend:** Single-file HTML, no framework, no build step. Works in any modern browser.
- **Backend:** Supabase (Postgres + Auth + RLS). Free tier is more than enough for a one-week intake.
- **Hosting:** GitHub Pages (free, static).

---

## Notes

- LocalStorage is per-browser. If an employee starts on their laptop and switches to their phone, those are separate journals. Tell them to stick with one device for the week.
- The `Submit` button intentionally allows resubmits. If someone hits Submit twice you'll see two rows in the dashboard — note the same `alias` (if filled) and the later `submitted_at` timestamp.
- You can delete bad/test rows from the Supabase Table Editor (the dashboard logs you in as service_role, which bypasses RLS).
