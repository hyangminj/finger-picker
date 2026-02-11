# 배포 가이드 (Deployment Guide)

## Android - Google Play Store

### 1. 서명 키 생성

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

### 2. 키 설정 파일 생성

`android/key.properties` 파일 생성:

```properties
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=/Users/<username>/upload-keystore.jks
```

### 3. build.gradle 수정

`android/app/build.gradle` 파일에 추가:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. 앱 정보 설정

`android/app/src/main/AndroidManifest.xml` 수정:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.fingerpicker.finger_picker_flutter">
    <application
        android:label="Finger Picker"
        android:icon="@mipmap/ic_launcher">
```

### 5. App Bundle 빌드

```bash
flutter build appbundle --release
```

출력 파일: `build/app/outputs/bundle/release/app-release.aab`

### 6. Play Console에 업로드

1. [Google Play Console](https://play.google.com/console) 접속
2. 새 앱 만들기
3. 앱 세부정보 입력
4. 릴리스 → 프로덕션 → 새 릴리스 만들기
5. App Bundle 업로드
6. 릴리스 노트 작성
7. 검토 제출

## iOS - App Store

### 1. Apple Developer 계정

- [Apple Developer](https://developer.apple.com) 가입 필요 (연간 $99)
- Xcode 설치

### 2. Bundle Identifier 설정

`ios/Runner.xcodeproj`를 Xcode에서 열기:

1. Runner 타겟 선택
2. Signing & Capabilities 탭
3. Bundle Identifier 설정: `com.fingerpicker.fingerPickerFlutter`
4. Team 선택

### 3. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 내 앱 → 새 앱
3. 번들 ID 선택
4. 앱 정보 입력

### 4. 빌드 및 아카이브

```bash
flutter build ios --release
```

그 다음 Xcode에서:

1. `ios/Runner.xcworkspace` 열기
2. Product → Archive
3. Archive 완료 후 Distribute App
4. App Store Connect 선택
5. Upload

### 5. App Store Connect에서 제출

1. 빌드 선택
2. 스크린샷 추가 (필수)
3. 앱 설명 작성
4. 심사 제출

## 테스트 배포 (TestFlight / Beta)

### Android - Internal Testing

1. Play Console → 테스트 → 내부 테스트
2. 새 릴리스 만들기
3. APK/AAB 업로드
4. 테스터 이메일 추가

### iOS - TestFlight

1. App Store Connect → TestFlight
2. 내부 테스트 그룹 생성
3. 테스터 추가
4. 빌드 자동으로 TestFlight에 표시됨

## 버전 관리

`pubspec.yaml`에서 버전 업데이트:

```yaml
version: 1.0.0+1
#        ^^^^^ ^^
#        |     build number (증가시켜야 함)
#        version name
```

다음 릴리스:
```yaml
version: 1.0.1+2
```

## 체크리스트

### 출시 전 확인사항

- [ ] 앱 아이콘 설정
- [ ] 앱 이름 확인
- [ ] 버전 번호 설정
- [ ] 개인정보 처리방침 URL (선택사항)
- [ ] 서명 키 생성 및 안전 보관
- [ ] 스크린샷 준비 (각 플랫폼 요구사항 확인)
- [ ] 앱 설명 작성 (한국어/영어)
- [ ] 실제 기기에서 테스트

### 스크린샷 요구사항

**Android (Play Store):**
- 최소 2장, 최대 8장
- 16:9 또는 9:16 비율
- 권장: 1080x1920 또는 1920x1080

**iOS (App Store):**
- 다양한 기기 크기별 스크린샷 필요
  - 6.7" (iPhone 15 Pro Max): 1290x2796
  - 6.5" (iPhone 11 Pro Max): 1242x2688
  - 5.5" (iPhone 8 Plus): 1242x2208
- 최소 3장

## 유용한 명령어

```bash
# 분석
flutter analyze

# 테스트
flutter test

# 디바이스 확인
flutter devices

# APK 빌드 (테스트용)
flutter build apk --release

# App Bundle 빌드 (Play Store)
flutter build appbundle --release

# iOS 빌드
flutter build ios --release

# 캐시 정리
flutter clean
```

## 문제 해결

### "Signing for Runner requires a development team"
- Xcode에서 Team 선택 필요
- Apple Developer 계정 필요

### "Build input file cannot be found"
```bash
cd ios
pod install
cd ..
```

### 서명 오류
```bash
flutter clean
flutter pub get
```

## 참고 자료

- [Flutter 배포 가이드](https://docs.flutter.dev/deployment)
- [Play Console 도움말](https://support.google.com/googleplay/android-developer)
- [App Store Connect 가이드](https://developer.apple.com/app-store-connect/)
