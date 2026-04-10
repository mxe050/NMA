# gen_stat3.ps1  (UTF-8 BOM で保存)
$base = Join-Path $PSScriptRoot 'refcode'
$src  = [System.IO.File]::ReadAllText("$base\NMAstat.txt", [System.Text.Encoding]::UTF8)

# ---- CSS 抽出 ----
$cssS = $src.IndexOf('<style>') + '<style>'.Length
$cssE = $src.IndexOf('</style>')
$css  = $src.Substring($cssS, $cssE - $cssS)

# ---- body コンテンツ抽出: <nav>は除外、<header>から</main>まで ----
$heroStart = $src.IndexOf('<header class="hero">')
$mainEnd   = $src.IndexOf('</main>') + '</main>'.Length
$bodyMain  = $src.Substring($heroStart, $mainEnd - $heroStart)

# refs section も main の中にあるので含まれている
# back-to-top ボタン
$bttS = $src.IndexOf('<button id="btt"')
$bttE = $src.IndexOf('</button>', $bttS) + '</button>'.Length
$btt  = $src.Substring($bttS, $bttE - $bttS)

# ---- JS 抽出 ----
$jsS = $src.IndexOf('<script>') + '<script>'.Length
$jsE = $src.LastIndexOf('</script>')
$js  = $src.Substring($jsS, $jsE - $jsS).Trim()

# ---- CSS スコープ化: ルート変数を :root から .stat3-outer に ----
$css = $css -replace ':root\{', '.stat3-outer{'

# nav (fixed) スタイル除去 (外側のナビと競合するため)
$css = $css -replace '(?s)nav\{[^}]+\}', ''
$css = $css -replace '(?s)nav \.inner\{[^}]+\}', ''
$css = $css -replace '(?s)nav \.logo\{[^}]+\}', ''
$css = $css -replace '(?s)nav \.links\{[^}]+\}', ''
$css = $css -replace '(?s)nav \.links a\{[^}]+\}', ''
$css = $css -replace '(?s)nav \.links a:hover\{[^}]+\}', ''
$css = $css -replace '(?s)#menu-toggle\{[^}]+\}', ''

# position:fixed の #btt はそのまま使えるが、既に外側のトップボタンがあるので除去
$css = $css -replace '(?s)#btt\{[^}]+\}', ''
$css = $css -replace '(?s)#btt\.show\{[^}]+\}', ''

# hero の margin-top:56px → 0 (固定navがないため)
$css = $css -replace 'margin-top:56px;', 'margin-top:0;'

# セレクタをスコープ化
$css = $css -replace 'html\{',           '.stat3-outer html{'
$css = $css -replace 'body\{',           '.stat3-outer {'
$css = $css -replace 'a\{',              '.stat3-outer a{'
$css = $css -replace 'a:hover\{',        '.stat3-outer a:hover{'
$css = $css -replace '\.hero\{',         '.stat3-outer .stat3-hero{'
$css = $css -replace '\.hero h1\{',      '.stat3-outer .stat3-hero h1{'
$css = $css -replace '\.hero \.sub\{',   '.stat3-outer .stat3-hero .stat3-sub{'
$css = $css -replace '\.hero h1 span\{', '.stat3-outer .stat3-hero h1 span{'
$css = $css -replace '\.toc-section\{',  '.stat3-outer .stat3-toc-section{'
$css = $css -replace '\.toc-section \.inner\{', '.stat3-outer .stat3-toc-section .stat3-inner{'
$css = $css -replace '\.toc-section h2\{', '.stat3-outer .stat3-toc-section h2{'
$css = $css -replace '\.toc-grid\{',     '.stat3-outer .stat3-toc-grid{'
$css = $css -replace '\.toc-grid a\{',   '.stat3-outer .stat3-toc-grid a{'
$css = $css -replace '\.toc-grid a:hover\{', '.stat3-outer .stat3-toc-grid a:hover{'
$css = $css -replace '\.toc-grid a \.num\{', '.stat3-outer .stat3-toc-grid a .stat3-num{'
$css = $css -replace 'main\{',           '.stat3-outer .stat3-main{'
$css = $css -replace 'section\{',        '.stat3-outer .stat3-main section{'
$css = $css -replace 'section h2\{',     '.stat3-outer .stat3-main section h2{'
$css = $css -replace 'section h3\{',     '.stat3-outer .stat3-main section h3{'
$css = $css -replace 'section h4\{',     '.stat3-outer .stat3-main section h4{'
$css = $css -replace 'p\{',              '.stat3-outer p{'
$css = $css -replace '\.note\{',         '.stat3-outer .stat3-note{'
$css = $css -replace '\.note\.green\{',  '.stat3-outer .stat3-note.stat3-green{'
$css = $css -replace '\.note\.warn\{',   '.stat3-outer .stat3-note.stat3-warn{'
$css = $css -replace '\.table-wrap\{',   '.stat3-outer .stat3-table-wrap{'
$css = $css -replace 'table\{',          '.stat3-outer table{'
$css = $css -replace 'th,td\{',          '.stat3-outer th, .stat3-outer td{'
$css = $css -replace 'th\{',             '.stat3-outer th{'
$css = $css -replace 'td\{',             '.stat3-outer td{'
$css = $css -replace 'pre\{',            '.stat3-outer pre{'
$css = $css -replace 'code\{',           '.stat3-outer code{'
$css = $css -replace '\.inline-code\{',  '.stat3-outer .stat3-inline-code{'
$css = $css -replace '\.ref-list\{',     '.stat3-outer .stat3-ref-list{'
$css = $css -replace '\.ref-list p\{',   '.stat3-outer .stat3-ref-list p{'
$css = $css -replace 'sup\{',            '.stat3-outer sup{'

# メディアクエリ内
$css = $css -replace '@media\(max-width:700px\)\{nav \.links\{display:none\}nav \.links\.open\{[^}]+\}[^}]+#menu-toggle\{display:block\}', '@media(max-width:700px){'
$css = $css -replace '\.hero\{padding:3\.5rem 1rem 2rem\}', '.stat3-hero{padding:3.5rem 1rem 2rem}'
$css = $css -replace 'main\{padding:0 1rem 3rem\}', '.stat3-main{padding:0 1rem 3rem}'

# ---- HTML クラス/ID リネーム ----
# hero
$bodyMain = $bodyMain -replace 'class="hero"',         'class="stat3-hero"'
$bodyMain = $bodyMain -replace 'class="sub"',           'class="stat3-sub"'
# toc-section
$bodyMain = $bodyMain -replace 'class="toc-section"',   'class="stat3-toc-section"'
$bodyMain = $bodyMain -replace 'class="inner"',         'class="stat3-inner"'
$bodyMain = $bodyMain -replace 'class="toc-grid"',      'class="stat3-toc-grid"'
$bodyMain = $bodyMain -replace 'class="num"',            'class="stat3-num"'
# main
$bodyMain = $bodyMain -replace '<main>',                '<div class="stat3-main">'
$bodyMain = $bodyMain -replace '</main>',               '</div>'
# note
$bodyMain = $bodyMain -replace 'class="note green"',    'class="stat3-note stat3-green"'
$bodyMain = $bodyMain -replace 'class="note warn"',     'class="stat3-note stat3-warn"'
$bodyMain = $bodyMain -replace 'class="note"',          'class="stat3-note"'
# table-wrap
$bodyMain = $bodyMain -replace 'class="table-wrap"',    'class="stat3-table-wrap"'
# inline-code
$bodyMain = $bodyMain -replace 'class="inline-code"',   'class="stat3-inline-code"'
# ref-list
$bodyMain = $bodyMain -replace 'class="ref-list"',      'class="stat3-ref-list"'
# header を section に変換（outer の app-header と混在しないよう）
$bodyMain = $bodyMain -replace '<header class="stat3-hero">', '<div class="stat3-hero">'
$bodyMain = $bodyMain -replace '</header>', '</div>'

# IDs をスコープ化（章アンカー）
$bodyMain = $bodyMain -replace ' id="ch',  ' id="stat3-ch'
$bodyMain = $bodyMain -replace ' id="refs"', ' id="stat3-refs"'
$bodyMain = $bodyMain -replace 'href="#ch', 'href="#stat3-ch'
$bodyMain = $bodyMain -replace 'href="#refs"', 'href="#stat3-refs"'

# ---- JS: IDリネーム・スコープ化 ----
# menu-toggle と nav-links は削除（nav自体を除外したため不要）
$js = $js -replace "document\.getElementById\('menu-toggle'\)\.addEventListener\('click',function\(\)\{document\.getElementById\('nav-links'\)\.classList\.toggle\('open'\)\}\);", ''
$js = $js -replace "document\.querySelectorAll\('#nav-links a'\)\.forEach\(function\(a\)\{a\.addEventListener\('click',function\(\)\{document\.getElementById\('nav-links'\)\.classList\.remove\('open'\)\}\)\}\);", ''
# btt は外側のグローバルボタンがあるため不要
$js = $js -replace "var b=document\.getElementById\('btt'\);window\.addEventListener\('scroll',function\(\)\{b\.classList\.toggle\('show',window\.scrollY>500\)\}\);", ''
$js = $js -replace "b\.addEventListener\('click',function\(\)\{window\.scrollTo\(\{top:0,behavior:'smooth'\}\)\}\);", ''

# ---- 組み立て ----
$nl = [System.Environment]::NewLine
$out  = "<!-- ===== タブ3: 統計的解説 ===== -->" + $nl
$out += "<style>" + $nl + $css + $nl + "</style>" + $nl
$out += "<div class='stat3-outer'>" + $nl
$out += $bodyMain + $nl
$out += "</div>" + $nl
if ($js.Trim() -ne '') {
    $out += "<script>" + $nl + $js + $nl + "</script>" + $nl
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$base\stat_tab3.txt", $out, $utf8NoBom)
Write-Host "stat_tab3.txt written: $($out.Length) chars"
