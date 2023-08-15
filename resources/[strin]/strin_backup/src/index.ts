import { CronJob } from "cron";
import mysqldump from "mysqldump";
import fs from "fs/promises";
import dayjs, { Dayjs } from "dayjs";
// import FormData from "form-data";

dayjs.locale("cs");

//const DatabaseBackupWebhook = "https://discord.com/api/webhooks/1138619585462026310/I6QS79fmOKVh_3N2r_UbXfI3GByUkjMDJ3liXmdXoKQyVGSwKc5M0XfT2n5hnuSygXZp";

const EnsureDatabaseDumpFolder = async () => {
    try {
        // this goes from the absolute root (server-data)
        await fs.mkdir("./database_dumps");
        console.log("Created a new database dump folder.");
    } catch(err) {
        console.log("Database dump folder already exists, skipping creation.");
    }
};

const ParseConnectionString = () => {
    // @ts-ignore
    const connectionString = GetConvar('mysql_connection_string', '')
    const splitMatchGroups = connectionString.match(
      new RegExp(
        '^(?:([^:/?#.]+):)?(?://(?:([^/?#]*)@)?([\\w\\d\\-\\u0100-\\uffff.%]*)(?::([0-9]+))?)?([^?#]+)?(?:\\?([^#]*))?$'
      )
    ) as RegExpMatchArray;
  
    if (!splitMatchGroups) throw new Error(`mysql_connection_string structure was invalid (${connectionString})`);
  
    const authTarget = splitMatchGroups[2] ? splitMatchGroups[2].split(':') : [];
  
    const options = {
      user: authTarget[0] || undefined,
      password: authTarget[1] || undefined,
      host: splitMatchGroups[3],
      port: parseInt(splitMatchGroups[4]),
      database: splitMatchGroups[5].replace(/^\/+/, ''),
      ...(splitMatchGroups[6] &&
        splitMatchGroups[6].split('&').reduce<Record<string, string>>((connectionInfo, parameter) => {
          const [key, value] = parameter.split('=');
          connectionInfo[key] = value;
          return connectionInfo;
        }, {})),
    };
  
    return options;
};

const ConnectionOptions = ParseConnectionString();

/*async function CreateBlobFromFile(path: string): Promise<Blob> {
    const file = await fs.readFile(path);
    return new Blob([file]);
}*/

EnsureDatabaseDumpFolder();

const DatabaseDumpJob: CronJob = new CronJob(
    //`*/5 * * * * *`,
    `0 0 */2 * * *`,
    async () => {
        const date: Dayjs = dayjs();
        const fileName = `${date.format("YYYY-MM-DDTHH-mm-ss")}.sql`
        const filePath = `./database_dumps/${fileName}`;
        try {
            await mysqldump({
                connection: {
                    host: ConnectionOptions.host,
                    user: ConnectionOptions.user,
                    password: ConnectionOptions.password || "",
                    database: ConnectionOptions.database
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