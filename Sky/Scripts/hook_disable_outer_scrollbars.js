function hookDisableOuterScrollbars() {
    let done = false;
    if (document !== undefined) {
        if (document.body !== undefined) {
            document.body.style.overflow = "hidden";
            done = true;
        }
    }
    if (!done) {
        // try again 200ms
        window.setTimeout(hookDisableOuterScrollbars, 200);
    }
}
hookDisableOuterScrollbars();
