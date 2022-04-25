#!/usr/bin/env zx

import "zx/globals";

$.verbose = false;
import { getConfig } from "./shared/get.mjs";

const configs = [
  {
    name: "Work",
    displayUUID: "58A2CDA4-CD64-CCFA-0857-D6964E3302DB",
    macPosition: "(1055,1440)",
  },
  {
    name: "Home",
    displayUUID: "2A9F7159-CE93-954E-0857-D6964E3302DB",
    macPosition: "(1236,1600)",
  },
];

const [args, config] = await getConfig(configs);

console.log(`Setting Laptop: ${config.name}`);
await $`displayplacer ${args}`;