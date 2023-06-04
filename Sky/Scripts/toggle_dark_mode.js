function toggleDarkMode() {
    let buttons = Array.from(
        document.querySelectorAll("div[aria-label]")
    ).filter((elem) => {
        let ariaLabel = elem.getAttribute("aria-label");
        return ariaLabel.match(/toggle .* mode/i);
    });
    if (buttons.length === 0) {
        let answer = window.confirm(
            "Toggling dark mode requires reloading the page. Would you like to proceed?"
        );
        if (answer) {
            let json = localStorage.root;
            let doc = JSON.parse(json);
            let changed = false;
            if (doc.shell.colorMode === "light") {
                doc.shell.colorMode = "dark";
                changed = true;
            } else if (doc.shell.colorMode === "dark") {
                doc.shell.colorMode = "light";
                changed = true;
            }
            if (changed) {
                let jsonReturn = JSON.stringify(doc, null, 0);
                localStorage.setItem("root", jsonReturn);
                window.webkit.messageHandlers.windowReload.postMessage({});
            }
        }
    } else {
        buttons[0].click();
    }
}

toggleDarkMode();
