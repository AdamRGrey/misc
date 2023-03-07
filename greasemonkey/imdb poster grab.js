// ==UserScript==
// @name     imdb poster grab
// @version  1
// @grant    none
// @namespace adamrgrey.com
// @license	 MIT
// @description don't know why imdb makes it so hard to grab the movie's own advertising. they want it to spread. it's advertising.
// @include /^https?://(www\.)?imdb.com\/title\//
// ==/UserScript==


setTimeout(() => {
  //console.log("searching for imdb poster");
  let srcset = document.querySelector(".ipc-media--poster-l img").getAttribute("srcset").split(', ');
  //console.log("srcs: ", srcset.length);
  let biggestW = 0;
  let biggestUri = "";
  srcset.forEach((elem) => { 
    let splitUp = elem.split(' ');
    let last = splitUp[splitUp.length - 1];
    let numVal = Number(last.match(/\d+/)[0]);
    if(numVal > biggestW){
      biggestUri = splitUp[0];
    }
  });
  //console.log("chose " + biggestUri + " because " + biggestW + " seems biggest");
  let feedLink = document.createElement("a");
  feedLink.setAttribute("href",biggestUri);
  feedLink.innerHTML = "poster plz";
  document.querySelector(".ipc-media--poster-l").parentElement.parentElement.parentElement.parentElement.appendChild(feedLink);
}, 1500);
