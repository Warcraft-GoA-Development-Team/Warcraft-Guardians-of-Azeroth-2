#!/usr/bin/env python
import argparse
import shutil
import os
from pathlib import Path
from sys import stderr
from enum import Enum

import glob
from PIL import Image
from git import Repo, DiffIndex, InvalidGitRepositoryError

#
# Enums
#

class MainExitCode(int, Enum):
    SUCCESS       = 0
    UNKNOWN_ERROR = 1
    MISSING_FILE  = 2
    OS_ERROR      = 3
    GIT_ERROR     = 4

#
# Constants
#

CLI_DESCRIPTION = f"""
Applies lossless RLE compression to TGA image file(s) given as one or more command line arguments.
Each argument can be a file path or a glob.

If run with --git-hook, only compresses the files currently staged for commit and re-stages them.
"""

BACKUP_FILE_SUFFIX = '.bak'

#
# Command line arguments
#

def parse_cli_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=CLI_DESCRIPTION, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument('raw_tga_paths', metavar='TGA_PATHS', nargs='+', type=str, help='TGA file paths or globs')
    parser.add_argument('-m', '--allow-missing', action='store_true', dest='allow_missing', help="don't fail on non-existing paths")
    parser.add_argument('-g', '--git-hook', action='store_true', dest='is_git_hook', help='only compress (and re-stage) files currently staged for commit')
    #parser.add_argument('-v', '--verbose', action='store_true', dest='is_verbose', help='print detailed logs to stdout')

    return parser.parse_args()

#
# Service
#

def extract_changed_paths(diff_index: DiffIndex) -> set[Path]:
    modified_diff_entries = filter(lambda diff_entry: diff_entry.change_type == 'M' or diff_entry.change_type == 'A', diff_index)
    return set(map(lambda diff_entry: Path(diff_entry.b_path), modified_diff_entries))

def backup_file(file_path: Path) -> Path:
    backup_file_path = file_path.with_suffix(BACKUP_FILE_SUFFIX)
    shutil.copyfile(file_path, backup_file_path)
    return backup_file_path

# Main
#

def main():
    args = parse_cli_args()

    try:
        repo = Repo() if args.is_git_hook else None
        if repo is not None and repo.bare:
            print(f"Error: cannot use this utility inside of a bare repo", file=stderr)
            exit(MainExitCode.GIT_ERROR)
    except InvalidGitRepositoryError:
        assert args.is_git_hook
        print(f"Error: cannot use --git-hook outside of a Git repo", file=stderr)
        exit(MainExitCode.GIT_ERROR)

    unstaged_changed_paths = None
    staged_changed_paths   = None
    if args.is_git_hook:
        assert repo is not None
        unstaged_changed_paths = extract_changed_paths(repo.index.diff(None))
        staged_changed_paths   = extract_changed_paths(repo.index.diff("HEAD"))

    tga_paths = set()

    for raw_tga_path in args.raw_tga_paths:
        glob_tga_paths = set(map(lambda pathlike: Path(pathlike), glob.glob(raw_tga_path)))
        if len(glob_tga_paths) <= 0:
            if args.allow_missing:
                print(f"Warning: no files matched for {raw_tga_path}", file=stderr)
                continue
            else:
                print(f"Error: no files matched for {raw_tga_path}", file=stderr)
                exit(MainExitCode.MISSING_FILE)

        if args.is_git_hook:
            assert isinstance(unstaged_changed_paths, set)
            assert isinstance(staged_changed_paths,   set)
            glob_tga_paths.intersection_update(staged_changed_paths)
            modified_staged_paths = glob_tga_paths.intersection(unstaged_changed_paths)
            if len(modified_staged_paths) > 0:
                modified_staged_path_example = next(iter(modified_staged_paths))
                print(f"Error: {modified_staged_path_example} has both staged and unstaged changes", file=stderr)
                print("Already staged changes in this file would be overwritten.")
                print("Please either stage or discard unstaged changes, then try again.")
                exit(MainExitCode.GIT_ERROR)

        tga_paths.update(glob_tga_paths)

    if len(tga_paths) <= 0:
        assert args.allow_missing or args.is_git_hook
        print(f"No {'staged ' if args.is_git_hook else ''}files matched given paths, nothing to do")
        exit(MainExitCode.SUCCESS)

    tga_paths_count = len(tga_paths)
    print(f"RLE-compressing {tga_paths_count} {'staged ' if args.is_git_hook else ''}TGA file{'s' if tga_paths_count != 1 else ''} matching given path{'s' if len(args.raw_tga_paths) != 1 else ''}:")

    for tga_path in tga_paths:
        print(f"{tga_path} ... ", end='')
        try:
            backup_tga_path = backup_file(tga_path)
            with Image.open(backup_tga_path, formats=['TGA']) as input_tga:
                if "compression" not in input_tga.info or input_tga.info["compression"] != 'tga_rle':
                    input_tga.save(tga_path, format='TGA', compression='tga_rle')
                    print("DONE")
                else:
                    print("SKIPPED (already compressed)")
            try:
                os.remove(backup_tga_path)
            except Exception as e:
                print(f"Warning: failed to remove backup {backup_tga_path}", file=stderr)
        except OSError as e:
            print("FAILED (OS error)")
            print(f"Error: {e}", file=stderr)
            exit(MainExitCode.OS_ERROR)
        except Exception as e:
            print("FAILED (unknown error)")
            print(f"Error: {e}", file=stderr)
            exit(MainExitCode.UNKNOWN_ERROR)

    if args.is_git_hook:
        assert repo is not None
        for restaged_path in map(lambda path: path.as_posix(), tga_paths):
            repo.git.add('-u', '--', str(restaged_path))
        print(f"Re-staged {tga_paths_count} files{'s' if tga_paths_count != 1 else ''}")

if __name__ == '__main__':
    main()
