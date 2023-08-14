importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");


const firebaseConfig = {
    apiKey: "AIzaSyAhDTVEXo0hbCRog2NwfoB6SoeiOvDpTdc",
    authDomain: "coursebubble-247b2.firebaseapp.com",
    projectId: "coursebubble-247b2",
    storageBucket: "coursebubble-247b2.appspot.com",
    messagingSenderId: "867948555298",
    appId: "1:867948555298:web:118f2d90d94a257f0f6e7b",
    measurementId: "G-2S3M3GSH8B"
};
firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    self.registration.showNotification("New Message");
    console.log("onBackgroundMessage", message);
});