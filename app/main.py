#!/usr/bin/env python3
import logging

try:
    # Github actions are run as a script, and relative imports won't work
    from github_api import GithubAPI
    from github_env import GithubEnv
except ModuleNotFoundError:
    # tests are run from another module, and since we can't use relative imports, we have to use this workaround
    from app.github_api import GithubAPI
    from app.github_env import GithubEnv

logging.getLogger().setLevel(logging.INFO)


def run() -> None:
    """Run the Github action."""
    event_name = GithubEnv.get_event_name()
    if event_name != "issues":
        raise NotImplementedError(f"`{event_name}` events not supported!")

    logging.info("Reading Github webhook event from local files...")
    event = GithubEnv.get_event()
    logging.info("Reading Github action input from environment...")
    input = GithubEnv.get_input()
    logging.info("Getting Github Project ID based on URL...")
    project_id = GithubAPI.get_project_id(input["project_url"])
    logging.info("Adding issue to Project board...")
    GithubAPI.add_issue_to_project(event["issue"]["node_id"], project_id)
    logging.info("Done, exiting.")


if __name__ == "__main__":
    run()
