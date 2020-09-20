const { join: baseJoin } = require("path");

module.exports = {
  join: (...props) => {
    return baseJoin(...[__dirname, "../../../", ...props]);
  },
};
