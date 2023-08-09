import { CronJob } from "cron";
import mysqldump from "mysqldump";
import fs from "fs/promises";
import dayjs, { Dayjs } from "dayjs";
import FormData from "form-data";

dayjs.locale("cs");

//const DatabaseBackupWebhook = "https://discord.com/api/webhooks/1138619585462026310/I6QS79fmOKVh_3N2r_UbXfI3GByUkjMDJ3liXmdXoKQyVGSwKc5M0XfT2n5hnuSygXZp";

async () => {
    try {
        await fs.mkdir("./database_dumps");
        console.log("Created a new database dump folder.");
    } catch(err) {
        console.log("Database dump folder already exists, skipping creation.");
    }
}

/*async function CreateBlobFromFile(path: string): Promise<Blob> {
    const file = await fs.readFile(path);
    return new Blob([file]);
}*/

const DatabaseBackupJob: CronJob = new CronJob(
    //`0 0 */1 * * *`,
    `0 0 */2 * * *`,
    async () => {
        const date: Dayjs = dayjs();
        const fileName = `${date.format("YYYY-MM-DDTHH-mm-ss")}.sql`
        const filePath = `./database_dumps/${fileName}`;
        try {
            await mysqldump({
                connection: {
                    host: "localhost",
                    user: "root",
                    password: "",
                    database: "fivemdev"
                },
                dumpToFile: filePath
            }).catch((o: any) => console.log(o));
            /*const form = new FormData();
            form.append('file', await CreateBlobFromFile(filePath), fileName);
            const data = {
                method: "POST",
                body: form,
                headers: form.getHeaders(),
            }
            const response = await fetch(DatabaseBackupWebhook, data as any).then(o => o.json()).catch(o => console.log(o));
            console.log(response);*/
        } catch (err) {
            console.log("An error occured during database backup.");
        }
    },
    null,
    true,
    "Europe/Prague"
)