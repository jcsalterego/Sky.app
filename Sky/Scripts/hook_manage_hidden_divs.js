$INCLUDE("_manage_hidden_divs");

function hookManageHiddenDivs() {
    let done = false;
    if (document !== undefined && document.body !== undefined) {
        if (document.body.dataset.manageHiddenDivs === undefined) {
            window.addEventListener("resize", manageHiddenDivs);
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
