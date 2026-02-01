# 📱 APK 다운로드 가이드

## 🎯 APK 파일 받는 방법

### 방법 1: GitHub에서 자동 빌드된 APK 다운로드

1. **GitHub 저장소 생성**
   - 이 프로젝트를 GitHub에 업로드
   - GitHub Actions가 자동으로 APK 빌드

2. **APK 다운로드**
   - GitHub > Actions 탭 이동
   - 최신 빌드 클릭
   - "simple-pdf-reader-apk" 다운로드

3. **또는 Releases에서 다운로드**
   - GitHub > Releases 탭 이동
   - 최신 릴리즈에서 APK 파일 다운로드

### 방법 2: 직접 제공

현재 프로젝트 파일들을 GitHub에 업로드하면 자동으로 APK가 빌드됩니다.

## 📋 GitHub 업로드 방법

```bash
# 1. GitHub에서 새 저장소 생성
# 2. 로컬에서 Git 초기화
git init
git add .
git commit -m "Initial commit: Simple PDF Reader"
git branch -M main
git remote add origin https://github.com/사용자명/simple-pdf-reader.git
git push -u origin main
```

## 🚀 자동 빌드 과정

1. 코드를 GitHub에 푸시
2. GitHub Actions가 자동 실행
3. Flutter 환경 설정
4. APK 빌드
5. 결과물을 Artifacts와 Releases에 업로드

## 📱 APK 설치 방법

1. **다운로드**: GitHub에서 APK 파일 다운로드
2. **전송**: 안드로이드 기기로 파일 복사
3. **권한 설정**: 설정 > 보안 > 알 수 없는 소스 허용
4. **설치**: APK 파일 터치하여 설치
5. **완료**: 앱 아이콘이 생성됨

## ⚡ 빠른 시작

**지금 바로 APK를 받고 싶다면:**

1. 이 프로젝트를 GitHub에 업로드
2. 5-10분 대기 (자동 빌드)
3. GitHub Actions 또는 Releases에서 APK 다운로드
4. 스마트폰에 설치

GitHub 계정이 있으시면 바로 시작할 수 있습니다!