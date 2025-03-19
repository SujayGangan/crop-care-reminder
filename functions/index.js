/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.scheduleNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
        console.error("No data found in Firestore document.");
        return null;
    }

    const notificationData = snapshot.data();

    if (!notificationData) {
        console.error("No data found in Firestore snapshot.");
        return null;
    }

    const payload = {
        notification: {
            title: notificationData.title,
            body: notificationData.body,
        },
        token: notificationData.token,
    };

    const sendTime = new Date(notificationData.scheduledTime).getTime();
    const currentTime = new Date().getTime();
    const delay = sendTime - currentTime;

    if (delay > 0) {
        console.log(`Scheduling notification in ${delay}ms`);
        await new Promise(resolve => setTimeout(resolve, delay));
    }

    return admin.messaging().send(payload)
        .then(() => console.log("Notification sent successfully"))
        .catch((error) => console.error("Error sending notification:", error));
});
