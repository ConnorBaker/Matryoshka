{
  fetchPnpmDeps,
  lib,
  makeWrapper,
  nodejs_26,
  pnpm_10,
  pnpmBuildHook,
  pnpmConfigHook,
  python3,
  stdenv,
}:
let
  nodejs = nodejs_26;
  pnpm = pnpm_10.override { nodejs-slim = nodejs; };
in
stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "matryoshka-rlm";
  version = "0.2.39";
  src = ./.;

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    pnpmBuildHook
    python3 # for node-gyp (better-sqlite3 native build)
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-WnHGAivvn8baRW8U83Tz3MLsW606+3neYTyhxT5eVOU=";
  };

  # Wrap the CLIs we actually use; lattice-mcp is the MCP server.
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/matryoshka"
    cp -r dist node_modules package.json "$out/lib/matryoshka"/
    for binpair in \
      "lattice-mcp:dist/lattice-mcp-server.js" \
      "rlm-mcp:dist/mcp-server.js" \
      "lattice-repl:dist/repl/lattice-repl.js" \
      "rlm:dist/index.js"; do
      name="''${binpair%%:*}"
      entry="''${binpair##*:}"
      makeWrapper "${lib.getExe' nodejs "node"}" "$out/bin/$name" \
        --add-flags "$out/lib/matryoshka/$entry"
    done
    runHook postInstall
  '';

  meta = {
    description = "MCP server for token-efficient large document analysis via the use of REPL state";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    mainProgram = "lattice-mcp";
  };
})
