#!/usr/bin/env python3

import argparse
import logging
import subprocess
from pathlib import Path

logging.basicConfig(level=logging.INFO)


def main():
    parser = argparse.ArgumentParser(description="Upload documentation to S3.")
    parser.add_argument("--docs-dir", default=None, type=dir_path, help="Path to docs directory")
    parser.add_argument(
        "--version",
        default=None,
        required=False,
        type=version_no_prefix,
        help="Version to upload. If provided and not empty, will upload files under version directory on S3",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        default=False,
        help="Do not upload docs to S3",
    )
    parser.add_argument(
        "--bucket", default="docs.mapbox.com-staging", help="S3 bucket to upload to (default: docs.mapbox.com-staging)"
    )
    parser.add_argument("--path", required=True, help="S3 path for upload (e.g. android/maps/api, ios/maps/api)")
    args = parser.parse_args()

    if args.docs_dir and args.docs_dir.exists() and args.docs_dir.is_dir():
        bucket = args.bucket
        s3_path = f"s3://{bucket}/{args.path}"
        version = args.version.strip()
        if version:
            s3_path = f"{s3_path}/{version}"

        print(f"Uploading docs from {args.docs_dir} to {s3_path}")

        if not args.dry_run:
            upload_to_s3(args.docs_dir, s3_path)
        else:
            print(f"dry_run: This stage would upload {args.docs_dir} to {s3_path}")
    else:
        print("No valid docs directory provided")


def upload_to_s3(docs_dir: Path, s3_path: str):
    try:
        # First sync: everything except HTML and JSON files with long cache
        # this is on par with publishing workflow in mapbox/android-docs and mapbox/ios-sdk
        # iOS docs PR: https://github.com/mapbox/ios-sdk/pull/2500
        # Android docs PR: https://github.com/mapbox/android-docs/pull/3138
        cmd1 = [
            "aws",
            "s3",
            "sync",
            str(docs_dir),
            s3_path,
            "--exclude",
            "*.html",
            "--exclude",
            "*.json",
            "--cache-control",
            "max-age=31536000",
        ]

        print(f"Running: {' '.join(cmd1)}")
        result1 = subprocess.run(cmd1, capture_output=True, text=True)

        if result1.returncode != 0:
            print(f"Error in first sync: {result1.stderr}")
            return False

        print(f"First sync output: {result1.stdout}")

        # Second sync: only HTML and JSON files with short cache
        # this is on par with publishing workflow in mapbox/android-docs and mapbox/ios-sdk
        cmd2 = [
            "aws",
            "s3",
            "sync",
            str(docs_dir),
            s3_path,
            "--exclude",
            "*",
            "--include",
            "*.html",
            "--include",
            "*.json",
            "--cache-control",
            "max-age=10,stale-while-revalidate=60",
        ]

        print(f"Running: {' '.join(cmd2)}")
        result2 = subprocess.run(cmd2, capture_output=True, text=True)

        if result2.returncode != 0:
            print(f"Error in second sync: {result2.stderr}")
            return False

        print(f"Second sync output: {result2.stdout}")
        return True

    except Exception as e:
        print(f"Error uploading to S3: {e}")
        return False


def dir_path(string):
    path = Path(string).expanduser().resolve()
    if path.is_dir():
        return path
    else:
        raise NotADirectoryError(string)


def version_no_prefix(version: str):
    return version.lstrip("v")


main()
