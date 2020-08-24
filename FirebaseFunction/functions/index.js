/* eslint-disable no-await-in-loop */
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
    memory: '256MB'
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
  .onWrite((event) => {
    const roomData = event.after.data();
    const participants = roomData.participants;


    const registrationTokens = getDocuments(participants)

    registrationTokens.then((result) => {
      console.log('print there are:', result);

      let fcmTokens = [];
      for (const token of result) {
        fcmTokens.push(token.fcm)
      }

      var message = {
        notification: {
          title: 'New Match!',
          body: 'We have matched you with someone new, jump in and say hi!'
        },
        tokens: fcmTokens
      }

      console.log(message)
      return message;
    }).then((message) => {

      const response = admin.messaging().sendMulticast(message)

      return response;
    }).then((response) => {
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(registrationTokens[idx]);
          }
        });
        console.log('List of tokens that caused failures:' + failedTokens);
      }
      return;
    }).catch((error) => {
      console.log('Error sending message:', error);
    });
    return;
  });

  async function getDocuments(array) {
  var newArray = [];
  console.log('starting iteration');

  for (i = 0; i < array.length; i++ ) {
    const docRef = db.collection('users').doc(`${array[i]}`);
    const doc = await docRef.get().then((result) => {
      return result.data()
    });
    newArray.push(doc);
    console.log(doc);
  }


  console.log(newArray);
  return newArray;
  }
