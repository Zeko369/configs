const path = require("path");
const workingDirPath = path.join("../../reactjs.org/");

const simpleGit = require("simple-git/promise");
const git = simpleGit(workingDirPath).silent();

(async () => {
  try {
    await git.push();
  } catch (err) {
    // console.log(err);
  }
})();
// git
//   .push()
//   .then(out => {
//     console.log(out);
//   })
//   .catch(err => {
//     console.log(err);
//   });
