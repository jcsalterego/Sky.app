async function overrideGet(...args) {
    const url = args[0];
    const response = await window._fetch(...args);
    if (
        response.headers.get("Content-Type").match(/application\/json/) === null
    ) {
        return response;
    }

    let responseData = await response.clone().json();
    let responseStatus = response.status;
    let responseText = response.statusText;

    window.webkit.messageHandlers.fetch.postMessage({
        url: url,
        response: responseData,
    });

    let altered = false;

    if (
        !altered &&
        url.indexOf("https://search.bsky.social/search/posts") === 0 &&
        document.body.dataset.featureOrderPosts === "yes"
    ) {
        responseData.sort((post2, post1) =>
            post1.post.createdAt < post2.post.createdAt ? -1 : 1
        );
        altered = true;
    }

    if (altered) {
        let body = new Blob([JSON.stringify(responseData, null, 0)], {
            type: "application/json",
        });
        let options = {
            status: responseStatus,
            statusText: responseText,
        };
        return new Response(body, options);
    } else {
        return response;
    }
}

function hookFetch() {
    if (window._fetch !== undefined) {
        return;
    }

    window._fetch = window.fetch;
    window.fetch = async function (...args) {
        let url = args[0];
        let method = "get";
        if (args.length > 1 && ["get"].indexOf(args[1].method) >= 0) {
            method = args[1].method;
        }

        try {
            if (method === "get") {
                return await overrideGet(...args);
            } else {
                return window._fetch(...args);
            }
        } catch (error) {
            console.error("fail", error);
            return window._fetch(...args);
        }
    };
}

hookFetch();
