import "zx/globals";

export const MAC_DISPLAY_UUID = "37D8832A-2D66-02CA-B9F7-8F30A301B230";

const keyMap = {
  "Persistent screen id": "UUID",
  "Contextual screen id": "contextId",
  Type: "type",
  Resolution: "resolution",
  Hertz: "refresh",
  "Color Depth": "colorDepth",
  Scaling: "scaling",
  Origin: "origin",
  Rotation: "rotation",
  "Resolutions for rotation 0": "resForRotation0",
};

export class Display {
  UUID = "";
  refresh = 60;
  resolution = "";
  colorDepth = 0;

  constructor(data) {
    for (const key in data) {
      this[key] = this._tryParseInt(data[key]);
    }
  }

  _tryParseInt(val) {
    if (/^\d+$/.test(val)) {
      return new Number(val);
    }
    return val;
  }
}

/** @param {string} str */
const parseDisplay = (str) => {
  return new Display(
    Object.fromEntries(
      str
        .split("\n")
        .filter((line) => !line.startsWith(" "))
        .map((line) =>
          // @ts-expect-error
          line.split(":").reduce((acc, val) => {
            switch (acc.length) {
              case 0:
                return [val];
              case 1:
                return [acc[0], val];
              default:
                return [acc[0], `${acc[1]}:${val}`];
            }
          }, [])
        )
        // @ts-expect-error
        .map(([key, value]) => [keyMap[key] || key, value.trim()])
    )
  );
};

export const loadDisplays = async () => {
  const out = await $`displayplacer list`;
  if (out.exitCode !== 0) {
    throw new Error(`Failed to load displays: ${out.stderr}`);
  }

  return out.stdout.split("\n\n").slice(0, -2).map(parseDisplay);
};
