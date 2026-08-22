# 모듈 구조

## 그래프

```
TelePointer (app)
  └─ MenuBar (staticFramework)
       ├─ Settings (staticFramework)
       │    └─ KeyboardShortcuts (external)
       ├─ KeyboardShortcuts (external)
       ├─ PointerCore (staticFramework)
       │    └─ PointerCoreTests (unitTests)
       └─ LaunchAtLogin (staticFramework)
```

| 모듈 | 책임 |
| --- | --- |
| `TelePointer` | `@main`, `MenuBarExtra` Scene 선언, 앱 리소스(AppIcon) |
| `MenuBar` | 메뉴 UI, 핫키 등록 |
| `Settings` | 설정 창 UI, 단축키 `Name`과 기본값 정의 |
| `PointerCore` | 좌표 계산(순수), 커서 이동, 방향 이동 홀드 루프 |
| `LaunchAtLogin` | 로그인 항목 조회·토글 |

## 디렉터리

```
TelePointer/
├── App/
│   ├── Sources/
│   └── Resources/
├── Features/
│   ├── MenuBar/Sources/
│   └── Settings/Sources/
└── Core/
    ├── PointerCore/
    │   ├── Sources/
    │   └── Tests/
    └── LaunchAtLogin/
        └── Sources/
```

## 결정 근거

### 왜 나눴나

앱 타깃에 의존하는 유닛 테스트는 test host를 요구한다.
`LSUIElement = true`인 메뉴바 앱을 host로 띄우는 건 느리고, 좌표 변환처럼 화면과 무관한 순수 로직을 검증하는 데
앱 실행이 끼어들 이유가 없다. `PointerCore`를 앱과 분리하면 `PointerCoreTests`가 host 없이 돈다.

부수적으로 `KeyboardShortcuts` 의존이 앱 전체가 아니라 `MenuBar`에만 걸리고,
백로그의 설정 창 · 단축키 변경 UI · 한국어 지원이 들어올 자리가 정해진다.

### 왜 staticFramework인가

App Store 배포에서 dylib 임베드·서명 단계가 생기지 않고, 메뉴바 앱의 실행 시간에 유리하다.
두 모듈 모두 자체 리소스가 없어 리소스 번들이 늘어나지도 않는다.

`KeyboardShortcuts`는 로컬라이제이션 리소스를 갖고 있어 Tuist가 별도 번들을 만든다.
`App → MenuBar → KeyboardShortcuts`로 한 단계 건너뛰지만 앱 번들의 `Contents/Resources`에 정상 임베드된다.

### 왜 `PointerCore`와 `LaunchAtLogin`을 나눴나

커서 이동과 로그인 항목은 공유하는 상태도 호출 관계도 없다.
한 모듈에 두면 `Move Pointer`를 고치는 동안 `SMAppService` 코드가 함께 컴파일되고,
모듈 이름이 어느 한쪽만 가리키게 된다.

`LaunchAtLogin`에는 순수 로직이 없어 — 상태가 앱이 아니라 시스템에 있다 — 테스트 타깃을 두지 않는다.
`PointerCore`만 `PointerCoreTests`를 갖는다.

### 왜 설정 창을 새 모듈로 뺐나

메뉴는 항목 몇 개로 끝나지만 설정 창은 Recorder · 방향키 십자 배치 · 초기화를 담은 화면 하나다.
`MenuBar`에 넣으면 모듈 이름이 내용을 가리키지 못한다.

단축키 `Name`도 창을 따라 `Settings`로 옮겼다. `KeyboardShortcuts.Recorder(for:)`가 `Name`을 그대로 받고,
`initial:`의 기본값도 초기화 버튼이 되돌리는 대상이라 소유자가 설정 쪽이다.
`MenuBar`는 그 `Name`을 읽어 핫키를 등록하고 메뉴에 글리프를 표시한다 — `MenuBar → Settings` 방향.

### 의존 방향

`App → MenuBar → {Settings, PointerCore, LaunchAtLogin}` 단방향. 역방향과 우회 경로를 만들지 않는다.

- `App`은 Core 모듈을 직접 참조하지 않는다 — `MenuBar`를 거친다
- `PointerCore`와 `LaunchAtLogin`은 서로를 참조하지 않는다
- Core 모듈은 SwiftUI를 쓰지 않는다
- `KeyboardShortcuts`는 Feature 모듈 밖으로 노출하지 않는다 — Core 모듈과 `App`은 모른다

`tuist graph --format dot`으로 확인할 수 있다.

## 모듈 경계의 비용

`staticFramework`로 나뉜 만큼 모듈 밖에서 쓰는 심볼에는 `public`이 필요하다.
`SWIFT_STRICT_CONCURRENCY: complete`이므로 public API는 격리를 명시한다 —
`NSScreen`을 읽는 코드는 `@MainActor`, 순수 계산 함수는 격리하지 않는다.

`@testable import`는 internal까지 보므로 테스트를 위해 `public`을 붙일 일은 없다.

## 관련 문서

- [Requirements.md](./v1/Requirements.md) — v1 요구사항
- [Tasks.md](./v1/Tasks.md) — v1 구현 작업 목록
