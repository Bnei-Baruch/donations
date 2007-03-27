function OpenWin(link, t, w, h) {
    win = new Window("new_win", {className:"darkX", title:t, url:link, width:w, height:h, resizable:true, minimizable:false, maximizable:false, wiredDrag:true, showEffectOptions:{duration:0.5}});
    win.setDestroyOnClose();
    win.showCenter(true);
}
