function isMessageThreadPage() {
    return /^\/messages\/[^/]+\/?$/.test(window.location.pathname);
}

function getMessageTextareas() {
    if (!isMessageThreadPage()) {
        return [];
    }
    return Array.from(document.querySelectorAll("textarea"))
        .filter((textarea) => !textarea.disabled);
}

function fixMessageInputBarTransforms() {
    if (!isMessageThreadPage()) {
        return false;
    }

    let fixed = false;
    const textareas = getMessageTextareas();
    for (const textarea of textareas) {
        const wrapper = textarea.closest("div[style*='transform: translateY(']");
        if (!wrapper) {
            continue;
        }
        if (wrapper.dataset.skyFixedMessageInputBar !== "true" || wrapper.style.transform !== "translateY(0px)") {
            wrapper.style.setProperty("transform", "translateY(0px)", "important");
            wrapper.dataset.skyFixedMessageInputBar = "true";
            fixed = true;
        }
    }

    return fixed || textareas.length > 0;
}

function observeMessageInputBar() {
    const root = document.body;
    if (!root) {
        return false;
    }
    if (root.dataset.skyObserveMessageInputBar === "true") {
        fixMessageInputBarTransforms();
        return true;
    }

    const observer = new MutationObserver(() => {
        fixMessageInputBarTransforms();
    });
    observer.observe(root, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["style"],
    });
    root.dataset.skyObserveMessageInputBar = "true";
    fixMessageInputBarTransforms();
    return true;
}

observeMessageInputBar();
