
window.toggleOuterScrollbars = function(enabled) {
    let success = false;
    if (document !== undefined) {
        if (document.body !== undefined) {
            const overflowProp = enabled ? "auto" : "hidden";
            document.body.style.overflow = "hidden";
            success = true;
        }
    }
    return success;
}

function hookToggleOuterScrollbars(enabled) {
    let done = window.toggleOuterScrollbars(enabled);
    if (!done) {
        // try again 200ms
        window.setTimeout(() => hookToggleOuterScrollbars(enabled), 200);
    }
}

hookToggleOuterScrollbars($__ENABLED__);
