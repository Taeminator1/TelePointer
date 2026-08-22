# Notes

## etc.

- Rotate 360과 ⌃⌥⌘C 경합에서 둘 중 하나만 실행 됨
- VS Code의 claude-code extension과 ⌃⌥F 경합에서 TelePointer만 실행 됨

## 단축키 후보

| 조합 | 비고 |
| --- | --- |
| ⌃⌥⌘ + 알파벳 | VocieOver, Xcode |
| ⌃⌥ + 알파벳 | Emacs 계열, 터미널 앱 |
| ⌃⌥ + 숫자 | 텍스트 입력과도 충돌 없음 |
| ⌃⌥⌘⇧ + 키 | 다소 복잡 |
| F13~F19 | fn 키가 멀리 떨어져 있을 수 있음 |

### ⌃⌥⌘ + 알파벳
- H/L/T/G: VoiceOver
- M/S: Xcode 커스텀 바인딩

### ⌃⌥ + 알파벳
- G/J/R: VS Code
- D: VS Code 커스텀 바인딩 (dart-code)
- F: VS Code 커스텀 바인딩 (claude-code)
- J/K/M/N: VS Code 커스텀 바인딩 (code-runner)

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

## warp은 이벤트를 발생시키지 않음

- 커서 아래 UI의 hover 상태는 사용자가 마우스를 실제로 움직이기 전까지 갱신되지 않음
- 합성 `mouseMoved` 이벤트를 post하면 갱신되지만 접근성 권한이 필요
    - `CGEvent.post`는 반환값이 없어 권한이 없으면 조용히 무시됨
    - v1에서는 하지 않는다
- 클릭 좌표는 정상 적용되므로 기능상 문제는 없음

## warp 직후 0.25초는 물리 마우스가 먹통 (2026-08-22)

- `CGWarpMouseCursorPosition` 뒤 약 0.25초 동안 로컬 마우스 이벤트가 억제된다
- 방향 이동은 8ms마다 warp하므로 이동 중 내내, 그리고 키를 뗀 뒤 0.25초까지 이어진다
- `CGAssociateMouseAndMouseCursorPosition`을 warp 뒤에 부르면 풀리지만 채택하지 않았다
    - 키보드로 맞춘 좌표가 손이 닿아 흔들리지 않는 편이 낫다
    - 전역 상태라 마우스를 캡처한 다른 앱(게임 · 원격 제어)의 입력까지 되돌려 놓는다

## 핫키 충돌은 감지할 수 없음

- 이미 다른 앱이나 시스템이 점유한 조합(예: Spotlight의 `⌘Space`)도 등록 자체는 성공
- 충돌이 나면 오류 없이 조용히 동작하지 않음
- 안전한 조합(`⌃⌥⌘C`)을 고정하는 것으로 대응

## `initial:` 단축키는 첫 실행에만 적용된다 (2026-08-22)

- `KeyboardShortcuts.Name(_:initial:)`은 UserDefaults에 값이 없을 때만 저장한다 (`setInitialShortcutIfNeeded`)
- 한 번 저장되면 코드의 `initial:`을 바꿔도 무시되고, 메뉴바에 표시되는 글리프도 그대로
- 개발 중 기본값을 바꾸려면 앱을 종료하고 저장값을 지운 뒤 재실행

```bash
osascript -e 'quit app "TelePointer"'
defaults delete com.taeminyun.TelePointer KeyboardShortcuts_movePointer
```

## 커서 좌표는 두 좌표계를 오간다

- AppKit(`NSScreen.frame`, `NSEvent.mouseLocation`): 주 화면 왼쪽 **아래**가 원점, y는 위로 증가
- warp(`CGWarpMouseCursorPosition`, `CGEvent.location`): 주 화면 왼쪽 **위**가 원점, y는 아래로 증가
- `ScreenGeometry`의 `warpPoint` · `warpFrame`이 AppKit → warp 변환을 맡는다
- `Direction.up`의 벡터가 `dy: -1`인 것도 warp 좌표계 기준이기 때문
- 화면 판정(`moveToScreenCenter`)은 AppKit 좌표, 방향 이동은 warp 좌표 — 섞어 쓰면 어긋난다

## 검토했으나 채택하지 않은 대안

- 이동 대상 화면: 주 디스플레이 / 포커스된 앱이 있는 디스플레이
- 가운데 기준: 메뉴바·Dock 제외 영역
- 핫키 방식: 메뉴가 열렸을 때만 동작
- 핫키 구현: 시스템 API 직접 호출 / 글로벌 이벤트 모니터
- 영벡터일 때 warp 건너뛰기 — 상·하 동시 입력 중 마우스가 살아나 내부 좌표와 어긋난다
- `Binding(set:)`에 메서드 참조 직접 전달 — Swift 6.3에서 IRGen 크래시, 클로저로 감싸 우회
