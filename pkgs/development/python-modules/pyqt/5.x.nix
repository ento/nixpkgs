{ lib, pythonPackages, pkgconfig
, dbus
, qmake, lndir
, qtbase
, qtsvg
, qtdeclarative
, qtwebchannel
, withConnectivity ? false, qtconnectivity
, withMultimedia ? false, qtmultimedia
, withWebKit ? false, qtwebkit
, withWebSockets ? false, qtwebsockets
}:

let

  inherit (pythonPackages) buildPythonPackage python isPy3k dbus-python enum34;

  sip = pythonPackages.sip5;

  pyqt5_sip = buildPythonPackage rec {
    pname = "PyQt5_sip";
    version = "12.8.1";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "30e944db9abee9cc757aea16906d4198129558533eb7fadbe48c5da2bd18e0bd";
    };

    # There is no test code and the check phase fails with:
    # > error: could not create 'PyQt5/sip.cpython-38-x86_64-linux-gnu.so': No such file or directory
    doCheck = false;
  };

in buildPythonPackage rec {
  pname = "PyQt5";
  version = "5.15.1";
  format = "other";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "18grs2p698ihjgi8agksv6sajakciywyr29ihslqvl260a2np9yr";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    pkgconfig
    qmake
    lndir
    sip
    qtbase
    qtsvg
    qtdeclarative
    qtwebchannel
  ]
    ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withMultimedia qtmultimedia
    ++ lib.optional withWebKit qtwebkit
    ++ lib.optional withWebSockets qtwebsockets
  ;

  buildInputs = [
    dbus
    qtbase
    qtsvg
    qtdeclarative
  ]
    ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withWebKit qtwebkit
    ++ lib.optional withWebSockets qtwebsockets
  ;

  propagatedBuildInputs = [
    dbus-python
    pyqt5_sip
  ] ++ lib.optional (!isPy3k) enum34;

  patches = [
    # Fix some wrong assumptions by ./configure.py
    # TODO: figure out how to send this upstream
    ./pyqt5-fix-dbus-mainloop-support.patch
  ];

  passthru = {
    inherit sip;
    multimediaEnabled = withMultimedia;
    webKitEnabled = withWebKit;
    WebSocketsEnabled = withWebSockets;
  };

  configurePhase = ''
    runHook preConfigure

    export PYTHONPATH=$PYTHONPATH:$out/${python.sitePackages}

    ${python.executable} configure.py  -w \
      --confirm-license \
      --dbus-moduledir=$out/${python.sitePackages}/dbus/mainloop \
      --no-qml-plugin \
      --bindir=$out/bin \
      --destdir=$out/${python.sitePackages} \
      --stubsdir=$out/${python.sitePackages}/PyQt5 \
      --sipdir=$out/share/sip/PyQt5 \
      --designer-plugindir=$out/plugins/designer

    runHook postConfigure
  '';

  pythonImportsCheck = [
    "PyQt5"
    "PyQt5.QtCore"
    "PyQt5.QtQml"
    "PyQt5.QtWidgets"
    "PyQt5.QtGui"
  ]
  ++ lib.optional withWebSockets "PyQt5.QtWebSockets"
  ++ lib.optional withWebKit "PyQt5.QtWebKit"
  ++ lib.optional withMultimedia "PyQt5.QtMultimedia"
  ++ lib.optional withConnectivity "PyQt5.QtConnectivity"
  ;

  doCheck = false;

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Python bindings for Qt5";
    homepage    = "http://www.riverbankcomputing.co.uk";
    license     = licenses.gpl3;
    platforms   = platforms.mesaPlatforms;
    maintainers = with maintainers; [ sander ];
  };
}
