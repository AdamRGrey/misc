// ==UserScript==
// @name     twitch activity feed watcher
// @version  1
// @grant    none
// @license  MIT
// @description how about instead of event sub I just open the fuckin window
// @include https://dashboard.twitch.tv/popout/u/silvermeddlists/stream-manager/activity-feed
// @namespace silvermeddlists.com
// ==/UserScript==

var observer = new MutationObserver(function(mutations) {
   mutations.forEach(function(mutation) {
     console.log(mutation);
     if ( mutation.type == 'childList' ) {
       if (mutation.addedNodes.length >= 1) {
         console.log("added nodes");
         for(let i = 0; i < mutation.addedNodes.length; i++){
           let added = mutation.addedNodes[i];
           let iconNode = added.querySelector(".activity-base-list-item__icon");
           
           let type = "unknown";
           let searchText = "activity-feed-v2-event--";
           iconNode.classList.forEach(cl => {
             if(cl.startsWith(searchText)){
               type = cl.substr(searchText.length);
               console.log("type is " + type);
             }
           });
           
       		 let reward = added.querySelector(".activity-base-list-item__title").textContent;
           let user = added.querySelector(".activity-base-list-item__subtitle button").textContent;
           let text = "type: " + type + "\ndata: " + reward + " • " + user;
           let textIncluded = added.querySelector(".activity-base-list-item__subtitle").nextSibling.textContent;
           if(textIncluded.length > 0){
              text += " • " + textIncluded;
           }
           text = text.substr(0, text.length);
           
           let formData = {};
           formData["content"] = text;
           console.log("sending: ", formData);
           
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", [REDACTED], true);
            xhttp.setRequestHeader("Content-Type", "application/json");
            xhttp.onreadystatechange = function() {
              console.log("ready state changed", this);
            }
            let result = xhttp.send(JSON.stringify(formData));
           console.log("sent, survived.", result);
         }
       }
     }
   });
});

var observerConfig = {
  subtree: true,
  attributes: false,
  childList: true,
  characterData: true
};

setTimeout(() => {
  observer.observe(document.querySelector(".simplebar-content"), observerConfig);
  console.log("I should be watchign");
}, 2000);
console.log("hi, hanging a sec so twitch can add");