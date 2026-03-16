import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import { refreshTicketmaster } from "./ticketmaster";
import { refreshVilleMontreal } from "./ville-montreal";
import { refreshPredictHQ } from "./predicthq";

admin.initializeApp();

const db = admin.firestore();

// ═══════════════════════════════════════════════════════════
// CRON: Ticketmaster — toutes les 15 minutes
// ═══════════════════════════════════════════════════════════
export const scheduledTicketmasterRefresh = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "America/Montreal",
    retryCount: 3,
  },
  async () => {
    console.log("[CRON] Début refresh Ticketmaster");
    const count = await refreshTicketmaster(db);
    await db.collection("metadata").doc("sync_ticketmaster").set({
      lastSync: admin.firestore.FieldValue.serverTimestamp(),
      eventsUpdated: count,
      status: "success",
    });
    console.log(`[CRON] Ticketmaster: ${count} événements mis à jour`);
  }
);

// ═══════════════════════════════════════════════════════════
// CRON: Ville de Montréal — toutes les 24 heures
// ═══════════════════════════════════════════════════════════
export const scheduledVilleMontrealRefresh = onSchedule(
  {
    schedule: "every 24 hours",
    timeZone: "America/Montreal",
    retryCount: 3,
  },
  async () => {
    console.log("[CRON] Début refresh Ville de Montréal");
    const count = await refreshVilleMontreal(db);
    await db.collection("metadata").doc("sync_ville_montreal").set({
      lastSync: admin.firestore.FieldValue.serverTimestamp(),
      eventsUpdated: count,
      status: "success",
    });
    console.log(`[CRON] Ville de Montréal: ${count} événements mis à jour`);
  }
);

// ═══════════════════════════════════════════════════════════
// CRON: PredictHQ — toutes les 6 heures (enrichissement)
// ═══════════════════════════════════════════════════════════
export const scheduledPredictHQRefresh = onSchedule(
  {
    schedule: "every 6 hours",
    timeZone: "America/Montreal",
    retryCount: 3,
  },
  async () => {
    console.log("[CRON] Début refresh PredictHQ");
    const count = await refreshPredictHQ(db);
    await db.collection("metadata").doc("sync_predicthq").set({
      lastSync: admin.firestore.FieldValue.serverTimestamp(),
      eventsUpdated: count,
      status: "success",
    });
    console.log(`[CRON] PredictHQ: ${count} événements enrichis`);
  }
);

// ═══════════════════════════════════════════════════════════
// HTTP: Trigger manuel (pour tests)
// ═══════════════════════════════════════════════════════════
export const manualRefresh = onRequest(
  { cors: false },
  async (req, res) => {
    const source = req.query.source as string;
    let count = 0;

    switch (source) {
      case "ticketmaster":
        count = await refreshTicketmaster(db);
        break;
      case "ville":
        count = await refreshVilleMontreal(db);
        break;
      case "predicthq":
        count = await refreshPredictHQ(db);
        break;
      default:
        res.status(400).json({ error: "Source invalide. Utiliser: ticketmaster, ville, predicthq" });
        return;
    }

    res.json({ source, eventsUpdated: count, timestamp: new Date().toISOString() });
  }
);
