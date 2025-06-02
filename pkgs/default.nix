{
  pkgs,
  pyproject-nix ?
    import
      (builtins.fetchGit {
        url = "https://github.com/pyproject-nix/pyproject.nix.git";
      })
      {
        inherit (pkgs) lib;
      },
  uv2nix ?
    import
      (builtins.fetchGit {
        url = "https://github.com/pyproject-nix/uv2nix.git";
      })
      {
        inherit pyproject-nix;
        inherit (pkgs) lib;
      },
  pyproject-build-systems ?
    import
      (builtins.fetchGit {
        url = "https://github.com/pyproject-nix/build-system-pkgs.git";
      })
      {
        inherit pyproject-nix uv2nix;
        inherit (pkgs) lib;
      },
}:
{
  nh = pkgs.callPackage ./nh.nix { };
  rename_music = pkgs.callPackage ./rename_music.nix { };
  byparr = pkgs.callPackage ./byparr.nix {
    inherit pyproject-nix uv2nix pyproject-build-systems;
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
  catpuccin-kde-frappe-red = pkgs.catppuccin-kde.override {
    flavour = [ "frappe" ];
    accents = [ "red" ];
    winDecStyles = [ "classic" ];
  };
  catpuccin-kde-latte-red = pkgs.catppuccin-kde.override {
    flavour = [ "latte" ];
    accents = [ "red" ];
    winDecStyles = [ "classic" ];
  };
  catpuccin-kde-latte-pink = pkgs.catppuccin-kde.override {
    flavour = [ "latte" ];
    accents = [ "pink" ];
    winDecStyles = [ "classic" ];
  };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
