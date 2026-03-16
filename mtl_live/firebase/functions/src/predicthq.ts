import axios from "axios";
import * as admin from "firebase-admin";

const API_KEY = process.env.PREDICTHQ_API_KEY || "YOUR_PREDICTHQ_API_KEY";
const BASE_URL = "https://api.predicthq.com/v1";

/**
 * Enrichit les événements existants avec les données PredictHQ
 * (impact score, predicted attendance) et ajoute les événements manquants
 */
export async function refreshPredictHQ(
  db: admin.firestore.Firestore
): Promise<number> {
  let totalUpdated = 0;

  try {
    // Récupère les événements PredictHQ à Montréal
    const response = await axios.get(`${BASE_URL}/events/`, {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        Accept: "application/json",
      },
      params: {
        "location_around.origin": "45.5017,-73.5673",
        "location_around.offset": "25km",
        "start.gte": new Date().toISOString().split("T")[0],
        sort: "rank",
        limit: 100,
        category:
          "concerts,conferences,expos,festivals,performing-arts,sports,community",
      },
    });

    const events = response.data?.results || [];

    for (const phqEvent of events) {
      const impactScore = phqEvent.rank || 0;
      const predictedAttendance = phqEvent.phq_attendance || null;
      const title = phqEvent.title || "";

      // Chercher un événement existant par titre similaire
      const matchingDocs = await db
        .collection("events")
        .where("startDate", ">=",
          admin.firestore.Timestamp.fromDate(
            new Date(phqEvent.start)
          ))
        .where("startDate", "<=",
          admin.firestore.Timestamp.fromDate(
            new Date(new Date(phqEvent.start).getTime() + 86400000)
          ))
        .limit(50)
        .get();

      let matched = false;

      for (const doc of matchingDocs.docs) {
        const existingTitle = (doc.data().title || "").toLowerCase();
        if (
          existingTitle.includes(title.toLowerCase().slice(0, 15)) ||
          title.toLowerCase().includes(existingTitle.slice(0, 15))
        ) {
          // Enrichir l'événement existant
          await doc.ref.update({
            impactScore: impactScore,
            predictedAttendance: predictedAttendance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
          matched = true;
          totalUpdated++;
          break;
        }
      }

      // Si pas de match, créer un nouvel événement
      if (!matched && impactScore >= 50) {
        const docId = `phq_${phqEvent.id}`;
        const location = phqEvent.location || [];

        await db
          .collection("events")
          .doc(docId)
          .set(
            {
              title: title,
              description: phqEvent.description || "",
              imageUrl: null,
              imageUrls: [],
              startDate: admin.firestore.Timestamp.fromDate(
                new Date(phqEvent.start)
              ),
              endDate: phqEvent.end
                ? admin.firestore.Timestamp.fromDate(
                    new Date(phqEvent.end)
                  )
                : null,
              venue: phqEvent.entities?.[0]?.name || "Montréal",
              venueAddress: null,
              latitude: location.length >= 2 ? location[1] : null,
              longitude: location.length >= 2 ? location[0] : null,
              category: mapPHQCategory(phqEvent.category),
              tags: phqEvent.labels || [],
              source: "PredictHQ",
              sourceUrl: null,
              externalId: phqEvent.id,
              priceCurrent: null,
              priceMin: null,
              priceMax: null,
              isFree: false,
              currency: "CAD",
              status: "available",
              impactScore: impactScore,
              predictedAttendance: predictedAttendance,
              lastUpdated:
                admin.firestore.FieldValue.serverTimestamp(),
              createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
              isIndoor: true,
              isFamilyFriendly: true,
              isAdultOnly: false,
            },
            { merge: true }
          );
        totalUpdated++;
      }
    }
  } catch (error) {
    console.error("[PredictHQ] Erreur:", error);
  }

  return totalUpdated;
}

function mapPHQCategory(category?: string): string {
  switch (category) {
    case "concerts":
      return "Musique";
    case "sports":
      return "Sports";
    case "festivals":
      return "Festivals";
    case "performing-arts":
      return "Arts & Culture";
    case "expos":
      return "Arts & Culture";
    case "conferences":
      return "Conférence";
    case "community":
      return "Meetups";
    default:
      return "Autre";
  }
}
