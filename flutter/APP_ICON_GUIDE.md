# 앱 아이콘 가이드

## 간단한 방법: flutter_launcher_icons 패키지 사용

### 1. pubspec.yaml에 추가

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#0A0A0F"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

### 2. 아이콘 이미지 준비

- `assets/icon/app_icon.png` - 1024x1024 PNG
- 배경은 투명하게 또는 앱 테마 색상 (#0A0A0F)

### 3. 생성 명령어

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## 수동 방법

### Android

아이콘 파일 위치: `android/app/src/main/res/`

필요한 크기:
- `mipmap-mdpi/ic_launcher.png` - 48x48
- `mipmap-hdpi/ic_launcher.png` - 72x72
- `mipmap-xhdpi/ic_launcher.png` - 96x96
- `mipmap-xxhdpi/ic_launcher.png` - 144x144
- `mipmap-xxxhdpi/ic_launcher.png` - 192x192

### iOS

아이콘 파일 위치: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Xcode에서:
1. `ios/Runner.xcworkspace` 열기
2. Assets.xcassets → AppIcon 선택
3. 각 크기별 이미지 드래그 앤 드롭

필요한 크기:
- iPhone App - iOS 14-18: 60x60, 120x120, 180x180
- iPad App - iOS 14-18: 76x76, 152x152
- App Store: 1024x1024

## 디자인 가이드라인

### 컨셉 아이디어

**Finger Picker 앱 아이콘:**

1. **손가락 원형 스타일**
   - 여러 개의 컬러풀한 원형
   - 중앙에 하나가 빛나는 디자인

2. **심플 버전**
   - 단일 컬러 원형
   - 그라디언트 효과

3. **추상적 버전**
   - 손가락 실루엣
   - 선택을 나타내는 화살표나 별

### 색상 추천

앱에서 사용하는 색상:
- #FF6B6B (레드)
- #4ECDC4 (청록)
- #FFE66D (옐로우)
- #A78BFA (퍼플)

배경: #0A0A0F (다크)

## 온라인 도구

- [App Icon Generator](https://www.appicon.co/)
- [Icon Resizer](https://iconresizer.com/)
- [Canva](https://www.canva.com/) - 디자인 도구

## 간단한 SVG 아이콘 코드

```svg
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#0A0A0F"/>
  <circle cx="512" cy="512" r="350" fill="url(#grad)"/>
  <defs>
    <radialGradient id="grad">
      <stop offset="0%" stop-color="#FF6B6B"/>
      <stop offset="100%" stop-color="#A78BFA"/>
    </radialGradient>
  </defs>
</svg>
```

이 SVG를 PNG로 변환 후 사용하세요.
