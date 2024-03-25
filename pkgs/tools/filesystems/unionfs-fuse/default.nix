{ lib, stdenv, fetchFromGitHub, cmake, fuse3, macfuse-stubs, pkg-config }:
let
  fuse = if stdenv.isDarwin then macfuse-stubs else fuse3;
in stdenv.mkDerivation rec {
  pname = "unionfs-fuse";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "rpodgorny";
    repo = "unionfs-fuse";
    rev = "v${version}";
    sha256 = "sha256-zTHJURpv56qY8FzS8DLnaH3HmKC5RzV9OEr7piTLDRg=";
  };

  patches = [
    # Prevent the unionfs daemon from being killed during
    # shutdown. See
    # https://www.freedesktop.org/wiki/Software/systemd/RootStorageDaemons/
    # for details.
    ./prevent-kill-on-shutdown.patch
  ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/local/include/osxfuse/fuse' '${fuse}/include/fuse'
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ fuse ];

  # Put the unionfs mount helper in place as mount.unionfs-fuse. This makes it
  # possible to do:
  #   mount -t unionfs-fuse none /dest -o dirs=/source1=RW,/source2=RO
  #
  # This must be done in preConfigure because the build process removes
  # helper from the source directory during the build.
  preConfigure = lib.optionalString (!stdenv.isDarwin) ''
    mkdir -p $out/sbin
    cp -a mount.unionfs $out/sbin/mount.unionfs-fuse
    substituteInPlace $out/sbin/mount.unionfs-fuse --replace mount.fuse ${fuse}/sbin/mount.fuse
    substituteInPlace $out/sbin/mount.unionfs-fuse --replace unionfs $out/bin/unionfs
  '';

  meta = with lib; {
    description = "FUSE UnionFS implementation";
    homepage = "https://github.com/rpodgorny/unionfs-fuse";
    license = licenses.bsd3;
    platforms = platforms.unix;
    mainProgram = "unionfs";
    maintainers = with maintainers; [ orivej ];
  };
}
