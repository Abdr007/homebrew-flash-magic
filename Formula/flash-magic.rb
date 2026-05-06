# Homebrew formula for flash-magic-terminal.
#
# Installs the CLI from the canonical npm tarball into a private libexec
# tree and symlinks both binaries (magic + flash-magic) into Cellar/bin so
# they land on PATH like any other brew-installed tool.
#
# Pinned to a specific tarball + sha256 so brew installs are deterministic
# and the user gets exactly what was audited at release time, not whatever
# floats in npm's `latest` tag.
class FlashMagic < Formula
  desc "Sub-second perpetuals trading on Solana via MagicBlock ER"
  homepage "https://github.com/Abdr007/flash-magic-terminal"
  url "https://registry.npmjs.org/flash-magic-terminal/-/flash-magic-terminal-0.2.0.tgz"
  sha256 "5432c4105538d73d0ea7bfd27aa2c1b553672ecb06a8e5d00cda0db81081fe81"
  license "MIT"

  # Match the package's engines.node — anything older fails at import time
  # because of the 22-only ESM flags + native fetch usage.
  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  # Smoke test — `--version` is the only command that runs without
  # touching any chain / RPC / wallet, so it's the right thing to exercise
  # in `brew test`. Anything heavier would make brew test flaky on
  # offline / sandboxed builders.
  test do
    assert_match version.to_s, shell_output("#{bin}/magic --version")
  end
end
