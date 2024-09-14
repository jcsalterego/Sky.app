$INCLUDE("_with_retry");
function updateColorScheme() {
    let background = document.body.style.backgroundColor;
    let foreground = document.body.style.color;
    let darkMode = false;
    if (background === "rgb(255, 255, 255)") {
        darkMode = false;
    } else {
        darkMode = true;
    }
    window.webkit.messageHandlers.windowColorSchemeChange.postMessage({
        darkMode: darkMode,
        backgroundColor: background,
    });
    let rules = [
        `::-webkit-scrollbar { width: auto }`,
        `::-webkit-scrollbar-track { background: ${background}; }`,
        `::-webkit-scrollbar-thumb { background-color: ${foreground}; ` +
            `border-radius: 6px; border: 4px solid ${background}; }`,
    ];
    let stylesheet = document.styleSheets[document.styleSheets.length - 1];
    for (let rule of rules) {
        stylesheet.insertRule(rule, stylesheet.rules.length - 1);
    }
}

function setColorSchemeChange() {
    let done = false;
    let elems = Array.from(document.querySelectorAll("body"));
    if (elems.length > 0) {
        let elem = elems[0];
        if (elem.dataset.windowColorSchemeObserverSet === undefined) {
            const config = {
                attributes: true,
                childList: true,
                subtree: false,
            };
            const callback = (mutationList, observer) => {
                for (let m of mutationList) {
                    let backgroundColor =
                        window.getComputedStyle(elem).backgroundColor;
                    if (elem.dataset.lastBackgroundColor !== backgroundColor) {
                        updateColorScheme();
                        elem.dataset.lastBackgroundColor = backgroundColor;
                        break;
                    }
                }
            };
            const observer = new MutationObserver(callback);
            observer.observe(elem, config);
            // elem.parentElement.style.border = "1px solid red";
            elem.dataset.windowColorSchemeObserverSet = true;
        }
        done = true;
    }
    return done;
}
withRetry(setColorSchemeChange);
