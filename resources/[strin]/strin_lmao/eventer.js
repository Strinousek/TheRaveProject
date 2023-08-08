const fs = require("fs")

try {
    fs.rmSync("./honeypot.json");
} catch {
    
}

fs.readFile("./honeypot.txt", "utf8", (_, data) => {
    const events = data.split(/\r?\n/);
    for(const [k,v] of Object.entries(events)) {
        events[k] = v.replace(/\"/g, "");
    }
    let stringifiedEvents = JSON.stringify(events);
    fs.writeFileSync("./honeypot.json", stringifiedEvents);
});