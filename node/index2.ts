import { execGitCmd } from "run-git-command";

const execOptions = {
  execOptions: {}, // Options passed to the child_process spawn executor
  logProcess: false, // By default a console log is being printed
  customMsg: `run-git-command` // A custom msg to be printed to the console
};

/** Simple usage **/
execGitCmd(["pull"], execOptions)
  .then(result => "Command ran successfully")
  .catch(error => "Command execution failed");

/** Since the executor returns a promise they can be chained **/
execGitCmd(["pull"], execOptions)
  .then(() => execGitCmd(["push"]))
  .then(result => "Both commands ran successfully")
  .catch(error => "Command execution failed");
