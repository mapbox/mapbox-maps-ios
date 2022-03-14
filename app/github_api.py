import logging
import os
import re
from enum import Enum
from typing import Any
from typing import Dict

import requests
from expectise import mock_if

logging.getLogger().setLevel(logging.INFO)


class GithubEntities(Enum):
    """Github projects can be created at the organization or user level, which is reflected in their URL."""

    orgs = "organization"
    users = "user"


class GithubAPI:
    """requests wrapper to access the Github GraphQL API."""

    URL = None
    TOKEN = None

    @classmethod
    def _set_up(cls):
        """Set up the API explicitly, after interpretation."""
        cls.URL = os.environ["GITHUB_GRAPHQL_URL"]
        cls.TOKEN = os.environ["GITHUB_API_TOKEN"]

    @mock_if("ENV", "test")
    @classmethod
    def _post(cls, query: str) -> Dict[str, Any]:
        """Send a POST request to the Github GraphQL API with the input query."""
        if cls.URL is None or cls.TOKEN is None:
            cls._set_up()

        response = requests.post(
            cls.URL,
            json={"query": query},
            headers={"Authorization": f"token {cls.TOKEN}"},
        )
        response.raise_for_status()
        return response.json()

    @classmethod
    def get_project_id(cls, project_url: str) -> str:
        """Get Github project node id from the full URL."""
        url_pattern = r"^https:\/\/github.com\/(orgs|users)\/(.+)\/projects\/([0-9]+)"
        regex_match = re.search(url_pattern, project_url)
        if not regex_match:
            raise ValueError(f"Invalid Github Project URL - `{project_url}`")

        entity_path, entity_name, project_number = regex_match.groups()
        entity_type = GithubEntities[entity_path].value
        response = cls._post(
            f"""
                {{
                    {entity_type}(login: "{entity_name}") {{
                        projectNext(number: {project_number}) {{
                            id
                        }}
                    }}
                }}
            """
        )
        logging.info(response)
        return response["data"][entity_type]["projectNext"]["id"]

    @classmethod
    def add_issue_to_project(cls, issue_id: str, project_id: str) -> None:
        """Add an issue to a Github project board."""
        cls._post(
            f"""
                mutation {{
                    addProjectNextItem(input: {{projectId: "{project_id}" contentId: "{issue_id}"}}) {{
                        projectNextItem {{
                            id
                        }}
                    }}
                }}
            """
        )
