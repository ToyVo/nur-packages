{
  callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenv,
  python3,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
  version ? "1.2.0",
  hash ? "sha256-tn3aynOEd8DD0ymidMMfMSflpJL6mvJxp+2TPr2IVcw=",
  venvIgnoreCollisions ? [
    "lib/python${python3.pythonVersion}/site-packages/Xlib/*"
    "bin/fastapi"
  ],
  dependenciesToAddSetuptoolsTo ? [
    "mouseinfo"
    "pyautogui"
    "pygetwindow"
    "pygments"
    "pymsgbox"
    "pyperclip"
    "pyrect"
    "pyscreeze"
    "python3-xlib"
    "pytweening"
  ],
}:
let
  src = fetchFromGitHub {
    owner = "ThePhaseless";
    repo = "Byparr";
    rev = "refs/tags/v${version}";
    inherit hash;
  };

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };

  pyprojectOverrides =
    _final: prev:
    builtins.listToAttrs (
      builtins.map (pkg: {
        name = pkg;
        value = prev.${pkg}.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ prev.setuptools ];
        });
      }) dependenciesToAddSetuptoolsTo
    );

  # Construct package set
  pythonSet =
    # Use base package set from pyproject.nix builders
    (callPackage pyproject-nix.build.packages {
      python = python3;
    }).overrideScope
      (
        lib.composeManyExtensions [
          (pyproject-build-systems.overlays.default or pyproject-build-systems.default)
          (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
          pyprojectOverrides
        ]
      );

  thisProjectAsNixPkg = pythonSet.byparr;

  pythonEnv =
    (pythonSet.mkVirtualEnv "${thisProjectAsNixPkg.pname}-env" workspace.deps.default).overrideAttrs
      (old: {
        inherit venvIgnoreCollisions;
      });
in
stdenv.mkDerivation {
  inherit (thisProjectAsNixPkg) pname version;
  inherit src;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${thisProjectAsNixPkg.pname} \
      --add-flags ${src}/main.py
  '';
}
