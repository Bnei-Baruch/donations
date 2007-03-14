function OpenWin(link, t, w, h) {
    win = new Window("new_win", {className:"darkX", title:t, url:link, width:w, height:h, resizable:true, minimizable:false, maximizable:false, wiredDrag:true, showEffectOptions:{duration:0.5}});
    win.setDestroyOnClose();
    //if (navigator.userAgent.indexOf("MSIE") > -1) {
        win.showCenter(true);
    //} else {
        //win.setLocation(50, 20);
        //win.show(true);
    //}
}
