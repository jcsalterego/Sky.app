$INCLUDE("_filter_visible.js");
function clickAriaLabels(...labels) {
    let elems = [];
    for (let label of labels) {
        elems.push(
            ...Array.from(
                document.querySelectorAll(
                    `div[role='button'][aria-label^='${label}' i]`
                )
            )
        );
    }
    elems = filterVisible(elems);
    elems.forEach((elem) => elem.click());
}
function escGoesBack() {
    if (document.location.pathname.indexOf("/search") === 0) {
        clickAriaLabels("Clear search query");
    } else {
        clickAriaLabels("back", "go back");
    }
}
escGoesBack();
