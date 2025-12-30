{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    typescript-language-server
    typescript
    vscode-css-languageserver
    superhtml
    vscode-json-languageserver
    live-server
    lsof
  ];

  shellHook = ''
    mkdir -p .logs
    echo "Logs available at: tail -f .logs/tsc.log -f .logs/server.log"

    tsc -w > .logs/tsc.log 2>&1 &
    if ! lsof -i :43004 > /dev/null; then
       echo "Starting live-server on http://127.0.0.1:43004..."
       ${pkgs.live-server}/bin/live-server --browser firefox -o index.html -H 127.0.0.1 -p 43004 > .server.log 2>&1 &
    else
       echo "Port 43004 is already in use. live-server may be running elsewhere."
    fi

    # Clean up background processes on exit
    trap "kill 0" EXIT
  '';
}
