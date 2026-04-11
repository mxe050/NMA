# gen_stat3.ps1  (UTF-8 BOM で保存)
# NMAstat.txt はすでに stat3- プレフィックス付きCSSで記述済み
# → そのまま stat_tab3.txt にコピーするだけ

$base = Join-Path $PSScriptRoot 'refcode'
$src  = [System.IO.File]::ReadAllText("$base\NMAstat.txt", [System.Text.Encoding]::UTF8)

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$base\stat_tab3.txt", $src, $utf8NoBom)
Write-Host "stat_tab3.txt written: $($src.Length) chars"
