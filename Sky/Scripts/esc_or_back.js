function filterVisible(elems) {
    $LOG(`elems.length = ${elems.length}`);
    return Array.from(elems).filter(elem => {
        return (elem.offsetParent !== null);
    });
}
function escOrBack() {
    if (document.location.pathname.indexOf("/search") === 0) {
        return;
    }
    let elems = filterVisible(
        Array.from(document.querySelectorAll("div[role='button']"))
            .filter(elem => {
                if (elem.getAttribute('aria-label') !== null) {
                    return ["back", "go back"].indexOf(elem.getAttribute('aria-label').toLowerCase()) > -1;
                }
                return false;
            })
    );
    let backElems = elems.filter(
        e => "back" === e.getAttribute('aria-label').toLowerCase()
    );
    let goBackElems = elems.filter(
        e => "go back" === e.getAttribute('aria-label').toLowerCase()
    );
    if (backElems.length > 0) {
        backElems.forEach(elem => elem.click());
    } else if (goBackElems.length > 0) {
        goBackElems.forEach(elem => elem.click());
    }
}
escOrBack();
