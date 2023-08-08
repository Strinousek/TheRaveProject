const fs = require("fs");
const sharp = require("sharp");

fs.readdir("./not_compressed_images", {
    encoding: "utf-8"
}, async (_, files) => {
    for(var fileId in files) {
        const fileBuffer = fs.readFileSync(`./not_compressed_images/${files[fileId]}`);

        await sharp(fileBuffer)
            .jpeg({quality: 25})
            .toFile(`./compressed_images/${files[fileId]}`);
    }
})