export function findCandidates(postRecord, post) {
    let candidates = [];
    if (postRecord !== undefined) {
        candidates.push([postRecord.text, post.author]);

        let embed = postRecord.embed;
        if (embed !== undefined) {
            let externalEmbed = embed["external"];
            if (externalEmbed !== undefined) {
                let title = externalEmbed.title;
                if (title !== undefined) {
                    candidates.push([title, post.author]);
                }

                let description = externalEmbed.description;
                if (description !== undefined) {
                    candidates.push([description, post.author]);
                }
            }

            let imagesEmbed = embed["images"];
            if (imagesEmbed !== undefined) {
                for (let image of imagesEmbed) {
                    let alt = image.alt;
                    if (alt !== undefined) {
                        candidates.push([alt, post.author]);
                    }
                }
            }
        }
    }
    return candidates;
}

export function newTimelineFeedFilterMap(filters, stats) {
    let fn = function (timelineFeedItem, stats) {
        let found = null;
        let candidates = [];

        let post = timelineFeedItem.post;
        if (post !== undefined) {
            let postRecord = post.record;
            if (postRecord !== undefined) {
                candidates = candidates.concat(
                    findCandidates(postRecord, post)
                );
            }
        }

        let reply = timelineFeedItem.reply;
        if (reply !== undefined) {
            let replyRoot = reply.root;
            if (replyRoot !== undefined) {
                let replyRootRecord = replyRoot.record;
                if (replyRootRecord !== undefined) {
                    candidates = candidates.concat(
                        findCandidates(replyRootRecord, replyRoot)
                    );
                }
            }
            let replyParent = reply.parent;
            if (replyParent !== undefined) {
                let replyParentRecord = replyParent.record;
                if (replyParentRecord !== undefined) {
                    candidates = candidates.concat(
                        findCandidates(replyParentRecord, replyParent)
                    );
                }
            }
        }

        for (let candidateInfo of candidates) {
            let candidate = candidateInfo[0];
            let record = candidateInfo[1];
            let lowercaseFilters = filters.map((filter) =>
                filter.toLowerCase()
            );
            if (
                lowercaseFilters.some((filter) =>
                    candidate.toLowerCase().includes(filter)
                )
            ) {
                found = record;
                stats.hits++;
                break;
            }
        }

        if (found !== null) {
            if (found.viewer === undefined) {
                found.viewer = {};
            }
            found.viewer.muted = true;
            stats.hits++;
        }

        return timelineFeedItem;
    };
    return function (item) {
        item = fn(item, stats);
        if (item.embed !== undefined && item.embed.record !== undefined) {
            item.embed.record = fn(item.embed.record);
        }
        return item;
    };
}

export function filterTimeline(timeline, filters, stats) {
    timeline.feed = timeline.feed.map(newTimelineFeedFilterMap(filters, stats));
    return timeline;
}

export function filterTimelineWithStats(timeline, filters) {
    let stats = {
        hits: 0,
    };
    timeline = filterTimeline(timeline, filters, stats);
    return {
        timeline: timeline,
        hits: stats.hits,
    };
}
