#!/usr/bin/env python3
#
# Implements https://circleci.com/docs/api/v2/#trigger-a-new-pipeline
#
# This script is used to trigger the end-to-end testing pipeline in https://github.com/mapbox/mapbox-sdk
#
# Documentation:
#   https://github.com/mapbox/mapbox-sdk/blob/master/docs/DEPENDENCY.md
#   https://github.com/mapbox/mapbox-sdk/blob/master/docs/CONFIG.md
#
# Example when using in `mapbox/mapbox-gl-native-internal` CircleCI environment:
#   ci-e2e-compatibility-start-pipeline.py --config mapbox-sdk-common="vendor/common" mapbox-gl-native-internal=${CIRCLE_SHA1} --platform all --versions latest
#

import argparse
import os
import requests
import sys
import datetime
import yaml
import git
from os import path
import subprocess


class ParseConfig(argparse.Action):
    """Parse space seperated key-value args delimited with '='."""

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, dict())
        for value in values:
            key, value = value.split("=")
            getattr(namespace, self.dest)[key] = value


def parse_args():
    target_slug = "mapbox/mapbox-sdk"

    versions = [
        {"id": "default", "name": "Default stable customer experience"},
        {"id": "latest", "name": "Latest releases"},
        {"id": "trunk", "name": "Latest commit of the default branch"},
    ]
    versions = dict({v["id"]: v["name"] for v in versions})

    """Parse script input parameters."""
    parser = argparse.ArgumentParser(
        description="Creates CircleCI jobs and waits for the result."
    )
    parser.add_argument(
        "--token",
        default=os.getenv("CIRCLE_API_TOKEN"),
        help="CircleCI token, otherwise environment CIRCLE_API_TOKEN.",
    )
    parser.add_argument(
        "--origin-slug",
        default=f'{os.getenv("CIRCLE_PROJECT_USERNAME")}/{os.getenv("CIRCLE_PROJECT_REPONAME")}',
        help="Origin repository, otherwise CIRCLE_PROJECT_USERNAME/CIRCLE_PROJECT_REPONAME.",
    )
    parser.add_argument(
        "--target-slug",
        default=target_slug,
        help="Repository to trigger the pipeline, example: mapbox/mapbox-sdk",
    )
    parser.add_argument(
        "--branch",
        help="Build a specific branch, otherwise it will build the default branch.",
    )
    parser.add_argument(
        "--current-branch",
        default=os.getenv("CIRCLE_BRANCH"),
        help="Current branch name. otherwise CIRCLE_BRANCH",
    )
    parser.add_argument(
        "--hash",
        default=os.getenv("CIRCLE_SHA1"),
        help="Commit git hash that triggered the pipeline, otherwise environment CIRCLE_SHA1.",
    )
    parser.add_argument(
        "--config",
        nargs="*",
        action=ParseConfig,
        help="""Configuration for dependencies, space seperated key-value
            pairs with dependeny name as key, value either a path to submodule
            or a branch, tag or commit SHA.""",
        required=True,
    )
    parser.add_argument("--platform", default="all")
    parser.add_argument(
        "--versions",
        default="default",
        choices=versions,
        help="SDK version configuration, otherwise using the default latest stable customer experience",
    )
    return parser.parse_args()


def validate_args(args):
    """Validate incoming arguments"""
    if not args.token:
        print("CircleCI token not set. Use --token or set CIRCLE_API_TOKEN.")
        sys.exit(1)

    if not args.hash:
        print("Originating commit hash not set. Use --hash or set CIRCLE_SHA1")
        sys.exit(1)


def execute_command(command):
    popen = subprocess.Popen(
        f"{command}", stdout=subprocess.PIPE, universal_newlines=True, shell=True
    )
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, command)


def resolve_config_to_yaml(config_args):
    """Resolve configuration to a yaml format and return encoded as utf-8.
    Validate if value points to a submodule path and get underlying commit sha
    or if we should treat the value as a branch, tag or commit.
    """
    config = {}
    for key in config_args:
        if path.isdir(path.abspath(config_args[key])):
            try:
                pin = git.Repo(config_args[key]).head.object.hexsha
            except:
                print(f"Submodule {config_args[key]} is not cloned, trying another way")
                command = (
                    "git submodule status | awk '/"
                    + config_args[key].replace("/", "\/")
                    + "/ {print substr($1, 2, length($1))}'"
                )
                ret = execute_command(command)
                for output in ret:
                    if output != "":
                        pin = output.strip()
                        break
                print("Found pin: " + pin)
            config[key] = {"pin": pin}
        else:
            config[key] = {"pin": config_args[key]}
    return yaml.dump(config).encode("utf-8")


def print_link(uri, label=None):
    if label is None:
        label = uri
    parameters = ""

    # OSC 8 ; params ; URI ST <name> OSC 8 ;; ST
    escape_mask = "\033]8;{};{}\033\\{}\033]8;;\033\\"

    print(escape_mask.format(parameters, uri, label))


def trigger_pipeline(slug, token, branch, params):
    """Trigger Circle-CI pipeline.
    Refs. https://circleci.com/docs/api/v2/#trigger-a-new-pipeline
    """
    url = f"https://circleci.com/api/v2/project/github/{slug}/pipeline"

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    data = {"parameters": params}

    if branch:
        data["branch"] = branch

    response = requests.post(url, auth=(token, ""), headers=headers, json=data)

    if response.status_code != 201 and response.status_code != 200:
        print("Error triggering the CircleCI: %s." % r.json()["message"])
        sys.exit(1)

    if response.status_code == 201:
        print(f"\nTriggered job can be found at:")
        print(
            f'https://app.circleci.com/pipelines/github/{slug}/{response.json()["number"]}'
        )


def main():
    args = parse_args()
    validate_args(args)

    config = resolve_config_to_yaml(args.config)
    params = {
        "mapbox_upstream": True,
        "mapbox_slug": args.origin_slug,
        "mapbox_hash": args.hash,
        "mapbox_config": config.decode("utf-8"),
        "mapbox_platform": args.platform,
        "mapbox_versions": args.versions,
    }
    print("Params: " + str(params))

    trigger_pipeline(args.target_slug, args.token, args.branch, params)
    return 0


if __name__ == "__main__":
    main()
