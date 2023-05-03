
window.toggleOuterScrollbars = function(enabled) {
    const overflowProp = enabled ? "auto" : "hidden";
    let success = false;
    if (document !== undefined) {
        let root = document.querySelector("#root");
        if (root !== undefined) {
            root.style.overflow = overflowProp;
            success = true;
        }
    }
    return success;
}

function hookDisableOuterScrollbars() {
    let done = window.toggleOuterScrollbars(false);
    if (!done) {
        // try again 200ms
        window.setTimeout(() => hookDisableOuterScrollbars(), 200);
    }
}

hookDisableOuterScrollbars();
