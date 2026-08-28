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

- [x] `NSScreen.screens`를 `frame.origin.x` 기준으로 정렬하는 순수 함수
- [x] 커서가 놓인 화면의 다음 화면 선택 + 마지막에서 첫 화면으로 순환
    - [x] 어느 화면에도 속하지 않는 좌표는 가장 가까운 화면으로 ([Notes.md](../Notes.md))
    - [x] **중앙 판정은 두지 않는다** — 누를 때마다 넘어간다 ([Notes.md](../Notes.md))
- [x] 모니터가 하나면 항상 그 화면의 중앙 (v1과 동일)
- [x] 위 두 함수의 단위 테스트 (`PointerCoreTests`)
- [x] `PointerMover`에 연결 — 커서 좌표 조회는 `NSEvent.mouseLocation`
- [x] 메뉴의 Move Pointer 항목도 동일 동작 (핫키와 로직 공유)

## 5. 설정 창

- [x] 설정 창을 어느 모듈에 둘지 결정 — 새 `Settings` 모듈. 단축키 `Name`도 함께 옮긴다
    - [x] 결정 근거를 [Architecture.md](../Architecture.md)에 반영
- [x] 메뉴에 `Keyboard Shortcuts...` 항목 추가 — Open at Login 다음, Quit 구분선 위
- [x] `Window` scene + `openWindow`로 창 띄우기
    - [x] `Settings` scene은 App menu가 없으면 ⌘, 로만 열리므로 쓰지 않는다
    - [x] 실행 직후 창이 뜨지 않도록 `.defaultLaunchBehavior(.suppressed)` ([Notes.md](../Notes.md))
- [x] `LSUIElement` 앱이라 창이 다른 앱 뒤에 뜬다 — `NSApp.activate()`로 앞에 올리기
    - [x] 창을 닫은 뒤 앱을 다시 비활성으로 되돌릴지 결정 — 되돌린다. `NSApp.hide(nil)`
- [x] `KeyboardShortcuts.Recorder`로 단축키 수정 UI 배치
    - [x] 입력 즉시 저장됨 (`KeyboardShortcuts`가 UserDefaults에 바로 쓴다) — 재시작 없이 바로 먹는다
    - [x] 창이 다른 앱 뒤로 숨지 않도록 `.windowLevel(.floating)` ([Notes.md](../Notes.md))
- [x] 방향키 4개를 십자 배치로 표현 — `Grid` 3열, Recorder 폭은 120pt 고정
- [x] 전체 초기화 버튼 — `KeyboardShortcuts.reset(...)`. `resetAll()`은 삭제라 쓰지 않는다 ([Notes.md](../Notes.md))
- [x] 완료 버튼 = 창 닫기
    - [x] 신호등 버튼(닫기 · 최소화 · 확대)을 어디까지 없앨지 함께 결정 —
      셋 다 `standardWindowButton(_:)?.isHidden`으로 감춘다
- [x] 창을 두 번 열어도 하나만 뜨는지 확인
- [x] v1 Requirements의 메뉴 3항목 표 갱신

## 6. 속도 설정

[Backlog.md](../Backlog.md)의 「포인터 속도 관련 함수」에서 옮겨왔다.

- [x] 속도 값을 어느 모듈이 갖는지 결정 — `PointerCore`. 근거는 [Architecture.md](../Architecture.md)
- [x] `SpeedCurve` — base · peak · rampDuration + 허용 범위 + 기본값
- [x] `SpeedStore` — UserDefaults 저장, 슬라이더를 놓는 즉시 반영
    - [x] 범위를 벗어난 저장값은 읽을 때 당겨온다
    - [x] 단위 테스트 (`SpeedStoreTests`)
- [x] `DirectionalMover.Tuning`에서 속도 3개를 떼어내고 press 시점에 곡선을 읽는다
- [x] 설정 창에 Speed 섹션 — 슬라이더 3개, Restore Defaults가 속도까지 되돌린다
- [x] ~~설정 창을 두 칸으로~~ → 창을 나눴다. `Speed`가 자기 창과 메뉴 항목을 갖는다
    - 메뉴에서 `Keyboard Shortcuts…` 바로 아래
    - 창 성질(타이틀 바 없음 · 내용 크기 고정 · floating)은 `Scene.settingsWindow()`로 공유
- [x] 두 속도가 서로의 벽이 되게 — 슬라이더 범위를 상대 값으로 좁힌다
    - `normalized()`는 어느 값이 움직였는지 모르므로 대칭을 만들 수 없다.
      조작 중 규칙은 슬라이더가, 저장된 값의 안전망은 `normalized()`가 맡는다
- [ ] 실제 창에서 레이아웃 확인 — 두 칸의 높이 차이, 슬라이더와 수치가 잘리지 않는지
- [x] 이징 곡선을 3차 베지어로 — `SpeedEasing`, 제어점 2개
    - [x] 기본값은 지금의 `progress²`와 같은 (1/3, 0, 2/3, 1/3)
    - [x] x는 t의 3차식이라 역함수가 없다 — Newton-Raphson + 이분법으로 t를 찾는다
    - [x] 단위 테스트 (`SpeedEasingTests`) — 기본값이 `progress²`와, 대각선이 선형과 일치하는지
- [x] 저장을 키 3개에서 Codable 한 덩어리로 — 이징 4개를 키로 늘리지 않는다
- [x] 속도 그래프 — x축 시간, y축 속도
    - [x] 램프 구간이 그대로 3차 베지어라 `addCurve` 한 번으로 그린다 — 샘플링하지 않는다
    - [x] 드래그는 제어점 2개만 — base · peak · rampDuration은 슬라이더가 소유한다
    - [x] 슬라이더를 움직이면 곡선도 따라온다 — 같은 값을 본다
    - [x] 축을 세 값에 맞춰 늘린다 — 시간축 `0…rampDuration`, 속도축 `base…peak`.
      곡선의 양 끝이 좌측 하단 · 우측 상단 모서리에 닿는다
    - [x] 눈금 간격을 축 구간에서 고른다 (1 · 2 · 5 × 10ⁿ) — 양 끝은 반올림하지 않는다
        - [x] 2.5배 간격은 버렸다 — 시간축에서 0.025 위치를 「0.02」로 표시했다
        - [x] peak을 base까지 내리면 속도 구간이 0 — 0으로 나누지 않게 막았다
- [ ] 그래프 조작감 확인 — 제어점 잡기, 슬라이더를 움직일 때 축이 변하는 느낌
- [x] 임시로 넣은 「실행하자마자 설정 창」 되돌리기

## 7. App Store 제출 준비

v1에서 이관.

- [ ] `AppIcon.appiconset` 에셋 추가 (현재 비어 있음)
- [ ] 코드 서명 팀 / provisioning profile 설정
- [ ] App Store Connect에 앱 등록
- [ ] 스크린샷 · 앱 설명 · 개인정보 처리방침 URL 준비

## 8. 검증

v1에서 이관.

- [ ] Dock 아이콘 미노출 확인
- [ ] 메뉴바 좌측 App menu 미노출 확인
- [ ] 멀티 디스플레이 — 커서가 있는 화면의 중앙으로 이동하는지
- [ ] 다른 앱 포커스 상태에서 핫키 동작 확인 (부작용 없이 커서만 이동)
- [ ] 샌드박스 빌드에서 핫키·커서 이동 동작 확인
- [ ] 커서 이동 직후 hover가 갱신되지 않는 것이 수용 가능한 수준인지 확인
- [ ] **Open at Login은 `/Applications`에 설치 후 검증** — Xcode DerivedData에서 실행하면 `notFound` 반환
- [ ] 시스템 설정에서 로그인 항목을 끈 뒤 메뉴를 다시 열면 체크가 풀리는지
