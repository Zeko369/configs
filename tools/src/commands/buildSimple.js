const { promises: fs } = require("fs");
const { join, add } = require("../util");

const OUT_FILE = join("shell/basic");
const f = ["functions.sh", "ls.sh"];
const base = `export EDITOR=vim\n`;

(async () => {
  const files = await Promise.all(
    f.map((name) => fs.readFile(join("shell/", name), "utf-8"))
  );

  let out = base + "\n" + files.join("\n");
  out = out.replace(/#!\/bin\/sh/g, "");
  out = out.replace(/\n\n\n/g, "\n");

  await fs.writeFile(OUT_FILE, out);
  await add(OUT_FILE);
})()
  .catch(console.error)
  .finally(() => console.log("Done"));
