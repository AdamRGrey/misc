// ==UserScript==
// @name     725984
// @version  1
// @grant    none
// @include  /^https?://([^\.]*\.)?twitch\.tv/(moderator/)?[^/]+$/
// @description auto claim active bonus. should probably keep this secret?
// ==/UserScript==

var reportToast = document.createElement("div");
reportToast.id = "snackbar";
var summaryObject = null;
var claimInterval = -1;
var summarySearch = setInterval(() => {
  popToast("725984 is alive");
  //reportToast.appendChild(document.createTextNode());
  //document.body.appendChild(reportToast);
  //reportToast.className = "show";
  console.log("725984 survived most of init");
	setInterval(function(){ reportToast.className = reportToast.className.replace("show", ""); }, 3000);
  
	summaryObject = document.querySelector(".community-points-summary");
  if(summaryObject !== null){
    popToast("725984: online");
    clearInterval(summarySearch);
    claimInterval = setTimeout(claim, 1000 + Math.random() * 1000);
    summaryObject.insertBefore(document.createTextNode("🟢"), summaryObject.firstChild)
  } else {
    console.log("725984: not ready");
    popToast("725984: not ready");
  }
}, 5000);

function claim(){
  //look for claim. if found:
  
  summaryObject.querySelectorAll("button").forEach((elem) => {
    //console.log(Date());
    let claimability = elem.querySelector(".claimable-bonus__icon");
    if(claimability !== null){
			console.log("725984: in motion");
      if(Math.random() < 0.1){
        popToast("725984 claims");
        elem.click();
      }else{
        popToast("725984 abstains");
      }
    }
    clearTimeout(claimInterval);
    claimInterval = setTimeout(claim, 1000 + Math.random() * 1000);
  });
  
}

function popToast(msg){
  console.log(msg);
  reportToast.innerHTML = "";
  reportToast.appendChild(document.createTextNode(msg));
  reportToast.className = "show";
}

let newStyle = document.createElement("style");
  newStyle.setAttribute("type", "text/css");
  newStyle.textContent = `
#snackbar {
  visibility: hidden; /* Hidden by default. Visible on click */
  min-width: 250px; /* Set a default minimum width */
  margin-left: -125px; /* Divide value of min-width by 2 */
  background-color: #333; /* Black background color */
  color: #fff; /* White text color */
  text-align: center; /* Centered text */
  border-radius: 2px; /* Rounded borders */
  padding: 16px; /* Padding */
  position: fixed; /* Sit on top of the screen */
  z-index: 1; /* Add a z-index if needed */
  right: 30px; /* near the right; where you'll be looking (probably) */
  bottom: 30px; /* 30px from the bottom */
}

/* Show the snackbar when clicking on a button (class added with JavaScript) */
#snackbar.show {
  visibility: visible; /* Show the snackbar */
  /* Add animation: Take 0.5 seconds to fade in and out the snackbar.
  However, delay the fade out process for 2.5 seconds */
  -webkit-animation: fadein 0.5s, fadeout 0.5s 2.5s;
  animation: fadein 0.5s, fadeout 0.5s 2.5s;
}

/* Animations to fade the snackbar in and out */
@-webkit-keyframes fadein {
  from {bottom: 0; opacity: 0;}
  to {bottom: 30px; opacity: 1;}
}

@keyframes fadein {
  from {bottom: 0; opacity: 0;}
  to {bottom: 30px; opacity: 1;}
}

@-webkit-keyframes fadeout {
  from {bottom: 30px; opacity: 1;}
  to {bottom: 0; opacity: 0;}
}

@keyframes fadeout {
  from {bottom: 30px; opacity: 1;}
  to {bottom: 0; opacity: 0;}
} 
`;
document.head.appendChild(newStyle);
document.body.appendChild(reportToast);