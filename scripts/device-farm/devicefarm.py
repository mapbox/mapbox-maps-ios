#!/usr/bin/python3

import argparse
import errno
# import io
import json
import os
import pathlib
import re
import subprocess
import sys
import time
import requests

# import urllib

TESTS_ERRORED = -1
TESTS_FAILED = -2
TESTS_FAILED_BECAUSE_EXCEPTION = -3


def file_system_arn(arn):
    """
    Converts an ARN to a file-system friendly string, so that it can be used for directory &
    file names
    """
    for source, dest in {":": "#", "/": "_", " ": "_"}.items():
        arn = arn.replace(source, dest)
    return arn


def dump_json(json_object):
    print(json.dumps(json_object, sort_keys=True, indent=2))


def write_object_as_json_to_file(json_object, output_file):
    if output_file is not None:
        with open(output_file, 'w') as outfile:
            json.dump(json_object, outfile)
    else:
        dump_json(json_object)


def projects():
    """
    Lists available projects
    See: https://docs.aws.amazon.com/cli/latest/reference/devicefarm/list-projects.html
    """
    try:
        response = subprocess.check_output(['aws', 'devicefarm', 'list-projects',
                                            '--no-paginate',
                                            '--region', 'us-west-2'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(
            e.cmd, e.returncode, e.output))

    # Convert to json
    response = json.loads(response)

    return response


def device_pool(project_arn, pool_type=None):
    """
    Lists available device pools for a project.
    See: https://docs.aws.amazon.com/cli/latest/reference/devicefarm/list-device-pools.html

    If pool_type is not None (e.g 'PRIVATE'), then only device pools of that type will be returned
    """
    try:
        response = subprocess.check_output(['aws', 'devicefarm', 'list-device-pools',
                                            '--arn', project_arn,
                                            '--region', 'us-west-2'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(
            e.cmd, e.returncode, e.output))

    # Convert to json
    response = json.loads(response)

    if type is not None:
        device_pools = response["devicePools"]
        filtered_pools = [
            pool for pool in device_pools if pool["type"] == pool_type]
        response["devicePools"] = filtered_pools

    return response


def wait_for_api_status(request_arn, api, completion_statuses, failure_statuses, delay, timeout=None, verbose=False):
    """
    Wait for an upload/run to complete by polling for a status
    Params:
    - request_arn - ARN for the previous API
    - api - the device farm API without the 'get-' prefix, e.g. if the API is 'get-upload'
      pass 'upload'
    - status - the expected status

    Returns:
    - 0 success
    - 1 failed
    - 2 timeout
    """
    start = time.monotonic()

    response = None
    print("Waiting for " + api, end='')
    while True:
        print('.', end='', flush=True)

        try:
            response = subprocess.check_output(['aws', 'devicefarm', 'get-'+api,
                                                '--arn', request_arn,
                                                '--region', 'us-west-2'], stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            # Credentials can expire during this process locally
            if verbose:
                print("Request ARN:"+request_arn)

                if response is not None:
                    # Dump the previous response, we'll use that.
                    print("Response:")
                    dump_json(response)

            raise RuntimeError("command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, e.output))

        # Convert to object
        response = json.loads(response)
        response_status = response[api]['status']

        duration = time.monotonic() - start

        if response_status in completion_statuses:
            print(api, response_status, "duration=", duration)
            return response

        if response_status in failure_statuses:
            print("Response:")
            dump_json(response)
            raise RuntimeError("wait_for_api_status: "+response_status)

        # Not completed, retrying
        if timeout is not None and duration > timeout:
            print("Response:")
            dump_json(response)
            raise RuntimeError("wait_for_api_status Forced TIMED OUT")

        time.sleep(delay)


def wait_for_upload(arn, verbose=False):
    # Upload status codes are one of:
    #     FAILED
    #     INITIALIZED
    #     PROCESSING
    #     SUCCEEDED
    return wait_for_api_status(arn, "upload", ['SUCCEEDED'], ['FAILED'], delay=15, timeout=300, verbose=verbose)


def wait_for_run(arn, timeout, verbose=False):
    # For a get-run the possible status codes are:
    #   PENDING
    #   PENDING_CONCURRENCY
    #   PENDING_DEVICE
    #   PROCESSING
    #   SCHEDULING
    #   PREPARING
    #   RUNNING
    #   COMPLETED
    #   STOPPING
    return wait_for_api_status(arn, "run", ['COMPLETED'], [], delay=60, verbose=verbose)


def list_artifacts(test_run_arn, output_dir=None, verbose=False):
    """
    Download artifacts with list-artifacts and curl
    https://docs.aws.amazon.com/cli/latest/reference/devicefarm/list-artifacts.html
    """

    try:
        response = subprocess.check_output(['aws', 'devicefarm', 'list-artifacts',
                                            '--arn', test_run_arn,
                                            '--type', 'FILE',
                                            '--region', 'us-west-2'], stderr=subprocess.STDOUT, universal_newlines=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(
            e.cmd, e.returncode, e.output))

    # Convert to python object
    response = json.loads(response)

    # Don't really need to do this. What we're really interested in is the xcresult file
    # but by default this is not included..yet :(
    # That would most likely be of type "CUSTOMER_ARTIFACT"
    if output_dir is not None:
        arn = file_system_arn(test_run_arn)
        output_folder = pathlib.Path(output_dir) / arn
        output_folder.mkdir(parents=True, exist_ok=True)

        filename = output_folder / "list-artifacts.json"
        with open(str(filename), 'w') as f:
            json.dump(response, f, sort_keys=True, indent=2)

        # # Save specific artifacts to
        # # <output-dir>/<run-arn>/<artifact-arn>/<name>.<extension>
        for artifact in response['artifacts']:
            if artifact['type'] in ["CUSTOMER_ARTIFACT", "CUSTOMER_ARTIFACT_LOG", "APPLICATION_CRASH_REPORT", "TESTSPEC_OUTPUT"]:
                artifact_arn = file_system_arn(artifact['arn'])
                artifact_folder = output_folder / artifact_arn
                artifact_folder.mkdir(parents=True, exist_ok=True)

                filename = artifact['name'] + "." + artifact['extension']
                filename = file_system_arn(filename)
                filename = artifact_folder / filename

                if verbose:
                    print("Downloading from", artifact["url"])

                download_url = artifact["url"]

                # Was using curl because of cert issues, but that seems ok now
                r = requests.get(download_url)
                with open(filename, 'wb') as f:
                    f.write(r.content)

                # Using curl because of cert issues
                # subprocess.check_output(['curl', '-o', str(filename), download_url], stderr=subprocess.STDOUT)

    if verbose:
        dump_json(response)


def generate_dashboard_url(run_arn):
    # TODO: add this function in correctly.
    # e.g. arn:aws:devicefarm:us-west-2:234858372212:run:0b153413-cf67-4192-9ae3-fbe93cda6ea2/7db70c2d-7397-4175-b32a-8e22639a9dd3
    # (arn:aws:devicefarm:).+(:run:)(project-number)/(run-number)
    # URL -> https://us-west-2.console.aws.amazon.com/devicefarm/home?region=us-east-1#/projects/(project)/runs/(run)

    m = re.search(r'.*:run:([\-0-9a-f]*)/([\-0-9a-f]*)', run_arn)
    url = "https://us-west-2.console.aws.amazon.com/devicefarm/home?region=us-east-1#/projects/" + \
        m.group(1)+"/runs/"+m.group(2)
    return url


class Project:
    def __init__(self, name, arn, timeout, artifact_dir=None, verbose=False, test_type='XCTEST', device_pool_arn=None, output_file=None):
        self.name = name
        self.project_arn = arn
        self.timeout = timeout
        self.artifact_dir = artifact_dir
        self.verbose = verbose
        self.test_type = test_type
        self.list_artifacts = list_artifacts
        self.output_file = output_file

        if device_pool_arn is None:
            pools = device_pool(arn, 'PRIVATE')
            self.device_pool_arn = pools["devicePools"][0]["arn"]
        else:
            self.device_pool_arn = device_pool_arn

        if verbose:
            print("Device Pool: " + self.device_pool_arn)

    def create_upload(self, uploadType, inputFilename, outputFilename=None):
        """
        Upload application to AWS Device Farm using create-upload and curl
        https://docs.aws.amazon.com/cli/latest/reference/devicefarm/create-upload.html
        https://docs.aws.amazon.com/cli/latest/reference/devicefarm/get-upload.html

        uploadType is one of:
        - 'IOS_APP' (ipa)
        - 'XCTEST_TEST_PACKAGE' (zipped xctests)
        - 'XCTEST_UI_TEST_SPEC'
        """

        _, filename = os.path.split(inputFilename)

        try:
            response = subprocess.check_output(['aws', 'devicefarm', 'create-upload',
                                                '--project-arn', self.project_arn,
                                                '--name', filename,
                                                '--type', uploadType,
                                                '--region', 'us-west-2'], stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            raise RuntimeError("command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, e.output))

        # Convert to object
        response = json.loads(response)

        if self.verbose:
            dump_json(response)

        if outputFilename is not None:
            with open(outputFilename, 'w') as f:
                json.dump(response, f)

        # Upload
        subprocess.check_output(
            ['curl', '-T', inputFilename, response['upload']['url']], stderr=subprocess.STDOUT)

        return response

    def schedule_run(self, app_package_arn, test_package_arn, test_spec_arn, outputFilename=None):
        """
        Schedule a test on AWS Device Farm
        https://docs.aws.amazon.com/cli/latest/reference/devicefarm/schedule-run.html
        """

        test = 'type='+self.test_type

        if test_package_arn is not None:
            test += ',testPackageArn='+test_package_arn

        if test_spec_arn is not None:
            test += ',testSpecArn='+test_spec_arn

        aws_command = ['aws', 'devicefarm', 'schedule-run',
                                            '--project-arn', self.project_arn,
                                            '--configuration', 'customerArtifactPaths={iosPaths=["Documents"]}',
                                            '--device-pool-arn', self.device_pool_arn,
                                            '--name', self.name,
                                            '--test', test,
                                            '--region', 'us-west-2']

        if app_package_arn is not None:
            aws_command.extend(['--app-arn', app_package_arn])

        try:
            response = subprocess.check_output(aws_command, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            raise RuntimeError("command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, e.output))

        response = json.loads(response)

        if self.verbose:
            dump_json(response)

        if outputFilename is not None:
            with open(outputFilename, 'w') as f:
                json.dump(response, f)

        return response

    def continue_test(self, run_response):
        run_arn = run_response["run"]["arn"]

        try:
            # timeout can be None here, which means "just keep going until AWS has done"
            results = wait_for_run(run_arn, self.timeout, self.verbose)

            if self.artifact_dir is not None:
                write_object_as_json_to_file(results, self.output_file)

            # Show artifacts
            list_artifacts(run_arn, self.artifact_dir, self.verbose)

            # counters look like:
            # "counters": {
            #     "errored": 0,
            #     "failed": 0,
            #     "passed": 24,
            #     "skipped": 0,
            #     "stopped": 0,
            #     "total": 24,
            #     "warned": 0
            # },

            counters = results["run"]["counters"]
            total = counters["total"]
            passed = counters["passed"]
            failed = counters["failed"]

            dump_json(counters)

            print("Dashboard:", generate_dashboard_url(run_arn))

            # With Fuzz tests, things seem to be a bit janky. (Devices not starting, fuzz being skipped)
            # With these tests (and others) we may want to loosen the requirements for "success"
            if total == passed:
                return 0
            
            if failed > 0:
                return TESTS_FAILED
            
            return TESTS_ERRORED

        except BaseException as e:
            print("Run", run_arn, "Test failed:", e)

            return TESTS_FAILED_BECAUSE_EXCEPTION

    def schedule_test(self, ipa_filename, xctest_filename, test_spec_filename):

        # Upload the test package
        test_package_type = None
        test_spec_type = None
        ipa_upload_arn = None

        # NOTE: AWS Device Farm has suggested using APPIUM_NODE as the test type to upload
        # the test spec yaml file. This may avoid the need to also pass the test app twice,
        # in the case of running with a custom yaml file.
        if self.test_type == 'XCTEST':
            test_package_type = 'XCTEST_TEST_PACKAGE'
        elif self.test_type == 'XCTEST_UI':
            test_package_type = 'XCTEST_UI_TEST_PACKAGE'
            test_spec_type = 'XCTEST_UI_TEST_SPEC'
        elif self.test_type == 'APPIUM_NODE':
            test_package_type = 'APPIUM_NODE_TEST_PACKAGE'
            test_spec_type = 'APPIUM_NODE_TEST_SPEC'

        # Upload the IPA
        if ipa_filename is not None:
            ipa_upload_response = self.create_upload("IOS_APP", ipa_filename)
            ipa_upload_arn = ipa_upload_response["upload"]["arn"]
            try:
                wait_for_upload(ipa_upload_arn, self.verbose)
            except BaseException as e:
                print("Wait for app upload failed: ", e)
                return TESTS_FAILED_BECAUSE_EXCEPTION

        # Upload the test package
        xctest_upload_arn = None

        if test_package_type is not None:
            xctest_upload_response = self.create_upload(
                test_package_type, xctest_filename)
            xctest_upload_arn = xctest_upload_response["upload"]["arn"]
            try:
                wait_for_upload(xctest_upload_arn, self.verbose)
            except BaseException as e:
                print("Wait for test upload failed: ", e)
                return TESTS_FAILED_BECAUSE_EXCEPTION

        # Upload test-spec
        test_spec_arn = None

        if test_spec_filename is not None and test_spec_type is not None:
            test_spec_response = self.create_upload(
                test_spec_type, test_spec_filename)
            test_spec_arn = test_spec_response["upload"]["arn"]
            try:
                wait_for_upload(test_spec_arn, self.verbose)
            except BaseException as e:
                print("Wait for spec upload failed: ", e)
                return TESTS_FAILED_BECAUSE_EXCEPTION

        # Schedule the test
        run_response = self.schedule_run(
            ipa_upload_arn, xctest_upload_arn, test_spec_arn)

        write_object_as_json_to_file(run_response, self.output_file)

        return 0


if __name__ == "__main__":
    epilog = """
    If your AWS credentials expire during a test run, save the printed run ARN, and then you 
    can continue monitoring the test run by issuing something like:
    
    ./scripts/device-farm.py "Unit Tests" <project arn> --run-arn-file <file> --artifacts-dir=artifacts
    """
    parser = argparse.ArgumentParser(
        description='Script to configure, schedule and AWS Device Farm runs.', epilog=epilog)

# TODO: clean up with multiple parsers
    parser.add_argument('--name', help='Name for this test')
    parser.add_argument('arn', help='Provide AWS Device Farm project ARN')
    parser.add_argument('--ipa', help='Provide path to ipa to test')
    parser.add_argument('--tests', help='Provide path to tests')
    parser.add_argument('--spec', help='Provide path to spec yml file')
    parser.add_argument('--test-type', default='XCTEST', choices=['BUILTIN_FUZZ', 'XCTEST', 'XCTEST_UI', 'APPIUM_NODE'], help='Indicates the type of tests being run; can be one of BUILTIN_FUZZ, XCTEST, XCTEST_UI')
    parser.add_argument('--run-arn-file', help='File of the schedule-run response')
    parser.add_argument('--artifacts-dir', help='Parent directory to dump artifacts JSON. Artifacts are not yet downloaded.')
    parser.add_argument('--verbose', action='store_true', help='More logging')
    parser.add_argument('--timeout', type=float, help="Timeout (in seconds) for the test run script. Default comes from run's jobTimeoutMinutes")
    parser.add_argument('--device-pool', help='Device Pool ARN')
    parser.add_argument('--fail-on-error', action='store_true', default=False, help='If the run "errored" rather than failing, return with an error. Defaults to 0 (no error)')
    parser.add_argument('--output', help='Output file to dump result to (excludes artifacts that may have been downloaded.')

    args = parser.parse_args()

    project = Project(args.name, args.arn, args.timeout, args.artifacts_dir,
                      args.verbose, args.test_type, args.device_pool, args.output)

    if args.run_arn_file is not None:
        with open(args.run_arn_file, 'r') as inputFile:
            run_response = json.load(inputFile)

        result = project.continue_test(run_response)
    else:
        result = project.schedule_test(args.ipa, args.tests, args.spec)

    if result == TESTS_ERRORED and not args.fail_on_error:
        print("Tests errored, but we don't want to fail")
        result = 0

    sys.exit(result)
