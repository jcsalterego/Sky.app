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
            doc.shell.darkMode = !doc.shell.darkMode;
            let jsonReturn = JSON.stringify(doc, null, 0);
            localStorage.setItem("root", jsonReturn);
            window.webkit.messageHandlers.windowReload.postMessage({});
        }
    } else {
        buttons[0].click();
    }
}

toggleDarkMode();
