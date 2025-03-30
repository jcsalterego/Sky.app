(function (key, value) {
    console.info(`localStorage setItem ${key} to ${value}`);
    localStorage.setItem(key, value);
})(`$__KEY__`, `$__VALUE__`);
