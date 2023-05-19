function ensureShadowRealm() {
    let shadowRealm = document.querySelector("#shadow-realm");
    if (shadowRealm === null) {
        let shadowRealm = document.createElement("div");
        shadowRealm.id = "shadow-realm";
        shadowRealm.style.display = "none";
        document.body.append(shadowRealm);
    }
}

function manageHiddenDivs() {
    const MIN_DESKTOP_WIDTH = 1230.0;
    ensureShadowRealm();
    if (window.innerWidth >= MIN_DESKTOP_WIDTH) {
        restoreHiddenDivs();
    } else {
        hideHiddenDivs();
    }
}

// banish hidden DIVs to the #shadow-realm (not to be confused with
// the shadow DOM). this speeds up render time when switching between
// panes within a view.
function hideHiddenDivs() {
    const shadowRealm = document.querySelector("#shadow-realm");
    const expr =
        "div[style*='display: none']" +
        ":not([data-shadow-parent-id])" +
        ":not(#shadow-realm)";
    document.querySelectorAll(expr).forEach((elem) => {
        let origParent = elem.parentElement;
        let shadowId = origParent.dataset.shadowId;
        if (shadowId == null) {
            // sufficiently unique ID
            shadowId =
                new Date().valueOf() +
                "-" +
                (Math.random() + "").substring(2, 10);
            origParent.dataset.shadowId = shadowId;
        }
        shadowRealm.append(elem);
        elem.dataset.shadowParentId = shadowId;
    });
}

// restore hidden DIVs from the #shadow-realm.
function restoreHiddenDivs() {
    let expr = "div[data-shadow-parent-id]";
    document.querySelectorAll(expr).forEach((elem) => {
        let shadowParentId = elem.dataset.shadowParentId;
        let parent = document.querySelector(
            `[data-shadow-id="${shadowParentId}"]`
        );
        parent.append(elem);
        delete elem.dataset.shadowParentId;
    });
}

function hookManageHiddenDivs() {
    let done = false;
    if (document !== undefined && document.body !== undefined) {
        if (document.body.dataset.manageHiddenDivs === undefined) {
            window.addEventListener("resize", manageHiddenDivs);
            window.addEventListener(new Event("navChange"), manageHiddenDivs);
            document.body.dataset.manageHiddenDivs = true;
        }
        done = true;
    }
    if (!done) {
        // try again 200ms
        window.setTimeout(hookManageHiddenDivs, 200);
    }
}

hookManageHiddenDivs();
