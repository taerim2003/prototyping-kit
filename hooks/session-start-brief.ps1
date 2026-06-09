# SessionStart hook — f:\Prototyping 아래 세션이면 HANDOFF + 최근 일기를 컨텍스트로 주입.
# 다른 위치에선 아무것도 출력하지 않음(타 프로젝트 영향 없음). stdout이 세션 컨텍스트로 들어간다.
# UTF-8로 읽고 UTF-8 바이트로 직접 출력 → 콘솔 코드페이지/리다이렉트 무관하게 한글 보존.
$root = 'f:\Prototyping'
$cwd  = (Get-Location).Path
if (-not $cwd.ToLower().StartsWith($root.ToLower())) { return }

$sb = New-Object System.Text.StringBuilder
function Add-Block($title, $body) {
    [void]$sb.AppendLine($title)
    [void]$sb.AppendLine($body)
    [void]$sb.AppendLine('')
}

if (Test-Path .\HANDOFF.md) {
    Add-Block '=== HANDOFF.md (현재 프로토타입 상태) ===' (Get-Content .\HANDOFF.md -Raw -Encoding UTF8)
}

$journalDir = Join-Path $root '_KIT\journal'
if (Test-Path $journalDir) {
    $latest = Get-ChildItem $journalDir -Filter '*.md' |
              Where-Object { $_.Name -ne 'README.md' } |
              Sort-Object Name -Descending | Select-Object -First 1
    if ($latest) {
        Add-Block "=== 최근 세션 일기: $($latest.Name) (프로토타이핑 과정 메모) ===" (Get-Content $latest.FullName -Raw -Encoding UTF8)
    }
}

# 미완료 마무리 리마인더: 변경사항 미커밋이거나 오늘 일기가 없으면 알림.
try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $dirty = git status --porcelain
        $today = Get-Date -Format 'yyyy-MM-dd'
        $todayJournal = Join-Path $journalDir "$today.md"
        $notes = @()
        if ($dirty) { $notes += '커밋 안 된 변경사항 있음' }
        if (-not (Test-Path $todayJournal)) { $notes += "오늘($today) 일기 아직 없음" }
        if ($notes.Count -gt 0) {
            Add-Block '=== 세션 종료 루틴 리마인더 (CLAUDE.md §9) ===' ('- ' + ($notes -join ' / ') + ' → 종료 전 HANDOFF 갱신·일기 작성·커밋 잊지 말 것.')
        }
    }
} catch {}

$bytes = [System.Text.Encoding]::UTF8.GetBytes($sb.ToString())
$stdout = [System.Console]::OpenStandardOutput()
$stdout.Write($bytes, 0, $bytes.Length)
$stdout.Flush()
