#!/usr/bin/python3

import sys, argparse, requests, json, plistlib, datetime

def check_results(test_results):
    """
    Checks the AWS run results and returns non-zero if there were failures (not "errored")
    """
#   {
#     "run" : {
#       ...
#       "counters": {
#         "total": 645, 
#         "passed": 352, 
#         "failed": 0, 
#         "warned": 0, 
#         "errored": 293, 
#         "stopped": 0, 
#         "skipped": 0
#       }
#     }
#   }

    with open(test_results) as f:
        results = json.load(f)

    try:
        counters = results["run"]["counters"]
        print(counters)
        failure_count = counters["failed"]

        if failure_count != 0:
            print("Detected", failure_count, "test failures :(")
            return 1

    except:
        pass
    
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('testresults', help='Path to AWS get-run JSON test results')

    args = parser.parse_args()
    result = check_results(args.testresults)
    exit(result)
