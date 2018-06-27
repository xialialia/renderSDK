#!/usr/bin/env python
#encoding:utf-8
# -*- coding: utf-8 -*-
## create by shen,2018.06.22
import os,sys,time
import subprocess
import argparse
import HfsSql
# import socket
# import shutil
# import platform
import re,json
import hou

class HfsBase():

    def __init__(self,args):
        # print(args)
        self._args = args
        # print("_args",self._args)
        self._ext = [".py"]
        self.CreateBasedate()

    def CreateBasedate(self):
        _temp_path = os.path.dirname(sys.argv[0])
        self._temp_path = "%s/data_tl.db"%_temp_path.replace("\\","/")
        # print(self._temp_path)
        new_data = True if not os.path.exists(self._temp_path) else False

        ## preset the date ,such as table named:ReFerType,node type ,just input "file"
        self._refer_table = "ReFerType"
        self._sl,self._cur =HfsSql.connectsl(self._temp_path,self._refer_table)
        if new_data: HfsSql.insertToTable(self._sl,self._cur,self._refer_table,["TYPES"],["file"])

        ## check result
        if 0:
            cursor = HfsSql.getTableInfo(self._cur,self._refer_table,["TYPES"])
            ## get typelist
            for elm in cursor:
                if elm[0] == "file":
                    print("elm",elm[0])
        self.GetNodeTypeData()

    def GetNodeTypeData(self):

        cursor = HfsSql.getTableInfo(self._cur,self._refer_table,["TYPES"])
        ## get typelist
        self._typelist = []
        for elm in cursor:
            # print("elm",elm)
            self._typelist.append(elm[0])
        print_times(self._typelist)

    def loadhipfile(self):

        self.hip_file=self._args.project
        if os.path.exists(self.hip_file):
            print_times ("Loading hip file: %s" % self.hip_file)
            try:
                hou.hipFile.load(self.hip_file)
                print_times ("Loading hip file success")

            except (IOError ,ZeroDivisionError),e:
                print_times (e)
        else:
            print_times ("ERROR: the hip file is not exist!")
            sys.exit(1)


    
    @staticmethod
    def GetSaveVersion(hipfile=""):
        if os.path.exists(hipfile):
            with open(hipfile, "rb") as hipf:
                Not_find = True
                search_elm = 2
                search_elm_cunt = 0
                while Not_find:
                    line = str(hipf.readline()).encode("utf-8")
                    if "set -g _HIP_SAVEVERSION = " in  str(line):
                        # print(str(line))
                        pattern = re.compile("[\d+\d+\d+]")
                        _HV = pattern.findall(str(line))
                        if len(_HV)>6: _HV = _HV[:6]
                        _hfs_save_version = int(''.join(elm for elm in _HV))
                        _hfs_save_version = "%s.%s.%s" % (str(_hfs_save_version)[:2],
                                      str(_hfs_save_version)[2:3],str(_hfs_save_version)[3:])
                        search_elm_cunt += 1

                    # The $HIP val with this file saved
                    if "set -g HIP = " in  str(line):
                        pattern = re.compile("\\'.*\\'") if sys.version[:1]=="2" else re.compile(r"\\'.*\\'")
                        _Hip = pattern.search(str(line)).group()
                        _hip_save_val = _Hip.split("\'")[1].replace("\\","/")
                        search_elm_cunt += 1
                    if search_elm_cunt >= search_elm:
                        Not_find = False
        else:
            print("The .hip file is not exist.")
            _hfs_save_version,_hip_save_val = ("","")
        return _hfs_save_version,_hip_save_val

    def GetAssets(self):
        ## eg. asset = {"Normal":{"node1":["files"],"node2":["files"]},
        ##                    "Miss":{"node1":["files"],"node2":["files"]}}
        Miss_adict = {}
        Normal_adict = {}
        file_adict = hou.fileReferences()
        for elm in file_adict:
            if self.isFile(elm[0].eval()):
                if elm[0].name() in self._typelist:
                    if self.isFile(elm[-1]):
                        if not os.path.exists(elm[0].eval()):
                            node_path = elm[0].node().path()
                            if node_path not in Miss_adict:
                                Miss_adict[node_path] = [elm[0].eval()]
                            else:
                                Miss_adict[node_path].append(elm[0].eval())
                        else:
                            node_path = elm[0].node().path()
                            if node_path not in Normal_adict:
                                Normal_adict[node_path] = [elm[0].eval()]
                            else:
                                Normal_adict[node_path].append(elm[0].eval())
                    else:
                        print_times(elm)

                elif len(elm[-1]):
                    # print(os.path.splitext(elm[-1]))
                    if not os.path.splitext(elm[-1])[-1] in self._ext:
                        HfsSql.insertToTable(self._sl,self._cur,self._refer_table,["TYPES"],[elm[0].name()])
                        self._typelist.append(elm[0].name())


        self.asset_adict = {"Normal":Normal_adict,"Miss":Miss_adict}
        self.task_adict = {}
        self.tips_adict = {}
        # print(self.asset_adict)
        self.WriteFile(self.asset_adict,self._args.asset,'json')
        self.WriteFile(self.task_adict,self._args.task,'json')
        self.WriteFile(self.tips_adict,self._args.tips,'json')

    @staticmethod
    def isFile(pathvale):
        isFilepath = False
        persent = 0
        drive_spl = os.path.splitdrive(pathvale)
        ext_spl = os.path.splitext(pathvale)
        along_spl = os.path.split(pathvale)
        if pathvale.replace("\\","/").startswith("//"):persent += 7
        if len(drive_spl[0]) and len(drive_spl[-1]):persent += 7
        if "/" in along_spl[0].replace("\\","/"):
            persent += 4
            ss = re.findall("[/*,//]",ext_spl[0].replace("\\","/"))
            if len(ss)>1:persent += 1
        if len(ext_spl[-1]):persent += 5
        if persent>9:isFilepath = True
        # print("persent",persent)
        # print(drive_spl)
        # print(ext_spl)
        # print(along_spl)

        return isFilepath

    @staticmethod
    def WriteFile(info="",file="",types='txt'):
        if types == 'txt':
            with open(file,"w") as f:
                f.write(info)
                f.close()
        elif types == 'json':
            with open(file,"w")as f:
                json.dump(info,f)
                f.close()
        print_times("Infomations write to %s" %file)

def SetArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-project', type=str, required=True, help='.hip file to load')
    parser.add_argument('-task', type=str, required=True, help='the asset file .json path')
    parser.add_argument('-asset', type=str, required=True, help='the asset file .json path')
    parser.add_argument('-tips', type=str, required=True, help='the asset file .json path')
    args = parser.parse_args()
    # print(args)
    return args

def hfsMain(args):
    hfs_job = HfsBase(args)
    print_times('Load hip file start...')
    try:
        hfs_job.loadhipfile()
    except:
        print_times('Load hip ignore Errors.')
    print_times('Load hip file end.')

    sys.stdout.flush()
    time.sleep(1)
    
    hfs_job.GetAssets()

def print_times(info):
    time_point=time.strftime("%b_%d_%Y %H:%M:%S", time.localtime())
    print("[%s] %s"%(time_point,str(info)))

if __name__ == "__main__":
    print(sys.argv[0])
    print("-"*60)
    print("Python version: %s"%sys.version)
    print("\n")
    hfsMain(SetArgs())    