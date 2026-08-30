# Compact Liquid Glass catalog

The packaged iOS app replaces Xcode's generated `Assets.car` with a compact,
prebuilt catalog. The catalog is compiled with Xcode 26.0.1 using the hidden
`--enable-icon-stack-fallback-generation=disabled` option. This preserves the
native `.icon` stacks and their iPhone and iPad renditions while omitting the
large legacy raster fallback images. With the current assets, the resulting
catalog is reduced from about 26 MB to 1.68 MB.

Rebuild the checked-in catalog with:

```sh
make liquid-glass-assets
```

The script requires Xcode 26.0.1. It finds the canonical installation or a
Spotlight-indexed copy automatically; `XCODE_DEVELOPER_DIR` can override the
search. It compiles disposable copies of the source catalogs so `actool` cannot
rewrite the checked-out `.icon` packages. The output is
`liquid-glass/prebuilt/Assets.car`.

The rebuild also writes `liquid-glass/prebuilt/manifest.json`, which records
the hashes of the asset catalog, all four icon packages, and their picker
previews. Packaging verifies that manifest before replacing the generated
catalog, so an icon or preview change cannot silently ship with stale Home
Screen artwork. Run that check directly with:

```sh
python3 liquid-glass/scripts/rebuild_assets.py --verify
```

The main Xcode build still creates the app and icon metadata. The Makefile
only swaps in this prebuilt catalog before the final ad-hoc signature is
applied. Mac Catalyst builds keep their normal generated catalog.

The compact catalog intentionally omits pre-iOS 26 fallback renditions for the
Liquid Glass alternates. The app therefore shows the Liquid Glass section only
on iOS 26 or later.
