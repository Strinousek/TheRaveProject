const fs = require('fs');

const StreamParser = async (stream) => {
    const chunks = [];

    for await (const chunk of stream) {
        chunks.push(Buffer.from(chunk));
    }

    return Buffer.concat(chunks);
};

const Test = async () => {
    const thumbnails = JSON.parse(fs.readFileSync("thumbnails.json", "utf8"));
    const start = new Date();
    for(const [key, value] of Object.entries(thumbnails)) {
        const image = await fetch(value, {
            method: "GET",
        }).then(o => o.body);
        const imageBuffer = await StreamParser(image)
        fs.writeFileSync(`images/${key}.jpg`, imageBuffer);
        //console.log(key, value);
    }
    const time = new Date().getTime() - start.getTime();
    console.log("Took ", time / 1000, " seconds");
};

Test();