/**
 * US Cargo · Confidential Employee Journal
 * ----------------------------------------------------------
 * Configure these two values BEFORE deploying.
 *
 *   1. Create a Supabase project (https://supabase.com)
 *   2. Run the SQL in supabase/schema.sql against your project
 *   3. From your project settings -> API, copy:
 *        - "Project URL"   into supabaseUrl
 *        - "anon public"   into supabaseAnonKey  (NOT the service_role key)
 *   4. Commit and push.
 *
 * The anon key is safe to commit. It can only do what the RLS
 * policies in schema.sql allow it to do — which is INSERT one
 * row into journal_submissions. It cannot read, update, or
 * delete anything. Only authenticated admin users can read.
 *
 * If these values are left as placeholders, the journal will
 * still work for drafting/downloading but the "Submit" button
 * will be disabled with a clear notice to the employee.
 */
window.USC_JOURNAL_CONFIG = {
  supabaseUrl: 'YOUR_SUPABASE_URL',     // e.g. https://abcdefgh.supabase.co
  supabaseAnonKey: 'YOUR_ANON_KEY',     // the public "anon" key, NOT service_role

  // Cosmetic only:
  companyName: 'US Cargo Brokers',
  appVersion: '1.0',
};
