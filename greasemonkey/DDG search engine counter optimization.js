// ==UserScript==
// @name     DDG search engine counter-optimization
// @version  1
// @grant    none
// @description SEO has really subverted search engines
// @include /^https?://(www\.)?duckduckgo.com/
// @namespace adamrgrey.com
// @license  MIT
// ==/UserScript==

let thisYear = new Date().getYear() + 1900;
let searchEngineConfounders = ["in " + thisYear, "in " + (thisYear - 1), "in " + (thisYear), "best", "top 10"];

window.onload = function(event) {
  clearInput(document.querySelector("#search_form_input_homepage"));
  clearInput(document.querySelector("#search_form_input"));
};

function clearInput(input){
  if(input === null){
    return;
  }
  let currentQuery = input.value;
 
  searchEngineConfounders.forEach((elem) => {
    let subtractor = "-\"" + elem + "\"";
    if(currentQuery.indexOf(subtractor) < 0){
      input.value += " " + subtractor;
    }
  });
}