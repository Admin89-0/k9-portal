import express from "express";
import { pool } from "./db/pool.js";

const app = express();
app.use(express.json());

// Health check for Replit deployments and uptime monitoring.
app.get("/health", async (_req, res) => {
  try {
    await pool.query("select 1");
    res.json({ ok: true, database: "up" });
  } catch {
    res.status(503).json({ ok: false, database: "down" });
  }
});

// Phase 1 adds: POST /webhooks/square, POST /webhooks/stripe, POST /webhooks/ghl.
// Each will verify the provider signature, store the event in webhook_events
// once (idempotent on source + event_id), then re-fetch the payment read-only.

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.log(`k9-portal listening on port ${port}`);
});
