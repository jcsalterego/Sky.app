function setColorScheme(darkMode){
    window.webkit.messageHandlers.
        windowColorSchemeChange.postMessage({"darkMode":darkMode});
}

function hookColorSchemeChange() {
    let elems = Array.from(document.querySelectorAll("#root div div"));
    if (elems.length > 0) {
        let elem = elems[0];
        if (elem.dataset.windowColorSchemeObserverSet === undefined) {
            const config = { attributes: true, childList: true, subtree: false };
            const callback = (mutationList, observer) => {
                for (let m of mutationList) {
                    let backgroundColor = window.getComputedStyle(elem).backgroundColor;
                    if (elem.dataset.lastBackgroundColor !== backgroundColor) {
                        if (backgroundColor === "rgb(0, 0, 0)") {
                            setColorScheme(true);
                        } else {
                            setColorScheme(false);
                        }
                        elem.dataset.lastBackgroundColor = backgroundColor;
                        break;
                    }
                }
            }
            const observer = new MutationObserver(callback);
            observer.observe(elem, config);
            // elem.parentElement.style.border = "1px solid red";
            elem.dataset.windowColorSchemeObserverSet = true;
        }
    } else {
        // try again 200ms
        window.setTimeout(hookColorSchemeChange, 200);
    }
}
hookColorSchemeChange();
