// ==UserScript==
// @name     Newegg Bullshit Reducer
// @version  1
// @grant    none
// @match 	 *://*.newegg.com/*
// @description you MOTHERFUCKER
// @namespace adamrgrey.com
// @license	 MIT
// ==/UserScript==

function killit(){
  let target = document.querySelector(".newegg-notification");
  if(target !== null){
    console.log("found, removing");
		target.remove();
    clearInterval(checkInterval);
  }
}


var checkInterval = setInterval(killit, 1000);
killit();