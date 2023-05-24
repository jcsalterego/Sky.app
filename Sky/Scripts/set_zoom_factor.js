$INCLUDE("_with_retry");

function setZoomFactor(zoomFactor) {
    if (document !== undefined && document.body !== undefined) {
        document.body.style.zoom = zoomFactor;
        return true;
    }
    return false;
}

withRetry(() => setZoomFactor($__ZOOM_FACTOR__));
