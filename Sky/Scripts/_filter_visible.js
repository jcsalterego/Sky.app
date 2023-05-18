function filterVisible(elems) {
    return Array.from(elems).filter((elem) => {
        return elem.offsetParent !== null;
    });
}
