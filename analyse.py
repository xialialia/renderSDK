# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import sys
import time
import traceback
import argparse
import logging

from rayvision_SDK.CG.cg_houdini.cg import Houdini
from rayvision_SDK.CG.cg_c4d.cg import C4D
from rayvision_SDK.CG.cg_maya.cg import Maya
from rayvision_SDK.CG.cg_max.cg import Max
from .RayvisionException import RayvisionError

basedir = os.path.abspath(os.path.dirname(__file__))


class RayvisionAnalyse(object):
    def __init__(self, job_info, cg_file, exe_path=None, type=None):
        self.job_info = job_info
        self.cg_file = cg_file
        self.custom_exe_path = exe_path
        self.type = type
        self.cg_class = None
        self.cg_instance = None
        self.cg_id = None

        self.init()
        self.init_logging()

    def init(self):
        cg_file = self.cg_file
        if not os.path.exists(cg_file):
            raise RayvisionError(1000000, "Cg file does not exist: {}".format(self.cg_file))

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
            raise RayvisionError(1000000, "Not a cg file.")
        if self.type is None:
            raise RayvisionError(1000000, "Unable to determine cg file type.")

        if self.custom_exe_path is not None:
            if not os.path.isabs(self.custom_exe_path):
                raise RayvisionError(1000000, "Please specify the exe full path")
            if not os.path.isfile(self.custom_exe_path):
                raise RayvisionError(1000000, "The specified exe path does not exist")

        objs = {
            "Max": (Max, "2001"),
            "Maya": (Maya, "2000"),
            "Houdini": (Houdini, "2004"),
            "C4D": (C4D, "2005"),
        }
        # init CG software
        self.cg_class, self.cg_id = objs[self.type]
        self.cg_instance = self.cg_class(cg_file=cg_file, 
                                         job_info=self.job_info,
                                         cg_id=self.cg_id,
                                         custom_exe_path=self.custom_exe_path,
                                         )

    def init_logging(self):
        format = '%Y-%m-%d'
        today = time.strftime(format, time.localtime())
        log_path = self.job_info._log_dir
        name = "analyse" + today
        filename = os.path.join(log_path, name)

        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s %(levelname)s [%(name)s] %(filename)s +%(lineno)d: %(message)s',
            datefmt="%Y-%m-%d %H:%M:%S",
            # filename=filename,
        )

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


def init_argparse():
    pass


def main():
    init_argparse()


if __name__ == '__main__':
    main()
