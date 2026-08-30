#!/usr/bin/env python3
"""Build or verify Feather's compact Liquid Glass asset catalog."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


REPO_ROOT = Path(__file__).resolve().parents[2]
SOURCE_CATALOG = REPO_ROOT / "Feather/Resources/Assets.xcassets"
ICON_ROOT = REPO_ROOT / "Feather/Resources/Icons/Liquid Glass"
PREBUILT_CATALOG = REPO_ROOT / "liquid-glass/prebuilt/Assets.car"
ICON_NAMES = (
    "GlassFeatherV1",
    "GlassFeatherV2",
    "GlassFeatherV3",
    "MidnightSky",
)
PREVIEW_SCALES = (2, 3)
XCODE_VERSION = "26.0.1"
MANIFEST_VERSION = 1
IGNORED_SOURCE_NAMES = {".DS_Store"}


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build or verify Feather's compact Liquid Glass Assets.car."
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Verify the checked-in catalog and source manifest without rebuilding.",
    )
    parser.add_argument(
        "--catalog",
        type=Path,
        default=PREBUILT_CATALOG,
        help="Catalog to build or verify (default: liquid-glass/prebuilt/Assets.car).",
    )
    return parser.parse_args()


def resolve_catalog(path: Path) -> Path:
    if not path.is_absolute():
        path = REPO_ROOT / path
    return path.resolve()


def catalog_sources() -> tuple[Path, ...]:
    icons = tuple(ICON_ROOT / f"{name}.icon" for name in ICON_NAMES)
    previews = tuple(
        ICON_ROOT / f"{name}@{scale}x.png"
        for name in ICON_NAMES
        for scale in PREVIEW_SCALES
    )
    return (SOURCE_CATALOG, *icons, *previews)


def repo_relative(path: Path) -> str:
    return path.resolve().relative_to(REPO_ROOT).as_posix()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def sha256_tree(path: Path) -> str:
    digest = hashlib.sha256()
    files = [path] if path.is_file() else sorted(
        candidate
        for candidate in path.rglob("*")
        if candidate.is_file() and candidate.name not in IGNORED_SOURCE_NAMES
    )
    for candidate in files:
        digest.update(repo_relative(candidate).encode("utf-8"))
        digest.update(b"\0")
        with candidate.open("rb") as source:
            for chunk in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(chunk)
        digest.update(b"\0")
    return digest.hexdigest()


def source_hashes() -> dict[str, str]:
    return {
        repo_relative(path): sha256_tree(path)
        for path in catalog_sources()
    }


def manifest_path(catalog: Path) -> Path:
    return catalog.with_name("manifest.json")


def _developer_dir(candidate: Path) -> Path:
    candidate = candidate.expanduser().resolve()
    if candidate.suffix == ".app":
        return candidate / "Contents/Developer"
    return candidate


def _is_xcode_26_0_1(candidate: Path) -> bool:
    xcodebuild = candidate / "usr/bin/xcodebuild"
    if not xcodebuild.is_file():
        return False
    result = subprocess.run(
        [str(xcodebuild), "-version"],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0 and result.stdout.splitlines()[:1] == [
        f"Xcode {XCODE_VERSION}"
    ]


def find_xcode() -> Path:
    candidates: list[Path] = []

    override = os.environ.get("XCODE_DEVELOPER_DIR")
    if override:
        candidates.append(_developer_dir(Path(override)))

    candidates.extend(
        (
            Path(f"/Applications/Xcode_{XCODE_VERSION}.app/Contents/Developer"),
            Path("/Applications/Xcode.app/Contents/Developer"),
        )
    )

    selected = subprocess.run(
        ["/usr/bin/xcode-select", "--print-path"],
        capture_output=True,
        text=True,
        check=False,
    )
    if selected.returncode == 0 and selected.stdout.strip():
        candidates.append(_developer_dir(Path(selected.stdout.strip())))

    spotlight = subprocess.run(
        [
            "/usr/bin/mdfind",
            "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'"
            f" && kMDItemVersion == '{XCODE_VERSION}'",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    candidates.extend(
        _developer_dir(Path(line.strip()))
        for line in spotlight.stdout.splitlines()
        if line.strip()
    )

    seen: set[Path] = set()
    for candidate in candidates:
        candidate = candidate.expanduser()
        if candidate in seen:
            continue
        seen.add(candidate)
        if _is_xcode_26_0_1(candidate):
            return candidate

    raise RuntimeError(
        "Xcode 26.0.1 is required for compact icon stacks. Install it or set "
        "XCODE_DEVELOPER_DIR to its Contents/Developer directory."
    )


def run(
    command: list[str],
    environment: dict[str, str],
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        env=environment,
        capture_output=True,
        text=True,
        check=True,
    )


def validate_catalog(
    catalog: Path,
    environment: dict[str, str],
) -> list[dict[str, object]]:
    run(["xcrun", "assetutil", "-Z", str(catalog)], environment)
    metadata = json.loads(
        run(["xcrun", "assetutil", "-I", str(catalog)], environment).stdout
    )
    entries = [entry for entry in metadata if isinstance(entry, dict)]

    names = {entry.get("Name") for entry in entries}
    missing_names = set(ICON_NAMES) - names
    if missing_names:
        raise RuntimeError(f"Catalog is missing icon stacks: {sorted(missing_names)}")

    stack_names = {
        entry.get("Name")
        for entry in entries
        if entry.get("AssetType") == "IconImageStack"
    }
    missing_stacks = set(ICON_NAMES) - stack_names
    if missing_stacks:
        raise RuntimeError(
            f"Catalog is missing native icon-stack data: {sorted(missing_stacks)}"
        )

    fallback_names = {
        entry.get("Name")
        for entry in entries
        if entry.get("AssetType") == "Icon Image"
    }
    unexpected_fallbacks = set(ICON_NAMES) & fallback_names
    if unexpected_fallbacks:
        raise RuntimeError(
            "Xcode generated legacy fallback renditions for: "
            f"{sorted(unexpected_fallbacks)}"
        )

    return entries


def verify_prebuilt(catalog: Path) -> None:
    manifest = manifest_path(catalog)
    if not catalog.is_file():
        raise RuntimeError(f"Missing prebuilt catalog: {catalog}")
    if not manifest.is_file():
        raise RuntimeError(f"Missing source manifest: {manifest}")

    data = json.loads(manifest.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise RuntimeError(f"Invalid source manifest: {manifest}")
    if data.get("version") != MANIFEST_VERSION:
        raise RuntimeError(f"Unsupported manifest version in {manifest}")

    expected_sources = data.get("sources")
    if not isinstance(expected_sources, dict):
        raise RuntimeError(f"Invalid source hashes in {manifest}")
    actual_sources = source_hashes()
    if expected_sources != actual_sources:
        changed = sorted(
            path
            for path in set(expected_sources) | set(actual_sources)
            if expected_sources.get(path) != actual_sources.get(path)
        )
        raise RuntimeError(
            "Prebuilt Assets.car is stale. Rebuild it after changing: "
            + ", ".join(changed)
        )

    catalog_data = data.get("catalog")
    if not isinstance(catalog_data, dict):
        raise RuntimeError(f"Invalid catalog metadata in {manifest}")
    actual_size = catalog.stat().st_size
    actual_hash = sha256_file(catalog)
    if catalog_data.get("size") != actual_size:
        raise RuntimeError(
            f"Catalog size does not match {manifest}: "
            f"{actual_size:,} != {catalog_data.get('size')}"
        )
    if catalog_data.get("sha256") != actual_hash:
        raise RuntimeError(f"Catalog checksum does not match {manifest}")

    print(f"Verified: {catalog}")
    print(f"Size: {actual_size:,} bytes")
    print(f"SHA-256: {actual_hash}")


def build_catalog(catalog: Path) -> None:
    missing_inputs = [path for path in catalog_sources() if not path.exists()]
    if missing_inputs:
        raise RuntimeError(f"Missing asset inputs: {missing_inputs}")

    original_sources = source_hashes()
    developer_dir = find_xcode()
    environment = os.environ.copy()
    environment["DEVELOPER_DIR"] = str(developer_dir)

    with tempfile.TemporaryDirectory(prefix="feather-liquid-glass-") as temporary:
        temporary_root = Path(temporary)
        input_root = temporary_root / "inputs"
        staged_catalog_source = input_root / "Assets.xcassets"
        staged_icon_root = input_root / "Icons"

        # actool may normalize .icon packages in place. Work from disposable
        # copies so rebuilding cannot modify the checked-out icon sources.
        ignore_metadata = shutil.ignore_patterns(*IGNORED_SOURCE_NAMES)
        shutil.copytree(
            SOURCE_CATALOG,
            staged_catalog_source,
            ignore=ignore_metadata,
        )
        staged_icon_root.mkdir(parents=True)
        for name in ICON_NAMES:
            shutil.copytree(
                ICON_ROOT / f"{name}.icon",
                staged_icon_root / f"{name}.icon",
                ignore=ignore_metadata,
            )

        compiled_directory = temporary_root / "compiled"
        compiled_directory.mkdir()
        compiled_catalog = compiled_directory / "Assets.car"

        command = [
            "xcrun",
            "actool",
            str(staged_catalog_source),
            *(str(staged_icon_root / f"{name}.icon") for name in ICON_NAMES),
            "--compile",
            str(compiled_directory),
            "--platform",
            "iphoneos",
            "--minimum-deployment-target",
            "16.0",
            "--output-format",
            "human-readable-text",
            "--include-all-app-icons",
            "--enable-icon-stack-fallback-generation=disabled",
            "--output-partial-info-plist",
            str(compiled_directory / "partial-info.plist"),
        ]

        print(f"Using Xcode {XCODE_VERSION}: {developer_dir}")
        run(command, environment)
        metadata = validate_catalog(compiled_catalog, environment)

        if source_hashes() != original_sources:
            raise RuntimeError("Asset sources changed while the catalog was compiling")

        catalog.parent.mkdir(parents=True, exist_ok=True)
        staged_catalog = catalog.with_suffix(".car.tmp")
        shutil.copy2(compiled_catalog, staged_catalog)
        os.replace(staged_catalog, catalog)

        idioms = sorted(
            {
                str(entry["Idiom"])
                for entry in metadata
                if entry.get("Idiom") is not None
            }
        )
        manifest_data = {
            "version": MANIFEST_VERSION,
            "xcode": XCODE_VERSION,
            "profile": "iphone-and-ipad-native-icon-stacks",
            "legacy_icon_fallbacks": False,
            "catalog": {
                "size": catalog.stat().st_size,
                "sha256": sha256_file(catalog),
                "idioms": idioms,
            },
            "sources": original_sources,
        }
        manifest = manifest_path(catalog)
        staged_manifest = manifest.with_suffix(".json.tmp")
        staged_manifest.write_text(
            json.dumps(manifest_data, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        os.replace(staged_manifest, manifest)

    verify_prebuilt(catalog)


def main() -> int:
    arguments = parse_arguments()
    catalog = resolve_catalog(arguments.catalog)
    try:
        if arguments.verify:
            verify_prebuilt(catalog)
        else:
            build_catalog(catalog)
        return 0
    except (
        OSError,
        RuntimeError,
        subprocess.CalledProcessError,
        json.JSONDecodeError,
    ) as error:
        print(f"Asset catalog operation failed: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
