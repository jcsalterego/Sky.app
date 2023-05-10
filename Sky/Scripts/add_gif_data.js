
async function addGifData(blob) {
    let gif = decodeURIComponent(blob);
    if (window.gifs === undefined) {
        window.gifs = [];
    }
    window.gifs.push(gif);
}

addGifData("$__BLOB__");
