if (window !== undefined) {
    window.open = function() {
        args = JSON.parse(JSON.stringify(arguments));
        window.webkit.messageHandlers.windowOpen.postMessage(args);
    }
}
