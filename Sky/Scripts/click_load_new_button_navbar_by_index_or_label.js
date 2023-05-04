function findByDivLabel(label) {
    let found = false;
    let elems = Array.from(document.querySelectorAll("div")).
            filter(elem => elem.innerHTML === label);
    if (elems.length > 0) {
        for (let elem of elems) {
            elem.click();
        }
    }
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
function clickNavbarByIndexOrLabel() {
    let loadNewButtons = getLoadNewButtons();
    if (loadNewButtons.length > 0) {
        loadNewButtons.forEach(b => b.click());
    } else {
        let found = false;
        if (!found) {
            found = findByDivLabel('$__LABEL__');
        }
        if (!found) {
            found = findByNavbarIndex($__INDEX__);
        }
    }
}
clickNavbarByIndexOrLabel();
