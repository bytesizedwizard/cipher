# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase (if you add it later)
-keep class com.google.firebase.** { *; }

# Preserve crypto and security classes (critical for TOTP)
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-keep class android.security.** { *; }

# Biometric authentication
-keep class androidx.biometric.** { *; }
-keep class android.hardware.biometrics.** { *; }

# Camera/QR scanning
-keep class androidx.camera.** { *; }

# Your app's main classes
-keep class dev.bytesizedwizard.cipherauth.** { *; }

# Preserve native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serialization classes intact
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Preserve annotations
-keepattributes *Annotation*

# Keep stack traces readable
-keepattributes SourceFile,LineNumberTable

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# Google Play Core - Suppress warnings for unused deferred components
-dontwarn com.google.android.play.core.**