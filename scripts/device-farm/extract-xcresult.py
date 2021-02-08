#!/usr/bin/python3
import os, sys, subprocess, argparse, json, glob, zipfile,shutil

def parse_xcresult(xcresult_path):
    # This can occassionally fail with
    # The folder “action.xccovarchive” doesn’t exist
    try:
        response = subprocess.check_output(['xcrun', 'xcresulttool', 'get', '--format', 'json',
                                            '--path', xcresult_path], stderr=subprocess.STDOUT, universal_newlines=True)
        print(response)

    except subprocess.CalledProcessError as e:
        print("Error getting json:", e)


def xcresult_paths_from_zip(filepath):
    directory = os.path.dirname(filepath)

    with zipfile.ZipFile(filepath,"r") as zip_ref:
        zip_ref.extractall(directory)

    test_runs = glob.iglob(directory+'/**/*.xcresult', recursive=True)
    test_runs_array = [path for path in test_runs] 

    # Coverage profdata too
    coverages =  glob.iglob(directory+'/**/Coverage.profdata', recursive=True)
    coverage_array = [path for path in coverages]
    test_runs_array.extend(coverage_array)

    return test_runs_array
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Gather xcresult folders under an output directory')
    parser.add_argument('--outdir', default='testruns')

    args = parser.parse_args()

    results = []

    for filepath in glob.iglob('**/Customer_Artifacts.zip', recursive=True):
        xcresults = xcresult_paths_from_zip(filepath)
        results.extend(xcresults)

    for result in results:
        newpath = os.path.join(args.outdir, os.path.basename(result))
        shutil.rmtree(newpath, ignore_errors=True) #, ignore_errors=False,
        os.renames(result, newpath)

        # parse_xcresult(newpath)

