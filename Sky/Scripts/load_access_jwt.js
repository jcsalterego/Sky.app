// Loads accessJwt from localStorage and sends it to loadAccessJwt messageHandler
function loadAccessJwt() {
    let accessJwt = null;
    if (localStorage.root !== undefined) {
        root = JSON.parse(localStorage.root);

        let session = root.session;
        if (session !== undefined) {
            let accounts = session.accounts;
            let data = session.data;

            if (accounts !== undefined && data !== undefined) {
                let did = data.did;
                let activeAccounts = accounts.filter(
                    (account) => account.did === did
                );

                if (activeAccounts.length === 1) {
                    accessJwt = activeAccounts[0].accessJwt;
                }
            }
        }
    }
    window.webkit.messageHandlers.loadAccessJwt.postMessage({
        accessJwt: accessJwt,
    });
}
loadAccessJwt();
