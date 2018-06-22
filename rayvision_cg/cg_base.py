# -*-coding: utf-8 -*-
from __future__ import print_function
from __future__ import division
import os
import traceback

import util
import tips_code
from tips import Tips
from cmd import Cmd
from zip7z import Zip7z
from exception import *
from message import *


class CGBase(object):
    def __init__(self, cg_file, job_info, cg_id):
        self.name = None
        self.exe_path = None
        self.version = None
        self.version_str = None
        self.cg_file = cg_file
        self.job_info = job_info
        self.tips = Tips(save_path=job_info.json_dir)
        self.cg_id = cg_id

        self.task_json = None
        self.asset_json = None
        self.tips_json = None
        self.upload_json = None

        self.cmd = Cmd()
        self.zip7z = Zip7z(exe_path=job_info.zip_path)

        # handle `user_input`
        user_id = self.job_info.task_info["task_info"]["user_id"]
        user_parent_id = int(user_id) // 500 * 500
        self.user_input = "{}/{}".format(user_parent_id, user_id)

    def __repr__(self):
        return "\n".join(['{}="{}"'.format(k, v) for k, v in self.__dict__.items()])

    def pre_analyse_custom_script(self):
        # TODO
        local_os = self.job_info.local_os
        programdata_path = os.getenv("programdata")
        if local_os == "Windows":
            pre = os.path.join(programdata_path, r"Rayvision\RenderBus SDK", "pre.bat")

        elif local_os == "Linux":
            pre = os.path.join(programdata_path, r"Rayvision\RenderBus SDK", "pre.sh")
        # run pre
        pass

    def valid(self):
        print("run CG.valid")
        software_config = self.job_info.task_info["software_config"]
        cg_version = software_config["cg_version"]
        cg_name = software_config["cg_name"]
        if cg_name.capitalize() != self.name.capitalize() and cg_version != self.version:
            self.tips.add(tips_code.cg_notmatch, self.version_str)
            self.tips.save()
            raise VersionNotMatchError(version_not_match)

    def dump_task_json(self):
        print("run CG.dump_task_json")
        task_json = self.job_info.task_info
        util.json_save(self.job_info.task_json_path, task_json)

    def run(self):
        raise NotImplementedError("You should override this method")

    @staticmethod
    def exe_path_from_location(location, exe_name):
        exe_path = None
        if location is not None:
            exe_path = os.path.join(location, exe_name)
            if not os.path.exists(exe_path):
                print(exe_path)
                return None
            else:
                pass
        return exe_path

    def load_output_json(self):
        task_path = self.job_info.task_json_path
        asset_path = self.job_info.asset_json_path
        tips_path = self.job_info.tips_json_path

        task_json = self.json_load(task_path)
        asset_json = self.json_load(asset_path)
        tips_json = self.json_load(tips_path)

        self.task_json = task_json
        self.job_info.task_info = task_json

        self.asset_json = asset_json
        self.job_info.asset_info = asset_json

        self.tips_json = tips_json
        self.job_info.tips_info = tips_json

    @staticmethod
    def json_load(json_path):
        try:
            d = util.json_load(json_path)
        except Exception as e:
            traceback.print_exc()
            d = {}
        return d

    def write_cg_path(self):
        """把 cg_file 和 cg_id 写进 task_info"""
        cg_id = self.cg_id
        cg_file = self.cg_file
        task_info = self.job_info.task_info["task_info"]
        task_info["input_cg_file"] = cg_file.replace("\\", "/")
        task_info["cg_id"] = cg_id

        util.json_save(self.job_info.task_json_path, self.job_info.task_info)
