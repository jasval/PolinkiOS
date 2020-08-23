const admin = require('firebase-admin');
const functions = require('firebase-functions');
const firebase_tools = require('firebase-tools');
const { firestore } = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.recursiveDelete = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB'
  })
  .https.onCall(async (data, context) => {
    // Only allow admin users to execute this function.
    if (!(context.auth && context.auth.token)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Must be an administrative user to initiate delete.'
      );
    }

    const path = data.path;
    console.log(
      `User ${context.auth.uid} has requested to delete path ${path}`
    );

    // Run a recursive delete on the given document or collection path.
    // The 'token' must be set in the functions config, and can be generated
    // at the command line by running 'firebase login:ci'.
    await firebase_tools.firestore
      .delete(path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
        token: functions.config().token.key
      });

      console.log(`User deleted path`)
    return {
      path: path 
    };
  });

exports.sendNotification = functions.firestore
  .document('rooms/{roomId}')
// database.ref('/rooms/{roomId}')
  .onWrite((event, context) => {
    const roomData = event.after.data();
    const participants = roomData.participants;

    const registrationTokens = [];

    const tokenOne = getDocument(participants[0]);
    const tokenTwo = getDocument(participants[1]);

    registrationTokens.push(tokenOne.fcm);
    registrationTokens.push(tokenTwo.fcm);
    // const fcmTokenOne = participantOne.fcm;
    // const fcmTokenTwo = participantTwo.fcm;

    console.log(registrationTokens);

    const message = {
      data: 'We have matched you with someone new!',
      tokens: registrationTokens
    }

    admin.messaging().sendMulticast(message)
      .then((response) => {
      // eslint-disable-next-line promise/always-return
      if (response.failureCount > 0 ) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(registrationTokens[idx]);
          }
        });
        console.log('List of tokens that caused failures: ' + failedTokens);
      }
    })
    .catch((error) => {
      console.log('Error sending message:', error)
    })
  });

async function getDocument(element) {
  const docRef = db.collection('users').doc(`${element}`);

  const doc = await docRef.get();
  if (!doc.exists) {
    console.log('No such document');
    return '';
  } else {
    console.log('Document data:', doc.data().fcm);
    return doc.data();
  }
}
// exports.sendMessage = functions
//   .runWith({
//     timeoutSeconds: 540,
//     memory: '2GB'
//   })
//   .https.onCall(async(data, context) => {
//     if (!(context.auth && context.auth.token)) {
//       throw new functions.https.HttpsError(
//         'permission-denied',
//         'Must be an administrative user to initiate messaging.'
//       );
//     }


//     const fcmToken = data.fcm;
//     const message = data.message;
//     const options = {

//     }

//     console.log (
//       `User ${context.auth.uid} has requested to send a message ${message}`
//     )
    
//     await admin.messaging().sendToDevice(fcmToken, message, options) {

//     }




//   })