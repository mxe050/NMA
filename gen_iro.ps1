# gen_iro.ps1  (UTF-8 BOM で保存)
$base = Join-Path $PSScriptRoot 'refcode'
$src  = [System.IO.File]::ReadAllText("$base\iro.txt", [System.Text.Encoding]::UTF8)

# ---- 抽出 ----
$cssS = $src.IndexOf('<style>') + '<style>'.Length
$cssE = $src.IndexOf('</style>')
$css  = $src.Substring($cssS, $cssE - $cssS)

$bodyS = $src.IndexOf('<body>') + '<body>'.Length
$bodyE = $src.IndexOf('<script>')
$body  = $src.Substring($bodyS, $bodyE - $bodyS).Trim()

$jsS  = $src.IndexOf('<script>') + '<script>'.Length
$jsE  = $src.LastIndexOf('</script>')
$js   = $src.Substring($jsS, $jsE - $jsS).Trim()

# ---- CSS クラス名リネーム ----
$classMap = @(
    @('\.app-container\b',  '.iro5-wrap'),
    @('\.app-header\b',     '.iro5-header'),
    @('\.subtitle\b',       '.iro5-subtitle'),
    @('\.nav-tabs\b',       '.iro5-nav-tabs'),
    @('\.nav-tab\b',        '.iro5-nav-tab'),
    @('\.panel\b',          '.iro5-panel'),
    @('\.card\b',           '.iro5-card'),
    @('\.info-box\b',       '.iro5-info-box'),
    @('\.form-row\b',       '.iro5-form-row'),
    @('\.help-text\b',      '.iro5-help-text'),
    @('\.table-wrap\b',     '.iro5-table-wrap'),
    @('\.input-table\b',    '.iro5-input-table'),
    @('\.btn-group\b',      '.iro5-btn-group'),
    @('\.btn-primary\b',    '.iro5-btn-primary'),
    @('\.btn-success\b',    '.iro5-btn-success'),
    @('\.btn-warning\b',    '.iro5-btn-warning'),
    @('\.btn-danger\b',     '.iro5-btn-danger'),
    @('\.btn-secondary\b',  '.iro5-btn-secondary'),
    @('\.btn-sm\b',         '.iro5-btn-sm'),
    @('\.btn\b',            '.iro5-btn'),
    @('\.result-table\b',   '.iro5-result-table'),
    @('\.cat-header\b',     '.iro5-cat-header'),
    @('\.legend-grid\b',    '.iro5-legend-grid'),
    @('\.lg-row-hd\b',      '.iro5-lg-row-hd'),
    @('\.lg-header\b',      '.iro5-lg-header'),
    @('\.lg-cell\b',        '.iro5-lg-cell'),
    @('\.conclusion-box\b', '.iro5-conclusion-box'),
    @('\.conc-item\b',      '.iro5-conc-item'),
    @('\.cert-h\b',         '.iro5-cert-h'),
    @('\.cert-m\b',         '.iro5-cert-m'),
    @('\.cert-l\b',         '.iro5-cert-l'),
    @('\.cert-vl\b',        '.iro5-cert-vl'),
    @('\.doc-section\b',    '.iro5-doc-section'),
    @('\.ref-list\b',       '.iro5-ref-list'),
    @('\.ref-tag\b',        '.iro5-ref-tag')
)

foreach ($pair in $classMap) {
    $css = $css -replace $pair[0], $pair[1]
}

# ---- HTML クラス名リネーム ----
$htmlClassMap = @(
    @('class="app-container"',  'class="iro5-wrap"'),
    @('class="app-header"',     'class="iro5-header"'),
    @('class="subtitle"',       'class="iro5-subtitle"'),
    @('class="nav-tabs"',       'class="iro5-nav-tabs"'),
    @('class="nav-tab active"', 'class="iro5-nav-tab active"'),
    @('class="nav-tab"',        'class="iro5-nav-tab"'),
    @('class="panel active"',   'class="iro5-panel active"'),
    @('class="panel"',          'class="iro5-panel"'),
    @('class="card"',           'class="iro5-card"'),
    @('class="info-box warn"',  'class="iro5-info-box warn"'),
    @('class="info-box ref"',   'class="iro5-info-box ref"'),
    @('class="info-box"',       'class="iro5-info-box"'),
    @('class="form-row"',       'class="iro5-form-row"'),
    @('class="help-text"',      'class="iro5-help-text"'),
    @('class="table-wrap"',     'class="iro5-table-wrap"'),
    @('class="input-table"',    'class="iro5-input-table"'),
    @('class="btn-group"',      'class="iro5-btn-group"'),
    @('class="btn btn-primary"','class="iro5-btn iro5-btn-primary"'),
    @('class="btn btn-success"','class="iro5-btn iro5-btn-success"'),
    @('class="btn btn-warning"','class="iro5-btn iro5-btn-warning"'),
    @('class="btn btn-danger btn-sm"','class="iro5-btn iro5-btn-danger iro5-btn-sm"'),
    @('class="btn btn-danger"', 'class="iro5-btn iro5-btn-danger"'),
    @('class="btn btn-secondary"','class="iro5-btn iro5-btn-secondary"'),
    @('class="result-table"',   'class="iro5-result-table"'),
    @('class="cat-header"',     'class="iro5-cat-header"'),
    @('class="legend-grid"',    'class="iro5-legend-grid"'),
    @('class="lg-cell lg-header"','class="iro5-lg-cell iro5-lg-header"'),
    @('class="lg-cell lg-row-hd"','class="iro5-lg-cell iro5-lg-row-hd"'),
    @('class="lg-cell"',        'class="iro5-lg-cell"'),
    @('class="conclusion-box"', 'class="iro5-conclusion-box"'),
    @('class="doc-section"',    'class="iro5-doc-section"'),
    @('class="ref-list"',       'class="iro5-ref-list"'),
    @('class="ref-tag"',        'class="iro5-ref-tag"')
)

foreach ($pair in $htmlClassMap) {
    $body = $body -replace [regex]::Escape($pair[0]), $pair[1]
}

# conc-item + cert-* (動的に生成されるのでJSで対応)

# ---- HTML ID リネーム ----
$idMap = @(
    @('id="navTabs"',       'id="iro5-navTabs"'),
    @('id="p-guide"',       'id="iro5-p-guide"'),
    @('id="p-setup"',       'id="iro5-p-setup"'),
    @('id="p-data"',        'id="iro5-p-data"'),
    @('id="p-result"',      'id="iro5-p-result"'),
    @('id="p-conclusion"',  'id="iro5-p-conclusion"'),
    @('id="p-ref"',         'id="iro5-p-ref"'),
    @('id="s_outcome"',     'id="iro5-s_outcome"'),
    @('id="s_reference"',   'id="iro5-s_reference"'),
    @('id="s_direction"',   'id="iro5-s_direction"'),
    @('id="s_measure"',     'id="iro5-s_measure"'),
    @('id="t_b1"',          'id="iro5-t_b1"'),
    @('id="t_b2"',          'id="iro5-t_b2"'),
    @('id="t_b3"',          'id="iro5-t_b3"'),
    @('id="t_h1"',          'id="iro5-t_h1"'),
    @('id="t_h2"',          'id="iro5-t_h2"'),
    @('id="t_h3"',          'id="iro5-t_h3"'),
    @('id="tblInput"',      'id="iro5-tblInput"'),
    @('id="tblBody"',       'id="iro5-tblBody"'),
    @('id="resultArea"',    'id="iro5-resultArea"'),
    @('id="conclusionArea"','id="iro5-conclusionArea"')
)
$dataPanelMap = @(
    @('data-panel="p-guide"',      'data-panel="iro5-p-guide"'),
    @('data-panel="p-setup"',      'data-panel="iro5-p-setup"'),
    @('data-panel="p-data"',       'data-panel="iro5-p-data"'),
    @('data-panel="p-result"',     'data-panel="iro5-p-result"'),
    @('data-panel="p-conclusion"', 'data-panel="iro5-p-conclusion"'),
    @('data-panel="p-ref"',        'data-panel="iro5-p-ref"')
)

foreach ($pair in $idMap)        { $body = $body -replace [regex]::Escape($pair[0]), $pair[1] }
foreach ($pair in $dataPanelMap) { $body = $body -replace [regex]::Escape($pair[0]), $pair[1] }

# onclick 関数名リネーム（引数のパネルIDも iro5- に）
$body = $body -replace "onclick=""goTab\('p-",        'onclick="iro5_goTab(''iro5-p-'
$body = $body -replace "onclick=""loadExample\(",      'onclick="iro5_loadExample('
$body = $body -replace "onclick=""addRow\(",           'onclick="iro5_addRow('
$body = $body -replace "onclick=""clearData\(",        'onclick="iro5_clearData('
$body = $body -replace "onclick=""generate\(",         'onclick="iro5_generate('
$body = $body -replace 'onclick="this\.closest\(''tr''\)\.remove\(\)"', 'onclick="this.closest(''tr'').remove()"'

# ---- JS スコープ化 ----
# getElementById → iro5- prefix
$js = $js -replace "getElementById\('navTabs'\)",      "getElementById('iro5-navTabs')"
$js = $js -replace "getElementById\('p-",              "getElementById('iro5-p-"
$js = $js -replace "getElementById\('s_outcome'\)",    "getElementById('iro5-s_outcome')"
$js = $js -replace "getElementById\('s_reference'\)",  "getElementById('iro5-s_reference')"
$js = $js -replace "getElementById\('s_direction'\)",  "getElementById('iro5-s_direction')"
$js = $js -replace "getElementById\('s_measure'\)",    "getElementById('iro5-s_measure')"
$js = $js -replace "getElementById\('t_b1'\)",         "getElementById('iro5-t_b1')"
$js = $js -replace "getElementById\('t_b2'\)",         "getElementById('iro5-t_b2')"
$js = $js -replace "getElementById\('t_b3'\)",         "getElementById('iro5-t_b3')"
$js = $js -replace "getElementById\('t_h1'\)",         "getElementById('iro5-t_h1')"
$js = $js -replace "getElementById\('t_h2'\)",         "getElementById('iro5-t_h2')"
$js = $js -replace "getElementById\('t_h3'\)",         "getElementById('iro5-t_h3')"
$js = $js -replace "getElementById\('tblBody'\)",      "getElementById('iro5-tblBody')"
$js = $js -replace "querySelectorAll\('#tblBody tr'\)", "querySelectorAll('#iro5-tblBody tr')"
$js = $js -replace "getElementById\('resultArea'\)",   "getElementById('iro5-resultArea')"
$js = $js -replace "getElementById\('conclusionArea'\)","getElementById('iro5-conclusionArea')"

# querySelector で data-panel / .panel / .nav-tab を iro5- に
$js = $js -replace "querySelectorAll\('\.panel'\)",   "querySelectorAll('.iro5-panel')"
$js = $js -replace "querySelectorAll\('\.nav-tab'\)", "querySelectorAll('.iro5-nav-tab')"
$js = $js -replace "closest\('\.nav-tab'\)",          "closest('.iro5-nav-tab')"
# テンプレートリテラル内のセレクタは後でアウトプット全体に対して直接置換

# 関数名リネーム
$js = $js -replace '\bgoTab\b',           'iro5_goTab'
$js = $js -replace '\baddRow\b',          'iro5_addRow'
$js = $js -replace '\bclearData\b',       'iro5_clearData'
$js = $js -replace '\bloadExample\b',     'iro5_loadExample'
$js = $js -replace '\bgenerate\b',        'iro5_generate'
$js = $js -replace '\bbuildConclusions\b','iro5_buildConclusions'
$js = $js -replace '\bclassify\b',        'iro5_classify'
$js = $js -replace '\bcolorClass\b',      'iro5_colorClass'
$js = $js -replace '\brenderSection\b',   'iro5_renderSection'

# JS内の goTab('p-...') 呼び出し引数をリネーム
$js = $js -replace "iro5_goTab\('p-guide'\)",      "iro5_goTab('iro5-p-guide')"
$js = $js -replace "iro5_goTab\('p-setup'\)",      "iro5_goTab('iro5-p-setup')"
$js = $js -replace "iro5_goTab\('p-data'\)",       "iro5_goTab('iro5-p-data')"
$js = $js -replace "iro5_goTab\('p-result'\)",     "iro5_goTab('iro5-p-result')"
$js = $js -replace "iro5_goTab\('p-conclusion'\)", "iro5_goTab('iro5-p-conclusion')"
$js = $js -replace "iro5_goTab\('p-ref'\)",        "iro5_goTab('iro5-p-ref')"

# JSテンプレートリテラル内のボタンクラスも修正
$js = $js -replace '"btn btn-danger btn-sm"', '"iro5-btn iro5-btn-danger iro5-btn-sm"'

# conc-item クラス名 (JS内で動的生成)
$js = $js -replace '"conc-item "',     '"iro5-conc-item "'
$js = $js -replace "'cert-' \+",       "'iro5-cert-' +"
$js = $js -replace '"cert-h"',         '"iro5-cert-h"'
$js = $js -replace '"cert-m"',         '"iro5-cert-m"'
$js = $js -replace '"cert-l"',         '"iro5-cert-l"'
$js = $js -replace '"cert-vl"',        '"iro5-cert-vl"'

# result-table / cat-header をJSテンプレート内でもリネーム
$js = $js -replace '"result-table"',   '"iro5-result-table"'
$js = $js -replace '"cat-header"',     '"iro5-cat-header"'
$js = $js -replace '"table-wrap"',     '"iro5-table-wrap"'
$js = $js -replace '"conclusion-box"', '"iro5-conclusion-box"'
$js = $js -replace '"ref-tag"',        '"iro5-ref-tag"'

# CSS追加: conc-item はJSで生成されるため iro5- に合わせたスタイルも追加
$extraCss = @"

/* iro5 動的生成クラス */
.iro5-conc-item { margin-bottom:8px; padding:8px 12px; border-radius:0 4px 4px 0; background:#f8f9fa; font-size:0.92em; }
.iro5-conc-item.iro5-cert-h  { border-left:4px solid #27ae60; }
.iro5-conc-item.iro5-cert-m  { border-left:4px solid #3498db; }
.iro5-conc-item.iro5-cert-l  { border-left:4px solid #f39c12; }
.iro5-conc-item.iro5-cert-vl { border-left:4px solid #e74c3c; }
"@

# ---- 組み立て ----
$nl = [System.Environment]::NewLine

# iro5_goTab 上書きスクリプト（別ファイルから読み込み）
$goTabOverride = [System.IO.File]::ReadAllText("$base\iro_gotab_fix.js", [System.Text.Encoding]::UTF8)

$out  = "<!-- ===== タブ5: 効果と確実性の表記 ===== -->" + $nl
$out += "<style>" + $nl + $css + $extraCss + $nl + "</style>" + $nl
$out += $body + $nl
$out += "<script>" + $nl + $js + $nl + "</script>" + $nl
$out += $goTabOverride

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$base\iro_tab5.txt", $out, $utf8NoBom)
Write-Host "iro_tab5.txt written: $($out.Length) chars"
