function setColorScheme(darkMode){
    const DARK_MODE_FOREGROUND = "#79787c";
    const DARK_MODE_BACKGROUND = "#000000";
    const LIGHT_MODE_FOREGROUND = "#c3c3c3";
    const LIGHT_MODE_BACKGROUND = "#fafafa";
    window.webkit.messageHandlers.
        windowColorSchemeChange.postMessage({"darkMode":darkMode});
    if (darkMode) {
        foreground = DARK_MODE_FOREGROUND;
        background = DARK_MODE_BACKGROUND;
    } else {
        foreground = LIGHT_MODE_FOREGROUND;
        background = LIGHT_MODE_BACKGROUND;
    }
    let rules = [
        `::-webkit-scrollbar { width: auto }`,
        `::-webkit-scrollbar-track { background: ${background}; }`,
        `::-webkit-scrollbar-thumb { background-color: ${foreground}; `+
            `border-radius: 6px; border: 4px solid ${background}; }`,
    ]
    let stylesheet = document.styleSheets[document.styleSheets.length - 1];
    for (let rule of rules) {
        stylesheet.insertRule(rule, stylesheet.rules.length - 1);
    }
    elems = Array.from(document.querySelectorAll("div")).
        filter(div => {return div.scrollHeight > window.innerHeight;});
    for (let elem of elems) {
        elem.style.overflow = 'hidden';
        window.setTimeout(() => {
            elem.style.overflow = 'auto';
        }, 10);
    }
    document.body.style.overflow = 'auto';
    window.setTimeout(() => {document.body.style.overflow = 'hidden';}, 10);
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
