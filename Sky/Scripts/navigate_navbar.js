$INCLUDE("_find_all_by_aria_label.js");
function clickByAriaLabel(label) {
    let elems = findAllByAriaLabel(label);
    elems.forEach((elem) => elem.click());
    return elems.length > 0;
}
function findByNavbarIndex(index) {
    if (index == -1) {
        return false;
    }
    let found = false;
    let elems = document.querySelectorAll(
        "div[style*='transform: translateY(0px)']"
    );
    for (let elem of elems) {
        let children = elem.children;
        if (children.length >= 4) {
            children[index].click();
            found = true;
            break;
        }
    }
    return found;
}
function getLoadNewButtons() {
    return Array.from(
        document.querySelectorAll("button[aria-label^=\"load new\" i]")
    );
}
function navigate(checkLoadNew, label, index, url) {
    let found = false;
    if (checkLoadNew) {
        let loadNewButtons = getLoadNewButtons();
        if (loadNewButtons.length > 0) {
            loadNewButtons.forEach((b) => b.click());
            found = true;
        }
    }
    let labels = label.split(";");
    for (const labelVariant of labels) {
        if (!found) {
            found = clickByAriaLabel(labelVariant);
        }
        if (!found) {
            found = findByNavbarIndex(labelVariant);
        }
        if (found) {
            break;
        }
    }
    if (!found) {
        if (url !== "") {
            document.location.href = url;
        }
    }
}
navigate($__CHECK_LOAD_NEW__, "$__LABEL__", $__INDEX__, "$__URL__");
