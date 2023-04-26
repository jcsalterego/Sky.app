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
findByDivLabel('$__LABEL__');
