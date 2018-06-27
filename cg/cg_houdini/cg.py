# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import re
import time
import sys
import logging as log
import traceback

try:
    import _winreg
except ImportError:
    import winreg as _winreg

from rayvision_SDK.CG.cg_base import CGBase
from rayvision_SDK.CG import util
from rayvision_SDK.CG import tips_code
from rayvision_SDK.CG.exception import *
from rayvision_SDK.CG.message import *

VERSION = sys.version_info[0]
basedir = os.path.abspath(os.path.dirname(__file__))
"""
D:/Program Files/Side Effects Software/Houdini 16.5.268/bin/hython.exe D:/api/HfsBase.py -project "E:/houdini_test/sphere.hip" -task "D:/api/out/task.json" -asset "D:/api/out/asset.json" -tips "D:/api/out/tips.json"
"""


class Houdini(CGBase):
    def __init__(self, *args, **kwargs):
        super(Houdini, self).__init__(*args, **kwargs)
        self.exe_name = "hython.exe"
        self.name = "Houdini"

        self.init()

    def init(self):
        pass

    def location_from_reg(self, version):
        version_str = "{} {}".format(self.name, version)

        location = None

        string = 'SOFTWARE\Side Effects Software\{}'.format(version_str)
        log.info(string)
        try:
            handle = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, string)
            location, type = _winreg.QueryValueEx(handle, "InstallPath")
            log.info("{} {}".format(location, type))

        except FileNotFoundError as e:
            msg = traceback.format_exc()
            log.error(msg)

        return location

    @staticmethod
    def get_save_version(hipfile=""):
        if os.path.exists(hipfile):
            with open(hipfile, "rb") as hipf:
                not_find = True
                search_elm = 2
                search_elm_cunt = 0
                while not_find:
                    line = str(hipf.readline()).encode("utf-8")
                    if "set -g _HIP_SAVEVERSION = " in str(line):
                        # print(str(line))
                        pattern = re.compile("\d+\.\d+\.\d+\.?\d+")
                        _HV = pattern.findall(str(line))
                        _hfs_save_version = _HV[0]
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
            _hfs_save_version, _hip_save_val = ("", "")
        return _hfs_save_version, _hip_save_val

    def pre_analyse_custom_script(self):
        super(Houdini, self).pre_analyse_custom_script()

    def analyse_cg_file(self):
        version = self.get_save_version(self.cg_file)[0]
        log.info("version: {}".format(version))
        self.version_str = "{} {}".format(self.name, version)

        location = self.location_from_reg(version)
        exe_path = self.exe_path_from_location(os.path.join(location, "bin"), self.exe_name)
        if exe_path is None:
            self.tips.add(tips_code.cg_notexists, self.version_str)
            self.tips.save()
            raise CGExeNotExistError(error9899_cgexe_notexist.format(self.name))

        self.exe_path = exe_path

    def valid(self):
        super(Houdini, self).valid()

    def dump_task_json(self):
        super(Houdini, self).dump_task_json()

    def analyse(self):
        script_full_path = os.path.join(os.path.dirname(__file__), "HfsBase.py")
        task_path = self.job_info._task_json_path
        asset_path = self.job_info._asset_json_path
        tips_path = self.job_info._tips_json_path

        cmd = '"{exe_path}" "{script_full_path}" -project "{cg_file}" -task "{task_path}" -asset "{asset_path}" -tips "{tips_path}"'.format(
            exe_path=self.exe_path,
            script_full_path=script_full_path,
            cg_file=self.cg_file,
            task_path=task_path,
            asset_path=asset_path,
            tips_path=tips_path,
        )
        returncode, stdout, stderr = self.cmd.run(cmd, shell=True)

    def load_output_json(self):
        # super().load_output_json()
        super(Houdini, self).load_output_json()

    def handle_analyse_result(self):
        upload_asset = []

        asset_json = self.asset_json
        assets = asset_json["asset"]
        for asset_dict in assets:
            path_list = asset_dict["path"]

            for path in path_list:
                d = {}
                local = path
                server = util.convert_path(self.user_input, local)
                d["local"] = local
                d["server"] = server
                upload_asset.append(d)

        # 把 cg 文件加入 upload.json
        upload_asset.append({
            "local": self.cg_file,
            "server": util.convert_path(self.user_input, self.cg_file)
        })

        upload_json = {}
        upload_json["asset"] = upload_asset

        self.upload_json = upload_json
        self.job_info._upload_info = upload_json

        util.json_save(self.job_info._upload_json_path, upload_json)

    def write_cg_path(self):
        # super().write_cg_path()
        super(Houdini, self).write_cg_path()

    def post_analyse_custom(self):
        pass

    def run1(self):
        # run a custom script if exists
        self.pre_analyse_custom_script()
        # 获取场景信息
        self.analyse_cg_file()
        # 基本校验（项目配置的版本和场景版本是否匹配等）
        self.valid()
        # 把 job_info._task_info dump 成文件
        self.dump_task_json()
        # 运行CMD启动分析（通过配置信息找CG所在路径,CG所在路径可定制）
        self.analyse()
        # 把分析结果的三个json读进内存
        self.load_output_json()
        # 写任务配置文件（定制信息，独立的上传清单）, 压缩特定文件（压缩文件，上传路径，删除路径）
        self.handle_analyse_result()
        # 把 cg_file 和 cg_id 写进 task_info
        self.write_cg_path()
        #
        self.post_analyse_custom()

    def run(self):
        version = "16.0.504.20"
        self.analyse_cg_file()
        # self.analyse()
