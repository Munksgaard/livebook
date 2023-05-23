with import <nixpkgs> { };

let
  # beam.interpreters.erlang_23 is available if you need a particular version
  packages = beam.packagesWith beam.interpreters.erlang;

  pname = "livebook";
  version = "0.9.2";

  src = ./.;

  # if using mix2nix you can use the mixNixDeps attribute
  mixFodDeps = packages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    # nix will complain and tell you the right value to replace this with
    sha256 = "FNxE2joI+eHKe6k3eTlyCIdm9Eg4aqBi0uRiJNHZVwk=";
    # mixEnv = ""; # default is "prod", when empty includes all dependencies, such as "dev", "test".
    # if you have build time environment variables add them here
  };

  nodeDependencies = (pkgs.callPackage ./assets/default.nix { }).shell.nodeDependencies;

in packages.mixRelease {
  inherit src pname version mixFodDeps;

  patches = [ ./fix_package_json.patch ./fix_cookies.patch ];

  nativeBuildInputs = [ nodejs ];

  postBuild = ''
    ln -sf ${nodeDependencies}/lib/node_modules assets/node_modules
    npm run deploy --prefix ./assets

    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, phx.digest
    mix phx.digest --no-deps-check
  '';
}
