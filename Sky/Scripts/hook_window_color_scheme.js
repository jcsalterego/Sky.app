$INCLUDE("_with_retry");
function updateColorScheme() {
    let background = document.body.style.backgroundColor;
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
