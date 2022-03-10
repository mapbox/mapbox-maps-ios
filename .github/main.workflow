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
    PROJECT_URL         = "https://github.com/masutaka/github-actions-all-in-one-project/projects/1"
    INITIAL_COLUMN_NAME = "To do"
  }
}
