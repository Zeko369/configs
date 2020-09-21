import { promises as fs } from "fs";
import { join, add } from "../util";

const OUT_FILE = join("shell/basic");
const f = ["functions.sh", "ls.sh"];
const base = `export EDITOR=vim\n`;

(async () => {
  const fp = f.map((name) => fs.readFile(join("shell/", name), "utf-8"));
  const files = await Promise.all(fp);

  let out = base + "\n" + files.join("\n");
  out = out.replace(/#!\/bin\/sh/g, "");
  out = out.replace(/\n\n\n/g, "\n");

  await fs.writeFile(OUT_FILE, out);
  await add(OUT_FILE);
})()
  .catch(console.error)
  .finally(() => console.log("Done"));