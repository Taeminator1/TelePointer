# 작업 목록 v1.1

요구사항은 [Requirements.md](./Requirements.md), 모듈 구조는 [Architecture.md](../Architecture.md),
미분류 항목은 [Backlog.md](../Backlog.md), 작업 기록과 채택하지 않은 대안은 [Notes.md](../Notes.md) 참고.

## 1. 최소 지원 버전 검토

- [x] macOS 26 전용 API를 쓰는 곳 확인
- [x] 낮출 버전 결정
- [x] `Project.swift`의 `deploymentTargets` 반영
- [ ] macOS 15에서 테스트

## 2. 한국어 지원

- [x] 메뉴 문자열 한국어 번역
- [ ] 설정 창 문자열 한국어 번역
- [ ] 시스템 언어를 따라 바뀌는지 확인

## 3. 스크롤

- [ ] 상 · 하 · 좌 · 우 스크롤 단축키 추가
- [ ] 커서 위치에서 스크롤되는지 확인

## 4. Hovering

- [ ] 단축키로 커서를 옮기면 커서 아래 UI의 hover 상태가 곧바로 갱신된다
- [ ] 자동 숨김 Dock이 나타난다
- [ ] Hot Corners가 동작한다

## 5. 시스템 단축키 겹침 확인

- [ ] 설정 창에서 단축키를 바꿀 때 macOS 시스템 단축키와 겹치면 알려준다

## 6. Preset

- [ ] preset을 여러 개 추가한다
- [ ] preset마다 별명을 붙인다

## 7. App Store Connect 메타데이터 정정

[AppStoreConnect.md](../AppStoreConnect.md)

- [ ] Support URL이 개인정보 처리방침 주소다 — `TelePointer/support`로 바꾼다
- [ ] Keywords 맨 앞의 공백을 지운다
- [ ] Keywords의 `pointer`가 Subtitle과 겹친다 — `mouse`로 바꾼다
- [ ] App Review Notes 정리 — 2.4.5 소명 문단을 새 버전에 맞게 고치고 Mouse Keys 경로 중복을 줄인다
