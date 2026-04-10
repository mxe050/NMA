<script>
// iro5_goTab override (correct querySelector)
function iro5_goTab(panelId){
  document.querySelectorAll('.iro5-panel').forEach(function(p){p.classList.remove('active');});
  document.querySelectorAll('.iro5-nav-tab').forEach(function(t){t.classList.remove('active');});
  var panel=document.getElementById(panelId);
  if(panel) panel.classList.add('active');
  var nb=document.querySelector('[data-panel="'+panelId+'"]');
  if(nb) nb.classList.add('active');
  window.scrollTo({top:0,behavior:'smooth'});
}
</script>
