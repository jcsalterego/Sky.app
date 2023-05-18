$INCLUDE("_filter_visible.js");
function clickByAriaLabel(ariaLabel) {
    let elems = filterVisible(document.querySelectorAll(`[aria-label^="${ariaLabel}" i]`));
    elems.forEach((elem) => elem.click());
}
clickByAriaLabel("$__ARIA_LABEL__");
