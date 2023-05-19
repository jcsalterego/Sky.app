$INCLUDE("_find_all_by_aria_label.js");
$INCLUDE("_manage_hidden_divs");
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
        "div[style*='position: absolute'][style*='bottom: 0']"
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
    return filterVisible(
        Array.from(document.querySelectorAll("div[aria-label]")).filter((e) =>
            e.innerHTML.match(/load new/i)
        )
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
    if (!found) {
        found = clickByAriaLabel(label);
    }
    if (!found) {
        found = findByNavbarIndex(index);
    }
    if (!found) {
        if (url !== "") {
            document.location.href = url;
        }
    }
    manageHiddenDivs();
}
navigate($__CHECK_LOAD_NEW__, "$__LABEL__", $__INDEX__, "$__URL__");
