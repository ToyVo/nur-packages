{
  description = "My personal NUR repository";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = { config, pkgs, lib, self', ... }: {
        packages = {
          nh = pkgs.callPackage ./pkgs/nh.nix { };
          byparr = pkgs.callPackage ./pkgs/byparr.nix {
            inherit (inputs) pyproject-nix uv2nix pyproject-build-systems;
          };
          catppuccin-papirus-folders-frappe-red = pkgs.catppuccin-papirus-folders.override {
            flavor = "frappe";
            accent = "red";
          };
          catppuccin-papirus-folders-latte-red = pkgs.catppuccin-papirus-folders.override {
            flavor = "latte";
            accent = "red";
          };
          catppuccin-papirus-folders-latte-pink = pkgs.catppuccin-papirus-folders.override {
            flavor = "latte";
            accent = "pink";
          };
          catppuccin-kde-frappe-red = pkgs.catppuccin-kde.override {
            flavour = [ "frappe" ];
            accents = [ "red" ];
            winDecStyles = [ "classic" ];
          };
          catppuccin-kde-latte-red = pkgs.catppuccin-kde.override {
            flavour = [ "latte" ];
            accents = [ "red" ];
            winDecStyles = [ "classic" ];
          };
          catppuccin-kde-latte-pink = pkgs.catppuccin-kde.override {
            flavour = [ "latte" ];
            accents = [ "pink" ];
            winDecStyles = [ "classic" ];
          };
        };
        checks = let
          isCacheable =
            p:
            let
              licenseFromMeta = p.meta.license or [ ];
              licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
            in
            !(p.meta.broken or false) && !(p.preferLocalBuild or false) && builtins.all (license: license.free or true) licenseList;
          in lib.mapAttrs' (n: lib.nameValuePair "package-${n}") (lib.filterAttrs (n: v: isCacheable v) self'.packages);
        formatter = pkgs.nixfmt-rfc-style;
      };
    };
}
