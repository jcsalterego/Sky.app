/*
 Blurs active element upon history.state change,
 which allows navigation keys (pgdn, pgup, arrows)
 to work after navigation
 */
(function (history) {
    var pushState = history.pushState;
    history.pushState = function (state) {
        if (typeof history.onpushstate == "function") {
            history.onpushstate({ state: state });
        }
        let rv = pushState.apply(history, arguments);
        document.activeElement.blur();
        return rv;
    };

    var replaceState = history.replaceState;
    history.replaceState = function (state) {
        if (typeof history.onreplacestate == "function") {
            history.onreplacestate({ state: state });
        }
        let rv = replaceState.apply(history, arguments);
        document.activeElement.blur();
        return rv;
    };
})(window.history);
