# 작업 목록

요구사항은 [Requirements.md](./Requirements.md), 모듈 구조는 [Architecture.md](../Architecture.md),
v1 이후 항목은 [Backlog.md](../Backlog.md), 작업 기록과 채택하지 않은 대안은 [Notes.md](../Notes.md) 참고.

## 1. 프로젝트 설정

`Project.swift` / `Tuist/Package.swift`

- [x] `deploymentTargets: .macOS("26.0")` 추가 (현재 미설정)
    - [x] 앱·테스트 두 타깃 모두 지정 (한쪽만 올리면 어긋남)
- [x] `bundleId`를 `dev.tuist.TelePointer` → `com.taeminyun.TelePointer`로 변경
- [x] 테스트 타깃 `bundleId`도 `dev.tuist.TelePointerTests` → `com.taeminyun.TelePointerTests`로 변경
- [x] `infoPlist`를 `.default` → 커스텀으로 교체
    - [x] `LSUIElement = true` 추가 (Dock 아이콘·App menu 숨김)
    - [x] 템플릿 잔재인 `NSMainStoryboardFile: Main` 제거 (SwiftUI 앱에 불필요)
- [x] App Sandbox entitlements 추가 (`com.apple.security.app-sandbox`)
- [x] Swift 6 strict concurrency 설정 명시
- [x] KeyboardShortcuts 3.0.1 의존성 추가
- [x] `tuist install` → `tuist generate`로 반영 확인

## 2. 모듈 구조

[Architecture.md](../Architecture.md)에 결정 근거 정리.

- [x] `App` / `Features` / `Core` 계층으로 디렉터리 재배치
- [x] `MenuBar`·`PointerCore`·`LaunchAtLogin` 세 모듈을 `staticFramework`로 분리
    - [x] 커서 이동(`PointerCore`)과 로그인 항목(`LaunchAtLogin`)은 별도 모듈
- [x] `Project.swift`에 모듈 타깃 헬퍼 추가 (단일 파일 유지)
- [x] `KeyboardShortcuts` 의존을 앱 → `MenuBar`로 이동
- [x] 테스트 타깃을 `PointerCoreTests`로 교체 — test host 없이 실행
- [x] 템플릿 잔재 `Preview Content` 제거
- [x] `tuist graph`로 의존 방향이 단방향인지 확인

## 3. 앱 골격

- [x] `TelePointerApp.swift`의 `WindowGroup` → `MenuBarExtra` + `.menuBarExtraStyle(.menu)`로 교체
- [x] 메뉴바 아이콘 설정 (SF Symbol `cursorarrow.rays`)
- [x] `ContentView.swift` 제거 (템플릿 잔재)
- [x] 메뉴 3개 항목 배치: Move Pointer / Open at Login / Quit

## 4. Move Pointer

- [x] 현재 커서가 위치한 `NSScreen` 판별
    - [x] 어느 화면에도 속하지 않으면 주 디스플레이로 폴백 (`nil`이면 조용히 아무 일도 안 일어남)
- [x] `NSScreen.frame` 정중앙 좌표 계산
- [x] **좌표계 변환** — `NSScreen`은 좌하단 원점, `CGWarpMouseCursorPosition`은 좌상단 원점
- [x] 화면 중앙 계산 + 좌표계 변환을 순수 함수로 분리
- [x] 분리한 함수의 단위 테스트 작성 (템플릿 `TelePointerTests.swift` 대체)
- [x] `CGWarpMouseCursorPosition`으로 이동 (애니메이션 없이 즉각)
- [x] KeyboardShortcuts `Name` 정의 + 기본값 `⌃⌥⌘C` 지정
- [x] 앱 시작 시 핫키 핸들러 등록
- [x] 메뉴 항목 클릭 시에도 동일 동작 실행 (핫키와 로직 공유)

## 5. Open at Login

- [x] `SMAppService.mainApp` 등록/해제 토글
    - [x] `register()` / `unregister()`는 `throws` — 실패 시 처리 정의
- [x] 체크 상태를 `SMAppService.mainApp.status`에서 직접 조회 (UserDefaults 미사용)
- [x] 메뉴가 열릴 때마다 status 재조회 — 사용자가 시스템 설정에서 직접 끈 경우 반영
- [x] `.requiresApproval` 상태 처리 (시스템 설정으로 안내)
- [x] `.notFound`는 앱이 `/Applications`에 없을 때도 나오므로 오류로 취급하지 말 것

## 6. Quit

- [x] 메뉴 항목 + ⌘Q 키 이퀴벌런트 연결
- [x] 메뉴가 열려 있을 때만 동작함을 확인 (전역 가로채기 아님)

## 7. App Store 제출 준비

- [ ] `AppIcon.appiconset` 에셋 추가 (현재 비어 있음)
- [ ] 코드 서명 팀 / provisioning profile 설정
- [ ] App Store Connect에 앱 등록
- [ ] 스크린샷 · 앱 설명 · 개인정보 처리방침 URL 준비

## 8. 검증

- [ ] Dock 아이콘 미노출 확인
- [ ] 메뉴바 좌측 App menu 미노출 확인
- [ ] 멀티 디스플레이 — 커서가 있는 화면의 중앙으로 이동하는지
- [ ] 다른 앱 포커스 상태에서 핫키 동작 확인 (부작용 없이 커서만 이동)
- [ ] 샌드박스 빌드에서 핫키·커서 이동 동작 확인
- [ ] 커서 이동 직후 hover가 갱신되지 않는 것이 수용 가능한 수준인지 확인
- [ ] **Open at Login은 `/Applications`에 설치 후 검증** — Xcode DerivedData에서 실행하면 `notFound` 반환
- [ ] 시스템 설정에서 로그인 항목을 끈 뒤 메뉴를 다시 열면 체크가 풀리는지
