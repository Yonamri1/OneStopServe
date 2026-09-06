
const DB_KEY = "adultFosterHomeDataV1";

const emptyData = {
  clients: [], staff: [], appointments: [], finances: [],
  meals: [], medications: [], policies: []
};

function loadData() {
  try { return {...emptyData, ...JSON.parse(localStorage.getItem(DB_KEY) || "{}")}; }
  catch(e) { return {...emptyData}; }
}
function saveData(data) { localStorage.setItem(DB_KEY, JSON.stringify(data)); }
function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2,8); }
function esc(value) {
  return String(value ?? "").replace(/[&<>"']/g, c => ({
    "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"
  }[c]));
}
function money(v) {
  const n = Number(v || 0);
  return n.toLocaleString(undefined,{style:"currency",currency:"USD"});
}
function renderTable(id, rows, empty="No records yet.") {
  const el = document.getElementById(id);
  if (!el) return;
  el.innerHTML = rows.length ? rows.join("") : `<tr><td colspan="20" class="empty">${empty}</td></tr>`;
}
function removeRecord(collection, id) {
  if (!confirm("Delete this record?")) return;
  const data=loadData();
  data[collection]=data[collection].filter(x=>x.id!==id);
  saveData(data); location.reload();
}
function editRecord(collection,id, formId) {
  const data=loadData(), item=data[collection].find(x=>x.id===id);
  if (!item) return;
  const form=document.getElementById(formId);
  Object.keys(item).forEach(k=>{ const el=form.elements[k]; if(el) el.value=item[k]; });
  form.elements.id.value=item.id;
  window.scrollTo({top:0,behavior:"smooth"});
}
function initForm(formId, collection, afterSave) {
  const form=document.getElementById(formId);
  if(!form) return;
  form.addEventListener("submit", e=>{
    e.preventDefault();
    const data=loadData();
    const obj={id:form.elements.id.value || uid()};
    [...form.elements].forEach(el=>{ if(el.name && el.name!=="id") obj[el.name]=el.value; });
    const i=data[collection].findIndex(x=>x.id===obj.id);
    if(i>=0) data[collection][i]=obj; else data[collection].push(obj);
    saveData(data);
    form.reset(); form.elements.id.value="";
    if(afterSave) afterSave(data);
    else location.reload();
  });
}
function clearForm(formId){ const f=document.getElementById(formId); if(f){f.reset();f.elements.id.value="";} }
