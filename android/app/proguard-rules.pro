# Flutter 관련 ProGuard 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Syncfusion PDF 뷰어 관련
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# 파일 피커 관련
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Gson 관련 (SharedPreferences JSON 처리용)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer