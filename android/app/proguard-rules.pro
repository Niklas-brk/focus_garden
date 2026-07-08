# R8-Regeln fuer Focus Garden.
# Die Flutter-Grundregeln bringt das Flutter-Gradle-Plugin selbst mit; hier
# stehen nur Ausnahmen fuer Plugins, deren Code per Reflection arbeitet.

# flutter_local_notifications: liest geplante Benachrichtigungen mit GSON und
# generischen Typen (TypeToken) ein - ohne diese Regeln verwirft R8 die
# Typinformationen und geplante Benachrichtigungen gehen kaputt.
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# androidx.work / Room (kommt ueber das Google-Ads-SDK mit): Room sucht die
# generierte Datenbank-Klasse per Reflection ("WorkDatabase_Impl") - wenn R8
# sie umbenennt, crasht die App sofort beim Start.
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.** { *; }

# Google Play Core wird vom Flutter-Embedding fuer Deferred Components
# referenziert, das nutzen wir nicht - Warnungen dazu ignorieren.
-dontwarn com.google.android.play.core.**
