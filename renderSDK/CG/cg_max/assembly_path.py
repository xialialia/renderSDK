# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import io
import re
import logging as log
import glob
from pprint import pprint

from renderSDK.CG.util import convert_path

"""
收集资产规则
http://10.60.96.133:8090/pages/viewpage.action?pageId=4490825
"""


def ensure_str(string):
    if type(string) == bytes:
        try:
            string = string.decode("utf-8")
        except UnicodeDecodeError as e:
            string = string.decode("gbk")
    return string


def general_rule(path, file):
    """通用规则"""
    assert os.path.isabs(path) is True
    # 1）根据所给的路径，判断是否存在
    if os.path.exists(path):
        return path

    # 2）如果1）不存在，再判断max文件夹是否存在此文件
    file_path = os.path.dirname(file)
    # 该贴图名字
    filename = os.path.basename(path)
    new_path = os.path.join(file_path, filename)
    if os.path.exists(new_path):
        return path

    # 3）如果1）2）不存在，则根据所给路径最底层的文件，查找max文件所在的路径此文件夹下，对应的文件是否存在。
    # 找上一级目录
    parent_path = os.path.abspath(os.path.dirname(path))
    # 上一级目录的名字
    parent_name = os.path.split(parent_path)[-1]
    new_path = os.path.join(file_path, parent_name, filename)
    if os.path.exists(new_path):
        return new_path
    else:
        return None


def general_rule_by_re(path, file):
    """"""
    assert os.path.isabs(path) is True
    # 1）根据所给的路径，判断是否存在
    dirname = os.path.dirname(path)
    basename = os.path.basename(path)
    name, ext = os.path.splitext(basename)
    pattern = "{0}/{1}*{2}".format(dirname, name, ext)
    result = glob.glob(pattern)
    if len(result) > 0:
        return result

    # 2）如果1）不存在，再判断max文件夹是否存在此文件
    file_path = os.path.dirname(file)
    pattern = "{0}/{1}*{2}".format(file_path, name, ext)
    result = glob.glob(pattern)
    if len(result) > 0:
        return result

    # 3）如果1）2）不存在，则根据所给路径最底层的文件，查找max文件所在的路径此文件夹下，对应的文件是否存在。
    # 贴图的上一级目录
    parent_path = os.path.abspath(os.path.dirname(path))
    # 贴图的上一级目录的名字
    parent_name = os.path.split(parent_path)[-1]
    new_path = os.path.join(file_path, parent_name)
    pattern = "{0}/{1}*{2}".format(new_path, name, ext)
    result = glob.glob(pattern)
    if len(result) > 0:
        return result
    else:
        return None


def _ifl_rule(path, file):
    # 1）根据所给的路径，判断是否存在
    # 如果 path 不是绝对路径 视为不存在, 要走下面
    if not os.path.isabs(path):
        pass
    elif os.path.exists(path):
        return path

    # 2）如果1）不存在，再判断max文件夹是否存在此文件
    file_path = os.path.dirname(file)
    # 该贴图名字
    filename = os.path.basename(path)
    new_path = os.path.join(file_path, filename)
    if os.path.exists(new_path):
        return new_path
    else:
        return None


def _handle_ifl(ifl_path, cg_file):
    os.path.abspath(os.path.dirname(ifl_path))
    with io.open(ifl_path, "r", encoding="utf-8") as fp:
        lines = fp.readlines()
    result = {
        "exist": [],
        "missing": [],
    }

    for line in lines:
        line = ensure_str(line)
        if not line:
            continue
        ext = os.path.splitext(line)[-1]
        l = ext.split(" ")
        if len(l) > 1:
            # 路径后面带数字 `f:/kk/bb/ag11c_00000.jpg 3` 重新赋值
            line = line.replace(l[1], "").strip()
        path = line
        # 判断路径是带盘符还是不带盘符, 应用不同规则
        r = _ifl_rule(line, ifl_path)
        if r is not None:
            result["exist"].append(r)
            continue

        r = _ifl_rule(path, cg_file)
        if r is not None:
            result["exist"].append(r)
        else:
            result["missing"].append(path)
    return result


def _point_cache_rule(path, file):
    assert os.path.isabs(path) is True
    # 1）根据所给的路径，判断是否存在
    dirname = os.path.dirname(path)
    basename = os.path.basename(path)
    name, ext = os.path.splitext(basename)
    if ext == ".xml":
        pattern = "{0}/{1}*{2}".format(dirname, name, ".mc")
    elif ext == ".mcx":
        pattern = "{0}/{1}*{2}".format(dirname, name, ".mcx")
    else:
        return None
    result = glob.glob(pattern)
    if len(result) > 0:
        return result

    # 2）如果1）不存在，再判断max文件夹是否存在此文件
    file_path = os.path.dirname(file)
    pattern = "{0}/{1}*{2}".format(file_path, name, ext)
    result = glob.glob(pattern)
    if len(result) > 0:
        return result

    # 3）如果1）2）不存在，则根据所给路径最底层的文件，查找max文件所在的路径此文件夹下，对应的文件是否存在。
    # 贴图的上一级目录
    parent_path = os.path.abspath(os.path.dirname(path))
    # 贴图的上一级目录的名字
    parent_name = os.path.split(parent_path)[-1]
    new_path = os.path.join(file_path, parent_name)
    pattern = "{0}/{1}*{2}".format(new_path, name, ext)
    result = glob.glob(pattern)
    if len(result) > 0:
        return result
    else:
        return None


def assemble_texture(path_list, cg_file, task_json):
    l = []
    for index, path in enumerate(path_list):
        d = {}
        
        ext = os.path.splitext(path)[-1]
        if ext.lower() == ".ifl":
            # 找 ifl 文件里的内容 得到贴图序列, 需要额外处理.
            result = _handle_ifl(path, cg_file)
            exist = result["exist"]
            for p in exist:
                d["local"] = p.replace("\\", "/")
                d["server"] = convert_path("", p)
                l.append(d)
        else:
            result = general_rule(path, cg_file)
            if result is not None:
                server_path = convert_path("", result)
                d["local"] = result.replace("\\", "/")
                d["server"] = server_path
                l.append(d)
            else:
                # 不存在的应该加missing, 后续处理
                pass

    return l


def assemble_vrmap(path_list, cg_file, task_json):
    task_json = task_json
    scene_info = task_json["scene_info"]
    
    renderer = scene_info["renderer"]
    #
    gi = renderer["gi"]
    primary_gi_engine = renderer["primary_gi_engine"]
    irradiance_map_mode = renderer["irradiance_map_mode"]

    l = []
    # a
    if gi == "1" and primary_gi_engine == "0" and irradiance_map_mode == "2":
        for index, path in enumerate(path_list):
            d = {}
            result = general_rule(path, cg_file)
            if result is not None:
                server_path = convert_path("", result)
                d["local"] = result.replace("\\", "/")
                d["server"] = server_path
                l.append(d)
            else:
                pass
    # b
    if gi == "1" and primary_gi_engine == "0" and irradiance_map_mode == "7":
        for index, path in enumerate(path_list):
            result = general_rule_by_re(path, cg_file)
            if result is not None:
                for p in result:
                    server_path = convert_path("", p)
                    d["local"] = result.replace("\\", "/")
                    d["server"] = server_path
                    l.append(d)
            else:
                pass
    return l


def assemble_vlmap(path_list, cg_file, task_json):
    task_json = task_json
    scene_info = task_json["scene_info"]
    
    renderer = scene_info["renderer"]
    #
    gi = renderer["gi"]
    primary_gi_engine = renderer["primary_gi_engine"]
    secondary_gi_engine = renderer["secondary_gi_engine"]
    light_cache_mode = renderer["light_cache_mode"]

    l = []
    if gi == "1" and (primary_gi_engine == "3" or secondary_gi_engine == "3") and light_cache_mode == "2":
        for index, path in enumerate(path_list):
            d = {}
            result = general_rule(path, cg_file)
            if result is not None:
                server_path = convert_path("", result)
                d["local"] = result.replace("\\", "/")
                d["server"] = server_path
            else:
                pass
    return l


def assemble_point_cache(path_list, cg_file, task_json):
    l = []
    for index, path in enumerate(path_list):
        d = {}
        result = _point_cache_rule(path, cg_file)
        if result is not None:
            server_path = convert_path("", result)
            d["local"] = result.replace("\\", "/")
            d["server"] = server_path
        else:
            pass
    return l


handle_funcs = {
    "texture": assemble_texture,
    "vrmap": assemble_vrmap,
    "vrlmap": assemble_vlmap,
    "point_cache": assemble_point_cache,
}


def test__handle_ifl():
    # 1. ifl 内容不带路径
    ifl_path = r"d:\no.ifl"
    cg_file = r"E:\test_find_path\find.max"
    result = _handle_ifl(ifl_path, cg_file)
    pprint(result)

    print("-" * 20)

    # 2. ifl 内容带路径
    ifl_path = r"d:\no1.ifl"
    cg_file = r"E:\test_find_path\find.max"
    result = _handle_ifl(ifl_path, cg_file)
    pprint(result)


def main():
    pass
    test__handle_ifl()


if __name__ == '__main__':
    pass
    main()
