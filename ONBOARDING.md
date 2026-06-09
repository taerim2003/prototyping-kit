# ONBOARDING.md — 새 프로토타입 시작 런북 (AI 실행용)

> **이 문서는 사람용 설명서가 아니라 에이전트가 따라 실행하는 절차다.**
> 사용자가 `f:\Prototyping\` 아래 새 게임 프로토타입을 시작하려 할 때, 아래 단계를 순서대로 진행하며 사용자를 안내한다.
> 각 단계는 **하나씩** 밟는다. 한 번에 다 하지 말고, 사용자 확인이 필요한 곳에서 멈춘다.

---

## 언제 이 런북을 실행하나 (트리거)

사용자가 다음 류의 의도를 보이면 실행:
- "새 프로토타입/게임 시작하자", "새 프로젝트 만들자"
- 빈 새 폴더에서 작업을 시작하려 하는데 키트 문서가 아직 없을 때

확신이 없으면 한 줄로 물어 확인: *"새 프로토타입 온보딩을 시작할까요?"*

---

## 어디서 여나 (Claude Code 실행 위치)

- **온보딩 시작 시**: 상위 `f:\Prototyping\` 에서 Claude Code를 연다. (Unity 프로젝트 폴더가 아직 없으므로. 빈 폴더를 미리 만들지 말 것 — Unity Hub가 직접 생성한다.)
- **온보딩 이후 일상 작업**: 만들어진 `f:\Prototyping\<작업명>\` 에서 직접 연다.

---

## 진행 원칙

1. **안내하되 떠넘기지 않는다.** 결정은 근거와 함께 *제안*하고, 사용자가 답할 것만 묻는다.
2. **무거운/되돌리기 어려운 동작 전엔 멈춘다.** 폴더 생성·git init·커밋은 직전에 무엇을 할지 한 줄로 알리고 진행.
3. **Unity 프로젝트 생성은 사용자의 수동 작업.** 에이전트가 CLI로 만들지 않는다. Unity Hub에서 만들도록 안내하고 완료를 기다린다.
4. **GDD 본문은 사용자 주도.** 에이전트는 개념 답변으로 §1~2 골격만 채우고, 시스템 설계는 사용자와 함께 채운다. 혼자 게임을 설계하지 않는다.

---

## 단계

### 0. 의도 확인 + 개념 수집
사용자에게 다음을 묻는다 (이미 말한 건 다시 묻지 않음). GDD §1~2와 폴더명을 채울 최소한만:
- 게임 한 줄 컨셉 / 핵심 경험은?
- 장르·플랫폼?
- 레퍼런스 게임?
- 작업명(폴더명) — 영문, 공백 없이 (예: `WeaponBallAutoBattler`)

> 너무 깊게 파지 말 것. 시스템 설계는 첫 작업 세션에서 함께 한다. 여기선 시작에 필요한 만큼만.

### 1. 폴더 레이아웃 확정
**권장 레이아웃: git 루트 = Unity 프로젝트 루트.** (문서가 `Assets/` 옆에 위치. 표준 Unity `.gitignore` 한 장이 그대로 동작하고 중첩 `Library/` 누락 footgun이 없음.)

```
f:\Prototyping\<작업명>\        ← git 루트 = Unity 프로젝트 루트
├─ Assets\ ProjectSettings\ Packages\   (Unity가 생성)
├─ .gitignore
├─ CLAUDE.md  GDD.md  ARCHITECTURE.md  HANDOFF.md
```
다른 레이아웃을 원하면 사용자 의사를 따르되, 위 footgun을 알린다.

### 2. Unity 프로젝트 생성 (사용자 수동) — 여기서 멈춤
사용자에게 안내하고 완료를 기다린다:
> Unity Hub → New Project → 2D (URP) 등 원하는 템플릿 → 위치 `f:\Prototyping\` , 이름 `<작업명>` → 생성.
> 생성·첫 컴파일 끝나면 알려주세요.

(엔진 버전·렌더 파이프라인은 사용자 선택. 받아서 CLAUDE.md §5에 기록.)

### 3. 키트 문서 복사
Unity 프로젝트 폴더가 생긴 것을 확인한 뒤, 템플릿을 프로젝트 루트로 복사:
```powershell
Copy-Item f:\Prototyping\_KIT\templates\CLAUDE.md,`
          f:\Prototyping\_KIT\templates\GDD.md,`
          f:\Prototyping\_KIT\templates\ARCHITECTURE.md,`
          f:\Prototyping\_KIT\templates\HANDOFF.md `
          f:\Prototyping\<작업명>\
Copy-Item f:\Prototyping\_KIT\templates\unity.gitignore f:\Prototyping\<작업명>\.gitignore
```
(`JOURNAL_ENTRY.md`는 복사하지 않음 — 일기 쓸 때 참고용.)

### 4. 문서 1차 채우기
- **CLAUDE.md §5**: 엔진 버전·렌더·플러그인 기입.
- **GDD.md §1~2**: 0단계 개념 답변으로 개요 표·핵심 컨셉 채움. 나머지 섹션은 골격 유지.
- **HANDOFF.md**: `현재 상태` = "프로젝트 생성·온보딩 완료, 첫 시스템 설계 대기". North Star = 한 줄 비전.
- ARCHITECTURE.md는 코드가 생기기 전이므로 골격 그대로 둔다.

### 5. git 초기화 + 첫 커밋 — 직전에 알리고 진행
```powershell
git -C f:\Prototyping\<작업명> init
git -C f:\Prototyping\<작업명> add -A
git -C f:\Prototyping\<작업명> commit -m "[init] Unity 프로젝트 + 프로토타입 키트 문서"
```
커밋 전 `git status`로 `Library/`·`Temp/` 등이 제외됐는지 확인. 잡혀 있으면 `.gitignore` 위치·내용 점검(루트에 있는지).
원격은 사용자가 원할 때만 — `git remote add` 여부를 묻는다.

### 6. 첫 작업 세션으로 인계
- HANDOFF의 "다음 세션 체크리스트"에 첫 목표(보통 핵심 루프/첫 시스템 설계)를 적는다.
- 세션 종료 시 일기 1편을 `f:\Prototyping\_KIT\journal\YYYY-MM-DD.md`에 남긴다 (CLAUDE.md §9).
- 사용자에게 "이제 GDD 시스템 설계부터 시작할까요?"로 자연스럽게 첫 세션을 연다.

---

## 체크리스트 (에이전트 자가 점검)
- [ ] 개념 4종(컨셉·장르/플랫폼·레퍼런스·작업명) 확보
- [ ] Unity 프로젝트 생성 확인 (사용자 완료 보고)
- [ ] 템플릿 4종 + .gitignore 복사
- [ ] CLAUDE §5 / GDD §1~2 / HANDOFF 현재상태 채움
- [ ] git init + 첫 커밋, Library 제외 확인
- [ ] 첫 세션 목표를 HANDOFF에 기록 후 인계
