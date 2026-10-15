# 요구 사항 v1.2

[v1.1/Requirements.md](../v1.1/Requirements.md)에 아래 기능을 더한다. 다시 적지 않은 항목은 v1.1 그대로 유지한다.

## UI

- 메뉴바 메뉴에서 Import Settings… · Export Settings…를 뺀다

## 설정

- **General**: 설정 창의 맨 위 탭
    - **Import · Export**: 메뉴바 메뉴에서 옮겨온다. Playground 실험 설정도 함께 내보내고 가져온다
    - **Presets**: Import · Export 아래에 둔다

## 기능

- **Playground**: 커서 움직임을 확인하는 흰색 창. 포인터가 지나간 자취가 남는다
    - 설정 창에서 연다
    - 배포 빌드에서는 숨긴다
    - 키로 창을 조작한다: `0`–`9` 자취 색 바꾸기(`0`은 그리지 않음), `c` 자취 지우기, `g` grid 간격 바꾸기(2·4·8·16배, 끄기 순)
    - 실험 중인 동작을 켜고 끈다: 부드러운 방향 전환, 오래 누르면 멈추는 제한 해제
- **부드러운 커서 이동**: 단축키로 움직이는 커서가 더 부드럽게 움직인다
- **시스템 단축키 겹침 확인**: 설정 창에서 단축키를 바꿀 때 macOS 시스템 단축키와 겹치면 알려준다
- **Preset**: 설정을 preset으로 저장해 두고 바꿔 쓴다
    - preset을 추가하고 삭제한다
    - preset마다 별명을 붙인다

## 관련 문서

- [Tasks.md](./Tasks.md) — v1.2 작업 목록
- [Architecture.md](../Architecture.md) — 모듈 구조와 결정 근거
- [Backlog.md](../Backlog.md) — 미분류 항목
- [Notes.md](../Notes.md) — 작업 중 남긴 기록과 채택하지 않은 대안
