$INCLUDE("_manage_hidden_divs");
$INCLUDE("_with_retry");

function addManageHiddenDivsResizeHook() {
    let done = false;
    if (document !== undefined && document.body !== undefined) {
        if (document.body.dataset.manageHiddenDivs === undefined) {
            window.addEventListener("resize", manageHiddenDivs);
            document.body.dataset.manageHiddenDivs = true;
        }
        done = true;
    }
    return done;
}

withRetry(addManageHiddenDivsResizeHook);
