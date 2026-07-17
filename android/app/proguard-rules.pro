# ── Flutter ────────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── WorkManager (prevents NoSuchMethodException on WorkDatabase_Impl) ──────────
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ── WorkManager Startup ────────────────────────────────────────────────────────
-keep class androidx.startup.** { *; }
-keep class * implements androidx.startup.Initializer { *; }

# ── flutter_local_notifications ────────────────────────────────────────────────
-keep class com.dexterous.** { *; }

# ── Room (used by WorkManager internally) ─────────────────────────────────────
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

# ── General Android ───────────────────────────────────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ── Kotlin ─────────────────────────────────────────────────────────────────────
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
