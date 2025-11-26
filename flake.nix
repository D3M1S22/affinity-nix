{
  description = "Affinity (macOS) packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "aarch64-darwin" "x86_64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        affinity = pkgs.stdenvNoCC.mkDerivation rec {
          pname   = "affinity";
          version = "3.0.1";  # or whatever version they show

          src = {
            x86_64-darwin = fetchurl {
              url  = "https://downloads.affinity.studio/Affinity.dmg";
              hash = "sha256-Ew3fukQWwKOrl/l7dPy6ZWj9sN592V1l+qep0zvQRIk=";
            };
            aarch64-darwin = fetchurl {
              url = "https://downloads.affinity.studio/Affinity.dmg";
              hash = "sha256-Ew3fukQWwKOrl/l7dPy6ZWj9sN592V1l+qep0zvQRIk=";
            };
          };

          nativeBuildInputs = [ pkgs.undmg ];

          # Extract the DMG
          unpackPhase = ''
            undmg "$src"
            # after this, there will be a mounted-like folder with the .app in it
            # nix build logs will show what it's called; adjust installPhase accordingly
          '';

          installPhase = ''
            mkdir -p "$out/Applications"
            # you might need to tweak this name depending on what's inside the DMG:
            # e.g. "Affinity.app" or "Affinity by Canva.app"
            cp -R "Affinity.app" "$out/Applications/Affinity.app"
          '';

          meta = with pkgs.lib; {
            description = "Affinity all-in-one creative app (macOS)";
            homepage    = "https://www.affinity.studio";
            license     = licenses.unfree;
            platforms   = [ "aarch64-darwin" "x86_64-darwin" ];
          };
        };
      }
    );
  };
}
