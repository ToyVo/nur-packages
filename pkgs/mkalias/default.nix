{
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  sha256 ? "sha256-tL3C/b2BPOGQpV287wECDCDWmKwwPvezAAN3qz7N07M=",
  cargoHash ? "sha256-RfKVmiFfFzIp//fbIcFce4T1cQPIFuEAw7Zmnl1Ic84=",
  version ? "0.3.2",
}:
let
  pname = "mkalias";
  src = fetchFromGitHub {
    owner = "reckenrode";
    repo = pname;
    rev = "v${version}";
    inherit sha256;
  };
  info = lib.importTOML "${src}/Cargo.toml";
in
rustPlatform.buildRustPackage {
  inherit pname src version cargoHash;
  buildInputs = [ darwin.apple_sdk.frameworks.CoreFoundation];
  meta = with lib; {
    description = info.package.description;
    homepage = info.package.repository;
    license = licenses.gpl3Only;
    platforms = platforms.darwin;
  };
}
