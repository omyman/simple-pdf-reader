# 🚀 GitHub Actions 자동 빌드 가이드

## 📋 단계별 진행

### 1단계: GitHub 저장소 생성
1. **GitHub.com 접속** 후 로그인
2. **"New repository"** 클릭
3. **저장소 이름**: `simple-pdf-reader`
4. **Public** 선택 (무료 Actions 사용)
5. **Create repository** 클릭

### 2단계: 프로젝트 업로드
현재 폴더에서 다음 명령어 실행:

```bash
# Git 초기화
git init

# 모든 파일 추가
git add .

# 커밋
git commit -m "Simple PDF Reader - Initial commit"

# 원격 저장소 연결 (본인의 GitHub 사용자명으로 변경)
git remote add origin https://github.com/사용자명/simple-pdf-reader.git

# 업로드
git push -u origin main
```

### 3단계: 자동 빌드 확인
1. **GitHub 저장소** 페이지로 이동
2. **Actions** 탭 클릭
3. **"Build Android APK"** 워크플로우 확인
4. **빌드 진행 상황** 모니터링 (5-10분 소요)

### 4단계: APK 다운로드
빌드 완료 후:

**방법 A: Releases에서 다운로드**
1. **Releases** 탭 클릭
2. **최신 릴리즈** 선택
3. **simple-pdf-reader-apk** 다운로드

**방법 B: Actions에서 다운로드**
1. **Actions** 탭 클릭
2. **완료된 빌드** 클릭
3. **Artifacts** 섹션에서 APK 다운로드

## 🎯 자동 빌드 설정 (이미 완료됨)

다음 파일들이 자동 빌드를 위해 준비되어 있습니다:

### `.github/workflows/build-apk.yml`
- Flutter 환경 설정
- 의존성 설치
- APK 빌드
- 자동 릴리즈 생성

### 빌드 과정
1. **Ubuntu 환경** 설정
2. **Java 17** 설치
3. **Flutter 3.24.0** 설치
4. **의존성** 설치 (`flutter pub get`)
5. **테스트** 실행 (선택사항)
6. **APK 빌드** (`flutter build apk --release`)
7. **Artifacts 업로드**
8. **Release 생성** (자동)

## 📱 생성될 APK 정보

**파일명**: `app-release.apk`  
**크기**: 약 25-30MB  
**지원**: Android 5.0 (API 21) 이상  
**기능**:
- ✅ PDF 파일 읽기
- ✅ 확대/축소 (핀치 + 버튼)
- ✅ 페이지 네비게이션
- ✅ 최근 파일 목록
- ✅ 다크모드 지원
- ✅ 텍스트 선택
- ✅ 오프라인 사용

## 📧 이메일 전송 계획

APK 생성 완료 후:
1. **Google Drive 업로드**
2. **공유 링크 생성**
3. **omyman@daum.net으로 이메일 전송**

**이메일 내용**:
- APK 다운로드 링크
- 설치 가이드
- 사용법 안내
- 문제 해결 방법

## ⚠️ 주의사항

**GitHub 계정 필요**:
- 무료 계정으로 충분
- Public 저장소에서 Actions 무료 사용

**빌드 시간**:
- 첫 빌드: 5-10분
- 이후 빌드: 3-5분 (캐시 사용)

**자동 업데이트**:
- 코드 변경시 자동 재빌드
- 새 버전 자동 릴리즈

## 🚀 지금 시작하세요!

1. **GitHub 저장소 생성**
2. **위 명령어로 업로드**
3. **Actions에서 빌드 확인**
4. **APK 다운로드**

**GitHub 사용자명을 알려주시면 정확한 명령어를 제공해드리겠습니다!**