$INCLUDE("_filter_visible.js");
function findAllByAriaLabel(ariaLabel) {
    return filterVisible(
        document.querySelectorAll(`[aria-label^="${ariaLabel}" i]`)
    );
}
