$INCLUDE("_find_all_by_aria_label.js");
function clickByAriaLabel(ariaLabel) {
    return findAllByAriaLabel(ariaLabel).forEach((elem) => elem.click());
}
clickByAriaLabel("$__ARIA_LABEL__");
