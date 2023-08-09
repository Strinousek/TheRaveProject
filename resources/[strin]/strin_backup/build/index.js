"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const cron_1 = require("cron");
const mysqldump_1 = __importDefault(require("mysqldump"));
const promises_1 = __importDefault(require("fs/promises"));
const dayjs_1 = __importDefault(require("dayjs"));
// import FormData from "form-data";
dayjs_1.default.locale("cs");
//const DatabaseBackupWebhook = "https://discord.com/api/webhooks/1138619585462026310/I6QS79fmOKVh_3N2r_UbXfI3GByUkjMDJ3liXmdXoKQyVGSwKc5M0XfT2n5hnuSygXZp";
const EnsureDatabaseDumpFolder = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // this goes from the absolute root (server-data)
        yield promises_1.default.mkdir("./database_dumps");
        console.log("Created a new database dump folder.");
    }
    catch (err) {
        console.log("Database dump folder already exists, skipping creation.");
    }
});
/*async function CreateBlobFromFile(path: string): Promise<Blob> {
    const file = await fs.readFile(path);
    return new Blob([file]);
}*/
EnsureDatabaseDumpFolder();
const DatabaseDumpJob = new cron_1.CronJob(
//`*/5 * * * * *`,
`0 0 */2 * * *`, () => __awaiter(void 0, void 0, void 0, function* () {
    const date = (0, dayjs_1.default)();
    const fileName = `${date.format("YYYY-MM-DDTHH-mm-ss")}.sql`;
    const filePath = `./database_dumps/${fileName}`;
    try {
        yield (0, mysqldump_1.default)({
            connection: {
                host: "localhost",
                user: "root",
                password: "",
                database: "fivemdev"
            },
            dumpToFile: filePath
        }).catch((o) => console.log(o));
        /*const form = new FormData();
        form.append('file', await CreateBlobFromFile(filePath), fileName);
        const data = {
            method: "POST",
            body: form,
            headers: form.getHeaders(),
        }
        const response = await fetch(DatabaseBackupWebhook, data as any).then(o => o.json()).catch(o => console.log(o));
        console.log(response);*/
    }
    catch (err) {
        console.log("An error occured during database backup.");
    }
}), null, true, "Europe/Prague");
