# -*-coding: utf-8 -*-
import os
import time
import sys
import glob
import shutil
from pprint import pprint
from analyse import RayvisionAnalyse


# 模拟
class Job(object):
    def __init__(self, job_id, local_os, workspace=None):
        self.job_id = job_id
        self.local_os = local_os  # "windows"/"linux"

        if workspace is None:
            if local_os == 'windows':
                workspace = r'c:\renderfarm\project'
            else:
                workspace = r'~/renderfarm/project'
        self.json_dir = os.path.join(workspace, job_id)
        if not os.path.exists(self.json_dir):
            os.makedirs(self.json_dir)

        if local_os == 'windows':
            # hack
            self.zip_path = r"C:\7-Zip\7z.exe"
        else:
            # self.zip_path = os.path.join(os.getcwd(), '7z')
            pass

        # self.json_dir = 'D:\\scripts\\script3\\rayvision_SDK\\test\\'
        self.json_dir = 'D:\\rayvision_SDK\\test_json\\'
        self.task_json_path = os.path.join(self.json_dir, "task.json")
        self.asset_json_path = os.path.join(self.json_dir, "asset.json")
        self.tips_json_path = os.path.join(self.json_dir, "tips.json")
        self.upload_json_path = os.path.join(self.json_dir, "upload.json")
        self.task_info = {
            "scene_info_render": {

            },
            "task_info": {
                "is_layer_rendering": "",
                "project_name": "dasdd",
                "distribute_render_node": "",
                "task_id": "5151",
                "platform": "1",
                "is_distribute_render": "",
                "frames_per_task": "",
                "split_tiles": "",
                "project_id": "",
                "cg_id": "",
                "is_split_render": "",
                "stop_after_test": "",
                "is_picture": "false",
                "test_frames": "",
                "input_cg_file": "",
                "time_out": "",
                "channel": "4",
                "user_id": "10001"
            },
            "scene_info": {

            },
            "software_config": {
                "cg_version": "2016",
                "cg_name": "maya",
                "plugins": {
                }
            }
        }
        # self.zip_path = os.path.join("xxx", r'module\bin\windows-32-msvc2012\7z.exe')


def test_max():
    # cg_file = r"D:\rayvision_SDK\test.max"
    # cg_file = r"d:\用户场景\荣誉墙--A.max"
    # cg_file = r"d:\用户场景\简欧--C.max"
    # cg_file = r"d:\用户场景\简欧--D.max"
    # cg_file = r"d:\用户场景\S沙发 机场aaa.max"
    # cg_file = r"D:\work\render\19183899\max\19183899.max"
    # cg_file = r"D:\work\render\19184023\max\d\zl_work\2018\3月\20180315碧桂园理想之家\max\理想之城  总场景0324  增加小品扩大地形 _\c09_okzz.max"
    cg_file = r"D:\用户场景\3.6米\改3.6米-1.max"

    job_info = Job(job_id="6666", local_os="windows", workspace=os.getcwd())
    ray = RayvisionAnalyse(job_info=job_info, cg_file=cg_file)
    # ray.cg_instance.analyse_cg_file_info()

    ray.run()
    # ray.cg_instance.get_cg_file_info(cg_file)


def test_maya():
    cg_file = r"d:\rayvision_SDK\test_maya.mb"
    job_info = Job(job_id="6666", local_os="windows", workspace=os.getcwd())
    ray = RayvisionAnalyse(job_info=job_info, cg_file=cg_file)
    ray.run()


def test_houdini():
    cg_file = r"D:\scripts\script3\rayvision_SDK\hou16050420.hip"
    job_info = Job(job_id="6666", local_os="windows", workspace=os.getcwd())
    ray = RayvisionAnalyse(job_info=job_info, cg_file=cg_file)
    ray.run()


def test_c4d():
    pass


def main():
    # test_max()
    # test_maya()
    test_houdini()
    # test_c4d()


if __name__ == '__main__':
    pass
    main()
