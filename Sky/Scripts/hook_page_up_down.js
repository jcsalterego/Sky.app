function filterVisible(elems) {
    $LOG(`elems.length = ${elems.length}`);
    return Array.from(elems).filter(elem => {
        return (elem.offsetParent !== null);
    });
}
function getElementsWithMaxScrollHeight() {
    let ary = Array.from(document.querySelectorAll("div"))
        .filter(e => e.scrollHeight > 0)
        .map(e => {
            return {
                "scrollHeight": parseInt(e.scrollHeight),
                "elem": e,
            };
        });
    ary.sort((b, a) => a.scrollHeight > b.scrollHeight ? 1 : -1);
    let maxScrollHeight = ary[0].scrollHeight;
    fs = ary.filter(item => item.scrollHeight === maxScrollHeight)
        .map(item => item.elem);
    return fs;
}
function pageUpDownEventHandler(ev) {
    const KEYDOWN_KEYS = ["PageDown", "PageUp", "Home", " ", "ArrowDown", "ArrowUp", "End"];
    const SCROLL_DIFF = 50;
    if (ev.target === document.body
        && KEYDOWN_KEYS.indexOf(ev.key) > -1
    ) {
        ev.preventDefault();
        let elems = Array.from(document.querySelectorAll("[data-testid]"));
        elems = elems.filter(elem => elem.dataset.testid.match(/Page|Feed$/));
        fs = filterVisible(elems);

        if (fs.length === 0) {
            fs = getElementsWithMaxScrollHeight();
        }

        if (ev.key === "PageDown" || (ev.key === " " && ev.shiftKey === false)) {
            fs.forEach(f => f.scrollTop += f.clientHeight)
        } else if (ev.key === "PageUp" || (ev.key === " " && ev.shiftKey === true)) {
            fs.forEach(f => f.scrollTop -= f.clientHeight)
        } else if (ev.key === "ArrowDown") {
            fs.forEach(f => f.scrollTop += SCROLL_DIFF);
        } else if (ev.key === "ArrowUp") {
            fs.forEach(f => f.scrollTop -= SCROLL_DIFF);
        } else if (ev.key === "Home") {
            fs.forEach(f => f.scrollTop = 0);
        } else if (ev.key === "End") {
            fs.forEach(f => f.scrollTop = f.scrollHeight - f.clientHeight);
        }
    }
}
function setPageUpDown() {
    let done = false;
    if (document !== undefined) {
        let root = document.body;
        if (root !== undefined) {
            if (root.dataset.pageUpDownHooked === undefined) {
                root.dataset.pageUpDownHooked = true;
                document.body.addEventListener("keydown", pageUpDownEventHandler);
            }
            done = true;
        }
    }
    return done;
}
function hookPageUpDown() {
    let done = setPageUpDown();
    if (!done) {
        // try again 200ms
        window.setTimeout(hookPageUpDown, 200);
    }
}
hookPageUpDown();
