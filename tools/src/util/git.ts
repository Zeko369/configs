import { command } from "./command";

export const add = async (file: string) => {
  return command(`git add ${file}`);
};
