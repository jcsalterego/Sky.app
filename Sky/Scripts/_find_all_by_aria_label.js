$INCLUDE("_filter_visible.js");

function findAllByAriaLabel(ariaLabel, visibleOnly = false) {
    let elems = document.querySelectorAll(`[aria-label^="${ariaLabel}" i]`);
    if (visibleOnly) {
        elems = filterVisible(elems);
    } else {
        elems = Array.from(elems);
    }
    elems = elems.filter(
        (elem) => {
            return elem.getAttribute("aria-label").toLowerCase() === ariaLabel.toLowerCase();
        }
    );
    return elems;
}
