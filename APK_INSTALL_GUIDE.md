# 📱 APK 설치 완전 가이드

## 🎯 APK 방식 선택 - 정확한 단계

### 1단계: Flutter 개발환경 설치 (한 번만)

#### Windows에서 Flutter 설치
1. **Flutter SDK 다운로드**
   - https://flutter.dev/docs/get-started/install/windows 접속
   - "Get the Flutter SDK" 섹션에서 ZIP 파일 다운로드
   - C:\flutter 폴더에 압축 해제

2. **환경변수 설정**
   - 시스템 환경변수 편집 열기
   - Path에 `C:\flutter\bin` 추가
   - 명령 프롬프트 재시작

3. **설치 확인**
   ```cmd
   flutter doctor
   ```

#### Android 도구 설치 (선택사항이지만 권장)
1. **Android Studio 다운로드**
   - https://developer.android.com/studio
   - 설치 후 Android SDK 자동 설치됨

2. **Flutter 플러그인 설치**
   - Android Studio > File > Settings > Plugins
   - "Flutter" 검색하여 설치

### 2단계: APK 파일 생성

#### 자동 생성 (추천)
```cmd
# 프로젝트 폴더에서 실행
build_apk.bat
```

#### 수동 생성
```cmd
# 의존성 설치
flutter pub get

# APK 빌드
flutter build apk --release
```

### 3단계: APK 파일 위치 확인
생성된 APK 파일 위치:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 4단계: 스마트폰에 설치

#### 안드로이드 기기 준비
1. **알 수 없는 소스 허용**
   - 설정 > 보안 > 알 수 없는 소스 허용
   - 또는 설정 > 앱 > 특별 액세스 > 알 수 없는 앱 설치

2. **APK 파일 복사**
   - USB 케이블로 연결하여 복사
   - 또는 클라우드 드라이브 사용 (Google Drive, OneDrive 등)
   - 또는 이메일로 전송

3. **APK 설치**
   - 파일 관리자에서 APK 파일 찾기
   - APK 파일 터치
   - "설치" 버튼 클릭
   - 권한 요청시 "허용" 선택

## 🚀 빠른 요약

**컴퓨터에서:**
1. Flutter 설치 (한 번만)
2. `build_apk.bat` 실행
3. `app-release.apk` 파일 생성 확인

**스마트폰에서:**
1. 알 수 없는 소스 허용
2. APK 파일 복사
3. APK 파일 실행하여 설치

## ⚠️ 문제 해결

### Flutter 설치 문제
- PATH 환경변수 확인
- 명령 프롬프트 재시작
- `flutter doctor` 명령어로 문제 확인

### APK 설치 문제
- 알 수 없는 소스 허용 확인
- 저장공간 부족 확인
- 기존 앱 삭제 후 재설치

### 권한 문제
- 파일 접근 권한 허용
- 앱 설정에서 권한 수동 허용

## 📋 최종 체크리스트

- [ ] Flutter 설치 완료
- [ ] `flutter doctor` 정상 실행
- [ ] `build_apk.bat` 실행 성공
- [ ] APK 파일 생성 확인
- [ ] 스마트폰 알 수 없는 소스 허용
- [ ] APK 파일 스마트폰으로 복사
- [ ] APK 설치 완료
- [ ] 앱 실행 및 PDF 파일 열기 테스트

## 🎉 완료!
이제 스마트폰에서 Simple PDF Reader를 사용할 수 있습니다!