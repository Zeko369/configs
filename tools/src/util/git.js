const { command } = require("./command");

module.exports = {
  add: async (file) => {
    return command(`git add ${file}`);
  },
};
