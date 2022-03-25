import json
import os
from typing import Any
from typing import Dict

from expectise import mock_if


class GithubEnv:
    @staticmethod
    def get_event_name() -> str:
        """Get the name of the event that triggered the Github workflow."""
        return os.environ["GITHUB_EVENT_NAME"]

    @mock_if("ENV", "test")
    @staticmethod
    def get_event() -> Dict[str, Any]:
        """Get the webhook event that triggered the Github workflow from local files."""
        with open(os.environ["GITHUB_EVENT_PATH"], "r") as event_file:
            event = json.loads(event_file.read())

        return event

    @staticmethod
    def get_input() -> Dict[str, str]:
        """Get Github Action inputs, that are passed through environment variables."""
        return {
            "project_url": os.environ["INPUT_PROJECT_URL"],
        }
