# 작업 목록 v3

모듈 구조는 [Architecture.md](../Architecture.md), 미분류 항목은 [Backlog.md](../Backlog.md),
작업 기록과 채택하지 않은 대안은 [Notes.md](../Notes.md) 참고.

## 1. 조금만 움직이기

- [x] 조작 방식 결정 — 방향 단축키에 보조 modifier를 얹을지, 단축키를 따로 둘지
- [x] 이동량 결정 — 누를 때마다 고정 거리인지, 속도 곡선을 배율로 눌러 쓰는지
- [x] `DirectionalMover`에 어떻게 얹을지 — `press`의 인자인지 별도 진입점인지
- [x] 설정에 노출할지 결정 — 노출한다면 어느 창에 두는지
- [x] 드래그 중에도 같은 방식으로 동작하는지 확인
- [x] 새 단축키가 기존 7개, 그리고 다른 앱과 충돌하지 않는지
- [x] 단위 테스트 (`PointerCoreTests`)

## 2. 설정 export/import

- [x] 내보낼 범위 결정 — 단축키 + `SpeedCurve` + `SteadySpeed`. Open at Login 같은 시스템 상태는 뺀다
- [x] 파일 형식 결정 — JSON, 확장자는 `.json`. 버전 필드와 전용 UTType은 두지 않는다
- [x] 단축키를 읽고 쓰는 경로 확인 — `KeyboardShortcuts.getShortcut(for:)` · `setShortcut(_:for:)`
    - [x] `setShortcut`이 핫키 해제 · 저장 · 재등록과 Recorder 갱신 알림까지 한다
    - [x] `Shortcut`은 `Codable` — `carbonKeyCode` · `carbonModifiers`로 인코딩된다
- [x] 직렬화 타입은 `Settings`에 둔다 — `KeyboardShortcuts` 의존을 Feature 모듈 밖으로 내보내지 않는다
    - [ ] 테스트 타깃 `SettingsTests`를 새로 만든다 (`PointerCore`는 `Settings`를 볼 수 없다)
- [x] 가져오기 실패 처리 결정 — 범위를 벗어난 값은 허용 범위 안으로 조여서 받는다
    - [x] 일부 항목만 든 파일은 빠진 항목을 그대로 둔다
    - [x] 아는 항목이 하나도 없는 파일은 실패로 알린다 — 형식을 가릴 표식이 이것뿐이다
- [x] 메뉴바 메뉴에 Import · Export — `NSOpenPanel` · `NSSavePanel`을 직접 띄운다
- [x] 샌드박스에 `com.apple.security.files.user-selected.read-write` 추가 (`Project.swift`)
- [ ] 가져온 뒤 재시작 없이 반영되는지 확인 — 핫키 재등록, 열려 있는 설정 창
- [ ] 단위 테스트 (`SettingsTests`) — 인코딩 · 디코딩 왕복, 손상된 파일

## 3. App Store 제출 준비

v1 → v2를 거쳐 이관.

- [ ] `AppIcon.appiconset` 에셋 추가 (현재 비어 있음)
- [ ] 코드 서명 팀 / provisioning profile 설정
- [ ] App Store Connect에 앱 등록
- [ ] 스크린샷 · 앱 설명 · 개인정보 처리방침 URL 준비

## 4. 검증

v1 → v2를 거쳐 이관.

- [ ] Dock 아이콘 미노출 확인
- [ ] 메뉴바 좌측 App menu 미노출 확인
- [ ] 멀티 디스플레이 — 커서가 있는 화면의 중앙으로 이동하는지
- [ ] 다른 앱 포커스 상태에서 핫키 동작 확인 (부작용 없이 커서만 이동)
- [ ] 샌드박스 빌드에서 핫키·커서 이동 동작 확인
- [ ] 릴리스 서명(Developer ID 또는 App Store)에서도 접근성 권한이 유지되는지 확인
- [ ] 커서 이동 직후 hover가 갱신되지 않는 것이 수용 가능한 수준인지 확인
- [ ] **Open at Login은 `/Applications`에 설치 후 검증** — Xcode DerivedData에서 실행하면 `notFound` 반환
- [ ] 시스템 설정에서 로그인 항목을 끈 뒤 메뉴를 다시 열면 체크가 풀리는지
