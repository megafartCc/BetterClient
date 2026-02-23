param(
    [string]$Source = "C:\Users\da204\Downloads\uc\scripts\MeepoV2.lua",
    [string]$PartsRoot = "C:\out\BetterClient\modules\meepov2\parts"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source file not found: $Source"
}

if (-not (Test-Path -LiteralPath $PartsRoot)) {
    New-Item -ItemType Directory -Path $PartsRoot -Force | Out-Null
}

$lines = [System.IO.File]::ReadAllLines($Source)
$enc = New-Object System.Text.UTF8Encoding($false)

function Find-LineStart {
    param(
        [string]$Needle
    )
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].StartsWith($Needle, [System.StringComparison]::Ordinal)) {
            return $i + 1
        }
    }
    throw "Marker not found: $Needle"
}

function Write-Part {
    param(
        [string]$Path,
        [int]$Start,
        [int]$End
    )
    if ($Start -lt 1 -or $End -gt $lines.Count -or $Start -gt $End) {
        throw "Invalid range $Start..$End for $Path"
    }
    $count = $End - $Start + 1
    $slice = New-Object string[] $count
    [Array]::Copy($lines, $Start - 1, $slice, 0, $count)
    [System.IO.File]::WriteAllLines($Path, $slice, $enc)
}

$lineCombo  = Find-LineStart "function script.draw_combo_runtime_switch()"
$linePanels = Find-LineStart "function script.draw_meepo_status_world("
$lineFarm   = Find-LineStart "function script.run_autofarm_logic("
$lineHooks  = Find-LineStart "function script.OnDraw()"

Write-Part (Join-Path $PartsRoot "00_base.lua")   1                 ($lineCombo - 1)
Write-Part (Join-Path $PartsRoot "10_combo.lua")  $lineCombo        ($linePanels - 1)
Write-Part (Join-Path $PartsRoot "20_panels.lua") $linePanels       ($lineFarm - 1)
Write-Part (Join-Path $PartsRoot "30_farm.lua")   $lineFarm         ($lineHooks - 1)
Write-Part (Join-Path $PartsRoot "40_hooks.lua")  $lineHooks        $lines.Count

Write-Host "Split complete:"
Write-Host "  Source: $Source"
Write-Host "  Parts:  $PartsRoot"
