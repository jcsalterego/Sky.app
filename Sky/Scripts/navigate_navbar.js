function findByAriaLabel(label) {
    let found = false;
    let elems = filterVisible(document.querySelectorAll("[aria-label]")).
        filter(elem => elem.getAttribute("aria-label") === label);
    if (elems.length > 0) {
        found = true;
        for (let elem of elems) {
            elem.click();
        }
    }
    document.activeElement.blur();
    return found;
}
function findByNavbarIndex(index) {
    if (index == -1) {
        return false;
    }
    let found = false;
    let elems = Array.from(document.querySelectorAll("div")).
            filter(elem => elem.style.position === "absolute"
                         && elem.style.bottom === "0px");
    if (elems.length > 0) {
        for (let elem of elems) {
            let children = elem.children;
            if (children.length >= 4) {
                children[index].click()
                found = true;
                break;
            }
        }
    }
    document.activeElement.blur();
    return found;
}
function filterVisible(elems) {
    return Array.from(elems).filter(elem => {
        // check if any ancestors have display none
        let visible = true;
        while (elem !== null) {
            if (window.getComputedStyle(elem).display === "none") {
                visible = false;
                break;
            }
            elem = elem.parentElement;
        }
        return visible;
    });
}
function getLoadNewButtons() {
    return filterVisible(
        Array.from(document.querySelectorAll("div[aria-label]"))
            .filter(e => e.innerHTML.match(/load new/i))
    );
}
function navigate(checkLoadNew, label, index) {
    let found = false;
    if (checkLoadNew) {
        let loadNewButtons = getLoadNewButtons();
        if (loadNewButtons.length > 0) {
            loadNewButtons.forEach(b => b.click());
            found = true;
        }
    }
    if (!found) {
        found = findByAriaLabel(label);
    }
    if (!found) {
        found = findByNavbarIndex(index);
    }
}
navigate($__CHECK_LOAD_NEW__, '$__LABEL__', $__INDEX__);
