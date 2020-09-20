import { join as baseJoin } from "path";

export const join = (...props: string[]) => {
  return baseJoin(...[__dirname, "../../../", ...props]);
};
