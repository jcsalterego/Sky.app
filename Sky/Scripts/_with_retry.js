function withRetry(fn, retryMs = 200, count = 1) {
    const MAX_RETRIES = 3;
    if (count >= MAX_RETRIES) {
        console.error(`Failed after ${count} tries. Aborting`);
    } else {
        let done = fn();
        const fnSig = fn.toString().split("\n")[0].substring(0, 50);
        if (!done) {
            $LOG(`failed "${fnSig}...". retrying in ${retryMs}`);
            window.setTimeout(() => withRetry(fn, retryMs, count + 1), retryMs);
        } else if (count > 1) {
            $LOG(`succeeded at try ${count}: "${fnSig}..."`);
        }
    }
}
