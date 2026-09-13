# 모듈 구조

## 그래프

```
TelePointer (app)
  └─ MenuBar (staticFramework)
       ├─ Settings (staticFramework)
       │    ├─ PointerCore (staticFramework)
       │    ├─ KeyboardShortcuts (external)
       │    └─ SettingsTests (unitTests)
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
| `PointerCore` | 좌표 계산(순수), 커서 이동, 방향 이동 홀드 루프, 속도 값과 그 저장 |
| `LaunchAtLogin` | 로그인 항목 조회·토글 |

## 디렉터리

```
TelePointer/
├── App/
│   ├── Sources/
│   └── Resources/
├── Features/
│   ├── MenuBar/Sources/
│   └── Settings/
│       ├── Sources/
│       └── Tests/
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

### 왜 속도 값은 `Settings`가 아니라 `PointerCore`에 두나

단축키 `Name`은 기본값까지 `Settings`가 갖는다. 속도는 반대다 —
`base` · `peak` · `rampDuration`은 홀드 루프가 매 tick 읽는 물리량이고, 기본값 400 → 2800pt/s는
설정 화면이 아니라 이동 동작이 정하는 값이다. `Settings`에 두면 `PointerCore`가 자기 기본값을
모르는 상태가 되어 화면 없이 테스트할 수 없다.

그래서 `SpeedCurve`(값 · 기본값 · 허용 범위 · 계산)와 `SpeedStore`(UserDefaults 저장)를
`PointerCore`가 갖고, `Settings`는 그 값을 슬라이더에 바인딩만 한다 — `Settings → PointerCore` 방향.
저장 키는 `SpeedStore` 안에 감춰 화면이 키 이름을 알지 못하게 한다.

일정 속도(`SteadySpeed`)도 같은 이유로 `PointerCore`에 둔다. 다만 `SpeedCurve`의 필드로 넣지 않고
`SpeedStore`가 저장 키를 따로 갖는다. 곡선 위의 점이 아니라 곡선을 통째로 대신하는 상수이고,
`SpeedCurve`는 `Codable`이라 필드를 더하면 이미 저장된 JSON이 디코딩에 실패해 기본값으로 돌아간다.

두 값 모두 press 시점에 한 번 읽는다. 누르고 있는 도중에 설정을 바꿔도 그 이동은 원래 값으로 끝난다.

### 왜 설정 파일 타입이 `Settings`에 있나

내보내는 파일은 단축키와 속도를 함께 담는다. 단축키는 `KeyboardShortcuts.Shortcut`을 그대로 직렬화하는데,
그 의존은 Feature 모듈 밖으로 내보내지 않기로 했으므로 타입이 앉을 자리는 `Settings`뿐이다.
`PointerCore`로 내리려면 `Shortcut`을 대신할 표현을 따로 만들어야 하고, 커서를 움직이는 모듈이 단축키를 알게 된다.

`PointerCore`는 `Settings`를 볼 수 없어 `PointerCoreTests`로는 이 타입을 검증할 수 없다. `SettingsTests`를 따로 둔 이유다.

### 의존 방향

`App → MenuBar → {Settings, PointerCore, LaunchAtLogin}`, `Settings → PointerCore` 단방향.
역방향과 우회 경로를 만들지 않는다.

- `App`은 Core 모듈을 직접 참조하지 않는다 — `MenuBar`를 거친다
- `PointerCore`와 `LaunchAtLogin`은 서로를 참조하지 않는다
- Core 모듈은 SwiftUI를 쓰지 않는다 — `Observation`은 쓴다
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
