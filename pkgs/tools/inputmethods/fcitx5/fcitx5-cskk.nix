{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  extra-cmake-modules,
  gettext,
  fcitx5,
  fcitx5-qt,
  libcskk,
  qtbase,
  skkDictionaries,
  enableQt ? false,
}:
let
  pname = "fcitx5-cskk";
  version = "1.2.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-rDaFsBXd3he40W27B6641qEfPYBpuw7Rc8JhvsZiPFg=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    gettext
    pkg-config
  ];

  buildInputs =
    [
      fcitx5
      libcskk
    ]
    ++ lib.optionals enableQt [
      fcitx5-qt
      qtbase
    ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT" enableQt)
    (lib.cmakeBool "USE_QT6" (lib.versions.major qtbase.version == "6"))
    "-DSKK_DICT_DEFAULT_PATH=${skkDictionaries.l}/share/skk/SKK-JISYO.L"
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "SKK input method plugin for fcitx5 that uses LibCSKK";
    homepage = "https://github.com/fcitx/fcitx5-cskk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ento ];
    platforms = platforms.linux;
  };
}
