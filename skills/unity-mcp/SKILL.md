---
name: unity-mcp
description: Unity 에디터를 MCP로 직접 조작할 때의 안전 수칙과 검증 절차. 씬·프리팹·에셋을 만들거나 고칠 때, 플레이모드로 측정할 때, script-execute를 쓰기 전에 읽을 것. 사용자 작업물 파괴·Unity 멈춤·조용한 실패를 막는다.
---

# Unity-MCP 작업 수칙

> 이 문서는 **키트 공용**이다(`prototyping-kit/skills/`). 프로젝트 고유 배선(MCP 서버 주소·훅 경로·씬 지도 파일명)은
> 각 프로젝트의 `CLAUDE.md`에 있다. 여기 있는 건 어느 Unity 프로토타입에나 적용되는 것들.

## 🚫 절대 호출 금지 — 모달을 띄우는 API

**모달 다이얼로그가 뜨면 Unity가 멈추고 MCP 연결이 통째로 죽는다.** 사용자가 직접 창을 눌러줄 때까지 아무것도 못 한다(세션20에 5분 이상 날림).

- `EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()` → **`EditorSceneManager.SaveScene(scene)`을 쓸 것**
- `EditorUtility.DisplayDialog` / `DisplayDialogComplex` / `OpenFilePanel` 계열

## 🔒 사용자 작업물을 파괴하지 말 것

에디터는 사용자와 **공유**한다. 미저장 편집을 날리면 git에도 없어 복구가 안 된다(세션15에 실제로 날렸다).

- 씬을 **읽기만 하면 additive로 열고 저장 없이 닫는다.** `OpenScene(..., Single)`은 사용자가 보던 씬을 갈아치운다. Single로 열어야 하면 **저장 여부부터 묻는다**(dirty면 확인 모달 → 위 "MCP 사망"까지 겹친다).
- 사람이 편집하는 에셋(SO·씬)은 **손대기 직전에 다시 읽는다.** 읽은 시점과 판단 시점이 벌어지면 감사·대조 결과가 통째로 틀어진다.
- **커밋 직전 `git status`의 모든 줄을 설명할 수 있어야 한다.** 설명 못 하는 줄이 사고다(컴파일 요청이 사용자의 미저장 편집을 디스크로 밀어낸 적 있음).

## ⚠️ 파일을 PowerShell로 왕복시키지 말 것

PowerShell 5.1의 `Get-Content`는 **BOM 없는 UTF-8 파일을 시스템 ANSI(CP949)로 읽는다.** 한글이 통째로 깨진다.
읽어서 다시 쓰는 순간 그 깨진 문자가 저장되고, 원본은 사라진다(세션27에 이 문서가 그렇게 한 번 날아갔다).

- 텍스트 파일 수정은 **Edit/Write 툴로** 한다. PowerShell·`sed`로 왕복시키지 않는다.
- PowerShell로 꼭 읽어야 하면 `Get-Content -Encoding UTF8`을 **명시**하고, **쓰지는 않는다**.
- 검증은 **읽기 전용으로** 짠다. "고쳐보고 되돌리기"는 되돌리기가 실패하면 원본이 사라진다.

## 검증은 위에서부터 — 아래로 갈수록 비싸다

① **에디트모드 리플렉션 테스트**(순수 로직. `new GameObject().AddComponent<T>()`는 Awake가 안 돌아 프리팹 참조 없이도 된다 — 조용한 실패가 없어 가장 확실) → ② **`script-execute` 반환값 대조**(에셋 값·커브. 손계산 말고 게임이 실제로 쓰는 경로로) → ③ **플레이모드 스모크**(연출·물리처럼 정말 실행이 필요할 때만) → ④ **사용자에게 물어보기**(버튼 하나 눌러보면 되는 UI 동작은 "눌러보고 알려줘"가 더 빠르고 정확).

⚠️ **에디트모드 `Instantiate`는 Awake를 안 돈다** — 런타임 필드를 에디트모드에서 읽어 검증하려 들지 말 것.

⚠️ **검산 스크립트를 새로 쓰면 대조군부터 돌린다** — 고치기 *전* 데이터처럼 **위반이 나와야 정상인 입력**에 먼저 돌려 실제로 실패가 찍히는지 볼 것. "전부 통과"는 검증이 아니라 **의심 신호**다. (세션25: PowerShell이 변수 대소문자를 안 가려 루프의 `$warn`이 상수 `$WARN`을 덮어 검사가 통째로 무력화됐다. before/after를 둘 다 돌린 덕에 걸렸다.)

## 플레이모드로 측정할 때 체크리스트

1. **시간이 흐르는가** — `Time.timeScale`·`Time.time` 확인. **게임오버·모달이면 `timeScale=0`**이라 `Time.deltaTime` 기반 값이 마지막 값에 굳는다. 이걸 버그로 오판한 적 있음(세션20).
2. **새 코드가 컴파일됐는가** — **플레이 중엔 스크립트가 컴파일되지 않는다.** 코드 수정 → 플레이 종료 → `EditorApplication.isCompiling == false` 확인 → 재진입.
3. **한 프레임에 판정 가능한가** — `script-execute`는 호출마다 **독립 어셈블리**라 static으로 프레임 간 상태를 못 넘긴다. 시계열 샘플링보다 **"어기면 반드시 벗어나는 불변식"**을 세워 한 번에 판정하는 쪽이 낫다.
4. **플레이 진입 직후 첫 호출이면 부트스트랩이 끝났는지부터 확인한다** — `isPlaying == true`여도
   `RuntimeInitializeOnLoadMethod`(특히 `AfterSceneLoad`)는 아직 안 돌았을 수 있다. 그 시점에 싱글톤 `Instance`를 읽으면
   **null이 나오는데 이건 버그가 아니라 이르게 물어본 것**이다(2026-08-05에 null을 버그로 오해해 진단 2회를 태웠다).
   → 값이 null이면 **다음 호출에서 한 번 더 확인**하고, 그래도 null일 때만 원인을 파기 시작할 것.
5. **씬을 임시로 고쳤으면 되돌리고 `git status`로 확인**할 것.
6. **화면을 눈으로 판정하기 전에 대조 실험을 한 번 넣는다** — 색을 불투명으로 바꿔 재촬영, 값을 극단으로 밀어보기. 스크린샷만 보고 "안 그려진다"고 판단했다가 **처음부터 정상이었던** 적이 있다(세션21). 로그로 찍은 상태값이 전부 정상이면 코드가 아니라 관측이 틀린 것이다.

## 에셋을 코드로 만들면 되읽어서 검증할 것

`SpriteRenderer.sprite` 직접 대입이 **조용히 무시된** 적 있다(세션20 — 다른 필드는 다 들어갔는데 스프라이트만 안 들어감). 생성 직후 `AssetDatabase.LoadAssetAtPath`로 되읽어 로그를 찍으면 잡힌다. 프리팹 수정은 `PrefabUtility.LoadPrefabContents` + `SerializedObject`가 가장 확실하다.

## 🪝 위험 호출은 훅으로 막는다

프로젝트에 `PreToolUse` 훅이 설치돼 있으면 모달 API 문자열·`scene-open`·`console-get-logs`·Additive 없는 `OpenScene` 호출이 차단된다.
**차단되면 stderr 메시지를 읽고 그대로 따를 것.**

- 정말 필요하면 인자 어딘가에 `HOOK-OK`를 넣어 통과시킬 수 있다. **사용자 승인을 받은 뒤에만.**
- 훅이 안 도는 것 같으면(위험 호출이 그냥 통과) 스크립트를 직접 실행해 확인할 것 — **훅은 조용히 실패한다.**
- 훅 스크립트는 **ASCII 전용**으로 쓸 것(no-BOM PowerShell 5.1이 한글 리터럴을 깨뜨린다).
- **훅이 아직 없는 프로젝트라면** 위 🚫·🔒 항목이 유일한 방어다. 더 조심할 것.

## 🧰 못 미더운 MCP 툴 — 우회법

- **씬의 컴포넌트를 코드로 찾기 전에 그 프로젝트의 씬 지도 문서**(예: `SCENE_MAP.md`)**부터 볼 것.** "프리팹이겠지"라고 넘겨짚고 프리팹 전수 검색을 짰다가 헛돈 적 있다(세션26 — 플레이어가 프리팹이 아니라 씬 오브젝트였다. 지도에 적혀 있었다).
- **`gameobject-duplicate`** — 반환값이 원본을 가리킨다. → 복제 후 **부모를 재조회**해 `"(N)"` 접미사로 찾기.
- **`script-execute`** — 관련 동작은 한 호출에 몰되(중간 도메인 리로드로 상태 리셋), **플레이모드 상태 전이만은 한 호출에 하나씩**. 문자열에 이스케이프 따옴표(`\"`) 금지(`"a" + var + "b"`로).
  - 🔴 **새 `.cs`를 만들었으면 그 타입을 쓰기 전에 `assets-refresh`를 먼저 부른다.** 파일만 써 두고 참조하면
    `CS0103: The name 'X' does not exist`로 죽는다 — 코드가 틀린 게 아니라 **아직 임포트가 안 된 것**이다.
    트리거는 자명하다: *새 스크립트 파일을 만든 직후.* (2026-08-05에 두 번 걸렸다.)
  - 🔴 **결과는 `Debug.Log`가 아니라 반환값으로 받는다.** `console-get-logs`가 훅에 막혀 있어 **로그를 읽을 수단이 없다** —
    `void`로 짜고 로그를 찍으면 실행은 `Success`로 끝나는데 정작 결과를 못 본다. `public static string Main()`으로 만들어
    `StringBuilder`에 담아 `return`할 것. **코드를 짜기 전에 정하는 첫 결정이다.**
  - ⚠️ **에디트모드 `AddComponent`가 조용히 `null`을 반환할 수 있다** — `[RequireComponent(typeof(Collider2D))]`처럼
    요구 타입이 **추상 클래스**면 Unity가 자동 추가를 못 한다. 구체 타입(`BoxCollider2D`)을 먼저 붙일 것.
    증상이 `"Non-static method requires a target"`으로 나와 원인을 안 가리킨다(리플렉션 `Invoke`에 null을 넘긴 것이라).
  - ⚠️ **Unity 6에서 바뀐 API** — `TextureImporter.spritePixelsToUnit`/`.spriteMode`는 `TextureImporterSettings`(`ReadTextureSettings`) 경유,
    `FindObjectsSortMode` 오버로드는 deprecated. **비활성 UI를 찾을 땐 `FindObjectsInactive.Include`가 필수**다.

## 📄 씬·프리팹·에셋에 직렬화되는 클래스는 독립 파일로

`MonoBehaviour`·`ScriptableObject`는 **반드시 파일명 = 클래스명인 자기 파일**에 둔다. 다른 .cs에 곁다리로 넣으면 `m_Script: {fileID: 0}`이 되어 **에디터에선 멀쩡한데 빌드에서만** 컴포넌트가 안 붙거나 SO가 null로 로드된다(빌드 데미지 숫자 "0" · 빌드에서 전 스테이지 동일 — 둘 다 이것). 런타임 `AddComponent` 전용이면 합쳐도 된다.

→ **에디터에서 재현이 안 되는 버그는 추측하지 말고 `Player.log`부터.**
