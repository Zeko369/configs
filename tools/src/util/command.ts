import { exec } from "child_process";

export const command = async (command: string) => {
  return new Promise((resolve, reject) => {
    exec(command, (err, stdout, stderr) => {
      if (err) {
        return reject(stderr);
      }

      resolve(stdout);
    });
  });
};
