$INCLUDE("_with_retry");

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

withRetry(() => window.toggleOuterScrollbars(false));
