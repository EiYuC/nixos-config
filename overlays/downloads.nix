final: prev:
let
  claudeVersion = prev.claude-code.version;
  claudeNpmPlatform = "linux-x64";

  claudeCode =
    if prev.stdenv.hostPlatform.system != "x86_64-linux" then
      prev.claude-code
    else
      assert prev.lib.assertMsg (claudeVersion == "2.1.296")
        "Update the claude-code NPM source hash in overlays/downloads.nix";
      prev.claude-code.overrideAttrs {
        src = prev.fetchurl {
          url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${claudeNpmPlatform}/-/claude-code-${claudeNpmPlatform}-${claudeVersion}.tgz";
          hash = "sha512-+m01urgelnI+VJxPaKPEK0wixgq42uZ8PeCaUk5tX/8YoDBvSmC/REVQG2jQfJAr8dxunpjJ600FvLrcj1WWTw==";
        };

        dontUnpack = false;
        sourceRoot = ".";
        installPhase = builtins.replaceStrings
          [ "unzstd -q $src -o $out/bin/claude" ]
          [ "install -m755 package/claude $out/bin/claude" ]
          prev.claude-code.installPhase;
      };
in
{
  claude-code = claudeCode;

  typora = prev.typora.overrideAttrs {
    src = prev.fetchurl {
      urls = [
        "https://downloads.typoraio.cn/linux/typora_${prev.typora.version}_amd64.deb"
        "https://download.typora.io/linux/typora_${prev.typora.version}_amd64.deb"
      ];
      hash = prev.typora.src.outputHash;
    };
  };
}
