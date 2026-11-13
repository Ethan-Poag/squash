# Squash

Squash is an unofficial fork of [Pumpkin](https://pumpkinmc.org/), a Minecraft server written in Rust. It is not affiliated with or endorsed by the Pumpkin team.

This repo ships a patch set on a pinned Pumpkin release, not a full copy of Pumpkin. The patches target Minecraft 26.3 (Pumpkin tag `0.2.2+26.3-26.60`).

Report bugs here. Do not file Squash bugs on the upstream Pumpkin tracker.

These patches were written with AI help and then reviewed and tested by Ethan Poag's setup. Treat this project as AI-assisted.

## What it adds

Stock Pumpkin 0.2.2 does not load current 26.3 worlds reliably. Squash patches that, and also brings spawning closer to vanilla and backports a sign-edit security fix.

- 26.3 chunk and world decode: palettes, biomes, noise, heightmaps, sky light, and default block entities
- Loading and saving that match vanilla more closely: relight, biomes on older chunks, item `Count`, and container loot
- Spawn parity: mob caps, per-chunk natural spawns, structure spawn lists, and monster light
- Datapack worldgen that Pumpkin was missing, including pack biomes, dimension types, and jigsaw placement
- Sign authorization from Pumpkin [#4503](https://github.com/Pumpkin-MC/Pumpkin/pull/4503) by Gavin Holmes. Sign edits need an open editor and a range check, and untrusted sign-click commands are blocked

Some vanilla gaps remain, including bats, some structure pieces, and a few Nether spawn oddities.

## Build

You need git, a Rust toolchain (stable, as in Pumpkin's `rust-toolchain.toml`), and a network to clone upstream.

```sh
./build.sh
```

The script clones Pumpkin at the pinned tag, checks the commit, applies `patches/` in order, and builds a release binary at `build/Pumpkin/target/release/pumpkin`. Pass a directory to build somewhere else: `./build.sh /tmp/squash-build`.

Do not run the binary with `--version`. That flag starts a server.

## Patches

Apply these in order on Pumpkin tag `0.2.2+26.3-26.60` (commit `eda69440e6369c5f8a05c3f69fc809c40dab93a6`). `build.sh` does that for you.

- `patches/0001-world-26.3-parity.patch` is the 26.3 decode, NBT, save, spawn, and datapack work. Those changes share too many files to split further without a rebase.
- `patches/0002-sign-authorization-4503.patch` is a cherry-pick of Pumpkin #4503 by Gavin Holmes (upstream commit `e46b8f93`).

## License

Squash is [GPL-3.0](LICENSE), the same license as Pumpkin. Pumpkin is copyright its authors. The sign authorization patch is a cherry-pick of work by Gavin Holmes.

## Upstream

- Pumpkin site: https://pumpkinmc.org/
- Pumpkin source: https://github.com/Pumpkin-MC/Pumpkin
