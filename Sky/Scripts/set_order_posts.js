$INCLUDE("_with_retry");
function setFeatureOrderPosts(value) {
    let done = false;
    if (document !== undefined) {
        let root = document.body;
        if (root !== undefined) {
            root.dataset.featureOrderPosts = value;
            done = true;
        }
    }
    return done;
}

withRetry(() => setFeatureOrderPosts("$__VALUE__"));
