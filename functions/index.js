const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * Sends a push notification when a new meetup is created.
 */
exports.sendNotificationOnMeetupCreate = functions.firestore
  .document("meetups/{meetupId}")
  .onCreate(async (snapshot, context) => {
    const meetupData = snapshot.data();

    if (!meetupData) {
      console.log("No data associated with the event");
      return;
    }

    const { invitedUserId, requestingUserId } = meetupData;

    console.log(`New meetup created. Invited: ${invitedUserId}, Requester: ${requestingUserId}`);

    try {
      // Get the invited user's profile to find their FCM token
      const invitedUserDoc = await db.collection("users").doc(invitedUserId).get();
      if (!invitedUserDoc.exists) {
        console.error(`Invited user profile not found for ID: ${invitedUserId}`);
        return;
      }
      const invitedUserData = invitedUserDoc.data();
      const fcmToken = invitedUserData.fcmToken;

      if (!fcmToken) {
        console.log(`User ${invitedUserId} does not have an FCM token. Cannot send notification.`);
        return;
      }

      // Get the requesting user's profile to get their name
      const requestingUserDoc = await db.collection("users").doc(requestingUserId).get();
      if (!requestingUserDoc.exists) {
        console.error(`Requesting user profile not found for ID: ${requestingUserId}`);
        return;
      }
      const requestingUserData = requestingUserDoc.data();
      const requesterName = requestingUserData.fullName || "Someone";

      // Construct the notification message
      const payload = {
        notification: {
          title: "You have a new date request! ✨",
          body: `${requesterName} has invited you for a meetup. Open the app to respond.`,
          sound: "default",
        },
        token: fcmToken,
        data: {
          type: "meetup_request",
          meetupId: context.params.meetupId,
        }
      };

      console.log(`Sending notification to token: ${fcmToken}`);
      await admin.messaging().send(payload);
      console.log("Successfully sent push notification.");

    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
