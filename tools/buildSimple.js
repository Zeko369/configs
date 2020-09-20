const { promises: fs } = require("fs");
const { join } = require("path");

const filesInSimple = ["functions.sh", "ls.sh"];

const base = `export EDITOR=vim`;

(async () => {
  const files = await Promise.all(
    filesInSimple.map((name) =>
      fs.readFile(join(__dirname, "../shell/", name), "utf-8")
    )
  );

  let out = base + "\n" + files.join("\n");
  out = out.replace(/#!\/bin\/sh/g, "");
  out = out.replace(/\n\n\n/g, "\n");

  console.log(out);
})()
  .catch(console.error)
  .finally(() => console.log("Done"));
