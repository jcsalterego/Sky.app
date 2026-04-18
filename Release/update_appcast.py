#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


SPARKLE_NS = "http://www.andymatuschak.org/xml-namespaces/sparkle"
ET.register_namespace("sparkle", SPARKLE_NS)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate an appcast for a release directory and prepend its entry "
            "to the repository appcast.xml feed."
        )
    )
    parser.add_argument(
        "output_dir",
        nargs="?",
        default="out",
        help="Directory to pass to generate_appcast. Defaults to out.",
    )
    parser.add_argument(
        "--env-file",
        default=".env",
        help="Path to the .env file to load before running generate_appcast.",
    )
    parser.add_argument(
        "--appcast",
        default="appcast.xml",
        help="Path to the historical appcast feed to update.",
    )
    return parser.parse_args()


def load_dotenv(path: Path) -> dict[str, str]:
    env = dict(os.environ)

    if not path.exists():
        return env

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        if line.startswith("export "):
            line = line[len("export ") :].strip()

        if "=" not in line:
            raise ValueError(f"Invalid line in {path}: {raw_line!r}")

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()

        if value and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]

        env[key] = value

    return env


def run_generate_appcast(output_dir: Path, env: dict[str, str]) -> None:
    appcast_dir = env.get("APPCAST_DIR", "").strip()
    executable = None

    if appcast_dir:
        candidate = Path(appcast_dir).expanduser() / "generate_appcast"
        if candidate.is_file() and os.access(candidate, os.X_OK):
            executable = str(candidate)
        else:
            raise FileNotFoundError(
                f"generate_appcast not found or not executable at {candidate}"
            )

    if executable is None:
        executable = shutil.which("generate_appcast", path=env.get("PATH"))

    if executable is None:
        raise FileNotFoundError(
            "generate_appcast is not installed, APPCAST_DIR is not set, and no generate_appcast was found on PATH."
        )

    subprocess.run(
        [executable, str(output_dir)],
        check=True,
        env=env,
    )


def find_channel(root: ET.Element, source: Path) -> ET.Element:
    channel = root.find("channel")
    if channel is None:
        raise ValueError(f"Missing <channel> in {source}")
    return channel


def item_version(item: ET.Element) -> str:
    version = item.findtext(f"{{{SPARKLE_NS}}}version")
    if version:
        return version.strip()

    title = item.findtext("title")
    if title:
        return title.strip()

    enclosure = item.find("enclosure")
    if enclosure is not None:
        return enclosure.get("url", "").strip()

    return ""


def update_enclosure_url(item: ET.Element) -> None:
    """Update enclosure URL from GitHub Pages format to GitHub Releases format.
    
    Transforms:
        https://jcsalterego.github.io/Sky.app/Sky%200.5.1.dmg
    To:
        https://github.com/jcsalterego/Sky.app/releases/download/0.5.1/Sky.0.5.1.dmg
    """
    enclosure = item.find("enclosure")
    if enclosure is None:
        return
    
    url = enclosure.get("url", "")
    if not url:
        return
    
    # Extract version from sparkle:version tag
    version = item.findtext(f"{{{SPARKLE_NS}}}version")
    if not version:
        return
    
    # Build new GitHub Releases URL
    new_url = f"https://github.com/jcsalterego/Sky.app/releases/download/{version}/Sky.{version}.dmg"
    enclosure.set("url", new_url)


def extract_generated_item(generated_appcast: Path) -> ET.Element:
    tree = ET.parse(generated_appcast)
    channel = find_channel(tree.getroot(), generated_appcast)
    item = channel.find("item")
    if item is None:
        raise ValueError(f"Missing <item> in {generated_appcast}")
    return item


def merge_appcast(target_appcast: Path, new_item: ET.Element) -> None:
    tree = ET.parse(target_appcast)
    root = tree.getroot()
    channel = find_channel(root, target_appcast)

    new_version = item_version(new_item)
    for existing_item in list(channel.findall("item")):
        if new_version and item_version(existing_item) == new_version:
            channel.remove(existing_item)

    insert_at = 0
    title = channel.find("title")
    if title is not None:
        insert_at = list(channel).index(title) + 1

    channel.insert(insert_at, new_item)
    ET.indent(tree, space="  ")
    tree.write(target_appcast, encoding="utf-8", xml_declaration=True)


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parent
    output_dir = (repo_root / args.output_dir).resolve()
    env_file = (repo_root / args.env_file).resolve()
    target_appcast = (repo_root / args.appcast).resolve()
    generated_appcast = output_dir / "appcast.xml"

    if not output_dir.is_dir():
        print(f"Output directory not found: {output_dir}", file=sys.stderr)
        return 1

    if not target_appcast.exists():
        print(f"Target appcast not found: {target_appcast}", file=sys.stderr)
        return 1

    try:
        env = load_dotenv(env_file)
        run_generate_appcast(output_dir, env)
        new_item = extract_generated_item(generated_appcast)
        update_enclosure_url(new_item)
        merge_appcast(target_appcast, new_item)
    except FileNotFoundError as error:
        print(error, file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as error:
        print(
            f"generate_appcast failed with exit code {error.returncode}",
            file=sys.stderr,
        )
        return error.returncode
    except (OSError, ValueError, ET.ParseError) as error:
        print(error, file=sys.stderr)
        return 1

    print(f"Updated {target_appcast} with {generated_appcast}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
