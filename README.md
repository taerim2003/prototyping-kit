# _KIT — 프로토타이핑 파이프라인

> 새 게임 프로토타입을 시작할 때마다 재사용하는 **문서 틀 + 운영 규칙 모음.**
> 게임 내용(GDD 본문 등)은 여기 없다. 여기 있는 건 *어떻게 굴러가는가*에 대한 골격뿐이다.

위치: `f:\Prototyping\_KIT\` — 모든 프로토타입(`MGGA`, `WeaponBallAutoBattler`, …)의 형제 폴더.

---

## 문서 5종 — 무엇을 / 언제

| 문서 | 역할 | 수명 | 누가 읽나 |
|---|---|---|---|
| **CLAUDE.md** | 작업 규칙·세션 루틴 (씬 우선, grep, 세션 시작/종료, 일기) | 거의 고정. 프로토타입마다 복사 | 에이전트(매 세션) |
| **GDD.md** | 게임 비전·시스템 설계 + 상단 퀵 인덱스 트리 | 프로토타입마다 새로 작성 | 사람·에이전트(섹션 검색) |
| **ARCHITECTURE.md** | 코드 지도 (폴더 책임·매니저 호출관계·"X 추가하려면 어디") | 코드 생기면 작성, 큰 구조 바뀔 때만 갱신 | 에이전트(코딩 전) |
| **HANDOFF.md** | 세션 인계 (현재 상태·North Star·체크리스트·변경요약·백로그) | 세션마다 갱신 | 에이전트(세션 시작) |
| **journal/YYYY-MM-DD.md** | **세션 일기** — 프로토타이핑 *과정 자체*의 회고·개선 | 매 세션 1편 누적, **전역**(`_KIT/journal/`) | 사람·에이전트(과정 개선) |

**처음 4개는 각 프로토타입 repo 루트에**, 일기만 여기 `_KIT/journal/`에 횡단 누적한다.

---

## 새 프로토타입 시작하기

**에이전트가 [ONBOARDING.md](ONBOARDING.md) 런북을 따라 사용자를 단계별로 안내한다.** (사람이 수동으로 밟을 필요 없음 — "새 프로토타입 시작하자"라고 하면 에이전트가 절차를 진행한다.) 런북 요지:

1. 개념 수집(컨셉·장르·레퍼런스·작업명) → 2. Unity 프로젝트 생성(사용자, Unity Hub) → 3. 템플릿+.gitignore 복사 → 4. CLAUDE §5 / GDD §1~2 / HANDOFF 채움 → 5. git init + 첫 커밋 → 6. 첫 세션 인계.

레이아웃: **git 루트 = Unity 프로젝트 루트** (문서가 `Assets/` 옆). 표준 Unity `.gitignore` 한 장이 그대로 동작.

---

## 새 기기에서 처음 켤 때 (1회성 환경 세팅)

이 repo(`taerim2003/prototyping-kit`)는 **키트 콘텐츠만** 담는다. 자동화 *배선*은 `~/.claude`에 있어 repo에 포함되지 않으므로, 새 컴퓨터에선 아래를 한 번 수행해야 자동화가 켜진다.

1. **키트 clone** — 경로는 가급적 동일하게(`f:\Prototyping\_KIT`). 다르면 아래 훅 경로도 맞춰 바꿀 것.
   ```bash
   git clone https://github.com/taerim2003/prototyping-kit.git f:\Prototyping\_KIT
   ```
2. **Notion MCP 등록** (user scope — 이 기기 모든 프로젝트 공용):
   ```bash
   claude mcp add notion --scope user --env NOTION_TOKEN=<토큰> -- npx -y @notionhq/notion-mcp-server
   ```
   환경변수 이름은 반드시 `NOTION_TOKEN`. `claude mcp list`로 `✓ Connected` 확인. 실패 시 Node.js(`npx`) 설치 여부부터.
3. **`~/.claude` 배선** (없으면 추가):
   - `CLAUDE.md` 에 온보딩 트리거 1줄 — "`f:\Prototyping` 아래 새 프로토타입 시작 의도 시 `_KIT\ONBOARDING.md`를 따른다".
   - `settings.json` 에 SessionStart 훅:
     ```json
     "hooks": { "SessionStart": [ { "hooks": [ { "type": "command",
       "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"f:\\Prototyping\\_KIT\\hooks\\session-start-brief.ps1\"" } ] } ] }
     ```
   - (선택) `"permissions": { "defaultMode": "bypassPermissions" }`.
4. **Claude Code 재시작** — MCP·훅·권한 모드는 재시작 후 적용.

---

## 일기(journal) 규칙

- **목적**: 게임 회고가 아니라 **프로토타이핑 과정의 개선**. "오늘 워크플로에서 뭐가 매끄러웠고 뭐가 막혔나, 다음엔 뭘 바꿀까."
- **언제**: 매 세션 종료 시 1편 (CLAUDE.md 세션 종료 루틴에 포함).
- **어디**: `f:\Prototyping\_KIT\journal\YYYY-MM-DD.md` (전역, 프로토타입 무관).
- **하루에 여러 세션**: 같은 날짜 파일에 `## 세션 N` 블록 추가.
- **틀**: `templates\JOURNAL_ENTRY.md` 참고. 짧게 — 안 쓰게 되는 게 최악.

---

## 키트 유지보수

- 어떤 프로토타입에서 "이 틀이 불편하다 / 이 섹션이 항상 빈다"를 느끼면 → 그 프로토타입이 아니라 **여기 templates 를 고친다.**
- 일기에서 반복적으로 나오는 개선점은 CLAUDE.md(규칙) 또는 템플릿 구조에 반영해 영구화한다.
