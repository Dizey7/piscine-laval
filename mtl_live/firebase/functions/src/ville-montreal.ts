import axios from "axios";
import * as admin from "firebase-admin";
import { parse } from "csv-parse/sync";

const OPEN_DATA_URL =
  "https://donnees.montreal.ca/api/3/action/datastore_search";
const EVENTS_RESOURCE_ID = "0b527e55-4742-486d-95a5-4c8f254c3df5";

/**
 * Récupère les événements publics de la Ville de Montréal (données ouvertes)
 * et les synchronise dans Firestore
 */
export async function refreshVilleMontreal(
  db: admin.firestore.Firestore
): Promise<number> {
  let totalUpdated = 0;
  let offset = 0;
  const limit = 100;
  let hasMore = true;

  while (hasMore) {
    try {
      const response = await axios.get(OPEN_DATA_URL, {
        params: {
          resource_id: EVENTS_RESOURCE_ID,
          limit: limit,
          offset: offset,
        },
      });

      const records = response.data?.result?.records || [];

      if (records.length === 0) {
        hasMore = false;
        break;
      }

      const batch = db.batch();

      for (const record of records) {
        const docId = `vmtl_${record._id || record.id || offset}`;
        const ref = db.collection("events").doc(docId);

        const startDate = parseDate(record.date_debut || record.start_date);
        const endDate = parseDate(record.date_fin || record.end_date);

        if (!startDate || startDate < new Date()) continue; // Ignorer les passés

        const eventData: Record<string, any> = {
          title: record.nom || record.title || record.name || "Événement",
          description:
            record.description ||
            record.description_fr ||
            record.details ||
            "",
          imageUrl: record.image || record.photo_url || null,
          imageUrls: record.image ? [record.image] : [],
          startDate: admin.firestore.Timestamp.fromDate(startDate),
          endDate: endDate
            ? admin.firestore.Timestamp.fromDate(endDate)
            : null,
          venue:
            record.lieu || record.location || record.adresse || "Montréal",
          venueAddress: record.adresse || record.address || null,
          latitude: record.latitude
            ? parseFloat(record.latitude)
            : null,
          longitude: record.longitude
            ? parseFloat(record.longitude)
            : null,
          category: mapVilleCategory(
            record.type || record.categorie || record.category
          ),
          tags: [
            record.type,
            record.categorie,
            record.arrondissement,
          ].filter(Boolean),
          source: "Ville de Montréal",
          sourceUrl:
            record.url ||
            record.lien ||
            "https://montreal.ca/evenements",
          externalId: record._id?.toString() || null,
          priceCurrent: null,
          priceMin: null,
          priceMax: null,
          isFree: isLikelyFree(record),
          currency: "CAD",
          status: "available",
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          isIndoor: guessIndoor(record),
          isFamilyFriendly: true,
          isAdultOnly: false,
          neighborhood:
            record.arrondissement || record.quartier || null,
        };

        batch.set(ref, eventData, { merge: true });
        totalUpdated++;
      }

      await batch.commit();

      offset += limit;
      hasMore = records.length === limit;

      await new Promise((resolve) => setTimeout(resolve, 100));
    } catch (error) {
      console.error(
        `[Ville MTL] Erreur offset ${offset}:`,
        error
      );
      hasMore = false;
    }
  }

  return totalUpdated;
}

function parseDate(dateStr?: string): Date | null {
  if (!dateStr) return null;
  const d = new Date(dateStr);
  return isNaN(d.getTime()) ? null : d;
}

function mapVilleCategory(type?: string): string {
  if (!type) return "Autre";
  const t = type.toLowerCase();

  if (t.includes("musique") || t.includes("concert")) return "Musique";
  if (t.includes("sport")) return "Sports";
  if (t.includes("festival")) return "Festivals";
  if (t.includes("art") || t.includes("culture") || t.includes("exposition"))
    return "Arts & Culture";
  if (t.includes("gastro") || t.includes("food") || t.includes("marché"))
    return "Gastronomie";
  if (t.includes("famille") || t.includes("enfant"))
    return "Enfants / Famille";
  if (t.includes("plein air") || t.includes("nature"))
    return "Plein air";
  if (t.includes("cinéma") || t.includes("film")) return "Cinéma";
  if (t.includes("théâtre")) return "Théâtre";
  return "Autre";
}

function isLikelyFree(record: any): boolean {
  const desc = (
    (record.description || "") +
    (record.tarif || "") +
    (record.prix || "")
  ).toLowerCase();
  return (
    desc.includes("gratuit") ||
    desc.includes("free") ||
    desc.includes("entrée libre") ||
    !record.tarif
  );
}

function guessIndoor(record: any): boolean {
  const text = (
    (record.lieu || "") +
    (record.type || "") +
    (record.description || "")
  ).toLowerCase();
  return (
    !text.includes("plein air") &&
    !text.includes("extérieur") &&
    !text.includes("parc ")
  );
}
