{ lib, fetchPypi, buildPythonPackage, packaging, toml }:

buildPythonPackage rec {
  pname = "sip5";
  version = "5.5.0";

  propagatedBuildInputs = [ packaging toml ];

  src = fetchPypi {
    pname = "sip";
    inherit version;
    sha256 = "1idaivamp1jvbbai9yzv471c62xbqxhaawccvskaizihkd0lq0jx";
  };

  meta = with lib; {
    description = "Creates C++ bindings for Python modules";
    homepage    = "http://www.riverbankcomputing.co.uk/";
    license     = licenses.gpl3Only;
    platforms   = platforms.all;
  };
}
