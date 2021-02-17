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
    print("Gathering from: " + filepath)
    directory = os.path.dirname(filepath)

    with zipfile.ZipFile(filepath,"r") as zip_ref:
        zip_ref.extractall(directory)

    test_runs = glob.iglob(directory+'/**/*.xcresult', recursive=True)
    test_runs_array = [path for path in test_runs] 

    results = []

    # Coverage profdata too
    for xcresult in test_runs_array:
        xcresult_dir = os.path.dirname(xcresult)
        stuff =  glob.iglob(xcresult_dir+'/**/*.profraw', recursive=True)
        coverages = [a for a in stuff]
        try:
            coverage = coverages[0]
            results.append((xcresult, coverage))
        except:
            results.append((xcresult, None))

    return results
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Gather xcresult folders under an output directory')
    parser.add_argument('--outdir', default='testruns')

    args = parser.parse_args()

    results = []

    for filepath in glob.iglob('**/Customer_Artifacts.zip', recursive=True):
        xcresults = xcresult_paths_from_zip(filepath)
        results.extend(xcresults)

    for result in results:
        xcresult = result[0]
        basename = os.path.basename(xcresult)
        stem = os.path.splitext(basename)[0]

        newpath = os.path.join(args.outdir, basename)
        shutil.rmtree(newpath, ignore_errors=True) #, ignore_errors=False,
        print("xcresult: " + newpath)

        os.renames(xcresult, newpath)

        coverage = result[1]
        if coverage is not None:
            newpath = os.path.join(args.outdir, stem + ".profraw")
            shutil.rmtree(newpath, ignore_errors=True) #, ignore_errors=False,
            os.renames(coverage, newpath)
            print("coverage: " + newpath)
