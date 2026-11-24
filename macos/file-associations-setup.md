# One-time macOS file association setup

On a new Mac, after installing the apps with the [Brewfile](../Brewfile), open
this repo in Codex while logged in to the Mac desktop. Give Codex this request.

> Run the one-time macOS file association setup in
> `macos/file-associations-setup.md`. Use computer control to click the macOS
> “Use Zed”, “Use IINA”, and “Use Keka” confirmations, then verify the defaults.

The full setup uses the [baseline Zed defaults](file-associations.json) and the
[additional defaults for Zed, IINA, and Keka](file-associations-setup.json).
It includes JSON, JavaScript, SVG, and TypeScript for Zed, MKV, MP4, and FLAC
for IINA, and `.rar` archives for Keka. Run it before `macos-defaults.sh` on
a new Mac so the baseline associations are already set when that script runs.

## Run with Codex

1. From the repo root, run `./bin/macos-file-associations --check --setup`.
   This requires Xcode Command Line Tools, Zed, IINA, and Keka. An exit with
   `MISMATCH` lines means there are defaults to update. Resolve missing apps or
   configuration errors before applying.
2. Start `./bin/macos-file-associations --apply --setup` in a live shell
   session that yields control while the command runs. Watch for the
   `Updating .… → Zed.app`, `IINA.app`, or `Keka.app` output. macOS can pause
   the command for an app-change dialog.
3. Use native computer control to inspect **CoreServicesUIAgent**
   (`com.apple.coreservices.uiagent`). Read the current dialog and click the
   **Use “Zed”**, **Use “IINA”**, or **Use “Keka”** button that matches the
   update in progress.
   Find the button by its label in the current accessibility tree. Read the
   dialog again before each click because macOS can move the buttons between
   dialogs. macOS may name several extensions when they share a content type.
   For example, the TypeScript dialog can name both `.ts` and `.tsx`.
   If the dialog names an unrelated type or a different destination app,
   inspect the current command before clicking anything. If a click times out,
   check the command output before retrying the click.
4. Wait for the command to finish and read the result. If a confirmation
   timed out or the old app was kept, rerun `--apply --setup`. Completed
   associations are skipped. Run `--check --setup` to confirm the final
   defaults and report any mismatches. If computer control cannot reach the
   confirmation, report the affected extension and the exact blocker.

## Shared extensions

- `.ts` defaults to Zed for TypeScript. For MPEG transport video with the same
  suffix, use Finder’s “Open With” menu and choose IINA.
- macOS currently groups `.svgz` with `.svg` and `.patch` with `.diff`.
  The default applies to both extensions in each pair.
