let _plugin = null;
function _need() {
  if (!_plugin) throw new Error("plugin not initialized");
  return _plugin;
}
export function _init(plugin) { _plugin = plugin; }

export async function command(t) { return _need().nvim.command(t); }
export async function execLua(l,a=[]) { return _need().nvim.execLua(l,a); }
export async function callFunction(n,a=[]) { return _need().nvim.call(n,a); }
export async function notify(n,a=[]) { return _need().nvim.notify(n,a); }
export async function setVar(n,v) { return _need().nvim.setVar(n,v); }
export async function getVar(n) { return _need().nvim.getVar(n); }
export async function feedKeys(k,m="",e=false){return _need().nvim.feedKeys(k,m,e);}
export async function redraw(f=false){return _need().nvim.redraw(f);}
export async function getCurrentBuffer(){return _need().nvim.buffer;}
export async function getCurrentWindow(){return _need().nvim.window;}
export async function getCurrentTabpage(){return _need().nvim.tabpage;}

function normalizeOptionScope(s){switch(s){case"global":return{scope:"global"};case"window":return{scope:"local",win:0};case"buffer":return{scope:"local",buf:0};default:throw new Error("bad scope");}}
export async function setOption(s,n,v){return _need().nvim.call("nvim_set_option_value",[n,v,normalizeOptionScope(s)]);}
export async function getOption(s,n){return _need().nvim.call("nvim_get_option_value",[n,normalizeOptionScope(s)]);}
export async function setGlobalOption(n,v){return setOption("global",n,v);}

function normalizeKeymapOptions(o){const x=o??{};const n={noremap:true,silent:true,...x};if(n.buffer===true)n.buffer=0;return n;}
export async function setKeymap(m,l,r,o={}){const{nvim}= _need();const f=normalizeKeymapOptions(o);if(f.buffer!==undefined&&f.buffer!==false){const b=f.buffer===0?0:Number(f.buffer);const{buffer,...rest}=f;return nvim.call("nvim_buf_set_keymap",[b,m,l,r,rest]);}return nvim.call("nvim_set_keymap",[m,l,r,f]);}
export async function setKeymapDefault(m,l,r){return setKeymap(m,l,r);}
export async function setKeymapWithDesc(m,l,r,d){return setKeymap(m,l,r,{desc:d});}
export async function deleteKeymap(m,l,o={}){const{nvim}= _need();const b=o?.buffer===true||Number.isFinite(o?.buffer);if(b){const buf=o.buffer===true?0:Number(o.buffer);return nvim.call("nvim_buf_del_keymap",[buf,m,l]);}return nvim.call("nvim_del_keymap",[m,l]);}

export async function createAutocmd(e,o={}){return _need().nvim.call("nvim_create_autocmd",[e,o]);}
export async function clearAutocmds(o={}){return _need().nvim.call("nvim_clear_autocmds",[o]);}
export async function createAugroup(n,o={}){return _need().nvim.call("nvim_create_augroup",[n,o]);}

export function registerCommand(n,h,o={}){_need().registerCommand(n,async(a)=>h(a??[]),o);}
export async function createUserCommand(n,d,o={}){const p=_need();const{nvim}=p;const co={nargs:"*",...o};if(typeof d==="string")return nvim.call("nvim_create_user_command",[n,d,co]);if(typeof d==="function"){p.registerCommand(n,async(a)=>d(a??[]),co);return null;}throw new Error("bad def");}

export async function outWrite(t){return _need().nvim.outWrite(String(t)+"\n");}

export default{_init,command,execLua,callFunction,notify,setVar,getVar,setOption,getOption,setGlobalOption,setKeymap,setKeymapDefault,setKeymapWithDesc,deleteKeymap,createAutocmd,clearAutocmds,createAugroup,registerCommand,createUserCommand,feedKeys,redraw,getCurrentBuffer,getCurrentWindow,getCurrentTabpage,outWrite};
