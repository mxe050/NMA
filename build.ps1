$base = Join-Path $PSScriptRoot 'refcode'
$out  = Join-Path $PSScriptRoot 'index.html'

$p1 = [System.IO.File]::ReadAllText("$base\パート1.txt", [System.Text.Encoding]::UTF8)
$p2 = [System.IO.File]::ReadAllText("$base\パート2.txt", [System.Text.Encoding]::UTF8)
$p3 = [System.IO.File]::ReadAllText("$base\パート3.txt", [System.Text.Encoding]::UTF8)
$p4 = [System.IO.File]::ReadAllText("$base\パート4.txt", [System.Text.Encoding]::UTF8)
$p5 = [System.IO.File]::ReadAllText("$base\パート5.txt", [System.Text.Encoding]::UTF8)
$p6 = [System.IO.File]::ReadAllText("$base\パート6.txt", [System.Text.Encoding]::UTF8)

# タブ1: マルチ介入NMA
$multiTab1 = [System.IO.File]::ReadAllText("$base\Multi_tab1.txt", [System.Text.Encoding]::UTF8)

# タブ2: NMAの基本
$nmaTab2 = [System.IO.File]::ReadAllText("$base\NMA_tab2.txt", [System.Text.Encoding]::UTF8)

# タブ5: 効果と確実性の表記
$iroTab5 = [System.IO.File]::ReadAllText("$base\iro_tab5.txt", [System.Text.Encoding]::UTF8)

# Split p1 at </div><!-- /container -->
$marker = '</div><!-- /container -->'
$idx1 = $p1.IndexOf($marker)
$p1_before = $p1.Substring(0, $idx1)
$p1_after  = $p1.Substring($idx1 + $marker.Length)

# Extract <script> block from p1_after (remove </body></html>)
$si = $p1_after.IndexOf('<script>')
$p1_script = $p1_after.Substring($si)
$p1_script = $p1_script.Replace('</body>' + [char]10 + '</html>', '')
$p1_script = $p1_script.Replace('</body>' + [char]13 + [char]10 + '</html>', '')

# Helper: extract from first <div class="section"
function Get-Sections($text) {
    $i = $text.IndexOf('<div class="section"')
    if ($i -ge 0) { return $text.Substring($i) }
    return $text
}

$p2s = Get-Sections $p2
$p3s = Get-Sections $p3
$p4s = Get-Sections $p4
$p5s = Get-Sections $p5

# p6: sections (before </div><!-- /container -->) and footer
$p6ci = $p6.IndexOf($marker)
$p6s  = Get-Sections $p6.Substring(0, $p6ci)
$fi   = $p6.IndexOf('<footer')
$fe   = $p6.IndexOf('</footer>') + '</footer>'.Length
$p6_footer = $p6.Substring($fi, $fe - $fi)

# --- Inject extra CSS before </style> ---
$extraCSS = @"

/* ===== 外部8タブシステム ===== */
.app-header{background:linear-gradient(135deg,#0a1929 0%,#0d2137 100%);color:#fff;box-shadow:0 2px 12px rgba(0,0,0,.4);}
.app-title-bar{max-width:1400px;margin:0 auto;padding:12px 20px;font-size:1.1em;font-weight:bold;letter-spacing:.03em;}
.app-title-bar small{font-size:.72em;opacity:.55;font-weight:normal;margin-left:8px;}
.main-tabs{background:rgba(0,0,0,.25);border-bottom:2px solid rgba(255,255,255,.08);}
.main-tabs-inner{max-width:1400px;margin:0 auto;display:flex;flex-wrap:wrap;}
.main-tab-btn{background:none;border:none;border-bottom:3px solid transparent;color:rgba(255,255,255,.6);padding:9px 13px;cursor:pointer;font-size:.8em;transition:all .2s;white-space:nowrap;font-family:inherit;}
.main-tab-btn:hover{color:#fff;background:rgba(255,255,255,.07);}
.main-tab-btn.active{color:#fff;border-bottom-color:#5dade2;font-weight:bold;}
.main-panel{display:none;}
.main-panel.active{display:block;}
.placeholder-panel{max-width:600px;margin:120px auto;text-align:center;padding:40px;}
.placeholder-panel h2{font-size:1.8em;color:#ccc;margin-bottom:12px;}
.placeholder-panel p{color:#aaa;font-size:.95em;}
.placeholder-panel .coming-soon{display:inline-block;margin-top:20px;padding:8px 24px;background:var(--secondary);color:#fff;border-radius:20px;font-size:.85em;}
"@

$p1_before = $p1_before.Replace('</style>', $extraCSS + '</style>')
$p1_before = $p1_before.Replace(
    '<title>NMA-GRADE エビデンス確実性評価 完全ガイド</title>',
    '<title>ネットワークメタ分析 総合ガイド</title>')

# --- Build outer header HTML (mp-2にNMA基本コンテンツを組み込む) ---
$navMark = '<nav class="top-nav">'
$outerHeader = @"
<!-- ===== 外部アプリヘッダー & 8タブ ===== -->
<div class="app-header">
  <div class="app-title-bar">ネットワークメタ分析 総合ガイド<small>Network Meta-Analysis Knowledge Base</small></div>
  <div class="main-tabs">
    <div class="main-tabs-inner">
      <button class="main-tab-btn active" data-tab="1" onclick="switchMainTab(1)">1. マルチ介入・NMA</button>
      <button class="main-tab-btn" data-tab="2" onclick="switchMainTab(2)">2. NMAの基本</button>
      <button class="main-tab-btn" data-tab="3" onclick="switchMainTab(3)">3. 統計的解説</button>
      <button class="main-tab-btn" data-tab="4" onclick="switchMainTab(4)">4. エビデンスの確実性</button>
      <button class="main-tab-btn" data-tab="5" onclick="switchMainTab(5)">5. 効果と確実性の表記</button>
      <button class="main-tab-btn" data-tab="6" onclick="switchMainTab(6)">6. 未定</button>
      <button class="main-tab-btn" data-tab="7" onclick="switchMainTab(7)">7. 未定</button>
      <button class="main-tab-btn" data-tab="8" onclick="switchMainTab(8)">8. 未定</button>
    </div>
  </div>
</div>
<div class="main-panel active" id="mp-1">
$multiTab1
</div><!-- /mp-1 -->
<div class="main-panel" id="mp-2">
$nmaTab2
</div><!-- /mp-2 -->
<div class="main-panel" id="mp-3"><div class="placeholder-panel"><h2>準備中</h2><p>「ネットワークメタ分析の統計的解説」のコンテンツは現在作成中です。</p><span class="coming-soon">Coming Soon</span></div></div>
<div class="main-panel" id="mp-4">
"@

$p1_before = $p1_before.Replace($navMark, $outerHeader + $navMark)

# --- Outer tab JS to prepend in script ---
$outerJS = @"

// ===== 外部タブ切替 =====
function switchMainTab(n){
  document.querySelectorAll('.main-tab-btn').forEach(function(b){b.classList.remove('active');});
  document.querySelectorAll('.main-panel').forEach(function(p){p.classList.remove('active');});
  var btn=document.querySelector('.main-tab-btn[data-tab="'+n+'"]');
  var panel=document.getElementById('mp-'+n);
  if(btn) btn.classList.add('active');
  if(panel) panel.classList.add('active');
  window.scrollTo({top:0,behavior:'smooth'});
  // タブ2を開いた時に初期セクションを表示
  if(n===2 && typeof showNMA2Section==='function'){ showNMA2Section('nma2-sec1'); }
}

// ===== トップに戻るボタン =====
(function(){
  var btn = document.createElement('button');
  btn.id = 'globalTopBtn';
  btn.innerHTML = '&#9650;';
  btn.title = 'トップに戻る';
  btn.style.cssText = 'position:fixed;bottom:28px;right:28px;width:44px;height:44px;border-radius:50%;background:#1a5276;color:#fff;border:none;font-size:1.1em;cursor:pointer;box-shadow:0 3px 10px rgba(0,0,0,.3);opacity:0;transition:opacity .3s;z-index:9999;display:flex;align-items:center;justify-content:center;';
  btn.onclick = function(){ window.scrollTo({top:0,behavior:'smooth'}); };
  document.body.appendChild(btn);
  window.addEventListener('scroll',function(){
    btn.style.opacity = window.scrollY > 300 ? '1' : '0';
    btn.style.pointerEvents = window.scrollY > 300 ? 'auto' : 'none';
  });
})();

"@

$p1_script = $p1_script.Replace('<script>', '<script>' + $outerJS)

# --- Closing panels for tabs 5-8 ---
$closingPanels = @"
</div><!-- /mp-4 -->
<div class="main-panel" id="mp-5">
$iroTab5
</div><!-- /mp-5 -->
<div class="main-panel" id="mp-6"><div class="placeholder-panel"><h2>準備中</h2><p>コンテンツは現在作成中です。</p><span class="coming-soon">Coming Soon</span></div></div>
<div class="main-panel" id="mp-7"><div class="placeholder-panel"><h2>準備中</h2><p>コンテンツは現在作成中です。</p><span class="coming-soon">Coming Soon</span></div></div>
<div class="main-panel" id="mp-8"><div class="placeholder-panel"><h2>準備中</h2><p>コンテンツは現在作成中です。</p><span class="coming-soon">Coming Soon</span></div></div>
"@

# --- Assemble ---
$nl = [System.Environment]::NewLine
$result = $p1_before + $p2s + $p3s + $p4s + $p5s + $p6s + $nl + $marker + $nl + $closingPanels + $p6_footer + $nl + $p1_script + $nl + '</body>' + $nl + '</html>'

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($out, $result, $utf8NoBom)
Write-Host "Done. Output size: $($result.Length) chars"
