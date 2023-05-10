async function fetchImgSrcFromXmlBlob(originalFetch, cid, did) {
    try {
        let url = `https://bsky.social/xrpc/com.atproto.sync.getBlob?did=${did}&cid=${cid}`
        const getBlobResp = await originalFetch(url);
        const getBlobRespXML = await getBlobResp.text();
        let xml = new window.DOMParser().parseFromString(getBlobRespXML, "text/xml")
        let src = xml.getElementsByTagName("img")[0].getAttribute("src");
        src = decodeURIComponent(src);
        return src;
    } catch (error) {
        console.warn("failed to fetch gif blob", error);
        return null;
    }
}

async function gifReplace(responseData, posts) {
    let altered = false;
    for (let post of posts) {
        let allGifData = [];
        try {
            if (post.embed === undefined
                || post.record === undefined
                || post.record.embed === undefined
                || post.record.embed.images === undefined
                || post.record.facets === undefined
            ) {
                continue;
            }
            let postEmbed = post.embed;
            let postRecordEmbed = post.record.embed;
            let postRecordFacets = post.record.facets;
            for (let facet of postRecordFacets) {
                let proceed = false;
                if (facet.index !== undefined) {
                    if (facet.index.byteEnd === 0 && facet.index.byteStart === 0) {
                        proceed = true;
                    }
                }
                if (proceed) {
                    for (let feature of facet.features) {
                        if (feature.uri !== undefined && feature.uri.indexOf('gif://') === 0) {
                            let gifData = feature.uri.substring("gif://".length);
                            allGifData.push(gifData);
                        }
                    }
                }
            }

            let idx = 0;
            for (let image of postRecordEmbed.images) {
                if (idx < allGifData.length) {
                    let gifData = allGifData[idx];
                    postEmbed.images[idx].thumb = gifData;
                    postEmbed.images[idx].fullsize = gifData;
                    altered = true;
                }
                idx++;
            }

            // BACKDATING
            // doc.record.createdAt = "2023-01-01T22:05:18.852Z";

        } catch (error) {
            console.warn("Fail", error);
        }
    }

    return {
        altered: altered,
        responseData: responseData,
    };
}

async function overrideGet(...args) {
    const url = args[0];
    const response = await window._fetch(...args);
    let responseData = await response.clone().json();
    let responseStatus = response.status;
    let responseText = response.statusText;

    window.webkit.messageHandlers.fetch.postMessage({
        "url": url,
        "response": responseData
    });

    let altered = false;

    if (!altered
        && url.indexOf('app.bsky.feed.getPosts') > 0
    ) {
        let rv = await gifReplace(responseData, responseData.posts);
        if (rv.altered) {
            altered = true;
            responseData = rv.responseData;
        }
    }

    if (!altered
        && url.indexOf('app.bsky.feed.getPostThread') > 0
    ) {
        let rv = await gifReplace(responseData, [responseData.thread.post]);
        if (rv.altered) {
            altered = true;
            responseData = rv.responseData;
        }
    }

    if (!altered
        && url.indexOf('app.bsky.feed.getTimeline') > 0
    ) {
        let rv = await gifReplace(responseData, responseData.feed.map(item => item.post));
        if (rv.altered) {
            altered = true;
            responseData = rv.responseData;
        }
    }

    if (!altered
        && url.indexOf('app.bsky.feed.getAuthorFeed') > 0
    ) {
        let rv = await gifReplace(responseData, responseData.feed.map(item => item.post));
        if (rv.altered) {
            altered = true;
            responseData = rv.responseData;
        }
    }

    if (!altered
        && url.indexOf('https://search.bsky.social/search/posts') === 0
        && document.body.dataset.featureOrderPosts === 'yes'
    ) {
        responseData.sort((post2, post1) => post1.post.createdAt < post2.post.createdAt ? -1 : 1)
        altered = true;
    }

    if (altered) {
        let body = new Blob([JSON.stringify(responseData, null, 0)], {
            "type": "application/json",
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

async function overridePost(...args) {
    const url = args[0];

    if (url.indexOf("com.atproto.repo.createRecord") > -1) {
        try {
            let array = args[1].body;
            var json = new TextDecoder().decode(array);
            var doc = JSON.parse(json);

            if (doc.record.facets === undefined) {
                doc.record.facets = []
            }
            if (window.gifs !== undefined) {
                for (let gif of window.gifs) {
                    doc.record.facets.push({
                        "index": {
                            "byteStart": 0,
                            "byteEnd": 0,
                        },
                        "features": [{
                            "uri": `gif://${gif}`,
                            "$type": "app.bsky.richtext.facet#link"
                        }],
                    });
                }
            }
            let returnJson = JSON.stringify(doc, null, 0);
            let returnArray = new TextEncoder().encode(returnJson);
            args[1].body = returnArray;
        } catch (error) {
            console.warn("fail", error);
            return null;
        }
    }

    const response = await window._fetch(...args);
    return response;
}

function hookFetch() {
    if (window._fetch !== undefined) {
        return;
    }

    window._fetch = window.fetch;
    window.fetch = async function(...args) {
        let url = args[0];
        let method = "get";
        if (args.length > 1 && ["post", "get"].indexOf(args[1].method) >= 0) {
            method = args[1].method;
        }

        try {
            if (method === "get") {
                return await overrideGet(...args);
            } else if (method === "post") {
                return await overridePost(...args);
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
