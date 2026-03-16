import axios from "axios";
import * as admin from "firebase-admin";

const API_KEY = process.env.TICKETMASTER_API_KEY || "YOUR_TICKETMASTER_API_KEY";
const BASE_URL = "https://app.ticketmaster.com/discovery/v2";

interface TicketmasterEvent {
  id: string;
  name: string;
  info?: string;
  images?: Array<{ url: string; width: number }>;
  dates?: {
    start?: { dateTime?: string; localDate?: string; localTime?: string };
    end?: { dateTime?: string };
    status?: { code?: string };
  };
  priceRanges?: Array<{ min: number; max: number; currency: string }>;
  classifications?: Array<{
    segment?: { name: string };
    genre?: { name: string };
  }>;
  _embedded?: {
    venues?: Array<{
      name: string;
      address?: { line1: string };
      city?: { name: string };
      location?: { latitude: string; longitude: string };
    }>;
  };
  url?: string;
}

/**
 * Récupère les événements Ticketmaster à Montréal et les synchronise dans Firestore
 */
export async function refreshTicketmaster(
  db: admin.firestore.Firestore
): Promise<number> {
  let totalUpdated = 0;
  let page = 0;
  let hasMore = true;

  while (hasMore && page < 5) {
    // Max 5 pages (250 événements)
    try {
      const response = await axios.get(`${BASE_URL}/events.json`, {
        params: {
          apikey: API_KEY,
          city: "Montreal",
          countryCode: "CA",
          stateCode: "QC",
          locale: "fr-ca",
          size: 50,
          page: page,
          sort: "date,asc",
          startDateTime: new Date().toISOString().replace("Z", ""),
        },
      });

      const data = response.data;
      const events: TicketmasterEvent[] =
        data?._embedded?.events || [];

      if (events.length === 0) {
        hasMore = false;
        break;
      }

      const batch = db.batch();

      for (const event of events) {
        const docId = `tm_${event.id}`;
        const ref = db.collection("events").doc(docId);

        const venue = event._embedded?.venues?.[0];
        const classification = event.classifications?.[0];
        const prices = event.priceRanges?.[0];
        const bestImage = getBestImage(event.images || []);

        const category = mapCategory(
          classification?.segment?.name,
          classification?.genre?.name
        );

        const status = mapStatus(event.dates?.status?.code);

        const eventData: Record<string, any> = {
          title: event.name,
          description: event.info || "",
          imageUrl: bestImage,
          imageUrls: (event.images || [])
            .slice(0, 5)
            .map((img) => img.url),
          startDate: event.dates?.start?.dateTime
            ? admin.firestore.Timestamp.fromDate(
                new Date(event.dates.start.dateTime)
              )
            : null,
          endDate: event.dates?.end?.dateTime
            ? admin.firestore.Timestamp.fromDate(
                new Date(event.dates.end.dateTime)
              )
            : null,
          venue: venue?.name || "Lieu inconnu",
          venueAddress: venue?.address?.line1 || null,
          latitude: venue?.location?.latitude
            ? parseFloat(venue.location.latitude)
            : null,
          longitude: venue?.location?.longitude
            ? parseFloat(venue.location.longitude)
            : null,
          category: category,
          tags: [
            classification?.segment?.name,
            classification?.genre?.name,
          ].filter(Boolean),
          source: "Ticketmaster",
          sourceUrl: event.url || null,
          externalId: event.id,
          priceCurrent: prices?.min || null,
          priceMin: prices?.min || null,
          priceMax: prices?.max || null,
          isFree: !prices || prices.min === 0,
          currency: prices?.currency || "CAD",
          status: status,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          isIndoor: true,
          isFamilyFriendly: category !== "Nightlife",
          isAdultOnly: category === "Nightlife",
        };

        batch.set(ref, eventData, { merge: true });
        totalUpdated++;
      }

      await batch.commit();

      // Pagination
      const totalPages = data?.page?.totalPages || 0;
      page++;
      hasMore = page < totalPages;

      // Rate limiting: 200ms entre les requêtes
      await new Promise((resolve) => setTimeout(resolve, 200));
    } catch (error) {
      console.error(`[Ticketmaster] Erreur page ${page}:`, error);
      hasMore = false;
    }
  }

  return totalUpdated;
}

function getBestImage(
  images: Array<{ url: string; width: number }>
): string | null {
  if (images.length === 0) return null;
  const sorted = [...images].sort((a, b) => (b.width || 0) - (a.width || 0));
  return sorted[0].url;
}

function mapCategory(
  segment?: string,
  genre?: string
): string {
  const s = segment?.toLowerCase() || "";
  const g = genre?.toLowerCase() || "";

  if (s === "music" || g.includes("music")) return "Musique";
  if (s === "sports") return "Sports";
  if (s === "arts & theatre" || g.includes("theatre")) return "Arts & Culture";
  if (g.includes("comedy")) return "Arts & Culture";
  if (g.includes("festival")) return "Festivals";
  if (g.includes("family")) return "Enfants / Famille";
  if (g.includes("film") || g.includes("movie")) return "Cinéma";
  if (g.includes("conference") || g.includes("seminar")) return "Conférence";
  return "Autre";
}

function mapStatus(code?: string): string {
  switch (code) {
    case "onsale":
      return "available";
    case "offsale":
      return "soldOut";
    case "cancelled":
      return "cancelled";
    case "postponed":
      return "postponed";
    case "rescheduled":
      return "rescheduled";
    default:
      return "available";
  }
}
