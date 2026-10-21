-- Phase 0 foundation: deposit-verified evaluations, payment ledger,
-- webhook log and audit log.
-- Contact details (name, phone, email) live in GoHighLevel only; this
-- database stores the GHL contact ID as the link.

create table evaluations (
  id                 bigint generated always as identity primary key,
  ghl_contact_id     text not null,
  ghl_appointment_id text not null unique,
  scheduled_at       timestamptz not null,
  deposit_status     text not null default 'pending'
                     check (deposit_status in ('pending', 'verified', 'refunded', 'expired')),
  hold_expires_at    timestamptz,
  confirmed_at       timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create index evaluations_ghl_contact_id_idx on evaluations (ghl_contact_id);
create index evaluations_pending_idx on evaluations (hold_expires_at)
  where deposit_status = 'pending';

-- One ledger for Square and Stripe. Rows are written only after the
-- payment is re-fetched from the provider, never from webhook data alone.
create table payments (
  id                  bigint generated always as identity primary key,
  provider            text not null check (provider in ('square', 'stripe')),
  provider_payment_id text not null,
  amount_cents        integer not null,
  currency            text not null default 'USD',
  status              text not null,
  ghl_contact_id      text,
  evaluation_id       bigint references evaluations (id),
  paid_at             timestamptz,
  raw_json            jsonb not null,
  created_at          timestamptz not null default now(),
  unique (provider, provider_payment_id)
);

alter table evaluations
  add column payment_id bigint references payments (id);

-- Every incoming webhook, stored once. Providers retry deliveries, so the
-- unique key makes processing safe to repeat.
create table webhook_events (
  id           bigint generated always as identity primary key,
  source       text not null check (source in ('square', 'stripe', 'ghl')),
  event_id     text not null,
  event_type   text,
  payload      jsonb not null,
  received_at  timestamptz not null default now(),
  processed_at timestamptz,
  result       text,
  unique (source, event_id)
);

create table audit_log (
  id     bigint generated always as identity primary key,
  actor  text not null,
  action text not null,
  target text,
  detail jsonb,
  at     timestamptz not null default now()
);
