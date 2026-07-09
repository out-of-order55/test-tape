{
  description = "Chipyard SoC generator development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        riscvPkgs = pkgs.pkgsCross.riscv64-embedded;
        riscvCc = riscvPkgs.stdenv.cc;
        spike = pkgs.spike;
        circt = pkgs.circt;
        libglossSrc = pkgs.fetchFromGitHub {
          owner = "ucb-bar";
          repo = "libgloss-htif";
          rev = "39234a16247ab1fa234821b251f1f1870c3de343";
          hash = "sha256-FXuN1xK5133QqoHI4EG7mvhk7K8J6//ar7Y1+IUPER0=";
        };

        rawRiscvUnknownElfTools = pkgs.runCommand "chipyard-raw-riscv64-unknown-elf-tools" { } ''
          mkdir -p $out/bin

          for tool in \
            addr2line ar as c++ c++filt cpp elfedit g++ gcc gcc-ar gcc-nm gcc-ranlib gcov \
            gcov-dump gcov-tool gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip
          do
            if command -v ${riscvCc}/bin/riscv64-none-elf-$tool >/dev/null 2>&1; then
              ln -s ${riscvCc}/bin/riscv64-none-elf-$tool $out/bin/riscv64-unknown-elf-$tool
            fi
          done

          ln -s ${spike}/bin/elf2hex $out/bin/elf2hex
          ln -s ${spike}/bin/spike $out/bin/spike
          ln -s ${spike}/bin/spike-dasm $out/bin/spike-dasm
          ln -s ${circt}/bin/firtool $out/bin/firtool
        '';

        libglossHtif = pkgs.stdenv.mkDerivation {
          pname = "chipyard-libgloss-htif";
          version = "local";
          src = libglossSrc;

          nativeBuildInputs = [
            pkgs.autoconf
            pkgs.automake
            pkgs.gnumake
            riscvCc
            rawRiscvUnknownElfTools
          ];

          configurePhase = ''
            runHook preConfigure
            mkdir build
            cd build
            ../configure \
              --prefix=$out/riscv64-unknown-elf \
              --libdir=$out/riscv64-unknown-elf/lib \
              --host=riscv64-unknown-elf \
              CC=riscv64-unknown-elf-gcc \
              AR=riscv64-unknown-elf-ar \
              SIZE=riscv64-unknown-elf-size
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            make
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/riscv64-unknown-elf/lib
            install -m 0644 libgloss_htif.a $out/riscv64-unknown-elf/lib/
            install -m 0644 ../util/htif.ld $out/riscv64-unknown-elf/lib/
            install -m 0644 ../util/htif.specs $out/riscv64-unknown-elf/lib/
            install -m 0644 ../util/htif_nano.specs $out/riscv64-unknown-elf/lib/
            install -m 0644 ../util/htif_wrap.specs $out/riscv64-unknown-elf/lib/
            install -m 0644 ../util/htif_argv.specs $out/riscv64-unknown-elf/lib/
            runHook postInstall
          '';
        };

        riscvUnknownElfTools = pkgs.runCommand "chipyard-riscv64-unknown-elf-tools" { } ''
          mkdir -p $out/bin
          libdir=${libglossHtif}/riscv64-unknown-elf/lib

          make_cc_wrapper() {
            local tool=$1
            local real_tool=${riscvCc}/bin/riscv64-none-elf-$tool
            local wrapper=$out/bin/riscv64-unknown-elf-$tool
            cat > $wrapper <<EOF
#!${pkgs.runtimeShell}
set -e
args=()
for arg in "\$@"; do
  case "\$arg" in
    -specs=htif.specs) args+=("-specs=$libdir/htif.specs") ;;
    -specs=htif_nano.specs) args+=("-specs=$libdir/htif_nano.specs") ;;
    -specs=htif_wrap.specs) args+=("-specs=$libdir/htif_wrap.specs") ;;
    -specs=htif_argv.specs) args+=("-specs=$libdir/htif_argv.specs") ;;
    *) args+=("\$arg") ;;
  esac
done
exec $real_tool -B$libdir/ -L$libdir "\''${args[@]}"
EOF
            chmod +x $wrapper
          }

          make_cc_wrapper gcc
          make_cc_wrapper g++
          make_cc_wrapper c++

          for tool in \
            addr2line ar as c++filt cpp elfedit gcc-ar gcc-nm gcc-ranlib gcov \
            gcov-dump gcov-tool gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip
          do
            if command -v ${riscvCc}/bin/riscv64-none-elf-$tool >/dev/null 2>&1; then
              ln -s ${riscvCc}/bin/riscv64-none-elf-$tool $out/bin/riscv64-unknown-elf-$tool
            fi
          done

          ln -s ${spike}/bin/elf2hex $out/bin/elf2hex
          ln -s ${spike}/bin/spike $out/bin/spike
          ln -s ${spike}/bin/spike-dasm $out/bin/spike-dasm
          ln -s ${circt}/bin/firtool $out/bin/firtool
        '';

        chipyardRiscvTools = pkgs.runCommand "chipyard-riscv-tools" { } ''
          mkdir -p $out/bin $out/include $out/lib $out/riscv64-unknown-elf

          ln -s ${riscvUnknownElfTools}/bin/* $out/bin/
          ln -s ${spike}/include/* $out/include/
          ln -s ${spike}/lib/* $out/lib/

          ln -s ${libglossHtif}/riscv64-unknown-elf/lib $out/riscv64-unknown-elf/lib
        '';

      in {
        packages = {
          inherit chipyardRiscvTools libglossHtif rawRiscvUnknownElfTools riscvUnknownElfTools;
        };

        devShells.default = pkgs.mkShellNoCC {
          RISCV = "${chipyardRiscvTools}";
          FIRTOOL_BIN = "${circt}/bin/firtool";
          JAVA_HOME = "${pkgs.jdk17_headless}";

          shellHook = ''
            export CY_DIR="$PWD"
            export RISCV="${chipyardRiscvTools}"
            export FIRTOOL_BIN="${circt}/bin/firtool"
            export JAVA_HOME="${pkgs.jdk17_headless}"
            export PATH="$RISCV/bin:${pkgs.bash}/bin:${pkgs.bison}/bin:${pkgs.dtc}/bin:${pkgs.flex}/bin:${pkgs.gcc}/bin:${pkgs.git}/bin:${pkgs.gnumake}/bin:${pkgs.jdk17_headless}/bin:${pkgs.numactl}/bin:${pkgs.perl}/bin:${pkgs.python3}/bin:${pkgs.sbt}/bin:${pkgs.verilator}/bin:${pkgs.which}/bin:${circt}/bin:${spike}/bin:${riscvCc}/bin:$PATH"
            export COURSIER_CACHE="$PWD/.coursier-cache"
            export SBT_OPTS="-Dsbt.global.base=$PWD/.sbt -Dsbt.boot.directory=$PWD/.sbt/boot -Dsbt.ivy.home=$PWD/.ivy2 $SBT_OPTS"
            unset NIX_LDFLAGS
            export EXTRA_SIM_CXXFLAGS="-O1 ''${EXTRA_SIM_CXXFLAGS:-}"
            export EXTRA_SIM_LDFLAGS="-no-pie ''${EXTRA_SIM_LDFLAGS:-}"

            echo "Chipyard Nix environment"
            echo "  RISCV=$RISCV"
            echo "  firtool=$FIRTOOL_BIN"
            echo "  verilator=$(command -v verilator)"
            echo "  java=$JAVA_HOME"
          '';
        };
      });
}
