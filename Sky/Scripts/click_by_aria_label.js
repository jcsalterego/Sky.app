$INCLUDE("_find_all_by_aria_label.js");
function clickByAriaLabel(ariaLabel, visibleOnly = false) {
    return findAllByAriaLabel(ariaLabel, visibleOnly).forEach((elem) => elem.click());
}
clickByAriaLabel("$__ARIA_LABEL__");
