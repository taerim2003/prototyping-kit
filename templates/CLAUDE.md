# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- **요청 속 명사를 일반어로 읽기 전에 `grep`할 것.** 프로젝트에 그 이름의 필드·함수·루트명이 이미 있으면 사용자가 말한 건 그쪽이다. ("성장률"을 레벨업 커브로 읽었는데 실제로는 `GrowthStacks` 기믹이었던 적 있음 — 왕복 하나를 통째로 날림.)
- **음성 받아쓰기로 들어온 숫자는 신뢰하지 말 것.** "이 십"이 15인지 20인지처럼 갈리면 추론하지 말고 물어본다.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

**예외 — 커플링된 상수는 같이 고쳐야 한다.** 밸런스 상수 하나를 바꾸라는 요청이 옆 상수를 조용히 깨뜨리는 일이 흔하다(적 정지거리를 벌렸더니 돌진이 허공을 치고, 소환 지점이 대응 불가가 됨). **바꾸기 전에 "이 값과 한 세트인 값"을 찾을 것** — 주석에 다른 상수 이름이 등장하면 그게 커플링 신호다. 같이 고쳤으면 서로를 가리키는 주석을 남기고, 변경 전과 같은 관계가 유지되는지 수치로 확인한다.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## 5. 개발 환경 & 패키지

- **Unity 6** (<버전>), <렌더 파이프라인 — 예: URP 2D>
- **UI 시스템**: <uGUI / UI Toolkit 중 택1 — §6 작성 규칙이 갈림>
- **빌트인 패키지** (엔진/Package Manager 제공): <예: UI Toolkit, Input System, TextMeshPro, Cinemachine>
- **서드파티 플러그인** (외부 에셋, **수정 금지**): <예: DOTween, JuicyUI>

---

## 6. 엔진·에디터 우선 원칙

**Unity가 제공하는 걸 코드로 재구현하지 말 것.** 빌트인 시스템·에디터 워크플로를 코드보다 먼저 고려한다.

- 에디터에서 할 수 있는 것(오브젝트 배치·크기·참조 연결)은 에디터에서. 코드는 로직만.
- **Unity 프로젝트는 Unity-MCP(IvanMurzak, `com.ivanmurzak.unity.mcp`) 사용을 기본값으로 고려한다.** AI가 씬 오브젝트 배치·컴포넌트 연결·프리팹 생성·플레이모드 진입까지 직접 수행 — 블루베리 디펜스 프로토타입에서 검증됨: 사용자가 매 피쳐 직접 테스트/수정하는 왕복이 줄고, 그림 작업과 병렬 진행이 가능해짐.
- **시각적 판단 원칙**: 스프라이트 방향·색감·스타일처럼 정적인 시각 요소는 결정 전에 원본 이미지를 직접 보고 판단한다 (임포트 설정 잡을 때 이미 여는 파일이라 추가 비용 거의 없음). 파티클·애니메이션처럼 동적인 결과는 스크린샷 검증의 신뢰도가 낮으니 사용자 확인에 맡긴다.
  - **좌표를 정할 땐 배경 그림에서 근거를 뽑을 것.** 배경 PNG의 픽셀 행을 색으로 분류하면 "수평선·지평선이 월드 y 몇인가"가 바로 나온다. 눈대중으로 넣고 되묻는 왕복보다 싸다.
- 🚫 **모달을 띄우는 에디터 API는 절대 호출 금지** — 다이얼로그가 뜨면 에디터가 멈추고 **MCP 연결이 통째로 죽는다**(사용자가 창을 눌러줄 때까지 아무것도 못 함). `EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()`(→ `SaveScene`을 쓸 것), `EditorUtility.DisplayDialog`, `OpenFilePanel` 계열.
- **플레이모드 측정 체크리스트**: ① `Time.timeScale`·`Time.time`이 흐르는가(게임오버면 0이라 deltaTime 기반 값이 굳는다 — 버그로 오판하기 쉬움) ② **플레이 중엔 스크립트가 컴파일되지 않는다**(수정 → 종료 → 컴파일 확인 → 재진입) ③ MCP 코드 실행은 호출마다 독립 어셈블리라 static이 안 넘어간다 — 시계열 샘플링 대신 **"어기면 반드시 벗어나는 불변식"**을 한 번에 판정 ④ 씬을 임시로 고쳤으면 되돌리고 `git status`로 확인 ⑤ **화면을 눈으로 판정하기 전에 대조 실험을 한 번 넣는다**(색을 불투명으로 바꿔 재촬영, 값을 극단으로 밀어보기) — 스크린샷만 보고 "안 그려진다"고 판단했다가 처음부터 정상이었던 적이 있다.
- **에셋을 코드로 생성·수정하면 되읽어서 검증할 것.** 일부 필드 대입이 **조용히 무시**될 수 있다(실제로 `SpriteRenderer.sprite`에서 발생). 프리팹 수정은 `PrefabUtility.LoadPrefabContents` + `SerializedObject`가 가장 확실.
- 🔴 **새 `SerializeField`를 추가할 때 클래스 기본값을 믿지 말 것.** 이미 임포트된 에셋·프리팹은 그 필드가 YAML에 없어도 **임포트 캐시에 구워진 옛 값**을 계속 쓴다. 스크립트 기본값 변경은 소급되지 않는다. ① 필드를 추가하면 **즉시 모든 기존 에셋에 값을 써 넣고** ② **불리언 기본값은 언제나 "기존 동작과 같은 쪽"으로**(특수 케이스를 기본값에 두지 말 것) ③ 되읽어 확인. 같은 함정을 두 세션에 걸쳐 두 번 밟았고, 한 번은 **모든 지상 적이 공격을 통과하는** 전면 회귀였다.
- 📄 **씬·프리팹·에셋에 직렬화되는 클래스는 파일명 = 클래스명인 독립 파일로.** `MonoBehaviour`·`ScriptableObject`를 다른 .cs에 곁다리로 넣으면 `m_Script: {fileID: 0}`이 되어 **에디터에선 멀쩡한데 빌드에서만** 컴포넌트가 안 붙거나 SO가 null로 로드된다. 런타임 `AddComponent` 전용이면 합쳐도 된다. → **에디터에서 재현 안 되는 버그는 추측 말고 `Player.log`부터.**
- 🔒 **사용자 작업물을 파괴하지 말 것.** 에디터는 사용자와 공유한다 — 미저장 편집을 날리면 git에도 없어 복구가 안 된다(실제로 날린 적 있음).
  - 씬을 **읽기만 하면 additive로 열고 저장 없이 닫는다.** `OpenScene(..., Single)`은 사용자가 보던 씬을 갈아치운다. Single로 열어야 하면 **저장 여부부터 묻는다.**
  - 사람이 편집하는 에셋(SO·씬)은 **손대기 직전에 다시 읽는다.** 읽은 시점과 판단 시점이 벌어지면 감사·대조 결과가 통째로 틀어진다.
  - **커밋 직전 `git status`의 모든 줄을 설명할 수 있어야 한다.** 설명 못 하는 줄이 있으면 그게 사고다.
- **검증은 위에서부터 — 아래로 갈수록 비싸다.** ① **에디트모드 리플렉션 테스트**(순수 로직. `new GameObject().AddComponent<T>()`는 Awake가 안 돌아 프리팹 참조 없이도 된다) → ② **에디터 스크립트 반환값 대조**(손계산 말고 게임이 실제로 쓰는 경로로) → ③ **플레이모드 스모크**(연출·물리처럼 정말 실행이 필요할 때만) → ④ **사용자에게 물어보기**(버튼 하나 눌러보면 되는 UI 동작은 "눌러보고 알려줘"가 더 빠르고 정확).
  ⚠️ **에디트모드 `Instantiate`는 Awake를 안 돈다** — 런타임 필드를 에디트모드에서 읽어 검증하려 들지 말 것.
- 🧰 **MCP 툴 중 못 미더운 것들** — `scene-open`(멀쩡한 경로를 거부 → `EditorSceneManager.OpenScene` 직접 호출) / `console-get-logs`(누적 버퍼 전체를 뱉어 토큰 초과 → **검증은 `Debug.Log`가 아니라 스크립트 반환값으로**) / `gameobject-duplicate`(반환값이 원본을 가리킴 → 부모 재조회로 `"(N)"` 찾기) / 스크립트 실행은 **관련 동작을 한 호출에 몰되**, 플레이모드 상태 전이만은 한 호출에 하나씩.
- ⚖️ **계기와 눈이 어긋나면 관측을 먼저 의심할 것.** 로그로 찍은 상태값(enabled·알파·rect·`Time.timeScale`)이 전부 정상인데 화면이 이상해 보이면, 대개 화면을 잘못 읽은 것이다. 코드를 파기 전에 **대조 실험 한 번**(색을 불투명으로 바꿔 재촬영, 값을 극단으로 밀어보기)이 추측보다 훨씬 싸다. 두 세션 연속 이걸로 헛발질했다.
- UI 작성 규칙은 프로젝트가 쓰는 시스템에 맞춰 여기 기입:
  - **uGUI 사용 시**: UI 오브젝트(Canvas·Text·Button)는 씬에 배치, 코드는 SerializeField 참조만.
  - **UI Toolkit 사용 시**: 레이아웃은 UXML/USS로 선언적으로, 코드(C#)는 데이터 바인딩·로직만.

---

## 7. 세션 시작 루틴

0. **코딩 첫 세션이면**: `SESSION_ZERO.md` 완료 여부 확인. 미완성이면 코딩 전에 채울 것.
1. `HANDOFF.md` 읽어서 현재 상태 파악
2. 코드 작업이 예상되면 `ARCHITECTURE.md` 함께 읽어 구조 파악 (폴더 책임·매니저 호출관계·"X 추가하려면 어디 손대나" 표)
3. `GDD.md`는 `grep`으로 필요한 섹션만 조각내어 읽을 것 (`cat GDD.md` 금지)
4. (선택) 최근 일기 `d:\unity\prototyping-kit\journal\` 의 마지막 1~2편 훑어 과정상 미해결 마찰 확인
5. 한 줄 브리핑 후 사용자에게 다음 목표 확인 — 이때 **HANDOFF의 미해결 목록을 같이 훑어 이번 세션 범위를 확정**할 것. 인계 문서에 적힌 항목이 자동으로 작업 범위가 되지는 않아서, 짚지 않으면 통째로 빠뜨린다.
   ⚠️ **HANDOFF는 할 일의 목록이지 코드의 진실이 아니다.** 거기 적힌 "~해야 함"을 사용자에게 말하기 전에 **코드로 1건이라도 확인**할 것. 그리고 **HANDOFF 갱신 = 추가 + 삭제** — 완료·검증된 항목을 안 지우면 다음 세션이 낡은 정보를 사실로 읊는다.

---

## 8. grep 사용

**코드 파일 (.cs) 수정 시:**
- 수정 전 `grep`으로 관련 클래스/함수의 정확한 위치(라인) 먼저 파악
- 불필요한 전체 파일 cat 금지, 해당 라인만 Read

---

## 9. 세션 종료 시 반드시 할 것

1. `HANDOFF.md` 업데이트 (빌드 상태 / 미해결 이슈 / 다음 할 일)
2. **세션 일기 작성** → `d:\unity\prototyping-kit\journal\YYYY-MM-DD.md`
   (틀: `templates\JOURNAL_ENTRY.md`. 게임이 아니라 *과정*의 회고. 하루 두 번째 세션이면 같은 파일에 `## 세션 N` 추가)
3. git commit + push (변경 파일 전체 스테이징, origin main)

## 10. 프로젝트 종료 루틴

플레이 빌드 배포 후 또는 프로토타입 중단 결정 후:

1. `RETROSPECTIVE.md` 작성 (틀: `templates\RETROSPECTIVE.md`)
   — **철저히 사용자 중심으로 작성.** "구현된 피쳐"·"기술 스택" 같은 사실 나열 섹션만 AI가 채우고, 나머지(What Went Well/Wrong·과정 개선안·게임 개선방안)는 작성 전 플레이테스트 여부/결과부터 묻고 섹션별로 사용자 입장을 질문해서 그 답변으로 채운다. AI가 짚고 싶은 이슈는 먼저 언급하고 사용자 동의를 받아 반영한다.
   — What Went Well/Wrong은 **워크플로 수준**으로. 코드 버그 목록 아님.
   — 과정 개선안 중 Kit에 반영할 것은 **[→ Kit]** 표시 후 실제 반영
2. 노션에 공유 - 해당 프로젝트 문서 밑에 회고 문서 작성 (확정 후에)
3. 다음 프로토타입 SESSION_ZERO 작성 시 이 회고 먼저 읽을 것
