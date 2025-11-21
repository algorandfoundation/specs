// theme/gtm-noscript.js
(function () {
  function insertGtmNoscript() {
    var noscript = document.createElement("noscript");
    var iframe = document.createElement("iframe");
    iframe.src = "https://www.googletagmanager.com/ns.html?id=GTM-NZL38PG9";
    iframe.height = "0";
    iframe.width = "0";
    iframe.style.display = "none";
    iframe.style.visibility = "hidden";
    noscript.appendChild(iframe);
    document.body.insertBefore(noscript, document.body.firstChild);
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", insertGtmNoscript);
  } else {
    insertGtmNoscript();
  }
})();
