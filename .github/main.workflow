# For issues

workflow "issues" {
  on       = "issues"
  resolves = ["Add an issue to project"]
}

action "Add an issue to project" {
  uses    = "docker://masutaka/github-actions-all-in-one-project"
  secrets = ["GITHUB_TOKEN"]
  args    = ["issue"]

  env = {
    PROJECT_URL         = "https://github.com/orgs/mapbox/projects/707"
    INITIAL_COLUMN_NAME = "Backlog"
  }
}
