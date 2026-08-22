# 작업 목록 v2

요구사항은 [Requirements.md](./Requirements.md), 모듈 구조는 [Architecture.md](../Architecture.md),
미분류 항목은 [Backlog.md](../Backlog.md), 작업 기록과 채택하지 않은 대안은 [Notes.md](../Notes.md) 참고.

## 1. 방향 이동

- [x] 이동 거리 결정 — 거리 대신 속도로. 400 → 2800pt/s, 0.4초 ease-in
- [x] 화면 경계 처리 결정 — 화면 안에 가둔다. 이어지는 구간에서는 인접 모니터로 넘어간다
- [x] 기본 단축키 조합 결정 — ⌃⌥ + IJKL
    - [ ] 4개 조합이 서로, 그리고 ⌃⌥⌘C와 충돌하지 않는지
    - [ ] ⌃⌥J · ⌃⌥K는 [Notes.md](../Notes.md) 후보표에 VS Code와 겹친다고 적어둔 조합 — 유지할지 결정
- [x] `KeyboardShortcuts.Name` 4개 정의 (상 · 하 · 좌 · 우)
- [x] 현재 좌표 + 방향 → 목표 좌표를 계산하는 순수 함수
    - [x] 단위 테스트 — `warpFrame` · `clamped` · `normalizedVector` · `rampedSpeed`
- [x] 핫키 핸들러 등록 — keyDown → `press`, keyUp → `release`
- [x] 연속 warp 중 물리 마우스가 먹통이 되는 것 확인 — 억제를 그대로 둔다 ([Notes.md](../Notes.md)) 구간
- [ ] modifier를 먼저 떼거나 앱 전환이 끼어들어도 커서가 멈추는지 확인

## 2. 왼쪽 클릭 스파이크

결과에 따라 기능 범위와 배포 경로가 바뀌므로 먼저 끝낸다.

- [ ] 샌드박스 빌드에서 `CGEvent.post`로 왼쪽 클릭이 실제로 발생하는지 확인
    - [ ] mouseDown / mouseUp 한 쌍을 보내야 클릭으로 인식되는지
- [ ] 접근성 권한 프롬프트가 뜨는 시점 확인 (`AXIsProcessTrustedWithOptions`)
- [ ] 권한 없이 실행하면 조용히 무시되는지 확인 — 실패를 사용자에게 알릴 방법 결정
- [ ] entitlement 추가가 필요한지 확인
- [ ] 접근성 권한을 쓰는 앱이 Mac App Store에 올라갈 수 있는지 조사
- [ ] 결과를 [Notes.md](../Notes.md)에 기록하고 Requirements의 「왼쪽 클릭」 범위 확정
- [ ] 확정된 범위대로 구현 (스파이크 결과에 따라 세부 작업 다시 나눔)

## 3. 모니터 간 이동

v1의 `PointerMover.moveToScreenCenter()`를 대체한다.

- [ ] `NSScreen.screens`를 `frame.origin.x` 기준으로 정렬하는 순수 함수
- [ ] 커서가 현재 화면의 중앙에 있는지 판정하는 순수 함수
    - [ ] **허용 오차 결정** — 정확히 일치를 요구하면 스케일·좌표 변환 오차로 판정이 어긋난다
- [ ] 다음 화면 선택 + 마지막에서 첫 화면으로 순환
- [ ] 모니터가 하나면 항상 그 화면의 중앙 (v1과 동일)
- [ ] 위 세 함수의 단위 테스트 (`PointerCoreTests`)
- [ ] `PointerMover`에 연결 — 커서 좌표 조회는 `NSEvent.mouseLocation`
- [ ] 메뉴의 Move Pointer 항목도 동일 동작 (핫키와 로직 공유)

## 4. 설정 창

- [ ] 설정 창을 어느 모듈에 둘지 결정 — `MenuBar`에 넣을지 새 모듈로 뺄지
    - [ ] 결정 근거를 [Architecture.md](../Architecture.md)에 반영
- [ ] 메뉴에 `Keyboard Shortcuts...` 항목 추가 (위치 결정)
- [ ] `Window` scene + `openWindow`로 창 띄우기
    - [ ] `Settings` scene은 App menu가 없으면 ⌘, 로만 열리므로 쓰지 않는다
- [ ] `LSUIElement` 앱이라 창이 다른 앱 뒤에 뜬다 — `NSApp.activate()`로 앞에 올리기
    - [ ] 창을 닫은 뒤 앱을 다시 비활성으로 되돌릴지 결정
- [ ] `KeyboardShortcuts.Recorder`로 단축키 수정 UI 배치
    - [ ] 입력 즉시 저장됨 (`KeyboardShortcuts`가 UserDefaults에 바로 쓴다)
- [ ] 방향키 4개를 십자 배치로 표현
- [ ] 전체 초기화 버튼 — `KeyboardShortcuts.reset(...)`
- [ ] 완료 버튼 = 창 닫기
- [ ] 창을 두 번 열어도 하나만 뜨는지 확인
- [ ] v1 Requirements의 메뉴 3항목 표 갱신

## 5. App Store 제출 준비

v1에서 이관.

- [ ] `AppIcon.appiconset` 에셋 추가 (현재 비어 있음)
- [ ] 코드 서명 팀 / provisioning profile 설정
- [ ] App Store Connect에 앱 등록
- [ ] 스크린샷 · 앱 설명 · 개인정보 처리방침 URL 준비

## 6. 검증

v1에서 이관.

- [ ] Dock 아이콘 미노출 확인
- [ ] 메뉴바 좌측 App menu 미노출 확인
- [ ] 멀티 디스플레이 — 커서가 있는 화면의 중앙으로 이동하는지
- [ ] 다른 앱 포커스 상태에서 핫키 동작 확인 (부작용 없이 커서만 이동)
- [ ] 샌드박스 빌드에서 핫키·커서 이동 동작 확인
- [ ] 커서 이동 직후 hover가 갱신되지 않는 것이 수용 가능한 수준인지 확인
- [ ] **Open at Login은 `/Applications`에 설치 후 검증** — Xcode DerivedData에서 실행하면 `notFound` 반환
- [ ] 시스템 설정에서 로그인 항목을 끈 뒤 메뉴를 다시 열면 체크가 풀리는지
