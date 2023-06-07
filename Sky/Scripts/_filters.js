export function findCandidates(record) {
    let candidates = [];
    if (record.text !== undefined) {
        candidates.push(record.text);
    }
    if (record.value !== undefined && record.value.text !== undefined) {
        candidates.push(record.value.text);
    }
    let embed = record.embed;
    if (embed !== undefined) {
        if (embed.$type === "app.bsky.embed.images") {
            for (let image of embed["images"]) {
                let alt = image.alt;
                if (alt !== undefined) {
                    candidates.push(alt);
                }
            }
        } else if (embed.$type === "app.bsky.embed.external") {
            let externalEmbed = embed["external"];
            let title = externalEmbed.title;
            if (title !== undefined) {
                candidates.push(title);
            }
            let description = externalEmbed.description;
            if (description !== undefined) {
                candidates.push(description);
            }
        }
    }
    return candidates;
}

export function newTimelineFeedFilterMap(filters, stats) {
    let fn = function (timelineFeedItem, stats) {
        let candidates = [];

        let record = timelineFeedItem.record;
        if (record !== undefined) {
            candidates = candidates.concat(findCandidates(record));
        }

        let post = timelineFeedItem.post;
        if (post !== undefined) {
            if (post.text !== undefined) {
                candidates = candidates.concat(findCandidates(post));
            }
            if (post.record !== undefined) {
                candidates = candidates.concat(findCandidates(post.record));
            }
        }

        let reply = timelineFeedItem.reply;
        if (reply !== undefined) {
            if (reply.root !== undefined) {
                if (reply.root.record !== undefined) {
                    candidates = candidates.concat(
                        findCandidates(reply.root.record)
                    );
                }
                if (
                    reply.root.embed !== undefined &&
                    reply.root.embed.record !== undefined &&
                    reply.root.embed.record.embeds !== undefined
                ) {
                    for (let embed of reply.root.embed.record.embeds) {
                        if (embed.record !== undefined) {
                            candidates = candidates.concat(
                                findCandidates(embed.record)
                            );
                        }
                    }
                }
            }
            if (reply.embed !== undefined) {
                if (reply.embed.record !== undefined) {
                    candidates = candidates.concat(
                        findCandidates(reply.embed.record)
                    );
                }
            }
            if (
                reply.parent !== undefined &&
                reply.parent.record !== undefined
            ) {
                candidates = candidates.concat(
                    findCandidates(reply.parent.record)
                );
            }
        }

        for (let candidate of candidates) {
            let lowercaseFilters = filters.map((filter) =>
                filter.toLowerCase()
            );
            if (
                lowercaseFilters.some((filter) =>
                    candidate.toLowerCase().includes(filter)
                )
            ) {
                timelineFeedItem = null;
                stats.hits++;
                break;
            }
        }

        return timelineFeedItem;
    };
    return function (item) {
        item = fn(item, stats);
        if (
            item !== null &&
            item.embed !== undefined &&
            item.embed.record !== undefined
        ) {
            item.embed.record = fn(item.embed.record, stats);
        }
        return item;
    };
}

export function filterTimeline(timeline, filters, stats) {
    if (Array.isArray(timeline)) {
        timeline = timeline
            .map(newTimelineFeedFilterMap(filters, stats))
            .filter((item) => item !== null);
    } else {
        const keys = ["feed", "notifications"];
        for (let key of keys) {
            if (timeline[key] !== undefined) {
                timeline[key] = timeline[key]
                    .map(newTimelineFeedFilterMap(filters, stats))
                    .filter((item) => item !== null);
            }
        }
    }
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

export function removeHomeReplies(timeline) {
    timeline.feed = timeline.feed.filter(item => item["reply"] === undefined);
    return timeline;
}
