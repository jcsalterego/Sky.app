$INCLUDE("_with_retry");

function setCtrlTab() {
    let done = false;
    if (document !== undefined) {
        let root = document.body;
        if (root !== undefined) {
            if (root.dataset.ctrlTabHooked === undefined) {
                root.dataset.ctrlTabHooked = true;
                document.body.addEventListener("keydown", function (ev) {
                    if (ev.ctrlKey === true && ev.code === "Tab") {
                        let msg = {
                            direction: ev.shiftKey === true ? -1 : 1,
                        };
                        window.webkit.messageHandlers.ctrlTab.postMessage(msg);
                    }
                });
            }
            done = true;
        }
    }
    return done;
}

withRetry(setCtrlTab);
