const fs = require("fs")

const SaveProfile = async () => {
    const response = await fetch(`http://127.0.0.1:30120/profileData.json`).then(o => o.json());
    fs.writeFileSync(`./profile${(Math.floor(Math.random() * 69) + 1)}.json`, JSON.stringify(response), {
        encoding: "utf-8"
    }, () => {
        console.log(success)
    });
};

SaveProfile()