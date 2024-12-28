$INCLUDE("_with_retry");

function getBskyStorage() {
    let bskyStorage = null;
    try {
        bskyStorage = JSON.parse(window.localStorage.BSKY_STORAGE);
    } catch (e) {
        console.error("Could not load BSKY_STORAGE", e);
    }
    return bskyStorage;
}

function updateColorScheme() {
    let bskyStorage = getBskyStorage();
    if (bskyStorage) {
        updateColorSchemeWithBskyStorage(bskyStorage);
    } else {
        updateColorSchemeAuto();
    }
}

function getInitSystemAppearance() {
    return localStorage.initSystemAppearance;
}

function updateColorSchemeWithBskyStorage(bskyStorage) {
    const colorMode = bskyStorage.colorMode;
    const darkTheme = bskyStorage.darkTheme;
    const classDefs = {
        "theme--light": {
            "name": "light",
            "darkMode": false,
            "backgroundColor": "rgb(255, 255, 255)",
        },
        "theme--dark": {
            "name": "dark",
            "darkMode": true,
            "backgroundColor": "rgb(0, 0, 0)",
        },
        "theme--dim": {
            "name": "dim",
            "darkMode": true,
            "backgroundColor": "rgb(24, 30, 38)",
        }
    };
    let match = classDefs["theme--light"];
    let initSystemAppearance = getInitSystemAppearance();
    console.info("updateColorSchemeWithBskyStorage initSystemAppearance", initSystemAppearance);
    if (colorMode === "system") {
        if (initSystemAppearance === "dark" && darkTheme === "dark") {
            match = classDefs["theme--dark"];
        } else if (initSystemAppearance === "dark" && darkTheme === "dim") {
            match = classDefs["theme--dim"];
        } else {
            match = classDefs["theme--light"];
        }
    } else {
        let htmlTheme = getHtmlTheme();
        for (let c of Object.keys(classDefs)) {
            if (htmlTheme === c) {
                match = classDefs[c];
                break;
            }
        }
    }
    window.webkit.messageHandlers.windowColorSchemeChange.postMessage({
        colorScheme: match.name,
        darkMode: match.darkMode,
        backgroundColor: match.backgroundColor,
    });
    return true;
}

function updateColorSchemeAuto() {
    const classDefs = {
        "theme--light": {
            "name": "light",
            "darkMode": false,
            "backgroundColor": "rgb(255, 255, 255)",
        },
        "theme--dark": {
            "name": "dark",
            "darkMode": true,
            "backgroundColor": "rgb(0, 0, 0)",
        },
        "theme--dim": {
            "name": "dim",
            "darkMode": true,
            "backgroundColor": "rgb(24, 30, 38)",
        }
    };
    let match = classDefs["theme--light"];
    let htmlTheme = getHtmlTheme();
    for (let c of Object.keys(classDefs)) {
        if (htmlTheme === c) {
            match = classDefs[c];
            break;
        }
    }
    window.webkit.messageHandlers.windowColorSchemeChange.postMessage({
        colorScheme: match.name,
        darkMode: match.darkMode,
        backgroundColor: match.backgroundColor,
    });
    return true;
}

function getHtmlTheme() {
    return document.querySelector("html").className;
}

function setColorSchemeChange() {
    let done = false;
    let elems = document.querySelectorAll("html");
    if (elems.length > 0) {
        let elem = elems[0];
        if (elem.dataset.windowColorSchemeObserverSet === undefined) {
            const config = {
                attributes: true,
                childList: false,
                subtree: false,
            };
            const callback = (mutationList, observer) => {
                for (let m of mutationList) {
                    let htmlTheme = getHtmlTheme();
                    if (elem.dataset.lastHtmlTheme !== htmlTheme) {
                        updateColorScheme();
                        elem.dataset.lastHtmlTheme = htmlTheme;
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
withRetry(setColorSchemeChange, 1000, 10);
