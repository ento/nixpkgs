{ lib
, fetchFromGitHub
, libxkbcommon
, cargo-c
, rust
, rust-cbindgen
, rustPlatform
}:
let
  pname = "libcskk";
  version = "3.1.4";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "naokiri";
    repo = "cskk";
    tag = "v${version}";
    hash = "sha256-EsMxEbDDYkJmwP2FsSUBVm7VdRe2efV+iKKx5ycqxeI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-oHHhAvcHYNV7qRE26VKS2wDQiLvfqM5F8ZiHO+n93cw=";

  buildInputs = [ libxkbcommon ];
  nativeBuildInputs = [ cargo-c ];

  patches = [
    ./xdg-data-dirs.patch
  ];

  postPatch = ''
    substituteAllInPlace src/env.rs
  '';

  postInstall = ''
    ${rust.envVars.setEnv} cargo cinstall --release --prefix=${placeholder "out"}
  '';

  meta = {
    description = "Japanese SKK input method library in Rust";
    longDescription = ''
      Cobalt SKK is a library that provides basic features of SKK,
      an input method for the Japanese language, including those
      found in ddskk and libskk.
    '';
    homepage = "https://github.com/naokiri/cskk";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ento ];
    platforms = lib.platforms.linux;
  };
}
