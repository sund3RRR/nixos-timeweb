{ stdenv, lib, makeWrapper, qemu_full, shadow }:

stdenv.mkDerivation rec {
  name = "qemu-ga-wrapped";
  version = "suka";

  src = qemu_full.ga;

  unpackPhase = ''
    cp -r $src/* .
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/qemu-ga $out/bin/
  '';

  postFixup = ''
    wrapProgram $out/bin/qemu-ga \
      --prefix PATH : "${lib.makeBinPath [ shadow ]}"
  '';
}