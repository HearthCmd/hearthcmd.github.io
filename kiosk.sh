#!/usr/bin/env bash
# Hearth display kiosk setup: turns this computer (a Raspberry Pi, or any
# Debian-family Linux box with a desktop) into a wall screen for a Hearth display.
#
#   curl -fsSL https://hearthcmd.com/kiosk.sh | bash -s -- http://<display-address>:8090
#
# The display address is shown in the Hearth app (Hosts → the computer running
# the display). This wrapper fetches the kiosk installer from the latest Hearth
# CLI release on GitHub (scripts/kiosk-install.sh in HearthCmd/hearth-cmd-cli, at
# that release's tag) and runs it with your arguments. Run it with --help for the
# installer's options, --uninstall to undo.
#
# Everything runs from main() on the last line, so a download cut short can't run
# half a script.

set -euo pipefail

REPO="HearthCmd/hearth-cmd-cli"

main() {
  command -v curl >/dev/null 2>&1 || { echo "error: curl is needed" >&2; exit 1; }

  local tag
  tag="$(curl -fsSI "https://github.com/${REPO}/releases/latest" |
    grep -i '^location:' | sed 's#.*/tag/##' | tr -d '\r\n')" || true
  # The tag goes into a URL: accept only a release-shaped one.
  [[ "$tag" =~ ^v[0-9]+(\.[0-9]+)*$ ]] || { echo "error: couldn't find the latest Hearth release on GitHub" >&2; exit 1; }

  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  curl -fsSL "https://raw.githubusercontent.com/${REPO}/${tag}/scripts/kiosk-install.sh" -o "$tmp" ||
    { echo "error: Hearth ${tag} doesn't include the kiosk installer" >&2; exit 1; }

  echo "Hearth kiosk installer (${tag})"
  bash "$tmp" "$@"
}

main "$@"
