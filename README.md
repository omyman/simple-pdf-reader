# Simple PDF Reader

단순하고 깔끔한 PDF 읽기에 집중한 Flutter 앱입니다.

## 주요 기능

- 📖 **단순한 PDF 읽기** - 복잡한 기능 없이 읽기에만 집중
- 🔍 **확대/축소** - 핀치 제스처와 버튼으로 자유로운 확대/축소
- 📱 **반응형 UI** - 다크모드 지원 및 Material 3 디자인
- 📚 **최근 파일** - 최근에 열어본 PDF 파일 목록 관리
- ⚡ **빠른 성능** - Syncfusion PDF 뷰어로 부드러운 렌더링

## 스마트폰 설치 방법

### 방법 1: 직접 설치 (USB 연결)
1. 안드로이드 기기에서 **개발자 옵션** 활성화
2. **USB 디버깅** 활성화
3. USB로 컴퓨터와 연결
4. 다음 명령어 실행:
```bash
# 자동 빌드 및 설치
build_and_install.bat

# 또는 수동으로
flutter pub get
flutter run --release
```

### 방법 2: APK 파일로 설치
1. APK 파일 생성:
```bash
# 자동 APK 빌드
build_apk.bat

# 또는 수동으로
flutter build apk --release
```
2. 생성된 APK 파일(`build/app/outputs/flutter-apk/app-release.apk`)을 스마트폰으로 복사
3. 스마트폰에서 **알 수 없는 소스** 설치 허용
4. APK 파일 실행하여 설치

### 방법 3: Google Play Store 배포 (선택사항)
1. Google Play Console 계정 필요
2. 앱 서명 키 생성 및 등록
3. APK/AAB 업로드 및 심사 대기

## 사용법

1. **PDF 파일 열기**: 홈 화면에서 "PDF 파일 열기" 버튼 클릭
2. **읽기**: 스크롤로 페이지 이동, 핀치로 확대/축소
3. **페이지 이동**: 상단 바의 첫 페이지/마지막 페이지 버튼 사용
4. **최근 파일**: 홈 화면에서 최근에 열어본 파일 바로 접근

## 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Syncfusion PDF Viewer**: 고성능 PDF 렌더링
- **File Picker**: 파일 선택 기능
- **Shared Preferences**: 최근 파일 목록 저장

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/
│   └── pdf_file_info.dart   # PDF 파일 정보 모델
├── screens/
│   ├── home_screen.dart     # 홈 화면
│   └── pdf_viewer_screen.dart # PDF 뷰어 화면
└── services/
    └── recent_files_service.dart # 최근 파일 관리 서비스
```

## 향후 개선 계획

- [ ] 북마크 기능
- [ ] 읽기 진행률 표시
- [ ] 텍스트 검색
- [ ] 페이지 썸네일 네비게이션
- [ ] 클라우드 스토리지 연동

## 라이선스

MIT License

## 배포 준비 사항

### Android
- ✅ 키스토어 파일 생성 완료
- ✅ 앱 서명 설정 완료
- ✅ ProGuard 난독화 설정
- ✅ 권한 설정 (파일 접근)
- ✅ PDF 파일 연결 설정

### iOS
- ✅ Info.plist 설정 완료
- ✅ 파일 접근 권한 설정
- ✅ PDF 파일 연결 설정
- ⚠️ Apple Developer 계정 필요 (실제 기기 설치시)

## 주요 설정 파일

- `android/app/build.gradle` - Android 빌드 설정
- `android/app/upload-keystore.jks` - 앱 서명용 키스토어
- `android/key.properties` - 키스토어 설정
- `ios/Runner/Info.plist` - iOS 앱 정보 및 권한
- `build_and_install.bat` - 자동 빌드/설치 스크립트
- `build_apk.bat` - APK 빌드 스크립트