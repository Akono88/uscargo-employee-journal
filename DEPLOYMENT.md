# Deployment Guide

Step-by-step, end-to-end. Should take 15-20 minutes start to finish for someone who's used Supabase or GitHub before. Longer if it's their first time with either.

---

## 1. Create the GitHub repository

1. Go to https://github.com/new
2. Repository name: `uscargo-employee-journal` (or whatever you want — the URL will reflect it)
3. **Public** (required for free GitHub Pages — but the *content* is just a static page; only Supabase has actual data)
4. Click **Create repository**
5. On your computer, drop all the files from this folder into a new local folder, then:

```bash
cd path/to/uscargo-employee-journal
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/uscargo-employee-journal.git
git push -u origin main
```

---

## 2. Create the Supabase project

1. Go to https://supabase.com → **Start your project** → sign in with GitHub.
2. Click **New project**.
   - Name: `uscargo-journal`
   - Database password: generate one and **save it in your password manager**.
   - Region: pick the one closest to Chicago (`us-east-1` or `us-east-2`).
   - Pricing plan: **Free**. (More than enough for one-time intake from a small team.)
3. Wait ~2 minutes while the project provisions.

---

## 3. Run the database schema

1. In your Supabase project, click **SQL Editor** in the left sidebar.
2. Click **+ New query**.
3. Open `supabase/schema.sql` from the repo, copy the entire contents, paste into the SQL Editor.
4. Click **Run** (or Cmd/Ctrl+Enter).
5. You should see: `Success. No rows returned.`
6. Verify the table exists: click **Table Editor** in the sidebar → you should see `journal_submissions`.

---

## 4. Get your API keys

1. In Supabase, click **Project Settings** (gear icon, bottom left) → **API**.
2. You'll see two important values:
   - **Project URL** — looks like `https://abcdefghijkl.supabase.co`
   - **Project API keys** → **anon** **public** — a long string starting with `eyJ...`

   ⚠️ **Do NOT use the `service_role` key.** That one has full database access and would defeat the entire confidentiality model. The `anon` key is the right one.

3. Open `config.js` in your repo. Replace the two placeholder values:

```js
window.USC_JOURNAL_CONFIG = {
  supabaseUrl: 'https://abcdefghijkl.supabase.co',
  supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  companyName: 'US Cargo Brokers',
  appVersion: '1.0',
};
```

4. Commit and push:

```bash
git add config.js
git commit -m "Configure Supabase"
git push
```

---

## 5. Create your admin user

1. In Supabase, click **Authentication** in the left sidebar → **Users**.
2. Click **Add user** → **Create new user**.
3. Enter your email (e.g. `adam@uscargobrokers.com`) and a strong password.
4. **Check the box** "Auto Confirm User" so you don't have to wait for an email confirmation.
5. Click **Create user**.

You can repeat this for any other person who should have admin read access (e.g., Luke, or a neutral third-party reviewer).

If you want to **restrict** which authenticated emails can read submissions (recommended if you create multiple users for any reason):

1. Open `supabase/schema.sql` and find the `Authenticated can read` policy.
2. Replace `using (true)` with:

```sql
using (auth.jwt() ->> 'email' in ('adam@uscargobrokers.com', 'luke@uscargobrokers.com'))
```

3. Re-run the policy block in the SQL Editor.

---

## 6. Enable GitHub Pages

1. In your GitHub repo, go to **Settings** → **Pages**.
2. Under **Source**, select:
   - Branch: `main`
   - Folder: `/ (root)`
3. Click **Save**.
4. Wait ~30 seconds. The page will show:
   `Your site is live at https://YOUR-USERNAME.github.io/uscargo-employee-journal/`

---

## 7. Test it end-to-end

### As an employee
1. Visit `https://YOUR-USERNAME.github.io/uscargo-employee-journal/`
2. Fill out a few fields — a Day 1 mood, a frustration, etc.
3. Skip ahead to the **Submit** tab.
4. Click **Submit Confidentially**.
5. You should see a green confirmation with a UUID.

### As an admin
1. Visit `https://YOUR-USERNAME.github.io/uscargo-employee-journal/admin.html`
2. Sign in with the admin email and password you created in step 5.
3. The dashboard should load and show your test submission.
4. Click the row to view the full submission.
5. Try the **Export CSV** and **Export JSON** buttons.

If everything works, **delete the test row** from the Supabase Table Editor (since it'll skew aggregate stats):
- Supabase → Table Editor → `journal_submissions` → check the test row → Delete.

---

## 8. Share with the team

Send this message to your employees:

> Hey team — as part of our overhaul, please take 10–15 minutes total over the next week to fill out a confidential journal. Daily check-ins (under 2 minutes each), some longer reflection topics whenever you have headspace, and a wrap-up at the end of the week. **Use one device for the whole week** (laptop or phone, your choice). Submit when you're done. Link: https://YOUR-USERNAME.github.io/uscargo-employee-journal/

---

## Maintenance & troubleshooting

| Symptom | Fix |
| --- | --- |
| Submit button is greyed out / banner says "not connected" | `config.js` still has `YOUR_SUPABASE_URL`. Push real values. |
| Admin login says "Invalid login credentials" | The user wasn't created or wasn't auto-confirmed. Re-create with "Auto Confirm User" checked. |
| Submissions appearing but admin dashboard is empty | RLS policy is blocking SELECT. Re-run the schema SQL. Verify the policy with `select * from pg_policies where tablename = 'journal_submissions';` |
| GitHub Pages 404 | Make sure the file is named `index.html` (not `Index.html`) at the repo root. |
| "Failed to fetch" on submit | Check the Supabase project isn't paused (free tier pauses after 1 week of inactivity). Go to the dashboard and "Restore project". |

---

## When the intake period is over

1. **Export everything** — Admin dashboard → Export JSON. Save somewhere private (a password-protected zip is wise).
2. **Decide on retention** — Either keep the data in Supabase indefinitely, or wipe it.
   - To wipe: Supabase → SQL Editor → `truncate table journal_submissions;`
3. **Take down the public journal** — In GitHub Pages settings, set Source to "None", or rename `index.html` to something else and add a polite "intake closed" page.
4. **Pause the Supabase project** — Project Settings → General → Pause project. (Free tier auto-pauses after a week of inactivity anyway.)
