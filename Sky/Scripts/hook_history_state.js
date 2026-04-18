/*
 Blurs active element upon history.state change,
 which allows navigation keys (pgdn, pgup, arrows)
 to work after navigation
 */
(function (history) {
    function isMessageThreadPage() {
        return /^\/messages\/[^/]+\/?$/.test(window.location.pathname);
    }

    function isDmTextarea(elem) {
        return Boolean(
            elem
            && elem.tagName === "TEXTAREA"
            && isMessageThreadPage()
        );
    }

    function getMessageThreadTextarea() {
        if (!isMessageThreadPage()) {
            return null;
        }
        const textareas = Array.from(document.querySelectorAll("textarea"));
        return textareas.find((textarea) => !textarea.disabled) || null;
    }

    function focusDmTextarea() {
        const textarea = getMessageThreadTextarea();
        if (!textarea || typeof textarea.focus !== "function") {
            return;
        }
        textarea.focus();
        if (typeof textarea.value === "string" && typeof textarea.setSelectionRange === "function") {
            const end = textarea.value.length;
            textarea.setSelectionRange(end, end);
        }
    }

    function preserveDmTextareaFocus() {
        setTimeout(() => {
            focusDmTextarea();
        }, 0);
    }

    var pushState = history.pushState;
    history.pushState = function (state) {
        if (typeof history.onpushstate == "function") {
            history.onpushstate({ state: state });
        }
        const activeElement = document.activeElement;
        let rv = pushState.apply(history, arguments);
        const skippedBlur = isDmTextarea(activeElement);
        if (skippedBlur) {
            preserveDmTextareaFocus();
        } else if (document.activeElement && typeof document.activeElement.blur === "function") {
            document.activeElement.blur();
        }
        return rv;
    };

    var replaceState = history.replaceState;
    history.replaceState = function (state) {
        if (typeof history.onreplacestate == "function") {
            history.onreplacestate({ state: state });
        }
        const activeElement = document.activeElement;
        let rv = replaceState.apply(history, arguments);
        const skippedBlur = isDmTextarea(activeElement);
        if (skippedBlur) {
            preserveDmTextareaFocus();
        } else if (document.activeElement && typeof document.activeElement.blur === "function") {
            document.activeElement.blur();
        }
        return rv;
    };
})(window.history);
