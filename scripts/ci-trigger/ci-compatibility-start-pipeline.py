#!/usr/bin/env python3

import argparse
import os
import requests
import sys
import yaml
import git
from os import path


class ParseConfig(argparse.Action):
    """Parse space seperated key-value args delimited with '='."""

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, dict())
        for value in values:
            key, value = value.split('=')
            getattr(namespace, self.dest)[key] = value


def parse_args():
    """Parse script input parameters."""
    parser = argparse.ArgumentParser(
        description="Creates CircleCI jobs and waits for the result.")
    parser.add_argument("--token", default=os.getenv("CIRCLE_API_TOKEN"),
        help="CircleCI token, otherwise environment CIRCLE_API_TOKEN.")
    parser.add_argument("--origin-slug", default=f'{os.getenv("CIRCLE_PROJECT_USERNAME")}/{os.getenv("CIRCLE_PROJECT_REPONAME")}',
        help="Origin repository, otherwise CIRCLE_PROJECT_USERNAME/CIRCLE_PROJECT_REPONAME.")
    parser.add_argument("--target-slug", required=True,
        help="Repository to trigger the pipeline, example: mapbox/mapbox-gl-native-android.")
    parser.add_argument("--branch",
        help="Build a specific branch, otherwise it will build the default branch.")
    parser.add_argument("--current-branch", default=os.getenv("CIRCLE_BRANCH"),
        help="Current branch name. otherwise CIRCLE_BRANCH")
    parser.add_argument("--hash", default=os.getenv("CIRCLE_SHA1"),
        help="Commit git hash that triggered the pipeline, otherwise environment CIRCLE_SHA1.")
    parser.add_argument('--config', nargs='*', action=ParseConfig,
        help="""Configuration for dependencies, space seperated key-value
        pairs with dependeny name as key, value either a path to submodule
        or a branch, tag or commit SHA.""", required=True)
    parser.add_argument('--platform', default="all")
    return parser.parse_args()


def validate_args(args):
    """Validate incoming arguments"""
    if not args.token:
        print("CircleCI token not set. Use --token or set CIRCLE_API_TOKEN.")
        sys.exit(1)

    if not args.hash:
        print("Originating commit hash not set. Use --hash or set CIRCLE_SHA1")
        sys.exit(1)


def resolve_config_to_yaml(config_args):
    '''Resolve configuration to a yaml format and return encoded as utf-8.
    Validate if value points to a submodule path and get underlying commit sha
    or if we should treat the value as a branch, tag or commit.
    '''
    config = {}
    for key in config_args:
        if(path.isdir(path.abspath(config_args[key]))):
            pin = git.Repo(config_args[key]).head.object.hexsha
            config[key] = {"pin": pin}
        else:
            config[key] = {"pin": config_args[key]}
    return yaml.dump(config).encode("utf-8")


def trigger_pipeline(slug, token, branch, params):
    """Trigger Circle-CI pipeline.
    Refs. https://circleci.com/docs/api/v2/#trigger-a-new-pipeline
    """
    url = f"https://circleci.com/api/v2/project/github/{slug}/pipeline"

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    data = {
        "parameters": params
    }

    if branch:
        data["branch"] = branch

    response = requests.post(url, auth=(token, ""), headers=headers, json=data)

    if response.status_code != 201 and response.status_code != 200:
        print("Error triggering the CircleCI: %s." % response.json()["message"])
        sys.exit(1)

    if response.status_code == 201:
        print(f'\nTriggered job can be found at:')
        print(f'https://app.circleci.com/pipelines/github/{slug}/{response.json()["number"]}')


def main():
    args = parse_args()
    validate_args(args)

    config = resolve_config_to_yaml(args.config)
    params = {
        "mapbox_upstream": True,
        "mapbox_slug": args.origin_slug,
        "mapbox_hash": args.hash,
        "mapbox_config": config.decode("utf-8"),
        "mapbox_platform": args.platform
    }

    trigger_pipeline(args.target_slug, args.token, args.branch, params)
    return 0


if __name__ == "__main__":
    main()