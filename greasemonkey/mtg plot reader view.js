// ==UserScript==
// @name     mtg plot reader view
// @version  1
// @grant    none
// @namespace adamrgrey.com
// @license	 MIT
// @description prepare an mtg article for printing to pdf - like reader view, but save in one file, and keep images
// @include /^https?://magic.wizards.com\/en\/news\/magic-story/

// ==/UserScript==



setTimeout(() => {
  purgeSiblingsUp(document.querySelector("article"));
}, 2000);

function purgeSiblingsUp(targetElement){
  console.log("purging siblings of", targetElement);
  let parent = targetElement.parentElement;
  if(parent == null || parent === targetElement){
    console.log("lol j/k, at the top");
    return;
  }
  if(targetElement.nodeName == "BODY"){
    console.log("lol j/k, found the body");
    return;
  }
  console.log(parent);
  var children = targetElement.parentElement.children;
  if(children.length > 1){
    let del = [];
    for (let i = 0; i < children.length; i++) {
      if(children[i] !== targetElement){
        del.push(children[i]);
      }
    }
    console.log(del.length + " targets")
    for (let i = 0; i < del.length; i++) {
      del[i].remove();
    }
  }
  purgeSiblingsUp(parent);
}