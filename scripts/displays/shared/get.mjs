import { loadDisplays, MAC_DISPLAY_UUID } from "./load.mjs";

/**
 * @typedef {{name: string, displayUUID: string, macPosition: string}} Config
 *
 * @param {Config[]} configs
 * @returns {Promise<[string[], Config]>}
 */
export const getConfig = async (configs) => {
  const displays = await loadDisplays();
  const config = configs.find((c) => displays.find((d) => d.UUID === c.displayUUID));
  if (!config) {
    console.log("No display found");
    process.exit(1);
  }

  const display = displays.find((d) => d.UUID === config.displayUUID);
  if (!display) {
    throw new Error("Display not found");
  }

  const args = [
    `id:${config.displayUUID} res:${display.resolution} hz:${display.refresh} color_depth:${display.colorDepth} scaling:off origin:(0,0) degree:0`,
    `id:${MAC_DISPLAY_UUID} res:1280x800 hz:60 color_depth:8 scaling:on origin:${config.macPosition} degree:0`,
  ];

  return [args, config];
};
