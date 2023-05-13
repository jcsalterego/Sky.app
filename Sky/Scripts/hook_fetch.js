(function() {
    let originalFetch = window.fetch;
    window.fetch = async function(...args) {
        let url = args[0];
        const response = await originalFetch(...args);
        try {
            let responseData = await response.clone().json();
            window.webkit.messageHandlers.fetch.postMessage({
                "url": url,
                "response": responseData
            });
            if (url.indexOf('https://search.bsky.social/search/posts') === 0
                && document.body.dataset.featureOrderPosts === 'yes'
                ) {
                responseData.sort((post2, post1) => post1.post.createdAt < post2.post.createdAt ? -1 : 1)
                response.json = async function() {
                    return responseData;
                }
            }
        } catch (error) {
            console.warn("Failed to hook_fetch", error);
        }
        return response;
    }
})();
