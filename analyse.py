# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import sys
import traceback
import argparse

from rayvision_SDK.rayvision_cg import *
from rayvision_SDK.exception import *


class RayvisionAnalyse(object):
    def __init__(self, job_info, cg_file, exe_path=None, type=None):
        print("start analyse")
        self.job_info = job_info
        self.cg_file = cg_file
        self.g_exe_path = exe_path   # TODO ??? todo
        self.type = type
        self.cg_class = None
        self.cg_instance = None
        self.cg_id = None

        self.init()

    def init(self):
        cg_file = self.cg_file
        if not os.path.exists(cg_file):
            raise CGFileNotExistsError("Cg file does not exist: {}".format(self.cg_file))

        types = {
            ".max": "Max",
            ".mb": "Maya",
            ".ma": "Maya",
            ".hip": "Houdini",
            ".c4d": "C4D",
        }
        ext = os.path.splitext(cg_file)[-1]
        if ext is not None and ext.startswith("."):
            self.type = types.get(ext.lower(), None)
        else:
            raise RayvisionError("Not a cg file.")
        if self.type is None:
            raise RayvisionError("Unable to determine cg file type.")
        objs = {
            "Max": (Max, "2001"),
            "Maya": (Maya, "2000"),
            "Houdini": (Houdini, "2004"),
            "C4D": (C4D, "2005"),
        }
        # init CG software
        self.cg_class, self.cg_id = objs[self.type]
        self.cg_instance = self.cg_class(cg_file, self.job_info, self.cg_id)

    @classmethod
    def analyse(cls, cg_file, job_info, exe_path=None):
        """
        入口.
        :param cg_file:
        :param job_info:
        :param exe_path: 用户可手动指定 cg 软件的exe路径.如有则直接用这个路径, 无则自己找. # TODO "直接用这个路径"
        :return:
        """
        self = cls(job_info, cg_file, exe_path)
        self.run()

    def run(self):
        self.cg_instance.run()
