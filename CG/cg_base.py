# -*-coding: utf-8 -*-
from __future__ import print_function
from __future__ import division
import os
import time
import logging
import traceback

from rayvision_SDK.CG import util
from rayvision_SDK.CG import tips_code
from rayvision_SDK.CG.tips import Tips
from rayvision_SDK.CG.cmd import Cmd
from rayvision_SDK.CG.zip7z import Zip7z
from rayvision_SDK.CG.exception import *
from rayvision_SDK.CG.message import *


class CGBase(object):
    def __init__(self, cg_file, job_info, cg_id, custom_exe_path):
        self.name = None
        self.exe_path = None
        self.version = None
        self.version_str = None
        self.cg_file = cg_file
        self.job_info = job_info
        self.cg_id = cg_id
        self.custom_exe_path = custom_exe_path

        self.task_json = None
        self.asset_json = None
        self.tips_json = None
        self.upload_json = None

        self.cmd = Cmd()
        self.zip7z = Zip7z(exe_path=job_info._zip_path)
        self.tips = Tips(save_path=job_info._work_dir)

        # handle `user_input`
        user_id = self.job_info._task_info["task_info"]["user_id"]
        user_parent_id = int(user_id) // 500 * 500
        self.user_input = "{}/{}".format(user_parent_id, user_id)

        self.log = None
        self.init_logging()

    def __repr__(self):
        return "\n".join(['{}={}'.format(k, v) for k, v in self.__dict__.items()])

    def init_logging(self):
        log_path = self.job_info._log_dir
        f = '%(asctime)s %(levelname)s [%(name)s] %(filename)s +%(lineno)d: \n%(message)s'
        today = time.strftime('%Y-%m-%d', time.localtime())
        name = "analyse" + today

        if log_path is None:
            filename = None
        else:
            if not os.path.exists(log_path):
                os.makedirs(log_path)
            filename = os.path.join(log_path, name)

        log = logging.getLogger("analyse")
        fm = logging.Formatter(f)
        log.setLevel(logging.DEBUG)
        if filename:
            handler = logging.FileHandler(filename, encoding="utf-8")
            handler.setFormatter(fm)
            log.addHandler(handler)

        console = logging.StreamHandler()
        console.setFormatter(fm)
        console.setLevel(logging.INFO)
        log.addHandler(console)
        self.log = log

    def pre_analyse_custom_script(self):
        # TODO
        local_os = self.job_info._local_os
        programdata_path = os.getenv("programdata")
        if local_os == "Windows":
            pre = os.path.join(programdata_path, r"Rayvision\RenderBus SDK", "pre.bat")

        else:
            pre = os.path.join(programdata_path, r"Rayvision\RenderBus SDK", "pre.sh")
        # run pre
        pass

    def valid(self):
        self.log.debug("run CG.valid")
        software_config = self.job_info._task_info["software_config"]
        cg_version = software_config["cg_version"]
        cg_name = software_config["cg_name"]
        if (cg_name.capitalize() != self.name.capitalize()) or (cg_version != self.version):
            self.tips.add(tips_code.cg_notmatch, self.version_str)
            self.tips.save()
            raise VersionNotMatchError(version_not_match)

    def dump_task_json(self):
        self.log.debug("run CG.dump_task_json")
        task_json = self.job_info._task_info
        util.json_save(self.job_info._task_json_path, task_json, ensure_ascii=False)

    def run(self):
        raise NotImplementedError("You should override this method")

    def exe_path_from_location(self, location, exe_name):
        exe_path = None
        if location is not None:
            exe_path = os.path.join(location, exe_name)
            if not os.path.exists(exe_path):
                self.log.debug(exe_path)
                return None
            else:
                pass
        return exe_path

    def load_output_json(self):
        task_path = self.job_info._task_json_path
        asset_path = self.job_info._asset_json_path
        tips_path = self.job_info._tips_json_path

        task_json = self.json_load(task_path)
        asset_json = self.json_load(asset_path)
        tips_json = self.json_load(tips_path)

        self.task_json = task_json
        self.job_info._task_info = task_json

        self.asset_json = asset_json
        self.job_info._asset_info = asset_json

        self.tips_json = tips_json
        self.job_info._tips_info = tips_json

    def json_load(self, json_path, encodings=None):
        if encodings is None:
            encodings = ["utf-8"]
        d = {}
        for index, encoding in enumerate(encodings):
            try:
                d = util.json_load(json_path, encoding=encoding)
                break
            except Exception as e:
                if index == len(encodings) - 1:
                    self.log.error("error load: {}\n{}".format(json_path, traceback.format_exc()))
                d = {}
                continue
                
        return d

    def write_cg_path(self):
        """把 cg_file 和 cg_id 写进 task_info"""
        cg_id = self.cg_id
        cg_file = self.cg_file
        task_info = self.job_info._task_info["task_info"]
        task_info["input_cg_file"] = cg_file.replace("\\", "/")
        task_info["cg_id"] = cg_id

        util.json_save(self.job_info._task_json_path, self.job_info._task_info, ensure_ascii=False)

    def json_exist(self):
        """如果没有生成 json 文件, 判断分析失败"""
        task_path = self.job_info._task_json_path
        asset_path = self.job_info._asset_json_path
        tips_path = self.job_info._tips_json_path

        for p in [task_path, asset_path, tips_path]:
            if not os.path.exists(p):
                msg = "Json file is not generated: {}".format(p)
                return False, msg
        return True, None
