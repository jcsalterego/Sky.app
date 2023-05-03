(function() {
    let originalFetch = window.fetch;
    window.fetch = async function(...args) {
        let url = args[0];
        const response = await originalFetch(...args);
        let responseData = await response.clone().json();
        window.webkit.messageHandlers.fetch.postMessage({
            "url": url,
            "response": responseData
        });
        return response;
    }
})();
