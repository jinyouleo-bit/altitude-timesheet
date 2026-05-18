# Supabase Edge Function Patch — v115 (M5 server-side lock validation)

## What this is for

The `sync` edge function at `https://cexxawhivegmirhiqild.supabase.co/functions/v1/sync` needs two small additions so the server enforces what the client's lock already does:

1. **Lock check on `POST /timesheet`** — refuse non-admin writes to weeks that are already `submitted` or `approved`. This stops a determined employee from bypassing the client-side lock (DevTools tweaks) and editing a submitted week.
2. **adminKey format change** — `adminKey` is now a SHA-256 hash, not the plain PIN. Compare against an `ADMIN_PIN_HASH` env var.

If you don't apply this patch, **the v115 client still works** — the admin operations (Approve, Reopen, project rename) will fail with whatever error your edge function currently returns when `adminKey` doesn't match. The client lock continues to work for honest employees. Apply this patch when you have a moment.

---

## Setup steps

### 1. Set the `ADMIN_PIN_HASH` env var on Supabase

Open the Supabase dashboard → your project → Edge Functions → `sync` → Settings → Secrets / Environment Variables.

Add a new secret:
- Name: `ADMIN_PIN_HASH`
- Value: the SHA-256 hex of your admin PIN

To compute the SHA-256 of `1234` (default PIN):

```bash
echo -n "1234" | sha256sum
# 03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4
```

If your admin PIN is something else, replace `1234` with your PIN. **Don't include a newline** in the input (`echo -n`).

In the browser console of the deployed site you can also compute it:

```js
crypto.subtle.digest('SHA-256', new TextEncoder().encode('1234'))
  .then(b => console.log(Array.from(new Uint8Array(b)).map(x=>x.toString(16).padStart(2,'0')).join('')))
```

After you change your admin PIN via the in-app Settings tab, **also update this env var** to the new hash (the toast shows the new PIN; compute its hash and update the secret). Out of sync = admin operations fail until you fix it.

### 2. Update the `POST /timesheet` handler

In your edge function source (`supabase/functions/sync/index.ts` or wherever you deploy from), add the lock check at the start of the `POST /timesheet` branch. The exact diff depends on your current code; here's the pattern:

```typescript
// In your POST /timesheet handler — add BEFORE the upsert:

const body = await req.json();
const { employee, employeeId, weekStart, data, status } = body;

// M5 (v115): server-side lock validation.
// Look up existing record. If it's locked (submitted/approved), only an admin
// — verified by adminKey matching ADMIN_PIN_HASH — may overwrite it.
const ADMIN_HASH = Deno.env.get("ADMIN_PIN_HASH") || "";
const isAdminWrite = ADMIN_HASH !== "" && body.adminKey === ADMIN_HASH;

// Look up the current stored status for this (employee, week).
// (Adjust the table/column names to match your schema.)
const { data: existing } = await supabase
  .from("timesheets")
  .select("data")
  .eq("week_start", weekStart)
  .eq("employee_id", employeeId || "")
  .maybeSingle();

const existingStatus = existing?.data?.status || "draft";
const isLocked = existingStatus === "submitted" || existingStatus === "approved";

if (isLocked && !isAdminWrite) {
  return new Response(
    JSON.stringify({
      error: "Week is " + existingStatus + ". Ask an admin to reopen it.",
      code: "LOCKED",
    }),
    { status: 403, headers: { "Content-Type": "application/json", ...corsHeaders } },
  );
}

// ...continue with the existing upsert logic...
```

Notes:
- Replace `"timesheets"`, `"week_start"`, `"employee_id"`, `"data"` with the actual column names your function uses.
- `corsHeaders` should match whatever your function already returns on other responses.
- The check only fires when the existing record is locked AND it's not an admin write — so legitimate first-time submits (existing record doesn't exist, or is draft) pass through unchanged.

### 3. Update the `POST /send-reminders` handler

Change the existing `adminKey === <plain PIN>` comparison to use the hash:

```typescript
// Before:
if (body.adminKey !== Deno.env.get("ADMIN_PIN")) {
  return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
}

// After (v115):
const ADMIN_HASH = Deno.env.get("ADMIN_PIN_HASH") || "";
if (!ADMIN_HASH || body.adminKey !== ADMIN_HASH) {
  return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
}
```

If you previously had `ADMIN_PIN` (plain) as an env var, you can remove it once `ADMIN_PIN_HASH` is set and tested.

### 4. Deploy the edge function

From your local Supabase CLI:

```bash
supabase functions deploy sync
```

Or upload via the Supabase dashboard.

---

## How to verify it works

1. **As employee**: open the URL without `?admin=...`, submit a week. Reload. Open DevTools, run:
   ```js
   _weekIsLocked = false;
   document.querySelectorAll('#days [disabled]').forEach(e => e.removeAttribute('disabled'));
   // Now try to edit and save — save() should refuse (M5 client side). Even if you bypass that, cloudSaveTimesheet refuses. If you bypass THAT, the edge function should now refuse with code: "LOCKED".
   ```

2. **As admin**: navigate to `?admin=<your PIN>`, click Approve / Reopen on a submitted week. Should succeed (adminKey matches ADMIN_PIN_HASH).

3. **Mismatch test**: temporarily change ADMIN_PIN_HASH to a wrong value. Approve a week. Should fail with 403 / Unauthorized. Restore the correct hash.

---

## If something breaks

- Symptom: every admin operation (Approve, Reopen, project rename, send reminders) fails.
  - Cause: `ADMIN_PIN_HASH` env var doesn't match the client's current PIN hash.
  - Fix: in the admin Settings tab, look at your admin PIN. Compute its SHA-256. Update the env var to match. Re-deploy if needed.

- Symptom: employees can't submit their first week.
  - Cause: the lock check is wrongly treating a non-existent record as locked.
  - Fix: ensure the check is `existingStatus === "submitted" || existingStatus === "approved"`, not `!== "draft"`. A missing record's status should default to `"draft"`.

- Symptom: `Promise.all` of project renames partially fails.
  - Cause: some records were re-written by another admin between fetch and post, hash mismatch.
  - Fix: this is the right behaviour — retry the rename.

---

## Quick reference

| Operation | Sends `adminKey` | Edge function requires admin |
|---|---|---|
| Employee submit week | No | No (status transitions draft → submitted) |
| Employee edit draft week | No | No (not locked) |
| Employee edit submitted week | No | **Yes — should reject without adminKey** |
| Admin approve | Yes (hash) | Yes |
| Admin reopen | Yes (hash) | Yes |
| Admin rename project (cloud propagation) | Yes (hash) | Yes (writes locked weeks) |
| Admin rename task | Yes (hash) | Yes |
| Admin send reminders | Yes (hash) | Yes |

That's it. The patch is small but it's the difference between "the lock is honor-system" and "the lock is actually enforced on the server".
