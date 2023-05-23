$INCLUDE("_filters.js");

async function overrideGet(...args) {
    const url = args[0];
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

    let muteTermValues = [];
    if (localStorage.getItem("muteTerms") !== null) {
        try {
            let muteTerms = JSON.parse(localStorage.getItem("muteTerms"));
            muteTermValues = muteTerms
                .filter((t) => t.isEnabled)
                .map((t) => t.value);
        } catch {
            console.warn(
                "Could not parse muteTerms",
                localStorage.getItem("muteTerms")
            );
        }
    }

    if (
        (url.indexOf("/xrpc/app.bsky.feed.getTimeline") > 0 ||
            url.indexOf("/xrpc/app.bsky.unspecced.getPopular") ||
            url.indexOf("/xrpc/app.bsky.unspecced.getAuthorFeed") ||
            url.indexOf("/xrpc/app.bsky.notification.listNotifications")) &&
        muteTermValues.length > 0
    ) {
        let results = filterTimelineWithStats(responseData, muteTermValues);
        responseData = results.timeline;
        let hits = results.hits;
        if (hits > 0) {
            webkit.messageHandlers.incrementMuteTermsHits.postMessage({
                hits: hits,
            });
        }
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
