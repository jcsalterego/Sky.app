function notifyLightModeChange(elem) {
    let data = {"innerText": elem.innerText};
    let msg = JSON.parse(JSON.stringify(data));
    window.webkit.messageHandlers.lightModeChange.postMessage(msg);
}

function hookLightMode() {
    let elems = Array.from(document.querySelectorAll("div"));
    elems = elems.filter(elem => {
        return elem.innerHTML.match(/^(dark|light) mode$/i) !== null;
    });
    for (let elem of elems) {
        if (elem.dataset.tagged === undefined) {
            elem.parentElement.addEventListener("click", (ev) => notifyLightModeChange(elem));
            elem.dataset.tagged = true;
        }
    }
    if (elems.length === 0) {
        // try again 1000ms
        window.setTimeout(hookLightMode, 200);
    }
}
hookLightMode();
