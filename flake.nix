{
  description = "OpenRiichi: An open source riichi mahjong client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      open-richii-drv = pkgs.stdenv.mkDerivation {
        name = "OpenRiichi";
        src = ./.;
        nativeBuildInputs = with pkgs; [
          vala
          meson
          cmake
          pkg-config
          glib
          libgee
          gtk3
          glew
          SDL2_image
          SDL2_mixer
          ninja
        ];
        buildPhase = ''
          mkdir -p $out
          meson setup build $src -Dbuildtype=release --prefix=$out
          ninja -C build
        '';
        installPhase = ''
          ninja -C build install
          mkdir -p $out/bin
          mv build/OpenRiichi $out/bin
        '';
      };
    in
    {
      packages.${system} = rec {
        OpenRiichi = open-richii-drv;
        default = OpenRiichi;
      };

      apps.${system} = rec {
        OpenRiichi = {
          type = "app";
          program = "${self.packages.${system}.OpenRiichi}/bin/OpenRiichi";
        };
        default = OpenRiichi;
      };
    };
}
