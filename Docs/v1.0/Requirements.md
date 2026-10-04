# 요구 사항 v1.0

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

- Dock 아이콘과 왼쪽 App menu는 노출하지 않는다
- 오른쪽 Menu bar extras만 두고, 아이콘을 누르면 메뉴가 펼쳐진다

| 목록 | 단축키 | 동작 |
| --- | --- | --- |
| Enable Click… | 단축키 없음 | 접근성 권한이 없을 때만 나타남 — 시스템 설정의 손쉬운 사용 패널을 연다 |
| Open at Login | 단축키 없음 | 로그인 시 자동 실행을 켜고 끈다 |
| Move Pointer | ⌃⌥C | 다음 모니터의 중앙으로 |
| Settings… | 단축키 없음 | 설정 창을 연다 |
| Import Settings… | 단축키 없음 | 설정 파일을 가져온다 |
| Export Settings… | 단축키 없음 | 설정 파일로 내보낸다 |
| Quit | ⌘Q | 앱 종료 |

## 기능

- **모니터 간 이동** (⌃⌥C): 누를 때마다 다음 모니터의 중앙으로 이동한다
- **방향 이동** (⌃⌥ + IJKL): 누르고 있는 동안 가속하며 이동한다
- **조금만 움직이기** (⌃⌥⌘ + IJKL): 일정한 속도로 천천히 이동한다
- **클릭** (⌃⌥X · ⌃⌥V): 커서 위치에 왼쪽 · 오른쪽 클릭. 누르고 있으면 드래그한다
    - 접근성 권한이 필요하다
- **Open at Login**: 로그인 시 앱을 자동 실행한다
- 단축키는 다른 앱을 쓰는 중에도 어디서나 동작한다

## 설정

- **Shortcuts**: 단축키를 바꾸고, 단축키마다 예외 앱을 지정한다
- **Pointer Speed**: 방향 이동의 속도 곡선과 조금만 움직이기의 속도를 바꾼다
- **Import · Export**: 설정을 `.telepointer` 파일로 내보내고 가져온다

## 관련 문서

- [Tasks.md](./Tasks.md) — v1.0 작업 목록
- [Architecture.md](../Architecture.md) — 모듈 구조와 결정 근거
- [Backlog.md](../Backlog.md) — 미분류 항목
- [Notes.md](../Notes.md) — 작업 중 남긴 기록과 채택하지 않은 대안
