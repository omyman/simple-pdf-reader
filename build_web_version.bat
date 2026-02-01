@echo off
echo 웹 버전 빌드 중...
echo ==================

echo.
echo 1. Flutter 웹 빌드 시작...
flutter build web --release

if %errorlevel% neq 0 (
    echo 웹 빌드 실패!
    pause
    exit /b 1
)

echo.
echo 2. 웹 버전 빌드 완료!
echo 파일 위치: build\web\
echo.
echo 3. 로컬 서버 실행 중...
echo 브라우저에서 http://localhost:8000 접속하세요
echo.
cd build\web
python -m http.server 8000

pause