(function () {
  var script = document.currentScript;
  var widgetKey = script.getAttribute("data-widget-key");
  if (!widgetKey) {
    console.error("[rag-widget] data-widget-key attribute is required");
    return;
  }

  var baseUrl = script.getAttribute("data-base-url") || script.src.replace(/\/widget\.js.*$/, "");

  var button = document.createElement("button");
  button.setAttribute("aria-label", "Destek sohbetini aç");
  button.style.cssText =
    "position:fixed;bottom:20px;right:20px;width:58px;height:58px;border-radius:50%;" +
    "background:linear-gradient(135deg,#6366f1,#4338ca);border:none;cursor:pointer;" +
    "box-shadow:0 10px 30px -8px rgba(67,56,202,0.6);z-index:2147483646;" +
    "display:flex;align-items:center;justify-content:center;transition:transform .15s ease;";
  button.innerHTML =
    '<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" ' +
    'stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>';
  button.onmouseenter = function () {
    button.style.transform = "scale(1.06)";
  };
  button.onmouseleave = function () {
    button.style.transform = "scale(1)";
  };

  var frame = document.createElement("iframe");
  frame.src = baseUrl + "/widget/" + encodeURIComponent(widgetKey);
  frame.title = "Destek sohbeti";
  frame.style.cssText =
    "position:fixed;bottom:88px;right:20px;width:380px;height:560px;max-width:calc(100vw - 40px);" +
    "max-height:calc(100vh - 110px);border:none;border-radius:16px;" +
    "box-shadow:0 20px 60px -15px rgba(0,0,0,0.45);z-index:2147483647;display:none;" +
    "background:#0a0b14;";

  var open = false;
  button.addEventListener("click", function () {
    open = !open;
    frame.style.display = open ? "block" : "none";
  });

  document.body.appendChild(frame);
  document.body.appendChild(button);
})();
