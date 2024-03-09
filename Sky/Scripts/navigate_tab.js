$INCLUDE("_filter_visible.js");
function getAncestor(elem, levels) {
    let parent = elem;
    for (let i = 0; i < levels; i++) {
        parent = parent.parentElement;
    }
    return parent;
}
function getDescendent(elem, levels) {
    let child = elem;
    for (let i = 0; i < levels; i++) {
        child = child.children[0];
    }
    return child;
}
function navigateHomeTabs(direction) {
    let rootElem = undefined,
        tabElems = undefined;
    if (rootElem === undefined) {
        let rootElems = filterVisible(
            document.querySelectorAll(`div[data-testid="homeScreenFeedTabs"]`)
        );
        if (rootElems.length === 1) {
            rootElem = rootElems[0];
        }
    }
    if (rootElem === undefined) {
        let followingElems = filterVisible(
            Array.from(document.querySelectorAll("div")).filter(
                (elem) => elem.innerHTML === "Following"
            )
        );
        if (followingElems.length == 1) {
            rootElem = getAncestor(followingElems[0], 2);
        }
    }
    if (rootElem === undefined) {
        console.warn("could not find rootElem");
        return;
    }
    tabElems = Array.from(rootElem.querySelectorAll(`div[tabindex]`));
    if (tabElems.length === 0) {
        console.warn("could not find tabElems");
        return;
    }

    navigateTabElems(tabElems, 2, direction);
}

function navigateProfileTabs(direction) {
    let rootElem = undefined,
        tabElems = undefined;
    if (rootElem === undefined) {
        let postsElems = filterVisible(
            Array.from(document.querySelectorAll("div")).filter(
                (elem) => elem.innerHTML === "Posts"
            )
        );
        if (postsElems.length == 1) {
            rootElem = getAncestor(postsElems[0], 3);
        }
    }
    if (rootElem === undefined) {
        console.warn("could not find rootElem");
        return;
    }
    tabElems = Array.from(rootElem.querySelectorAll(`div[aria-label]`));
    if (tabElems.length === 0) {
        console.warn("could not find tabElems");
        return;
    }
    navigateTabElems(tabElems, 2, direction);
}

function navigateSearchTabs(direction) {
    let rootElem = undefined,
        tabElems = undefined;
    if (rootElem === undefined) {
        let postsElems = filterVisible(
            Array.from(document.querySelectorAll("div")).filter(
                (elem) => elem.innerHTML === "Posts"
            )
        );
        if (postsElems.length == 1) {
            rootElem = getAncestor(postsElems[0], 3);
        }
    }
    if (rootElem === undefined) {
        console.warn("could not find rootElem");
        return;
    }
    tabElems = Array.from(rootElem.querySelectorAll(`div[tabindex]`));
    if (tabElems.length === 0) {
        console.warn("could not find tabElems");
        return;
    }

    navigateTabElems(tabElems, 2, direction);
}

function navigateTabElems(tabElems, descendentCount, direction) {
    var selected = -1;
    var idx = 0;
    for (let tabElem of tabElems) {
        let child = getDescendent(tabElem, descendentCount);
        if (
            child.parentElement.style.borderBottomColor !== ""
        ) {
            selected = idx;
            break;
        }
        idx++;
    }
    if (selected < 0) {
        console.warn("Could not find selected tab");
        return;
    }

    let total = tabElems.length;
    let nextIndex = selected + direction;
    if (nextIndex < 0) {
        while (nextIndex < 0) {
            nextIndex += total;
        }
    } else {
        nextIndex = nextIndex % total;
    }
    tabElems[nextIndex].click();
}

function navigateTab(direction) {
    let path = window.location.pathname;
    if (path === "/") {
        navigateHomeTabs(direction);
    } else if (path.match(/\/profile\//)) {
        navigateProfileTabs(direction);
    } else if (path.match(/\/search/)) {
        navigateSearchTabs(direction);
    }
}

navigateTab($__DIRECTION__);
