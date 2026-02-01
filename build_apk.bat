@echo off
echo Simple PDF Reader APK 빌드 스크립트
echo =================================

echo.
echo 1. 의존성 설치 중...
call flutter pub get
if %errorlevel% neq 0 (
    echo 의존성 설치 실패!
    pause
    exit /b 1
)

echo.
echo 2. APK 빌드 중...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo APK 빌드 실패!
    pause
    exit /b 1
)

echo.
echo APK 빌드 완료!
echo 파일 위치: build\app\outputs\flutter-apk\app-release.apk
echo.
echo 이 APK 파일을 안드로이드 기기에 복사하여 설치할 수 있습니다.
pause