{ stdenv }:

stdenv.mkDerivation rec {
  name = "oracle-cloud-agent-${version}";
  version = "1.0";
  src = ./.;
  buildPhase = "echo echo Hello World > example";
  installPhase = "install -Dm755 example $out";
}
