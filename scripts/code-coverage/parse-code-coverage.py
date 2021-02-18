#!/usr/bin/python3

import os
import re
from io import open
import argparse
import git
import subprocess
import json
import gzip
import datetime

def parseReport(reportPath):
    with open(reportPath) as f:
        results = json.load(f)

    try:
        totals = results["data"][0]["totals"]
        return totals

    except:
        print("No coverage totals found")
        return {}

def publish_coverage_report(report, fileName):
    # write output to zip file
    with gzip.open(fileName, mode="wt") as f:
        f.write(json.dumps(report))

    print("TODO: publish " + fileName + " to S3")

    # remove the temporary zip file
    os.remove(fileName)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script to parse the lcov JSON coverage report.')
    parser.add_argument('--report', help= 'Provide path the lcov JSON report', required=True)
    parser.add_argument('--scheme', help= 'Xcode scheme', required=True)
    parser.add_argument('-c', '--component', help= 'Provide a specific benchmark name, used for comparisons.', required=True)
    parser.add_argument('-g', '--git', help= 'Provide path to retrieve git information from (eg. upstream dependency submodule)', required=True)

    # Optional
    parser.add_argument('-d', '--dryrun', help= 'Run the analyzer locally without uploading result to S3.', action='store_true')
    parser.add_argument('-b', '--build', help= 'Build number of circle-ci job, default is 0.', default = "0")

    args = parser.parse_args()

    buildNumber = args.build
    component = args.component
    scheme = args.scheme
    reportPath = os.path.abspath(args.report)
    gitInfoPath = os.path.abspath(args.git)

    isLocal = args.dryrun

    # Format
    # {
    #   "version" : string (schema version),
    #   "created_at" : <isoformat>,
    #   "project" : string (github),
    #   "branch" : string (default to main),
    #   "component" : string (for modules),
    #   "commit_sha" : string,
    #   "commit_message" : string,
    #   "coverage" : {
    #     "version" : string,
    #     "scheme" : string,
    #     "total" : <lcov JSON totals object>,
    #     "build" : string(CI build number)
    #   },
    # }

    # Git properties
    repo = git.Repo(gitInfoPath)
    branch = repo.head.name
    sha = repo.head.object.hexsha
    message = repo.head.object.message
    splitGitInfoPath = gitInfoPath.split("/")

    coverage_info = {}
    coverage_info["version"] = "1"
    coverage_info["scheme"]  = scheme
    coverage_info["build"]   = buildNumber
    coverage_info["totals"]  = parseReport(reportPath)

    report = {}
    report["version"]        = "1"
    report["created_at"]     = datetime.datetime.utcnow().isoformat()
    report["project"]        = splitGitInfoPath[len(splitGitInfoPath)-1]
    report["branch"]         = branch
    report["component"]      = component
    report["commit_sha"]     = sha
    report["commit_message"] = message
    report["coverage"]       = coverage_info

    # Print the stats of current file
    print(json.dumps(report, indent=2))

    # Save stats as a zipped file and publish to aws
    if isLocal:
      print("### Local run, do not upload to S3.")
    else:
      print("### Uploading to S3.")
      publish_coverage_report(report, './code-coverage-' + component + '-' + scheme + '-' + buildNumber +'.json.gz')
