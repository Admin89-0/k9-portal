# k9-portal

Operations app for K9 Obedience Academy, LLC: dogs, training programs, trainer schedules, daily progress reports, a client portal, and evaluations confirmed only after a verified $50 deposit.

## How it fits with existing systems

- **GoHighLevel** stays the system of record for contacts and appointments. This app stores only the GHL contact and appointment IDs, never copies of contact details.
- **Square and Stripe** are read-only. The app receives signed webhooks, re-fetches each payment from the provider, and records it in one `payments` table. It never creates charges or refunds.
- **One Postgres database**, hosted on Replit.
- **Code** lives in this repo. Changes arrive as pull requests and are reviewed before merging. Replit deploys from `main`.

## Status

Phase 0 (foundation) is in progress. This includes:

- An Express + TypeScript server with a `/health` check.
- A plain SQL migration runner (`npm run migrate`).
- Tables for `evaluations`, `payments`, `webhook_events` and `audit_log`.

Nothing is connected to GoHighLevel, Square or Stripe yet. Phase 1 adds the webhook endpoints and the deposit-verified evaluation flow, using test credentials only.

## Running locally

Requires Node 20+ and a Postgres database.

```sh
cp .env.example .env   # then set DATABASE_URL
npm install
npm run migrate
npm run dev            # http://localhost:3000/health
```

On Replit, set `DATABASE_URL` and other values in the Secrets panel. Never commit real keys.

## Layout

```
src/server.ts            HTTP server and routes
src/db/pool.ts           Postgres connection
src/db/migrate.ts        Applies db/migrations/*.sql once each
db/migrations/           Schema, one numbered SQL file per change
```
