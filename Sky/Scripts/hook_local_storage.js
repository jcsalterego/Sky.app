$INCLUDE("_with_retry.js");
function hookLocalStorage() {
    let done = false;
    if (window !== undefined && window.localStorage !== undefined) {
        let localStorage = window.localStorage;
        if (window._localStorageSetItem === undefined) {
            window._localStorageSetItem =
                localStorage.setItem.bind(localStorage);
            localStorage.setItem = function (...args) {
                window._localStorageSetItem(...args);
            };
        }
        if (window._localStorageGetItem === undefined) {
            window._localStorageGetItem =
                localStorage.getItem.bind(localStorage);
            localStorage.getItem = function (...args) {
                return window._localStorageGetItem(...args);
            };
        }
        done = true;
    }
    return done;
}
withRetry(hookLocalStorage);
