# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import time
import sys
import glob
import shutil
from pprint import pprint
import traceback

try:
    import _winreg
except ImportError:
    import winreg as _winreg

from rayvision_SDK.rayvision_cg.cg_base import CGBase
from rayvision_SDK import util
from rayvision_SDK import tips_code
from rayvision_SDK.exception import *
from rayvision_SDK.message import *

VERSION = sys.version_info[0]


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
        print(string)
        try:
            handle = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, string)
            location, type = _winreg.QueryValueEx(handle, "InstallPath")
            print(location, type)

        except FileNotFoundError as e:
            traceback.print_exc()

        return location

    def pre_analyse_custom_script(self):
        super(Houdini, self).pre_analyse_custom_script()

    def analyse_cg_file_info(self):
        version = "16.0.504.20"
        version = str(version)
        self.version = str(version)
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
        script_full_path = os.path.join(os.path.dirname(__file__), "analyse.py")
        output_path = r"D:\scripts\script3\rayvision_SDK\7777"
        # cmd = '"D:/plugins/houdini/160504/bin/hython.exe c:/script/new_py/CG/Houdini/script/analyse.py -project "E:/houdini_maya/houdini_maya/untitled.hip" -outdir "c:/work/render/4431""'
        # TODO 接收3个json文件路径
        cmd = '"{exe_path}" "{script_full_path}" -project "{cg_file}" -outdir "{output_path}"'.format(
            exe_path=self.exe_path,
            script_full_path=script_full_path,
            cg_file=self.cg_file,
            output_path=output_path,
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
        self.job_info.upload_info = upload_json

        util.json_save(self.job_info.upload_json_path, upload_json)

    def write_cg_path(self):
        # super().write_cg_path()
        super(Houdini, self).write_cg_path()

    def post_analyse_custom(self):
        pass

    def run1(self):
        # run a custom script if exists
        self.pre_analyse_custom_script()
        # 获取场景信息
        self.analyse_cg_file_info()
        # 基本校验（项目配置的版本和场景版本是否匹配等）
        self.valid()
        # 把 job_info.task_info dump 成文件
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
        # self.location_from_reg(version)
        self.analyse_cg_file_info()
        self.analyse()
