#!/usr/bin/env python3
import sys
import argparse
import re


def main(argv):
    parser = argparse.ArgumentParser(description="Replace string in file.")
    parser.add_argument("--old", required=True)
    parser.add_argument("--new", required=True)
    parser.add_argument("file")

    args = parser.parse_args()

    fin = open(args.file, "rt")
    data = fin.read()
    pattern = re.compile(args.old)
    data = re.sub(pattern, args.new, data)
    fin.close()

    fin = open(args.file, "wt")
    fin.write(data)
    fin.close()


if __name__ == "__main__":
    main(sys.argv[1:])
