# Firebase Messaging
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.RemoteMessage { *; }
-dontwarn com.google.firebase.messaging.**

# Auth
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep the GSON serializer/deserializer
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
