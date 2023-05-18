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

function hookFeatureOrderPosts(value) {
    let done = setFeatureOrderPosts(value);
    if (!done) {
        // try again 200ms
        window.setTimeout(() => hookFeatureOrderPosts(value), 200);
    }
}

hookFeatureOrderPosts("$__VALUE__");
