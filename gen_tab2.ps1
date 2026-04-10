$base = Join-Path $PSScriptRoot 'refcode'
$f1 = [System.IO.File]::ReadAllText("$base\NMA1.txt", [System.Text.Encoding]::UTF8)
$f2 = [System.IO.File]::ReadAllText("$base\NMA2.txt", [System.Text.Encoding]::UTF8)

# --- NMA1から各パーツ抽出 ---
$sidebarStart = $f1.IndexOf('<nav class="sidebar"')
$sidebarEnd   = $f1.IndexOf('</nav>') + 6
$sidebar      = $f1.Substring($sidebarStart, $sidebarEnd - $sidebarStart)

$mainOpen    = '<main class="content" id="mainContent">'
$mainStart   = $f1.IndexOf($mainOpen)
$mainEnd     = $f1.IndexOf('</main>')
$mainContent = $f1.Substring($mainStart + $mainOpen.Length, $mainEnd - $mainStart - $mainOpen.Length)

# --- 関数名をスコープ化（メインアプリとの衝突防止）---
$sidebar = $sidebar -replace 'class="sidebar"',  'class="nma2-sidebar"'
$sidebar = $sidebar -replace 'id="sidebar"',      'id="nma2-sidebar"'
$sidebar = $sidebar -replace 'onclick="showSection\(', 'onclick="showNMA2Section('

$mainContent = $mainContent -replace 'onclick="showSection\(',       'onclick="showNMA2Section('
$mainContent = $mainContent -replace 'onclick="openTab\(',           'onclick="nma2OpenTab('
$mainContent = $mainContent -replace 'onclick="toggleCollapsible\(', 'onclick="nma2ToggleCollapsible('
$mainContent = $mainContent -replace "onclick='showSection\(",       "onclick='showNMA2Section("
$mainContent = $mainContent -replace "onclick='openTab\(",           "onclick='nma2OpenTab("

$ext2 = $f2 -replace 'onclick="openTab\(',           'onclick="nma2OpenTab('
$ext2 = $ext2 -replace 'onclick="toggleCollapsible\(', 'onclick="nma2ToggleCollapsible('
$ext2 = $ext2 -replace "onclick='openTab\(",           "onclick='nma2OpenTab("
$ext2 = $ext2 -replace "onclick='toggleCollapsible\(", "onclick='nma2ToggleCollapsible("

# --- スコープ済みCSS ---
$scopedCss = @"
/* ===== NMAの基本タブ 専用スタイル ===== */
#mp-2 { box-sizing:border-box; }
.nma2-outer { padding:16px 0; }
.nma2-wrap {
  display:flex; gap:0;
  background:#fff; border-radius:8px;
  box-shadow:0 1px 5px rgba(0,0,0,.08);
  overflow:hidden;
  min-height:600px;
}
.nma2-sidebar {
  flex-shrink:0; width:240px;
  background:#f8f9fa; border-right:1px solid #dee2e6;
  padding:12px 0; font-size:0.82em;
  position:sticky; top:55px;
  max-height:calc(100vh - 60px); overflow-y:auto;
}
.nma2-sidebar .nav-section {
  padding:7px 14px; font-weight:bold; color:#1a5276; font-size:0.9em;
  border-bottom:1px solid #dee2e6; background:#dce9f5; margin-top:4px;
}
.nma2-sidebar a {
  display:block; padding:5px 14px 5px 20px; color:#2c3e50;
  text-decoration:none; border-left:3px solid transparent; transition:all 0.15s;
  font-size:0.92em; line-height:1.5;
}
.nma2-sidebar a:hover,.nma2-sidebar a.active {
  background:#eaf2f8; border-left-color:#2980b9; color:#2980b9;
}
.nma2-sidebar a.sub { padding-left:32px; font-size:0.88em; color:#5d6d7e; }
.nma2-main {
  flex:1; min-width:0;
  padding:28px 40px 40px 40px;
  box-sizing:border-box; overflow-x:hidden;
}
.nma2-wrap .timeline { border-left:3px solid #2e86c1; padding-left:25px; margin:20px 0; }
.nma2-wrap .timeline-item { margin-bottom:20px; position:relative; }
.nma2-wrap .timeline-item::before {
  content:''; position:absolute; left:-32px; top:5px;
  width:12px; height:12px; background:#2e86c1; border-radius:50%; border:2px solid white;
}
.nma2-wrap .timeline-item .year { font-weight:bold; color:#2e86c1; font-size:0.95em; }
.nma2-wrap .tag { display:inline-block; padding:2px 8px; border-radius:3px; font-size:0.8em; font-weight:bold; margin:2px; }
.nma2-wrap .tag-free     { background:#d5f5e3; color:#1e8449; }
.nma2-wrap .tag-paid     { background:#fadbd8; color:#c0392b; }
.nma2-wrap .tag-r        { background:#d6eaf8; color:#2471a3; }
.nma2-wrap .tag-web      { background:#fdebd0; color:#ca6f1e; }
.nma2-wrap .tag-bayesian { background:#e8daef; color:#7d3c98; }
.nma2-wrap .tag-freq     { background:#d5dbdb; color:#566573; }
.nma2-wrap .network-diagram {
  text-align:center; padding:20px; margin:15px 0;
  background:#f8f9fa; border-radius:8px; border:1px solid #d5dbdb;
}
.nma2-wrap .network-diagram svg { max-width:100%; }
.nma2-wrap .tab-container { margin:20px 0; }
.nma2-wrap .tab-buttons { display:flex; border-bottom:2px solid #d5dbdb; }
.nma2-wrap .tab-btn {
  padding:10px 20px; border:none; background:#ecf0f1; cursor:pointer;
  font-size:0.9em; transition:all 0.2s; border-bottom:3px solid transparent;
}
.nma2-wrap .tab-btn.active { background:#fff; border-bottom-color:#2e86c1; color:#2e86c1; font-weight:bold; }
.nma2-wrap .tab-content { display:none; padding:20px; background:#fff; border:1px solid #d5dbdb; border-top:none; }
.nma2-wrap .tab-content.active { display:block; }
.nma2-wrap .step-list { counter-reset:step; list-style:none; padding:0; }
.nma2-wrap .step-list li {
  counter-increment:step; padding:12px 15px 12px 55px; margin:8px 0;
  background:#fff; border:1px solid #d5dbdb; border-radius:4px; position:relative;
}
.nma2-wrap .step-list li::before {
  content:counter(step); position:absolute; left:15px; top:50%; transform:translateY(-50%);
  width:28px; height:28px; background:#2e86c1; color:white; border-radius:50%;
  display:flex; align-items:center; justify-content:center; font-weight:bold; font-size:0.85em;
}
.nma2-wrap .toggle-btn {
  background:#2e86c1; color:white; border:none; padding:8px 16px;
  border-radius:4px; cursor:pointer; font-size:0.9em; margin:5px 0;
}
.nma2-wrap .toggle-btn:hover { background:#1a5276; }
.nma2-wrap .collapsible { display:none; margin:10px 0; padding:15px; background:#f8f9fa; border-radius:4px; border:1px solid #d5dbdb; }
.nma2-wrap .collapsible.open { display:block; }
.nma2-wrap code { background:#f4f6f7; padding:2px 6px; border-radius:3px; font-family:Consolas,Monaco,monospace; font-size:0.9em; }
.nma2-wrap .code-block { background:#2d2d2d; color:#f8f8f2; padding:15px; border-radius:6px; overflow-x:auto; font-family:Consolas,Monaco,monospace; font-size:0.85em; line-height:1.5; margin:15px 0; }
.nma2-wrap .formula { background:#f4f6f7; border:1px solid #d5dbdb; padding:15px; margin:15px 0; text-align:center; font-family:'Cambria Math',serif; font-size:1.1em; border-radius:4px; overflow-x:auto; word-break:break-word; }
.nma2-wrap .ref { background:#fef9e7; border-left:4px solid #f39c12; padding:10px 15px; margin:12px 0; font-size:0.88em; border-radius:0 4px 4px 0; word-break:break-word; }
.nma2-wrap .ref strong { color:#e67e22; }
.nma2-wrap .note { background:#eaf2f8; border-left:4px solid #3498db; padding:12px 15px; margin:12px 0; border-radius:0 4px 4px 0; word-break:break-word; }
.nma2-wrap .warning-box { background:#fdedec; border-left:4px solid #e74c3c; padding:12px 15px; margin:12px 0; border-radius:0 4px 4px 0; word-break:break-word; }
.nma2-wrap .card { background:#fff; border:1px solid #d5dbdb; border-radius:8px; padding:20px; margin:15px 0; box-shadow:0 2px 5px rgba(0,0,0,.05); overflow-x:auto; }
.nma2-wrap .card h4 { color:#1a5276; margin-bottom:10px; }
.nma2-wrap table { width:100%; border-collapse:collapse; margin:15px 0; font-size:0.9em; display:block; overflow-x:auto; }
.nma2-wrap th,
.nma2-wrap td { border:1px solid #d5dbdb; padding:10px 12px; text-align:left; }
.nma2-wrap th { background:#1a5276; color:white; font-weight:600; }
.nma2-wrap tr:nth-child(even) { background:#f8f9fa; }
.nma2-wrap tr:hover { background:#eaf2f8; }
.nma2-wrap .section { margin-bottom:50px; }
.nma2-wrap .section h2 { font-size:1.5em; color:#1a5276; border-bottom:3px solid #2e86c1; padding-bottom:8px; margin-bottom:20px; }
.nma2-wrap .section h3 { font-size:1.2em; color:#2e86c1; margin:25px 0 12px; padding-left:12px; border-left:4px solid #2e86c1; }
.nma2-wrap .section h4 { font-size:1.05em; color:#2c3e50; margin:18px 0 8px; font-weight:600; }
.nma2-wrap p { margin-bottom:14px; text-align:justify; }
.nma2-wrap .bucher-form { background:#f8f9fa; border:1px solid #d5dbdb; border-radius:8px; padding:20px; margin:15px 0; }
.nma2-wrap .bucher-form label { font-size:0.9em; color:#5d6d7e; display:block; margin:5px 0 2px; }
.nma2-wrap .bucher-form input { width:100%; padding:7px 10px; border:1px solid #d5dbdb; border-radius:4px; font-size:0.95em; }
.nma2-wrap .bucher-form button { background:#2e86c1; color:white; border:none; padding:10px 24px; border-radius:4px; cursor:pointer; font-size:0.95em; margin-top:10px; }
.nma2-wrap .bucher-form button:hover { background:#1a5276; }
.nma2-wrap #bucherResult { display:none; margin-top:12px; padding:12px 16px; background:#d5f5e3; border-left:4px solid #27ae60; border-radius:0 4px 4px 0; }
@media (max-width:900px) {
  .nma2-wrap { flex-direction:column; border-radius:0; }
  .nma2-sidebar { width:100%; position:static; max-height:none; border-right:none; border-bottom:1px solid #dee2e6; }
  .nma2-main { padding:20px 20px; }
}
@media (max-width:600px) {
  .nma2-main { padding:14px 14px; }
  .nma2-wrap .section h2 { font-size:1.2em; }
  .nma2-wrap .section h3 { font-size:1.05em; }
}
"@

# --- JavaScript ---
$js = @"
<script>
// ===== NMAの基本タブ 専用JavaScript =====
(function(){
  window.showNMA2Section = function(sectionId) {
    var wrap = document.getElementById('nma2-content-wrap');
    if (!wrap) return;
    wrap.querySelectorAll('.section').forEach(function(s){ s.style.display='none'; });
    var t = document.getElementById(sectionId);
    if (t) t.style.display = 'block';
    document.querySelectorAll('#nma2-sidebar a').forEach(function(l){ l.classList.remove('active'); });
    var al = document.querySelector('#nma2-sidebar a[href="#'+sectionId+'"]');
    if (al) al.classList.add('active');
    var mc = document.getElementById('nma2-content-wrap');
    if (mc) mc.parentElement.scrollTop = 0;
  };

  window.nma2OpenTab = function(evt, tabName) {
    var container = evt.target.closest('.tab-container');
    if (!container) return;
    container.querySelectorAll('.tab-content').forEach(function(c){ c.classList.remove('active'); });
    container.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
    var tgt = container.querySelector('#'+tabName);
    if (tgt) tgt.classList.add('active');
    evt.target.classList.add('active');
  };

  window.nma2ToggleCollapsible = function(id) {
    var el = document.getElementById(id);
    if (el) el.classList.toggle('open');
  };

  window.calcBucher = function() {
    var logAC = parseFloat(document.getElementById('logAC').value)||0;
    var seAC  = parseFloat(document.getElementById('seAC').value)||0;
    var logBC = parseFloat(document.getElementById('logBC').value)||0;
    var seBC  = parseFloat(document.getElementById('seBC').value)||0;
    var logAB = logAC - logBC;
    var seAB  = Math.sqrt(seAC*seAC + seBC*seBC);
    var z     = 1.96;
    var lower = Math.exp(logAB - z*seAB);
    var upper = Math.exp(logAB + z*seAB);
    var or    = Math.exp(logAB);
    function nCDF(x){
      var t=1/(1+0.2316419*Math.abs(x));
      var d=0.3989423*Math.exp(-x*x/2);
      var p=d*t*(0.3193815+t*(-0.3565638+t*(1.7814779+t*(-1.8212560+t*1.3302744))));
      return x>0?1-p:p;
    }
    var pv = 2*(1-nCDF(Math.abs(logAB/seAB)));
    var res = document.getElementById('bucherResult');
    if (res) {
      res.innerHTML='<strong>間接比較結果 (A vs B)：</strong><br>'
        +'OR = '+or.toFixed(3)+' （95%CI: '+lower.toFixed(3)+'–'+upper.toFixed(3)+'）<br>'
        +'P値 = '+pv.toFixed(4);
      res.style.display='block';
    }
  };

  // 初期表示
  document.addEventListener('DOMContentLoaded', function(){
    showNMA2Section('sec1');
  });
})();
</script>
"@

# --- 組み立て ---
$nl = [System.Environment]::NewLine
$tab2  = "<!-- ===== タブ2: NMAの基本 ===== -->" + $nl
$tab2 += "<style>" + $nl + $scopedCss + $nl + "</style>" + $nl
$tab2 += "<div class='container nma2-outer'>" + $nl
$tab2 += "<div class='nma2-wrap' id='nma2-content-wrap'>" + $nl
$tab2 += $sidebar + $nl
$tab2 += "<main class='nma2-main'>" + $nl
$tab2 += $mainContent + $nl
$tab2 += $ext2 + $nl
$tab2 += "</main>" + $nl + "</div>" + $nl
$tab2 += "</div>" + $nl
$tab2 += $js

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$base\NMA_tab2.txt", $tab2, $utf8NoBom)
Write-Host "NMA_tab2.txt written: $($tab2.Length) chars"
