window.toggleOuterScrollbars = function (enabled) {
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
};

function hookToggleOuterScrollbars(enabled) {
    let done = window.toggleOuterScrollbars(enabled);
    if (!done) {
        // try again 200ms
        window.setTimeout(() => hookToggleOuterScrollbars(enabled), 200);
    }
}

hookToggleOuterScrollbars($__ENABLED__);
