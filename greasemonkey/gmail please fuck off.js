// ==UserScript==
// @name     gmail please fuck off
// @version  1
// @grant    none
// @include /^https?://mail.google.com/
// @require	 https://code.jquery.com/jquery-3.4.1.min.js
// @require https://gist.githubusercontent.com/BrockA/2625891/raw/9c97aa67ff9c5d56be34a55ad6c18a314e5eb548/waitForKeyElements.js
// ==/UserScript==

function onBannerFound(){
  console.log("found something");
  $("p:contains(This message was not sent to Spam because of a filter you created)").each(function(idx, elem){
    console.log("removing a parent of:");
    console.log(elem);
    $(elem).parent().parent().remove();
  });
}

waitForKeyElements("p:contains(This message was not sent to Spam because of a filter you created)", onBannerFound);