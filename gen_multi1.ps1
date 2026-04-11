$base = Join-Path $PSScriptRoot 'refcode'
$fm = [System.IO.File]::ReadAllText("$base\Multi1.txt", [System.Text.Encoding]::UTF8)

# --- パーツ抽出 ---
$asideStart = $fm.IndexOf('<aside')
$asideEnd   = $fm.IndexOf('</aside>') + 8
$aside      = $fm.Substring($asideStart, $asideEnd - $asideStart)

# sec1-6: <main>内のコンテンツ（<div id="remainingContent"></div>の直前まで）
$mainOpen  = '<main class="main-content" id="mainContent">'
$mainStart = $fm.IndexOf($mainOpen)
$remainingDiv = '<div id="remainingContent"></div>'
$mainContentEnd = $fm.IndexOf($remainingDiv)
$mainContent = $fm.Substring($mainStart + $mainOpen.Length, $mainContentEnd - $mainStart - $mainOpen.Length).Trim()

# sec7-14: JavaScriptテンプレートリテラル内のHTML
$assignPos = $fm.IndexOf("remainingContent').innerHTML = ")
$btStart   = $fm.IndexOf([char]96, $assignPos)   # 開始バッククォート
$btEnd     = $fm.IndexOf([char]96, $btStart + 1)  # 終端バッククォート
$tmplContent = $fm.Substring($btStart + 1, $btEnd - $btStart - 1).Trim()

# --- スコープ化 (クラス名・関数名・IDの衝突防止) ---
# セクションID を m1-secX に変換（タブ2とのid重複を防ぐ）
$aside        = $aside        -replace 'href="#sec',   'href="#m1-sec'
$aside        = $aside        -replace 'data-sec="sec', 'data-sec="m1-sec'
$mainContent  = $mainContent  -replace ' id="sec',     ' id="m1-sec'
$mainContent  = $mainContent  -replace 'href="#sec',   'href="#m1-sec'
$tmplContent  = $tmplContent  -replace ' id="sec',     ' id="m1-sec'
$tmplContent  = $tmplContent  -replace 'href="#sec',   'href="#m1-sec'

# aside クラス
$aside = $aside -replace 'class="sidebar"',        'class="m1-sidebar"'
$aside = $aside -replace 'id="sidebar"',           'id="m1-sidebar"'
$aside = $aside -replace 'class="sidebar-header"', 'class="m1-sidebar-header"'
$aside = $aside -replace 'class="toc-list"',       'class="m1-toc-list"'
$aside = $aside -replace 'id="tocList"',           'id="m1-tocList"'
$aside = $aside -replace 'class="toc-item"',       'class="m1-toc-item"'
$aside = $aside -replace 'class="toc-link"',       'class="m1-toc-link"'
$aside = $aside -replace 'class="toc-link sub"',   'class="m1-toc-link m1-sub"'
$aside = $aside -replace 'data-sec="',             'data-m1sec="'
$aside = $aside -replace 'onclick="toggleSidebar\(\)"', 'onclick="m1_toggleSidebar()"'

# mainContent: クラスをm1-プレフィックスに
# クラス置換を共通関数化
function ConvertClasses($html) {
    $html = $html -replace 'class="section"',             'class="m1-section"'
    $html = $html -replace 'class="section-header"',      'class="m1-section-header"'
    $html = $html -replace 'class="section-num"',         'class="m1-section-num"'
    $html = $html -replace 'class="section-body"',        'class="m1-section-body"'
    $html = $html -replace 'class="subsection"',          'class="m1-subsection"'
    $html = $html -replace 'class="quote-block"',         'class="m1-quote-block"'
    $html = $html -replace 'class="quote-source"',        'class="m1-quote-source"'
    $html = $html -replace 'class="key-point"',           'class="m1-key-point"'
    $html = $html -replace 'class="kp-title"',            'class="m1-kp-title"'
    $html = $html -replace 'class="warning-box"',         'class="m1-warning-box"'
    $html = $html -replace 'class="wb-title"',            'class="m1-wb-title"'
    $html = $html -replace 'class="success-box"',         'class="m1-success-box"'
    $html = $html -replace 'class="sb-title"',            'class="m1-sb-title"'
    $html = $html -replace 'class="explanation-box"',     'class="m1-explanation-box"'
    $html = $html -replace 'class="eb-title"',            'class="m1-eb-title"'
    $html = $html -replace 'class="data-table"',          'class="m1-data-table"'
    $html = $html -replace 'class="flow-diagram"',        'class="m1-flow-diagram"'
    $html = $html -replace 'class="flow-step"',           'class="m1-flow-step"'
    $html = $html -replace 'class="flow-arrow"',          'class="m1-flow-arrow"'
    $html = $html -replace 'class="flow-row"',            'class="m1-flow-row"'
    $html = $html -replace 'class="flow-vertical-arrow"', 'class="m1-flow-vertical-arrow"'
    $html = $html -replace 'class="comparison-grid"',     'class="m1-comparison-grid"'
    $html = $html -replace 'class="comparison-card"',     'class="m1-comparison-card"'
    $html = $html -replace 'class="cc-title"',            'class="m1-cc-title"'
    $html = $html -replace 'class="con"',                 'class="m1-con"'
    $html = $html -replace 'class="tabs"',                'class="m1-tabs"'
    $html = $html -replace 'class="tab-btn"',             'class="m1-tab-btn"'
    $html = $html -replace 'class="tab-content"',         'class="m1-tab-content"'
    $html = $html -replace 'class="stars"',               'class="m1-stars"'
    $html = $html -replace 'class="empty"',               'class="m1-empty"'
    return $html
}

$mainContent  = ConvertClasses $mainContent
$tmplContent  = ConvertClasses $tmplContent

# onclick="showTab(event,'xxx')" → onclick="m1ShowTab(event,'xxx')"
$mainContent  = $mainContent  -replace 'onclick="showTab\(event,', 'onclick="m1ShowTab(event,'
$tmplContent  = $tmplContent  -replace 'onclick="showTab\(event,', 'onclick="m1ShowTab(event,'

# --- CSS ---
$scopedCss = @"
/* ===== マルチ介入NMAタブ 専用スタイル ===== */
#mp-1 { box-sizing:border-box; }
.m1-outer { padding:16px 0; }

.m1-wrap {
  display:flex; gap:0;
  background:#fff; border-radius:8px;
  box-shadow:0 1px 5px rgba(0,0,0,.08);
  overflow:hidden; min-height:600px;
}

/* サイドバー */
.m1-sidebar {
  flex-shrink:0; width:260px;
  background:#f0f4f8; border-right:1px solid #cbd5e0;
  padding:0; font-size:0.83em;
  position:sticky; top:55px;
  max-height:calc(100vh - 60px); overflow-y:auto;
  transition:width .25s;
}
.m1-sidebar.hidden { width:0; overflow:hidden; }
.m1-sidebar-header {
  padding:12px 16px; font-weight:bold; color:#fff; font-size:0.88em;
  background:linear-gradient(135deg,#1a365d,#2c5282);
  letter-spacing:.03em; display:flex; align-items:center; gap:6px;
}
.m1-toc-list { list-style:none; padding:4px 0 8px; margin:0; }
.m1-toc-item { margin:0; }
/* 大見出しリンク（sec直下）*/
.m1-toc-link {
  display:block; padding:7px 14px 7px 16px; color:#2d3748;
  text-decoration:none; border-left:4px solid transparent; transition:all .15s;
  font-size:0.87em; line-height:1.45; font-weight:500;
}
.m1-toc-link:hover {
  background:#dbeafe; border-left-color:#3182ce; color:#1e40af;
}
.m1-toc-link.active {
  background:#dbeafe; border-left-color:#2563eb; color:#1e40af; font-weight:700;
}
/* サブリンク */
.m1-toc-link.m1-sub {
  padding-left:30px; font-size:0.82em; color:#4a5568; font-weight:400;
}
.m1-toc-link.m1-sub:hover, .m1-toc-link.m1-sub.active {
  background:#e0f2fe; border-left-color:#0ea5e9; color:#0369a1;
}
/* セクショングループ区切り */
.m1-toc-group {
  margin-top:6px; padding:4px 12px 2px;
  font-size:0.72em; font-weight:700; color:#718096;
  text-transform:uppercase; letter-spacing:.06em;
  border-top:1px solid #cbd5e0;
}

/* メインコンテンツ */
.m1-main {
  flex:1; min-width:0;
  padding:28px 40px 40px 40px;
  box-sizing:border-box; overflow-x:hidden;
}

/* セクション */
.m1-section {
  margin-bottom:24px;
  border:1px solid #e2e8f0; border-radius:8px; overflow:hidden;
  box-shadow:0 1px 4px rgba(0,0,0,.06);
}
.m1-section-header {
  background:linear-gradient(135deg,#1a365d,#2c5282);
  color:#fff; padding:14px 20px; cursor:pointer;
  display:flex; align-items:center; gap:12px;
  user-select:none;
}
.m1-section-header:hover { background:linear-gradient(135deg,#2c5282,#3182ce); }
.m1-section-num {
  background:rgba(255,255,255,.2); border-radius:4px;
  padding:2px 8px; font-size:0.78em; font-weight:bold; white-space:nowrap;
}
.m1-section-header h2 { font-size:1.05em; margin:0; font-weight:600; }
.m1-section-body { padding:20px 24px; }
.m1-section-body.hidden { display:none; }

/* サブセクション */
.m1-subsection { margin:18px 0; padding-left:14px; border-left:3px solid #3182ce; }
.m1-subsection h3 { color:#1a365d; font-size:1.0em; margin-bottom:8px; }
.m1-subsection h4 { color:#2c5282; font-size:0.9em; margin:10px 0 4px; }

/* 引用ブロック */
.m1-quote-block {
  background:#f7fafc; border-left:4px solid #3182ce;
  padding:12px 16px; margin:12px 0; border-radius:0 6px 6px 0;
  font-size:0.9em; color:#2d3748;
}
.m1-quote-source { font-size:0.8em; color:#718096; margin-top:6px; }

/* キーポイント */
.m1-key-point {
  background:#f0fff4; border:1px solid #9ae6b4; border-radius:6px;
  padding:14px 16px; margin:12px 0;
}
.m1-kp-title { font-weight:bold; color:#276749; margin-bottom:6px; font-size:0.9em; }

/* 警告・成功・説明ボックス */
.m1-warning-box {
  background:#fff5f5; border:1px solid #feb2b2; border-radius:6px;
  padding:14px 16px; margin:12px 0;
}
.m1-wb-title { font-weight:bold; color:#c53030; margin-bottom:6px; font-size:0.9em; }
.m1-success-box {
  background:#f0fff4; border:1px solid #9ae6b4; border-radius:6px;
  padding:14px 16px; margin:12px 0;
}
.m1-sb-title { font-weight:bold; color:#276749; margin-bottom:6px; font-size:0.9em; }
.m1-explanation-box {
  background:#ebf8ff; border:1px solid #90cdf4; border-radius:6px;
  padding:14px 16px; margin:12px 0;
}
.m1-eb-title { font-weight:bold; color:#2b6cb0; margin-bottom:6px; font-size:0.9em; }

/* テーブル */
.m1-data-table { overflow-x:auto; margin:14px 0; }
.m1-data-table table { width:100%; border-collapse:collapse; font-size:0.88em; }
.m1-data-table th { background:#1a365d; color:#fff; padding:9px 12px; text-align:left; font-weight:600; }
.m1-data-table td { border:1px solid #e2e8f0; padding:8px 12px; text-align:left; vertical-align:top; }
.m1-data-table tr:nth-child(even) { background:#f7fafc; }
.m1-data-table tr:hover { background:#ebf4ff; }
.m1-wrap table { width:100%; border-collapse:collapse; font-size:0.88em; display:block; overflow-x:auto; }
.m1-wrap th { background:#1a365d; color:#fff; padding:9px 12px; font-weight:600; }
.m1-wrap td { border:1px solid #e2e8f0; padding:8px 12px; vertical-align:top; }
.m1-wrap tr:nth-child(even) { background:#f7fafc; }

/* フロー図 */
.m1-flow-diagram { margin:16px 0; }
.m1-flow-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin:8px 0; }
.m1-flow-step {
  background:#ebf4ff; border:1px solid #90cdf4; border-radius:6px;
  padding:8px 14px; font-size:0.88em; color:#1a365d; min-width:80px; text-align:center;
}
.m1-flow-arrow { color:#3182ce; font-size:1.2em; font-weight:bold; }
.m1-flow-vertical-arrow { text-align:center; color:#3182ce; font-size:1.2em; margin:4px 0; }

/* 比較グリッド */
.m1-comparison-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(220px,1fr)); gap:12px; margin:14px 0; }
.m1-comparison-card { border:1px solid #e2e8f0; border-radius:8px; padding:16px; background:#fff; }
.m1-cc-title { font-weight:bold; color:#1a365d; margin-bottom:8px; font-size:0.9em; }
.m1-con { font-size:0.87em; color:#4a5568; margin:3px 0; padding-left:12px; }

/* タブ */
.m1-tabs { margin:14px 0; }
.m1-tab-btn {
  padding:8px 16px; border:none; background:#e2e8f0; cursor:pointer;
  font-size:0.88em; border-radius:6px 6px 0 0; transition:background .2s; margin-right:2px;
}
.m1-tab-btn.active { background:#1a365d; color:#fff; }
.m1-tab-content { display:none; padding:16px; border:1px solid #e2e8f0; border-radius:0 6px 6px 6px; background:#fff; }
.m1-tab-content.active { display:block; }

/* 星評価 */
.m1-stars { color:#d69e2e; letter-spacing:2px; }
.m1-empty { color:#e2e8f0; }

/* 汎用テキスト要素 */
.m1-wrap p { margin-bottom:12px; line-height:1.75; text-align:justify; }
.m1-wrap code { background:#edf2f7; padding:2px 6px; border-radius:3px; font-family:Consolas,Monaco,monospace; font-size:0.88em; }
.m1-wrap pre { background:#1a202c; color:#e2e8f0; padding:16px; border-radius:6px; overflow-x:auto; font-size:0.85em; line-height:1.5; margin:12px 0; }
.m1-wrap strong { color:#1a365d; }
.m1-wrap ul, .m1-wrap ol { padding-left:24px; margin:10px 0; }
.m1-wrap li { margin:4px 0; line-height:1.7; font-size:0.94em; }

/* レスポンシブ */
@media (max-width:900px) {
  .m1-wrap { flex-direction:column; border-radius:0; }
  .m1-sidebar { width:100%; position:static; max-height:none; border-right:none; border-bottom:1px solid #dee2e6; }
  .m1-main { padding:20px; }
  .m1-comparison-grid { grid-template-columns:1fr; }
}
@media (max-width:600px) {
  .m1-main { padding:14px; }
  .m1-section-header h2 { font-size:0.95em; }
}
"@

# --- JavaScript ---
$js = @"
<script>
// ===== マルチ介入NMAタブ 専用JavaScript =====
(function(){
  // サイドバートグル
  window.m1_toggleSidebar = function() {
    document.getElementById('m1-sidebar').classList.toggle('hidden');
  };

  // タブ切替（onclick="m1ShowTab(event,'tabId')" から呼ばれる）
  window.m1ShowTab = function(evt, tabId) {
    var btn = evt.currentTarget;
    var tabsContainer = btn.parentElement;          // .m1-tabs
    var sectionBody   = tabsContainer.parentElement; // .m1-section-body
    tabsContainer.querySelectorAll('.m1-tab-btn').forEach(function(b){ b.classList.remove('active'); });
    sectionBody.querySelectorAll('.m1-tab-content').forEach(function(c){ c.classList.remove('active'); });
    btn.classList.add('active');
    var tc = sectionBody.querySelector('#'+tabId);
    if(tc) tc.classList.add('active');
  };

  // セクションヘッダークリックで折りたたみ
  document.addEventListener('DOMContentLoaded', function(){
    // ヘッダークリックで本文トグル
    document.querySelectorAll('.m1-section-header').forEach(function(hdr){
      hdr.addEventListener('click', function(){
        var body = hdr.nextElementSibling;
        if(body && body.classList.contains('m1-section-body')){
          body.classList.toggle('hidden');
        }
      });
    });

    // TOCリンクで該当セクションにスクロール
    document.querySelectorAll('.m1-toc-link').forEach(function(link){
      link.addEventListener('click', function(e){
        e.preventDefault();
        var secId = this.getAttribute('href').replace('#','');
        // m1-mainの中で検索（ID重複対策）
        var main = document.getElementById('m1-mainContent');
        var target = main ? main.querySelector('#'+secId) : document.getElementById(secId);
        if(target){
          var body = target.querySelector('.m1-section-body');
          if(body) body.classList.remove('hidden');
          target.scrollIntoView({behavior:'smooth', block:'start'});
          document.querySelectorAll('.m1-toc-link').forEach(function(l){ l.classList.remove('active'); });
          this.classList.add('active');
        }
      });
    });

    // タブ切替
    document.querySelectorAll('.m1-tab-btn').forEach(function(btn){
      btn.addEventListener('click', function(){
        var container = btn.closest('.m1-tabs');
        if(!container) return;
        var target = btn.getAttribute('data-tab');
        container.querySelectorAll('.m1-tab-btn').forEach(function(b){ b.classList.remove('active'); });
        container.querySelectorAll('.m1-tab-content').forEach(function(c){ c.classList.remove('active'); });
        btn.classList.add('active');
        var tc = container.querySelector('#'+target);
        if(tc) tc.classList.add('active');
      });
    });

    // IntersectionObserver でTOCハイライト
    var sections = document.querySelectorAll('.m1-section');
    if(sections.length && 'IntersectionObserver' in window){
      var obs = new IntersectionObserver(function(entries){
        entries.forEach(function(entry){
          if(entry.isIntersecting){
            var id = entry.target.id;
            document.querySelectorAll('.m1-toc-link').forEach(function(l){ l.classList.remove('active'); });
            var al = document.querySelector('.m1-toc-link[href="#'+id+'"]');
            if(al) al.classList.add('active');
          }
        });
      }, {threshold:0.2});
      sections.forEach(function(s){ obs.observe(s); });
    }
  });
})();
</script>
"@

# --- 組み立て ---
$nl = [System.Environment]::NewLine
$tab1  = "<!-- ===== タブ1: マルチ介入NMA ===== -->" + $nl
$tab1 += "<style>" + $nl + $scopedCss + $nl + "</style>" + $nl
$tab1 += "<div class='container m1-outer'>" + $nl
$tab1 += "<div class='m1-wrap'>" + $nl
$tab1 += $aside + $nl
$tab1 += "<main class='m1-main' id='m1-mainContent'>" + $nl
$tab1 += $mainContent + $nl
$tab1 += $tmplContent + $nl
$tab1 += "</main>" + $nl + "</div>" + $nl
$tab1 += "</div>" + $nl
$tab1 += $js

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$base\Multi_tab1.txt", $tab1, $utf8NoBom)
Write-Host "Multi_tab1.txt written: $($tab1.Length) chars"
