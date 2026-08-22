# 작업 목록 v2

요구사항은 [Requirements.md](./Requirements.md), 모듈 구조는 [Architecture.md](../Architecture.md),
미분류 항목은 [Backlog.md](../Backlog.md), 작업 기록과 채택하지 않은 대안은 [Notes.md](../Notes.md) 참고.

## 1. 방향 이동

- [x] 이동 거리 결정 — 거리 대신 속도로. 400 → 2800pt/s, 0.4초 ease-in
- [x] 화면 경계 처리 결정 — 화면 안에 가둔다. 이어지는 구간에서는 인접 모니터로 넘어간다
- [x] 기본 단축키 조합 결정 — ⌃⌥ + IJKL
    - [ ] 7개 조합(방향 4 + 클릭 2 + 이동 1)이 서로, 그리고 다른 앱과 충돌하지 않는지
    - [ ] ⌃⌥J · ⌃⌥K는 [Notes.md](../Notes.md) 후보표에 VS Code와 겹친다고 적어둔 조합 — 유지할지 결정
- [x] `KeyboardShortcuts.Name` 4개 정의 (상 · 하 · 좌 · 우)
- [x] 현재 좌표 + 방향 → 목표 좌표를 계산하는 순수 함수
    - [x] 단위 테스트 — `warpFrame` · `clamped` · `normalizedVector` · `rampedSpeed`
- [x] 핫키 핸들러 등록 — keyDown → `press`, keyUp → `release`
- [x] 연속 warp 중 물리 마우스가 먹통이 되는 것 확인 — 억제를 그대로 둔다 ([Notes.md](../Notes.md)) 구간
- [ ] modifier를 먼저 떼거나 앱 전환이 끼어들어도 커서가 멈추는지 확인

## 2. 클릭

스파이크 결과는 [Notes.md](../Notes.md), 확정된 범위는 [Requirements.md](./Requirements.md)의 「클릭」 참고.

- [x] 샌드박스 빌드에서 `CGEvent.post`로 왼쪽 클릭이 실제로 발생하는지 확인
    - [x] mouseDown / mouseUp 한 쌍을 보내야 클릭으로 인식되는지
- [x] 접근성 권한 프롬프트가 뜨는 시점 확인 — 앱이 띄우는 경로는 샌드박스에서 막히고, `CGEvent.post`가 TCC 프롬프트를 유발한다
- [x] 권한 없이 실행하면 조용히 무시되는지 확인 — 실패를 사용자에게 알릴 방법 결정
- [x] entitlement 추가가 필요한지 확인 — 불필요
- [x] 접근성 권한을 쓰는 앱이 Mac App Store에 올라갈 수 있는지 조사 — 확답 없음, 위험을 안고 MAS 유지
- [x] 결과를 [Notes.md](../Notes.md)에 기록하고 Requirements의 「클릭」 범위 확정
- [x] 왼쪽 · 오른쪽 클릭 구현 (⌃⌥U · ⌃⌥O)
- [x] 온보딩 전 과정 검증 — 프롬프트 → 목록 등록 → 토글 → 클릭 동작 → 재시작 후 메뉴 항목 사라짐
- [ ] `clickState`를 순수 함수로 분리하고 `PointerCoreTests`에 단위 테스트 추가
- [ ] 릴리스 서명(Developer ID 또는 App Store)에서도 권한이 유지되는지 확인

## 3. 드래그

클릭을 홀드 방식으로 바꾸면 짧게 누르는 것이 곧 클릭이 된다.

- [x] 클릭 단축키를 `onKeyDown` → mouseDown, `onKeyUp` → mouseUp으로 분리
    - [x] 짧게 눌렀을 때 클릭으로 인식되는지 — 더블·트리플 클릭 카운트가 유지되는지
- [x] `PointerMover`가 눌린 버튼을 들고 있게 한다
- [x] 드래그 중 방향 이동은 warp 대신 `mouseDragged`를 보낸다
    - [x] `DirectionalMover`는 드래그를 몰라도 된다 — `PointerMover.move(to:)` 안에서 갈라진다
- [x] 홀드 판정을 하드웨어 키 상태로 바꾼다 — 합성 이벤트가 `NSEvent.modifierFlags`를 지운다
    - [x] 방향 이동도 같은 이유로 함께 고친다
- [x] **안전장치와의 관계 결정** — modifier가 풀리면 버튼도 뗀다. 시간 제한은 두지 않는다
- [x] 기본 단축키를 방향키와 매트릭스가 겹치지 않는 곳으로 — ⌃⌥X · ⌃⌥C · ⌃⌥V
- [ ] 앱이 종료될 때 눌린 버튼을 떼는지 확인
- [x] 창 옮기기 · 텍스트 선택 · 드래그 앤 드롭 각각 동작 확인
- [x] 바뀐 단축키가 서로, 그리고 다른 앱과 충돌하지 않는지 (1번의 충돌 검증에 포함)

## 4. 모니터 간 이동

v1의 `PointerMover.moveToScreenCenter()`를 대체한다.

- [ ] `NSScreen.screens`를 `frame.origin.x` 기준으로 정렬하는 순수 함수
- [ ] 커서가 현재 화면의 중앙에 있는지 판정하는 순수 함수
    - [ ] **허용 오차 결정** — 정확히 일치를 요구하면 스케일·좌표 변환 오차로 판정이 어긋난다
- [ ] 다음 화면 선택 + 마지막에서 첫 화면으로 순환
- [ ] 모니터가 하나면 항상 그 화면의 중앙 (v1과 동일)
- [ ] 위 세 함수의 단위 테스트 (`PointerCoreTests`)
- [ ] `PointerMover`에 연결 — 커서 좌표 조회는 `NSEvent.mouseLocation`
- [ ] 메뉴의 Move Pointer 항목도 동일 동작 (핫키와 로직 공유)

## 5. 설정 창

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

## 6. App Store 제출 준비

v1에서 이관.

- [ ] `AppIcon.appiconset` 에셋 추가 (현재 비어 있음)
- [ ] 코드 서명 팀 / provisioning profile 설정
- [ ] App Store Connect에 앱 등록
- [ ] 스크린샷 · 앱 설명 · 개인정보 처리방침 URL 준비

## 7. 검증

v1에서 이관.

- [ ] Dock 아이콘 미노출 확인
- [ ] 메뉴바 좌측 App menu 미노출 확인
- [ ] 멀티 디스플레이 — 커서가 있는 화면의 중앙으로 이동하는지
- [ ] 다른 앱 포커스 상태에서 핫키 동작 확인 (부작용 없이 커서만 이동)
- [ ] 샌드박스 빌드에서 핫키·커서 이동 동작 확인
- [ ] 커서 이동 직후 hover가 갱신되지 않는 것이 수용 가능한 수준인지 확인
- [ ] **Open at Login은 `/Applications`에 설치 후 검증** — Xcode DerivedData에서 실행하면 `notFound` 반환
- [ ] 시스템 설정에서 로그인 항목을 끈 뒤 메뉴를 다시 열면 체크가 풀리는지
