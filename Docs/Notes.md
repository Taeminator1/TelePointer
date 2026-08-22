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
- 화면 판정(`cycleScreenCenter`)은 AppKit 좌표, 방향 이동은 warp 좌표 — 섞어 쓰면 어긋난다

## 합성 클릭은 샌드박스에서도 동작한다 (2026-08-22)

클릭을 받아 기록하는 별도 앱을 표적으로 두고 관측했다.

- `CGEvent.post`로 보낸 클릭이 다른 앱의 창에 정상 전달된다 — entitlement는 `app-sandbox` 하나로 충분
- mouseDown / mouseUp 한 쌍이 필요하고, 그것으로 충분하다
- `mouseEventClickState`를 올리면 수신 측 `NSEvent.clickCount`에 그대로 반영된다
- `event.flags = []`가 필요하다. 단축키의 ⌃가 실린 채 가면 control-click이 되어 우클릭으로 해석된다
- 권한이 없으면 조용히 무시된다 — 반환값도 없고 커서도 움직이지 않는다
- 합성 클릭은 down·up 간격이 0~1ms이고 좌표가 완전히 같다. 물리 클릭은 수십~수백ms에 좌표가 매번 흔들린다 — 로그에서 둘을 구분하는 기준

## 권한 프롬프트는 경로가 둘이고, 하나만 막힌다 (2026-08-22)

- 앱이 `AXIsProcessTrustedWithOptions(prompt:)`로 **요청**하는 경로는 샌드박스가 막는다

```
Sandbox: TelePointer deny(1) mach-lookup com.apple.universalaccessAuthWarn
  ← AXIsProcessTrustedWithOptions ← _AXRegisterControlComputerAccess
```

- 다이얼로그 없이 `false`만 돌아온다. `CGRequestPostEventAccess()`도 같은 거부에 걸려 우회로가 못 된다
- 같은 코드를 샌드박스 없이 서명하면 거부가 없고 프롬프트가 정상적으로 뜬다
- 반면 권한 없이 `CGEvent.post`를 호출하면 **TCC가 스스로** 프롬프트를 띄운다. 앱이 요청하는 게 아니라 샌드박스와 무관하다
    - 앱당 한 번만 뜬다. 거부하면 앱이 다시 띄울 방법이 없다
    - 버튼은 `허용 안 함` · `시스템 설정 열기` 둘뿐 — `허용` 버튼은 없다
    - 이때 앱이 손쉬운 사용 목록에 등록되므로 사용자는 토글만 켜면 된다
- 그래서 `click()`에 `AXIsProcessTrusted` 가드를 두면 안 된다. `post`에 도달하지 못해 프롬프트가 뜰 기회 자체가 사라진다

## 권한 조회 API는 시작 시점 스냅샷 (2026-08-22)

- 샌드박스에서 `AXIsProcessTrusted()` · `CGPreflightPostEventAccess()`는 실행 중 갱신되지 않는다
- 권한을 켜도 재시작 전까지 계속 `false`, 꺼도 계속 `true`
- 반면 클릭 능력은 즉시 반영된다 — 켠 직후 재시작 없이 클릭이 동작한다
- 그래서 `isGranted`를 `static let`으로 둔다. 다시 호출해도 값이 바뀌지 않고 샌드박스 위반 로그만 쌓인다
- 대가: 권한을 켠 뒤에도 재시작 전까지 메뉴의 `Enable Click…`이 남는다. 우회할 API가 없어 감수한다

## 권한을 확인할 때 빠지기 쉬운 함정 (2026-08-22)

- **인스턴스가 둘 이상 뜨면 핫키는 먼저 등록한 쪽이 가져간다.** 재빌드 후 옛 프로세스가 남아 있으면
  권한을 가진 옛 프로세스가 클릭을 처리해 "재빌드해도 잘 된다"로 오독하게 된다. 확인 전에 전부 종료할 것
- 시스템 설정이 열린 채로 `tccutil reset`을 하면 UI가 낡은 행을 들고 있다. 닫고 실행할 것
- 권한을 켠 뒤에는 앱을 재시작해야 메뉴 표시가 맞는다 (위 「시작 시점 스냅샷」 참고)

### 권한을 초기화해 프롬프트를 다시 띄우기

```bash
# 빌드 없이 실행만 다시 하는 경우

## TelePointer 앱 닫기
osascript -e 'quit app "TelePointer"'

## 시스템 설정 끄기
osascript -e 'quit app "System Settings"'

## 권한 기록 지우기
tccutil reset Accessibility com.taeminyun.TelePointer

## TelePointer 열기
open ~/Library/Developer/Xcode/DerivedData/TelePointer-*/Build/Products/Debug/TelePointer.app
```

```bash
# 재빌드하는 경우

## TelePointer 앱 닫기 (직접)

## 시스템 설정 끄기
osascript -e 'quit app "System Settings"'

## 권한 기록 지우기
tccutil reset Accessibility com.taeminyun.TelePointer

## TelePointer 빌드하기 (직접)
```

**Xcode에서 실행 중인 앱은 Xcode에서 정지시킨다.** 스크립트로 끄고 리셋했을 때
프롬프트가 다시 뜨지 않고 클릭도 그대로 동작한 적이 있다. 앱을 직접 종료하면 정상이었다.
같은 명령을 따로 실행하면 앱은 제대로 꺼지므로 원인은 미확인이다.

재실행만으로는 프롬프트가 뜨지 않는다. **클릭 단축키(⌃⌥U)를 눌러야** `CGEvent.post`가 실행되고
그제서야 TCC가 프롬프트를 띄운다 — 앱은 스스로 권한을 요청하지 않는다.

**리셋이 먹었는지는 메뉴로 확인한다.** 재실행 후 메뉴에 `Enable Click…`이 보이면 리셋된 것이고,
안 보이면 권한이 남아 있는 것이다.

실행 방식(Xcode Run / `open`)은 결과에 영향을 주지 않는다. Xcode로 띄워도
책임 프로세스는 TelePointer 자신이고(부모만 `debugserver`), TCC 판단도 동일하다.

한 번은 재빌드 후 권한이 무효가 되어, 목록에서 껐다 켜는 것으로 복구되지 않고
기록을 지우고 프롬프트로 새로 등록해야 했다. 이후 재빌드에서는 권한이 그대로 유지됐으므로
재빌드가 원인이라고 단정할 근거는 없다 — 원인 미확인.

## Mac App Store와 접근성 권한 (2026-08-22)

- MAS는 샌드박스를 의무화하지만, 샌드박스가 접근성 권한 자체를 금지하지는 않는다
- `AXUIElementCreateApplication`처럼 다른 앱을 들여다보는 AX API는 막힌다. TelePointer는 쓰지 않는다
- `CGEvent.post`가 정책상 금지된다는 근거는 찾지 못했다. 같은 질문에 App Review는 "Meet with Apple 예약해서 물어보라"는 정형 답변만 했다 — 공개된 확답이 없다
- 확답이 없는 채로 MAS 경로를 유지하기로 했다. 반려되면 샌드박스를 끄고 Developer ID 직접 배포로 돌린다

## 연타를 더블클릭으로 올리는 기준

- `PointerMover.clickState`가 직전 클릭과 비교해 `mouseEventClickState`를 올린다
- 같은 버튼 · `NSEvent.doubleClickInterval` 이내 · 좌표 차이 `doubleClickRadius` 미만일 때만 이어진다
- 간격을 시스템 설정에서 가져오므로 사용자가 바꾼 값을 그대로 따른다

## 합성 이벤트가 전역 modifier 상태를 지운다 (2026-08-22)

- `flags = []`로 보낸 마우스 이벤트가 처리되고 나면 시스템의 현재 modifier 상태가 그 값으로 덮인다
- `post` 직후에는 멀쩡하고 수십 ms 뒤에 지워진다 — 비동기라 바로 재보면 안 보인다
- 그래서 `NSEvent.modifierFlags` · `CGEventSource.flagsState`로는 홀드 여부를 판정할 수 없다.
  드래그 중에는 우리가 계속 이벤트를 보내므로 값이 계속 지워진다
- `CGEventSource.keyState(.hidSystemState, key:)`는 영향을 받지 않는다 — `ModifierState.modifiersHeld`가 이걸 쓴다
- 방향 이동도 같은 이유로 고쳤다. 고치기 전에는 드래그 중 이동이 8ms 몇 틱 만에 멈췄다

## 클릭과 방향키는 키 매트릭스가 겹치면 안 된다 (2026-08-22)

- 드래그는 클릭 키와 방향 키를 동시에 눌러야 한다. 여기에 modifier 두 개가 더해져 4개 동시 입력이 된다
- 처음 기본값이던 ⌃⌥U · ⌃⌥O는 방향키 IJKL 바로 위여서 **키보드가 조합을 유지하지 못했다**

```
press right  물리키[U+L+ctrlL+optL]   ← U와 L은 함께 잡힌다
press left   물리키[J+ctrlL+optL]     ← J를 누르는 순간 U가 사라진다
```

- U가 놓이면 macOS가 ⌃⌥U의 keyUp을 보내 드래그가 끝난다. 앱은 받은 대로 동작한 것이라 코드로는 못 고친다
- modifier 없이 `u`+`j` 두 개만 누르면 정상이다 — modifier가 더해져야 드러난다
- 기본값을 ⌃⌥X(왼쪽 클릭) · ⌃⌥C(모니터 간 이동) · ⌃⌥V(오른쪽 클릭)로 옮겼다.
  방향키와 손·매트릭스가 갈리고, 왼쪽부터 클릭 · 이동 · 클릭 순으로 놓인다

## 클릭 단축키에 modifier를 더 붙이면 드래그가 깨진다 (2026-08-22)

- Carbon 핫키는 modifier가 정확히 일치해야 발동한다. 여분이 있으면 탈락한다
- 클릭을 ⌃⌥⌘X로 두면 드래그 중 ⌘이 계속 눌려 있어, J를 눌러도 시스템이 보는 조합은 ⌃⌥⌘J다.
  등록된 ⌃⌥J와 달라 방향 이동이 발동하지 않는다
- 방향키를 ⌃⌥⌘으로 함께 옮기는 것도 막혀 있다 — ⌃⌥⌘L이 VoiceOver 조합이다
- 결론: Pointer 단축키는 전부 같은 modifier를 쓴다

## 검토했으나 채택하지 않은 대안

- 이동 대상 화면: 주 디스플레이 / 포커스된 앱이 있는 디스플레이
- 가운데 기준: 메뉴바·Dock 제외 영역
- 핫키 방식: 메뉴가 열렸을 때만 동작
- 핫키 구현: 시스템 API 직접 호출 / 글로벌 이벤트 모니터
- 영벡터일 때 warp 건너뛰기 — 상·하 동시 입력 중 마우스가 살아나 내부 좌표와 어긋난다
- `Binding(set:)`에 메서드 참조 직접 전달 — Swift 6.3에서 IRGen 크래시, 클로저로 감싸 우회
- `AXIsProcessTrustedWithOptions(prompt:)`로 권한 프롬프트 띄우기 — 샌드박스가 막는다
- `CGRequestPostEventAccess()` — 같은 거부에 걸린다
- 클릭 전 `AXIsProcessTrusted` 가드 — TCC가 프롬프트를 띄울 기회를 없앤다
- 권한 요청 시 `NSApp.activate()` — 얻는 것 없이 클릭 대상 앱의 포커스만 빼앗는다
- 샌드박스 해제 + Developer ID 직접 배포 — 온보딩은 나아지지만 MAS를 포기하게 된다

## 화면 중앙 판정은 정확히 일치할 수 없다 (2026-08-22)

- 중앙으로 보낸 커서를 다시 읽으면 좌표가 조금 어긋난다. warp이 픽셀에 스냅되고,
  `NSEvent.mouseLocation`은 CG 좌표를 뒤집은 값이라 변환에서 1pt가 더 붙을 수 있다
- 정확히 일치를 요구하면 「이미 중앙」이 성립하지 않아 순환이 시작되지 않는다
- 허용 오차는 2pt. 더 키우면 사용자가 마우스를 조금 움직인 것까지 중앙으로 쳐서 한 화면을 건너뛴다

## 화면 맨 윗줄은 어느 화면에도 속하지 않는다 (2026-08-22)

- `CGRect.contains`는 `maxX` · `maxY` 경계를 제외한다. AppKit 좌표에서 화면 맨 위(`y == maxY`)가 여기 걸린다
- 메뉴바를 누르러 올린 커서가 이 위치일 수 있다 — 메뉴의 `Move Pointer`와 겹치는 경로다
- v1처럼 주 화면으로 되돌리면 엉뚱한 모니터로 튄다. `targetFrame`은 가장 가까운 화면을 고른다

## 메뉴바 앱에 창을 붙이기 (2026-08-22)

- `Settings` scene은 쓰지 않는다. `LSUIElement` 앱은 App menu가 없어 ⌘, 로만 열리고 메뉴 항목에서 부를 수단이 없다
- scene은 `App.body`에만 놓을 수 있다. `Window` scene은 App 타깃에 선언하고 루트 View만 `Settings` 모듈에서 `public`으로 내보낸다
- 창이 이것 하나뿐이라 그대로 두면 실행 직후 뜬다 — `.defaultLaunchBehavior(.suppressed)`로 막는다
- `.restorationBehavior(.disabled)`는 종료 시점에 열려 있던 창이 다음 실행에서 복원되는 것을 막는다
- 앱이 비활성이라 `openWindow`만으로는 창이 다른 앱 뒤에 뜬다 — `NSApp.activate()`를 함께 부른다
- 창을 닫아도 앱은 활성으로 남고, 되돌려줄 창이 없어 키보드 포커스가 어디에도 가지 않는다.
  `NSApp.hide(nil)`로 내리면 직전 앱이 포커스를 되찾는다 — 대신 다시 열 때 `NSApp.unhide(nil)`가 필요하다
- **창을 닫아도 `.onDisappear`는 불리지 않는다.** `Window` scene은 창이 닫혀도 콘텐츠 View를 살려둔다.
  SwiftUI에 창 닫힘을 알려주는 모디파이어도 없어(`onDisappear` 외에 창 이벤트가 없다)
  `NSWindow.willCloseNotification`을 직접 구독한다 — `Settings`의 `onWindowClose`
