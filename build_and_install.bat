@echo off
echo Simple PDF Reader 빌드 및 설치 스크립트
echo =====================================

echo.
echo 1. 의존성 설치 중...
call flutter pub get
if %errorlevel% neq 0 (
    echo 의존성 설치 실패!
    pause
    exit /b 1
)

echo.
echo 2. 연결된 디바이스 확인 중...
call flutter devices
if %errorlevel% neq 0 (
    echo 디바이스를 찾을 수 없습니다!
    echo USB 디버깅이 활성화된 안드로이드 기기를 연결해주세요.
    pause
    exit /b 1
)

echo.
echo 3. 앱 빌드 및 설치 중...
call flutter run --release
if %errorlevel% neq 0 (
    echo 빌드 또는 설치 실패!
    pause
    exit /b 1
)

echo.
echo 설치 완료!
pause