if (window !== undefined) {
    window.open = function() {
        window.webkit.messageHandlers.consoleLog.postMessage({"window open": "hi"});
        args = JSON.parse(JSON.stringify(arguments));
        window.webkit.messageHandlers.windowOpen.postMessage(args);
    }
}
