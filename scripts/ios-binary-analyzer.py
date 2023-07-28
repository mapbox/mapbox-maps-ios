#!/usr/bin/env python3

# See android-binary-analyzer.py from this this script is modified.
# The iOS binary size stats are uploaded to mobile_staging.binarysize_v2. This is
# unlike the Common and gl-native SDKs that use different schemas:
#
# mapbox-sdk-common: coresdk_staging.binarysize_ios
# mapbox-gl-native-internal: mobile_staging.binarysize
#
# Although iOS is using the same schema as Android, we're using the fields slightly differently:
#
# {
#   created: <datestamp>
#   name: "ios-maps-carbon"
#   binary_name: <xcframework name, e.g. "Mapbox.xcframework">
#   core: null
#   binary_size: <file size of zipped framework, e.g. Mapbox.xcframework.zip>
#   version: 3
#   platform: <JSON dictionary as output from ios-binary-size>
#   build: <build metadata (as Android)>
# }

import argparse
import git
import subprocess
import os
import sys
import shutil
import json
import gzip
import urllib.request
import pathlib
import datetime


def spawn_subprocess(command_args, working_dir):
  try:
    response = subprocess.check_output(command_args, cwd=working_dir, stderr=subprocess.STDOUT)
    return response
  except subprocess.CalledProcessError as e:
    raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode, e.output))

def get_associated_tag(repo, commit="HEAD"):
  try:
    tag_info = repo.git.describe(commit, tags=True, match="v*", exact_match=True)
    return tag_info
  except:
    return

class iOSBinaryAnalyzer:
  def __init__(self, binary_path, work_dir, build):
    self.binary_path = os.path.abspath(binary_path)
    self.work_dir = os.path.abspath(work_dir)
    self.scripts_dir = os.path.dirname(os.path.realpath(__file__))
    self.output_dir = os.path.join(self.work_dir, 'out')
    self.output_file = os.path.join(self.output_dir, 'binary-size-' + build +'.json.gz')
    # Store the generated result
    self.stats = {}
    os.makedirs(self.output_dir, exist_ok=True)

  def run_ios_binary_size(self):
    (working_dir, file_name) = os.path.split(self.binary_path)
    response = spawn_subprocess(["ios-binary-size", "xc", file_name], working_dir)
    # Convert to json
    stats = json.loads(response)
    return stats

  def parse_core_libraries(self):
    so_files_summary = {}
    # Do nothing
    return so_files_summary

  def get_file_size(self, file_path):
    return os.path.getsize(file_path)

  def get_binary_size(self):
    # shutil.make_archive(self.binary_path, 'zip', self.binary_path)

    # Using zip from the commandline as the above results in a slightly different sized
    # zip, and we want to use the same as our release process
    (working_dir, file_name) = os.path.split(self.binary_path)
    zip_path = os.path.join(self.work_dir, file_name + '.zip')
    spawn_subprocess(["zip", "-r", zip_path, file_name], working_dir)

    return self.get_file_size(zip_path)

  def run_binaryanalyzer(self):
    self.stats['binary_name'] = os.path.basename(self.binary_path)
    self.stats['created'] = datetime.datetime.utcnow().isoformat()
    self.stats['binary_size'] = self.get_binary_size()
    self.stats['platform'] = self.run_ios_binary_size()
    self.stats['core'] = self.parse_core_libraries()

  def update_stats(self, entry):
    self.stats.update(entry)

  def print_stats(self):
    print(json.dumps(self.stats, indent=2))

  def save_stats(self):
    # write output to zip file
    with gzip.open(self.output_file, mode="wt") as f:
      f.write(json.dumps(self.stats))

  def publish_stats(self):
    publish_script = os.path.join(self.scripts_dir, 'publish_to_aws.sh')
    try:
      self.publish_results = subprocess.check_output(['sh', publish_script, 'mobile_staging.binarysize_v2', self.output_file], stderr=subprocess.STDOUT)
      print(self.publish_results)
    except subprocess.CalledProcessError as e:
      raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode, e.output))

  def cleanup(self):
    shutil.rmtree(self.work_dir)

if __name__ == "__main__":
  ###
  ### Script input
  ###
  parser = argparse.ArgumentParser(description='Script to analyze the iOS binary size.')
  parser.add_argument('-d', '--dryrun', help= 'Run the analyzer locally without uploading result to S3.', action='store_true')
  parser.add_argument('-c', '--build', help= 'Build number of circle-ci job, default is 0.', default = "0")
  parser.add_argument('-w', '--workdir', help= 'Provide path the temporary work directory, default is ./tmp', default = "./tmp")
  parser.add_argument('-g', '--git', help= 'Provide path to retrieve git information from (eg. upstream dependency submodule)')

  parser.add_argument('-r', '--root', help= 'Provide path to root git project')
  parser.add_argument('-b', '--baseline')
  parser.add_argument('-t', '--baseline-tolerance', default=5, type=float)

  requiredNamed = parser.add_argument_group('required named arguments')
  requiredNamed.add_argument('-x', '--xcframework', help= 'Provide path to the iOS SDK .xcframework', required=True)
  requiredNamed.add_argument('-n', '--name', help= 'Provide a specific benchmark name, used for creating baseline data.', required=True)

  args = parser.parse_args()
  buildNumber = args.build
  baselineName = args.name
  binaryPath = os.path.abspath(args.xcframework)
  workdirPath = os.path.abspath(args.workdir)

  gitInfoPath = None
  rootGitPath = None
  isLocal = args.dryrun

  if args.git is not None:
    gitInfoPath = os.path.abspath(args.git)

  if args.root is not None:
    rootGitPath = os.path.abspath(args.root)

  ###
  ### Analyze the input file using AndroidBinary Analyzer
  ###
  analyzer = iOSBinaryAnalyzer(binaryPath, workdirPath, buildNumber)
  analyzer.run_binaryanalyzer()

  ###
  ### Load git information if git path is specified
  ###
  buildInfo = {}

  if gitInfoPath is not None:
    repo = git.Repo(gitInfoPath, search_parent_directories=True)

    tag_info = get_associated_tag(repo)
    if tag_info:
      buildInfo['tag_name'] = tag_info

    branch = repo.head.name
    sha = repo.head.object.hexsha
    author = repo.head.object.author.name
    timestamp = repo.head.object.committed_date
    message = repo.head.object.message
    splitGitInfoPath = gitInfoPath.split("/")

    ### Add build info to the result
    buildInfo.update({"build":int(buildNumber)})
    buildInfo.update({"project":splitGitInfoPath[len(splitGitInfoPath)-1]})
    buildInfo.update({"branch":branch})
    buildInfo.update({"sha":sha})
    buildInfo.update({"author":author})
    buildInfo.update({"timestamp":timestamp})
    buildInfo.update({"message":message})

    try:
      tag = repo.git.describe('--tags', '--exact-match', '--match', 'v*')
      buildInfo.update({"tag_name":tag})
    except:
      pass


    ## Xcode version
    response = spawn_subprocess(["xcodebuild", "-version"], ".")
    strresponse = [x.decode("utf-8") for x in response.splitlines()]
    version = " ".join(strresponse)
    buildInfo.update({"xcode":version})

  if rootGitPath is not None:
    ## SHA for mobile-metrics
    metrics_repo = git.Repo(rootGitPath)
    metrics_sha = metrics_repo.head.object.hexsha
    buildInfo.update({"metrics-sha":metrics_sha})

  analyzer.update_stats({'build': buildInfo})

  # Add additional name, version and build info to the result
  analyzer.update_stats({'name': baselineName})
  analyzer.update_stats({"version": "3"})

  # Print the stats of current file
  print("### Binary stats:")
  analyzer.print_stats()
  analyzer.save_stats()

  # Save stats as a zipped file and publish to aws
  if isLocal:
    print("### Local run, do not upload to S3.")

    if args.baseline is not None:
      with open(args.baseline, 'r') as input:
        baseline = json.load(input)

      def compare(baseValue, sourceValue, percent):
        diff = abs(baseValue - sourceValue)
        result = 100.0 * diff / baseValue
        return result < percent

      keys = ["binary_size", "MapboxMaps_iphoneos_arm64", "MapboxMaps_iphonesimulator_x86_64", "MapboxMaps_iphonesimulator_arm64"]

      # Recursively compare the values for the keys above, and fail if the size difference is
      # more than X% (in either direction)
      def compare_dictionaries(base, source):
        for key, basevalue in base.items():

          sourcevalue = source[key]

          if type(basevalue) is dict:
            result = compare_dictionaries(basevalue, sourcevalue)
            if result != 0:
              return result

          # Only interested in the keys above
          if key not in keys:
            continue

          # Missing entry is not expected
          if sourcevalue is None:
            return 1

          # Nor is a different type
          if type(basevalue) != type(sourcevalue):
            return 2

          if type(basevalue) is int:
            if compare(basevalue, sourcevalue, args.baseline_tolerance) == False:
              print(f"Current value ({sourcevalue}) exceeded tolerance ({args.baseline_tolerance}) for key={key}, base={basevalue}")
              return 3

        return 0

      result = compare_dictionaries(baseline, analyzer.stats)
      print("Comparison against baseline:", result)
      exit(result)

  else:
    print("### Uploading to S3.")
    analyzer.publish_stats()

    # Final cleanup, will remove all temporary files
    analyzer.cleanup()

  exit(0)