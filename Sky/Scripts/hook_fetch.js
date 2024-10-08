$INCLUDE("_filters.js");

async function overrideGet(...args) {
    let request = args[0];
    let url = null;
    if (request.constructor.name === "Request") {
        url = request.url;
    } else if (request.constructor.name === "URL") {
        url = request.href;
    } else if (request.constructor.name === "String") {
        url = request;
    } else {
        console.warn("Unknown request type", request);
        return window._fetch(...args);
    }
    const response = await window._fetch(...args);
    const contentType = response.headers.get("Content-Type");
    if (
        contentType === null ||
        contentType.match(/application\/json/) === null
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
    let isSearch = url.indexOf("https://search.bsky.social/search/posts") === 0;
    let featureOrderPosts = localStorage.getItem("featureOrderPosts") === "yes";
    let featureHideHomeReplies = localStorage.getItem("featureHideHomeReplies") === "yes";

    if (isSearch && featureOrderPosts) {
        responseData.sort((post2, post1) =>
            post1.post.createdAt < post2.post.createdAt ? -1 : 1
        );
        altered = true;
    }

    if (url.indexOf("/xrpc/app.bsky.feed.getTimeline") > 0 &&
        featureHideHomeReplies
    ) {
        responseData = removeHomeReplies(responseData);
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
