function withRetry(fn, retryMs = 200, maxRetries = null, count = 1) {
    const DEFAULT_MAX_RETRIES = 3;
    if (!maxRetries) {
        maxRetries = DEFAULT_MAX_RETRIES;
    }
    if (count >= maxRetries) {
        console.error(`Failed after ${count} tries. Aborting`);
    } else {
        let done = fn();
        const fnSig = fn.toString().split("\n")[0].substring(0, 50);
        if (!done) {
            $LOG(`failed "${fnSig}...". retrying in ${retryMs}`);
            window.setTimeout(() => withRetry(fn, retryMs, maxRetries, count + 1), retryMs);
        } else if (count > 1) {
            $LOG(`succeeded at try ${count}: "${fnSig}..."`);
        }
    }
}
