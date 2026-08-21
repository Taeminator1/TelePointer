# Notes

## etc.

- Rotate 360과 ⌃⌥⌘C 경합에서 둘 중 하나만 실행 됨

## 단축키 후보

- ⌃⌥⌘Z, ⌃⌥⌘X, ⌃⌥⌘G

## SwiftUI 프리뷰 JIT 실패 (2026-08-21)

- 증상: 캔버스에서 `FailedToLaunchAppError` → `JITError` → `XOJITError: file doesn't have architecture 'arm64'`
- 원인: 실행 중인 macOS(26.2, 25C56)보다 Xcode SDK(26.4, 25E236)가 앞섬
- 대응: Xcode 26.2(SDK 26.2, 25C57)로 열면 정상
- OS를 SDK와 같거나 높은 버전으로 올리면(예: macOS 26.6.2) 최신 Xcode에서도 해소될 것으로 보임

## SwiftUI 프리뷰를 두지 않은 이유 (2026-08-21)

- `MenuBarExtra`는 Scene이라 `#Preview` 대상이 아님
- 메뉴 항목은 `NSMenu`가 자기 창에 그리므로 캔버스 안에 렌더되지 않음
    - `Menu`로 감싸면 클릭해야 열리고, `NSHostingMenu` + `popUp()`으로 자동으로 띄워도 캔버스 위에 뜨는 별도 창
    - `MenuBarContent()`를 그대로 그리면 `Button`·`Toggle`이 일반 컨트롤이 되고, 단축키 글리프는 메뉴 밖에서 표시되지 않음
- 설정 창처럼 일반 창 UI가 생기면 그때 다시 검토
