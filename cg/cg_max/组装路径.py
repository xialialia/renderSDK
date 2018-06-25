# -*-coding: utf-8 -*-
from __future__ import print_function
import os
import re
import time
import sys
import glob
import shutil
from pprint import pprint


def general_rule(path, cg_file):
    # 1）根据所给的路径，判断是否存在
    if os.path.exists(path):
        return path

    # 2）如果1）不存在，再判断max文件夹是否存在此文件
    cg_path = os.path.dirname(cg_file)
    # 该贴图名字
    cg_name = os.path.basename(path)
    new_path = os.path.join(cg_path, cg_name)
    if os.path.exists(new_path):
        return path

    # 3）如果1）2）不存在，则根据所给路径最底层的文件，查找max文件所在的路径此文件夹下，对应的文件是否存在。
    # 找上一级目录
    parent_path = os.path.abspath(os.path.dirname(path))
    # 上一级目录的名字
    parent_name = os.path.split(parent_path)[-1]
    new_path = os.path.join(cg_path, parent_name, cg_name)
    if os.path.exists(new_path):
        return path
    else:
        return None


def assemble_texture(path_list):
    for index, path in enumerate(path_list):
        ext = os.path.splitext(path)[-1]
        if ext.lower() == ".ifl":
            # TODO submitu.ms -> getIflFile
            pass
        else:
            s = general_rule(path, cg_file)
            if s is True:
                server_path = convert_path(path)
            else:
                # TODO
                pass
    pass


def assemble_vrmap(path_list):
    temp_task_json = temp_task_json
    scene_info = temp_task_json["scene_info"]
    commom = scene_info["commom"]
    renderer = scene_info["renderer"]
    #
    gi = renderer["gi"]
    primary_gi_engine = renderer["primary_gi_engine"]
    irradiance_map_mode = renderer["irradiance_map_mode"]

    # a
    if gi == "1" and primary_gi_engine == "0" and irradiance_map_mode == "2":
        pass

    # b
    if gi == "1" and primary_gi_engine == "0" and irradiance_map_mode == "7":
        pass

    #
    pass


def assemble_vlmap(path_list):
    temp_task_json = temp_task_json
    scene_info = temp_task_json["scene_info"]
    commom = scene_info["commom"]
    renderer = scene_info["renderer"]
    #
    gi = renderer["gi"]
    primary_gi_engine = renderer["primary_gi_engine"]
    secondary_gi_engine = renderer["secondary_gi_engine"]
    light_cache_mode = renderer["light_cache_mode"]

    if gi == "1" and (primary_gi_engine == "3" or secondary_gi_engine == "3") and light_cache_mode == "2":
        pass


def assemble_point_cache(path_list):
    pass


funcs = {
    "texture": assemble_texture,
    "vrmap": assemble_vrmap,
    "vrlmap": assemble_vlmap,
    "point_cache": assemble_point_cache,
}


def main():
    pass


if __name__ == '__main__':
    pass
    main()
