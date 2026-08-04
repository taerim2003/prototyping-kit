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

## 스킬(`skills/`) — 필요할 때만 펼쳐지는 절차서

`CLAUDE.md`가 **매 세션 무조건** 읽히는 상비 문서라면, 스킬은 **필요할 때만 로드되는 절차서**다.
평소엔 이름과 설명 한 줄만 목록에 떠 있고, 관련 작업이 생기거나 `/스킬이름`을 치면 그때 본문이 펼쳐진다.
→ CLAUDE.md가 길어져 **규칙이 노이즈에 묻히는 것**을 막는 게 목적이다(토큰 절약이 아니다).

**무엇을 어디에 둘 것인가 — 판정 순서**

1. **매번 필요한가?** → `CLAUDE.md` (프로젝트 고유 배선·"내가 뭘 할 수 있는가"의 선언은 여기)
2. 아니면, **필요한 순간이 자명한가?** → 자명하면 **스킬**
   - ✅ 자명: "씬을 만질 때", "새 PNG가 들어왔을 때", "세션을 끝낼 때"
   - ❌ 불명: "화면이 이상해 보이면" → 스킬로 빼면 안 열린다. 기존 절차의 한 단계로 박을 것
3. **안 읽으면 파괴적인가?** → 스킬 + `CLAUDE.md`에 한 줄 경고 + 가능하면 훅

**실패 신호** — CLAUDE.md에 있는데 안 지켜지면 *파일이 너무 길어 묻힌 것*. 스킬로 뺐는데 안 열리면 *2번 판정이 틀린 것*.

**두 종류**

| | 위치 | 범위 |
|---|---|---|
| **키트 스킬** | `_KIT/skills/<이름>/SKILL.md` | 프로토타입 무관. `~/.claude/skills/`에 **정션**으로 걸어 모든 프로젝트가 같은 파일을 본다 (아래 "새 기기" 4번) |
| **프로젝트 스킬** | `<프로젝트>/.claude/skills/<이름>/SKILL.md` | 그 프로젝트 고유 정보(노션 DB id 등)가 든 것만 |

원본이 하나뿐이라 복사본이 어긋날 일이 없다 — `[→ Kit]`이 단방향으로만 흘러 정작 현재 프로젝트는 빈손이던 문제(2026-08-02 일기)를 구조적으로 막는다.

**성격도 두 가지다** — 어느 쪽이냐에 따라 *누가 부르는지*가 달라진다.

- **참조형**(읽는 것): 순서 없는 주의사항 목록. Claude가 관련 작업을 만나면 알아서 연다. → `unity-mcp`
- **실행형**(시키는 것): 순서 있는 체크리스트. 부수효과(커밋·외부 도구 수정)가 있으므로 frontmatter에
  `disable-model-invocation: true`를 넣어 **사용자가 `/이름`을 칠 때만** 돌게 한다. → `wrap`

현재 키트 스킬:
| 스킬 | 성격 | 내용 |
|---|---|---|
| **`unity-mcp`** | 참조형 | Unity-MCP 안전 수칙 · 검증 4계층 · 플레이모드 함정 |
| **`wrap`** | 실행형 | 세션 종료 루틴 (칸반 → HANDOFF → 일기 → 커밋). `/wrap`으로 실행 |

---

## 새 프로토타입 시작하기

**에이전트가 [ONBOARDING.md](ONBOARDING.md) 런북을 따라 사용자를 단계별로 안내한다.** (사람이 수동으로 밟을 필요 없음 — "새 프로토타입 시작하자"라고 하면 에이전트가 절차를 진행한다.) 런북 요지:

1. 개념 수집(컨셉·장르·레퍼런스·작업명) → 2. Unity 프로젝트 생성(사용자, Unity Hub) → 3. 템플릿+.gitignore 복사 → 4. CLAUDE §5 / GDD §1~2 / HANDOFF 채움 → 5. git init + 첫 커밋 → 6. SESSION_ZERO 스코프 선언(같은 세션에서, Must Have 3개 이하로 컷) → 7. 첫 세션 인계.

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
4. **키트 스킬을 전역에 연결** (`skills/` 참고) — 아래 스크립트는 **키트 경로만 바꿔서** 그대로 실행하면 된다.
   스킬이 늘어나도 다시 돌리기만 하면 새 것까지 연결된다.
   ```powershell
   $kit = "d:\unity\prototyping-kit"   # ← 이 기기의 키트 경로로
   New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
   Get-ChildItem "$kit\skills" -Directory | ForEach-Object {
     $d = "$HOME\.claude\skills\$($_.Name)"
     if (-not (Test-Path $d)) { New-Item -ItemType Junction -Path $d -Target $_.FullName | Out-Null }
   }
   ```
   ⚠️ **심볼릭 링크가 아니라 정션(Junction)이다.** `New-Item -ItemType SymbolicLink`는 관리자 권한이나
   개발자 모드를 요구해서 실패한다. 정션은 권한 없이 되고, Claude Code는 둘 다 그냥 폴더로 읽는다.
5. **Claude Code 재시작** — MCP·훅·권한 모드는 재시작 후 적용. 스킬 폴더를 이번에 새로 만들었으면 이때 인식된다.

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
