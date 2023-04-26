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
function clickNavbarByIndexOrLabel() {
    let found = false;
    if (!found) {
        found = findByDivLabel('$__LABEL__');
    }
    if (!found) {
        found = findByNavbarIndex($__INDEX__);
    }
}
clickNavbarByIndexOrLabel();
