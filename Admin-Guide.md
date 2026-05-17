# Altitude Timesheet — Admin Guide

**Admin URL:** https://altitudeco.netlify.app/?admin=1234
*(Bookmark this — keep it private)*

## Access

- Open the admin URL → you're in
- The badge at the top shows **ADMIN**

## Setup: Create Employee Accounts

Before anyone can sign in, you need to add employees:

1. Open Admin → **Employees** tab
2. Type their full name and a 4-digit PIN (or leave PIN blank to auto-generate)
3. Click **+ Add**
4. Tell each person their PIN — they'll need it to sign in
5. Open the **Projects** tab and click **📨 Publish Updates** so all devices receive the new accounts

You can later **Archive** anyone who leaves (keeps their history but blocks login) or **Reset PIN** if they forget it.

## The Admin Tabs

### 🏠 Dashboard
- This week at a glance — who submitted, who's outstanding, total hours
- 4-week trend chart
- Per-employee status list (NOT STARTED / DRAFT / SUBMITTED / APPROVED)

### 👥 Employees
- Add, archive, rename, reset PIN, delete
- After changes click **Publish** in Projects tab

### 📁 Projects
- Add new jobs employees can pick from
- Set per-job budgets, total project hours, start dates and deadlines
- Archive old jobs (hides them from employees, keeps history)
- **Publish** pushes everything to the cloud — every device auto-syncs

### 📊 Report
- Pick a week → see all hours by employee/job
- Download as Excel

### 📈 Project Dashboard
- Cumulative hours per project across all weeks
- Burn rate, weeks remaining, projected finish date

### 📂 History
- Every timesheet ever submitted, pulled live from the cloud
- Filter by employee, project, status, date range
- **Approve** submitted weeks → locks them permanently
- **Reopen** any week so the employee can edit it again
- Download single weeks or **Bulk XLSX** of everything filtered
- Delete records (admin only — employees cannot delete)

### 📝 Audit
- Every action recorded on this device (submit, approve, reopen, employee changes, etc.)
- Export as Excel, clear when needed

### ⚙ Settings
- Change the admin **PIN**
- Set default work **hours / start times**
- Set the **email** timesheets go to
- **Bulk Export by Date Range** — pull all weeks between two dates as one workbook
- **💾 Cloud Backup** — download a JSON snapshot of every employee, project, timesheet, audit entry. Keep it safe.

## Daily Workflow

1. Employees fill in their timesheets during the week
2. End of week → open **Dashboard** to see who's outstanding
3. Open **History**, review submitted weeks, click **Approve**
4. Use **Report** or **Bulk Export** for payroll

## Security Notes

- Never share the admin URL with employees
- Employees using the plain URL cannot see or access admin tools
- PINs are stored on each device after sync — acceptable for a small team but means **anyone with the app installed has access to all PINs**. Only install the app on trusted devices.
- Run **Cloud Backup** in Settings periodically — it's your only safety net if the cloud is ever lost
