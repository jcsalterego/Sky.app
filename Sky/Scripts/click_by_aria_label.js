function filterVisible(elems) {
    return Array.from(elems).filter((elem) => {
        return elem.offsetParent !== null;
    });
}
function clickByAriaLabel(ariaLabel) {
    let elems = filterVisible(document.querySelectorAll(`[aria-label^="${ariaLabel}" i]`));
    elems.forEach((elem) => elem.click());
}
clickByAriaLabel("$__ARIA_LABEL__");
