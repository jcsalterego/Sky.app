$INCLUDE("_filter_visible.js");
function findAllByAriaLabel(ariaLabel) {
    return filterVisible(
        document.querySelectorAll(`[aria-label^="${ariaLabel}" i]`)
    ).filter(
        (elem) => {
            return elem.getAttribute("aria-label").toLowerCase() === ariaLabel.toLowerCase();
        }
    );
}
