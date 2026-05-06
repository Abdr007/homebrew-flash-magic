# Homebrew formula for flash-magic-terminal.
#
# Installs the canonical npm tarball into a private libexec tree and
# wraps the `magic` + `flash-magic` binaries with shell shims that
# invoke them via the brew-managed `node` interpreter. Pinned to a
# specific tarball + sha256 so brew installs are deterministic.
#
# Notes on the install method:
# - `Language::Node.std_npm_install_args` was removed in newer Homebrew
#   versions; we install dependencies manually inside libexec and write
#   the bin shims by hand. This keeps the formula working across Homebrew
#   3.x, 4.x, and 5.x.
# - The package's `bin` field declares `magic` and `flash-magic`, both
#   pointing at `dist/index.js`. We mirror that here.
class FlashMagic < Formula
  desc "Sub-second perpetuals trading on Solana via MagicBlock ER"
  homepage "https://github.com/Abdr007/flash-magic-terminal"
  url "https://registry.npmjs.org/flash-magic-terminal/-/flash-magic-terminal-0.3.2.tgz"
  sha256 "e2038ccc06a0137854b4bcdaff7eb89364b55d7499745b5609c8c9d88fba2eaa"
  license "MIT"

  # Match the package's engines.node — anything older fails at import
  # because of the 22-only ESM flags + native fetch usage.
  depends_on "node"

  def install
    # 1. Move the extracted tarball contents into libexec so the
    #    package + its node_modules end up sandboxed under the
    #    flash-magic Cellar.
    libexec.install Dir["*"], Dir[".[!.]*"]

    # 2. Install runtime dependencies inside libexec. `--production`
    #    skips devDeps. We DO let dep postinstalls run — without them,
    #    native bindings (e.g. bigint) fall back to pure JS and surface
    #    a noisy warning on every CLI launch. Our own package has no
    #    install hooks, only `prepublishOnly`, which `npm install` never
    #    triggers — so this is safe.
    cd libexec do
      system "npm", "install", "--production", "--no-audit", "--no-fund",
                    "--no-package-lock"
    end

    # 3. Hand-rolled bin shims — point both binary names at dist/index.js
    #    via the brew-managed node. Hard-coding `Formula["node"].opt_bin`
    #    means the shim survives a `brew upgrade node` without breakage.
    node_bin = Formula["node"].opt_bin/"node"
    %w[magic flash-magic].each do |name|
      (bin/name).write <<~SHIM
        #!/bin/bash
        exec "#{node_bin}" "#{libexec}/dist/index.js" "$@"
      SHIM
      chmod 0755, bin/name
    end
  end

  # Smoke test — `--version` is the only command that runs without
  # touching any chain / RPC / wallet, so it's the right thing to
  # exercise in `brew test`. Anything heavier would make brew test
  # flaky on offline / sandboxed builders.
  test do
    assert_match version.to_s, shell_output("#{bin}/magic --version")
    assert_match version.to_s, shell_output("#{bin}/flash-magic --version")
  end
end
