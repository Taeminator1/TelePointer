# 요구 사항

단축키를 통해 마우스의 좌표를 즉각적으로 이동시킬 수 있는 앱

## 버전

- Minimum Deployments: macOS 26
- Swift: 6
- Tuist: 4.205.0

## 기술 스택

- SwiftUI
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts): 3.0.1

## 배포

- Mac App Store
- App Sandbox 필수
- Bundle ID: com.taeminyun.TelePointer

## UI

### Dock

- 아이콘 노출시키면 안 됨

### Menu Bar

#### App menu

- 왼쪽에 노출되는 App menu는 노출시키면 안 됨

#### Menu bar extras

- 오른쪽에 노출되는 Menu bar extras만 추가
- 아이콘을 누르면 메뉴가 펼쳐지는 형태

| 목록 | 단축키 | 동작 |
| --- | --- | --- |
| Move Pointer | ⌃⌥C | 커서가 있는 화면의 중앙으로. 이미 중앙이면 다음 모니터로 ([v2/Requirements.md](../v2/Requirements.md)) |
| Enable Click… | 단축키 없음 | 접근성 권한이 없을 때만 나타남 — 시스템 설정의 손쉬운 사용 패널을 연다 |
| Open at Login | 단축키 없음 | 누를 때마다 왼쪽에 체크가 표시되었다가 사라졌다가 함 |
| Keyboard Shortcuts… | 단축키 없음 | 설정 창을 연다 |
| Quit | ⌘Q | 앱 종료 |

## 동작 상세

### Move Pointer

- **화면 기준**: 현재 커서가 위치한 디스플레이
- **가운데 기준**: 메뉴바와 Dock을 제외하지 않은 물리적 화면 전체의 정중앙
- **이동 방식**: 애니메이션 없이 즉각 이동
- 커서 아래 UI의 hover 상태는 사용자가 마우스를 실제로 움직이기 전까지 갱신되지 않음 (v1에서 수용). 클릭 좌표는 정상 적용됨
- **단축키**: ⌃⌥C — v2에서 설정 창으로 바꿀 수 있다
- 다른 앱을 쓰는 중에도 어디서나 동작해야 하며, 누른 키가 앞의 앱으로 전달되어 부작용을 일으키면 안 됨
- 메뉴에서 눌렀을 때도 단축키와 동일하게 동작해야 함

### Open at Login

- 켜면 로그인 시 앱이 자동 실행됨
- 체크 상태는 시스템에 등록된 로그인 항목 상태를 그대로 따름
    - 사용자가 시스템 설정에서 직접 끈 경우에도 메뉴의 체크 상태가 올바르게 반영되어야 함
- 메뉴가 열릴 때마다 상태를 다시 조회

### Quit

- Dock에 노출되지 않는 앱은 활성 앱이 아니므로, ⌘Q는 **메뉴가 열려 있는 동안에만** 동작함
- 전역 ⌘Q 가로채기는 다른 앱의 종료 단축키를 뺏게 되므로 하지 않음

## 검증 완료 사항

- 전역 핫키 등록 · 커서 이동 · 로그인 항목 조회 **세 기능 모두 App Sandbox 안에서 정상 동작**
- 세 기능 모두 **접근성 권한이 필요 없음** — 권한 요청 UI를 만들지 않아도 됨

## 관련 문서

- [Tasks.md](./Tasks.md) — v1 구현 작업 목록
- [Architecture.md](../Architecture.md) — 모듈 구조와 결정 근거
- [Backlog.md](../Backlog.md) — v1 이후 항목
- [Notes.md](../Notes.md) — 작업 중 남긴 기록과 채택하지 않은 대안
