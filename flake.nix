
{
  description = "Portfolio";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          typescript-language-server
          typescript
          vscode-css-languageserver
          superhtml
          vscode-json-languageserver
          live-server
          fish
        ];

        shellHook = ''
          fishConfig="
            function fish_prompt; set_color green; echo -n \"[portfolio]\"; set_color normal; echo \" :: \"; end;
            echo 'Logs: tail -f .tsc.log | tail -f .server.log'
          "
          ${pkgs.typescript}/bin/tsc -w > .tsc.log 2>&1 &
          if ! pgrep -f "live-server" > /dev/null; then
             echo "Starting live-server..."
             ${pkgs.live-server}/bin/live-server --browser firefox -o index.html > .server.log 2>&1 &
          else
             echo "live-server is already running. Skipping start."
          fi

          trap "kill 0" EXIT
          ${pkgs.fish}/bin/fish -C "$fishConfig"
          exit
        '';
      };
    };
}
