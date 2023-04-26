function findByDivLabel(label) {
    let found = false;
    let elems = Array.from(document.querySelectorAll("div")).
            filter(elem => elem.innerHTML === label);
    console.log("div label elems", elems);
    if (elems.length > 0) {
        for (let elem of elems) {
            elem.click();
        }
    }
    return found;
}
function findBySvgPathD(svgPathD) {
    let found = false;
    let elems = Array.from(document.querySelectorAll("svg path[d]")).
            filter(elem => elem.getAttribute("d") === svgPathD);
    console.log("svg path d elems", elems);
    if (elems.length > 0) {
        console.log(elems.length);
        for (let elem of elems) {
            elem.parentElement.parentElement.click();
        }
    }
    return found;
}
function clickNavbarByIndexOrLabel() {
    let found = false;
    if (!found) {
        found = findByDivLabel('New Post');
    }
    if (!found) {
        found = findBySvgPathD('M 20 9 L 20 16 C 20 18.209 18.209 20 16 20 L 8 20 C 5.791 20 4 18.209 4 16 L 4 8 C 4 5.791 5.791 4 8 4 L 15 4');
    }
}
clickNavbarByIndexOrLabel();
