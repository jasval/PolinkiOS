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

exports.notificationOnFinished = functions.
  https.onCall(async (data) => {
    const user = data.userName;
    const targetId = data.targetId;


    const userRef = db.collection('users').doc(targetId);

    userRef.get().then((snap) => {
      const user = snap.data()
      return user.fcm
    }).then((fcmToken) => {

      const messageTitle = `${user} finalised the conversation`;

      var message = {
        notification: {
          title: messageTitle,
          body: 'Get in the conversation and offer your feedback!',
        },
        apns: {
          headers: {
            'apns-priority' : '10',
          },
          payload: {
            aps: {
              sound: 'default',
            }
          }
        },
        token: fcmToken
      }
      const response = admin.messaging().send(message);
      return response
    }).catch((error) => {
      console.log('We couldnt notify because of this error:', error)
    })

})


exports.sendNotification = functions.firestore
  .document('rooms/{roomId}')
  .onCreate((event) => {
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
          body: 'We have matched you with someone new, jump in and say hi!',
        },
        apns: {
          headers: {
            'apns-priority' : '10',
          },
          payload: {
            aps: {
              sound: 'default',
            }
          }
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

  exports.sendMessageNotification = functions.firestore
  .document('rooms/{roomId}/messages/{messageId}')
  .onCreate((change, context) => {
    const message = change.data();
    const logMessage = `Sent a message with id: ${context.params.messageId}`;
    console.log(logMessage);

    const roomRef = db.collection('rooms').doc(context.params.roomId);
    roomRef.get().then((snap) => {
      var targetId;
      let room = snap.data()
      for (i = 0; i < room.participants.length; i++) {
        if (room.participants[i] !== message.senderId) {
          targetId = room.participants[i];
        }
      }
      return targetId;
    }).then((targetId) => {
      const docRef = db.collection('users').doc(targetId);

      return docRef.get();
    }).then((result) => {

      let messageTitle = `${message.senderUsername} sent you a message`;
      let messageBody = `${message.content}`;
      let user = result.data()

      var messageNotification = {
        notification: {
          title: messageTitle,
          body: messageBody
        },
        apns: {
          headers: {
            'apns-priority' : '10',
          },
          payload: {
            aps: {
              sound: 'default',
            }
          }
        },
        token: user.fcm,
      } 

      const response = admin.messaging().send(messageNotification);
      return response;
    }).catch((error) => {
      console.log('Error getting target id', error);
    })
  })

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
