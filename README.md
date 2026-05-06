# homebrew-flash-magic

Homebrew tap for [`flash-magic-terminal`](https://github.com/Abdr007/flash-magic-terminal) — sub-second perpetuals trading on Solana via MagicBlock ephemeral rollups.

## Install

```bash
brew tap Abdr007/flash-magic
brew install flash-magic
```

Then:

```bash
magic init       # one-prompt wizard
magic            # start trading
```

## Update

```bash
brew upgrade flash-magic
```

## Uninstall

```bash
brew uninstall flash-magic
brew untap Abdr007/flash-magic
```

## Alternatives

If you don't want Homebrew, install via npm instead:

```bash
npm install -g flash-magic-terminal
```

Both binaries (`magic` + `flash-magic`) ship with either install method.

## Versioning

This tap tracks the same versions published to [npmjs.org/flash-magic-terminal](https://www.npmjs.com/package/flash-magic-terminal). Each formula bump points at a specific npm tarball + sha256 for reproducible installs.

## License

MIT — see the canonical repo: https://github.com/Abdr007/flash-magic-terminal
