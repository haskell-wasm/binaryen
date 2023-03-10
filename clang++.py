#!/usr/bin/env python3

import os
import sys

if __name__ == "__main__":
    args = [arg for arg in sys.argv[1:] if not arg in {"-fcolor-diagnostics"}]
    if any(any(arg.endswith(f) for f in {"Precompute.cpp"}) for arg in args):
        compiler = "g++"
        args = [arg for arg in args if not arg.startswith("-flto")]
    else:
        compiler = "clang++"
    os.execvp(compiler, [compiler] + args)
