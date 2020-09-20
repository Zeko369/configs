const { exec } = require("child_process");

module.exports = {
  command: async (command) => {
    return new Promise((resolve, reject) => {
      exec(command, (err, stdout, stderr) => {
        if (err) {
          return reject(stderr);
        }

        resolve(stdout);
      });
    });
  },
};
