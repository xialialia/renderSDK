#!/usr/bin/env python
## create by shen,2018.12.28
import os,sys,time
import subprocess
import argparse
import HfsBase

def SetArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-project', type=str, required=True, help='.hip file to load')
    parser.add_argument('-task', type=str, required=True, help='the asset file .json path')
    parser.add_argument('-asset', type=str, required=True, help='the asset file .json path')
    parser.add_argument('-tips', type=str, required=True, help='the asset file .json path')
    args = parser.parse_args()
    # print(args)
    return args

if __name__ == "__main__":
    print("\n")
    print("-"*80)
    print("Python version: %s"%sys.version)
    print("\n")
    HfsBase.hfsMain(SetArgs())
