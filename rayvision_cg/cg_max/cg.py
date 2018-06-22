# -*-coding: utf-8 -*-
from __future__ import unicode_literals
from __future__ import print_function
import os
import re
import datetime
import traceback
import subprocess

try:
    import _winreg
except ImportError:
    import winreg as _winreg
from pprint import pprint

from rayvision_cg.cg_base import CGBase
import util
import tips_code
from exception import *
from message import *


def cmp(a, b):
    r = (a > b) - (a < b)
    return r


# TODO
"""
Max 软件先跳过, 2018/06/07
待完善:tips.add() tips.save()
exception tips_code 还有其他条件

判断路径和文件名是否过长 


"""


class Max(CGBase):
    def __init__(self, *args, **kwargs):
        super(Max, self).__init__(*args, **kwargs)
        self.exe_name = "3dsmax.exe"
        self.vray = None
        self.name = "3ds Max"

        self.init()

    def init(self):
        """
        1. check filename
        """
        # check filename
        basename = os.path.basename(self.cg_file)
        short_name, extension = os.path.splitext(basename)
        pattern = r'^[A-Z][^-]*?\d$'
        m = re.match(pattern, short_name)
        if m is None:
            self.tips.add(tips_code.max_name_illegal, self.cg_file)
            self.tips.save()
            raise CGFileNameIllegalError("")

    def location_from_reg(self, bit, file_version):
        """
        从注册表中读取 3dsmax.exe 所在目录
        :param bit: 位
        :param file_version: 从 cg 文件中读取到的版本
        :return:
        """
        location = None
        language_code = ''

        software_str = 'SOFTWARE\Autodesk\\'
        if bit == '32':
            software_str = 'SOFTWARE\Wow6432Node\Autodesk\\'
        # get max locaction from regedit
        type_list = ['3dsMax', '3dsMaxDesign']
        if file_version < 15:
            language_code_list = ['409', '40C', '407', '411', '412', '804']  # English,French,German,Japanese,Korean,Chinese
            # HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\3dsMax\12.0\MAX-1:409
            for t in type_list:
                for code in language_code_list:
                    try:
                        version_str = software_str + t + '\\' + str(file_version) + '.0\MAX-1:' + code
                        key = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, version_str)
                        location, type = _winreg.QueryValueEx(key, "Installdir")
                        language_code = code
                    except Exception as e:
                        pass
                        traceback.print_exc()
        else:
            for t in type_list:
                print(t)
                try:
                    version_str = software_str + t + '\\' + str(file_version) + '.0'  # Software\Autodesk\3dsMax\15.0
                    key = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, version_str)
                    location, type = _winreg.QueryValueEx(key, "Installdir")
                except Exception as e:
                    pass
                    traceback.print_exc()
        return location, language_code

    def location_from_env(self, bit, cg_version_str):
        """
        从环境变量中找安装路径
        # ADSK_3DSMAX_x64_2012    C:\Program Files\Autodesk\3ds Max 2012\
        # ADSK_3DSMAX_x64_2014    C:\Program Files\Autodesk\3ds Max 2014\
        """
        location = None
        env_key = 'ADSK_3DSMAX_x' + bit + '_' + cg_version_str.replace('3ds Max ', '')
        print(env_key)
        try:
            location = os.environ[env_key]
        except Exception as e:
            traceback.print_exc()
        return location

    # def exe_path_from_location(self, location):
    #     exe_path = None
    #     if location is not None:
    #         exe_path = os.path.join(location, self.exe_name)
    #         if not os.path.exists(exe_path):
    #             return None
    #         else:
    #             pass
    #     return exe_path

    def exe_path_with_hardcode(self):
        """
        找的默认安装位置
        :return:
        """
        driver_max_list = ['c:', 'd:', 'e:', 'f:']
        for driver in driver_max_list:
            location = os.path.join(driver, r"Program Files\Autodesk", self.version_str, self.exe_name)
            if os.path.exists(location):
                exe_path = location
                return exe_path

    def exe_path_from_ftype(self):
        """
        用 windows 命令行 ftype 查找
        :return:
        """
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags = subprocess.CREATE_NEW_CONSOLE | subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = subprocess.SW_HIDE
        cmd = 'ftype 3dsmax'

        returncode, stdout, stderr = self.cmd.run(cmd, shell=True)
        if returncode != 0:
            self.tips.add(tips_code.unknow_err)

        if stdout.startswith('3dsmax="') and self.version_str in stdout:
            location = stdout.replace('3dsmax="', '').replace('"%1"', '').replace('"', '').strip()
            if os.path.exists(location):
                exe_path = location
                return exe_path

    def find_location(self):
        """
        etc. cg_version = 16
        cg_version_str = 3ds Max 2016
        软件年份(2016)跟 文件版本 相差 2
        比如 文件版本 = 13.00
        max 版本就是 2011

        赋值:
        self.version
        self.version_str
        self.exe_path
        self.vray
        """
        cg_version, file_version = self.get_cg_file_info(self.cg_file)
        # cg_version = file_version
        cg_version_str = "3ds Max " + cg_version
        self.version = cg_version
        self.version_str = cg_version_str
        language_code = ""
        location, language_code = self.location_from_reg("64", file_version)
        if location is None:
            location, language_code = self.location_from_reg("32", file_version)
        if location is None:
            location, language_code = self.location_from_env("64", cg_version_str)
        if location is None:
            location, language_code = self.location_from_env("32", cg_version_str)
        if location is None:
            raise RayvisionError("Can't find Max location.")

        exe_path = self.exe_path_from_location(location, self.exe_path)
        if exe_path in (None, ""):
            exe_path = self.exe_path_with_hardcode()
        if exe_path in (None, ""):
            exe_path = self.exe_path_from_ftype()

        if exe_path in (None, ""):
            self.tips.add(tips_code.cg_notexists, cg_version_str)
            self.tips.save()
            raise MaxExeNotExistError(error9899_maxexe_notexist)
        self.exe_path = exe_path
        if file_version < 15 and language_code in ['40C', '407', '411', '412', '804']:
            self.tips.add(tips_code.not_english_max, exe_path)

    def get_cg_file_info(self, cg_file):
        """
        file_version 是从 GetMaxProperty.exe 解析得到, cg_version 是根据 file_version 计算得到.
        :param cg_file:
        :return: (cg_version :str, file_version :int)
        """
        cg_version = None
        file_version = None
        # 使用 exe 对 max 文件分析, 得出使用的软件的版本.
        exe_name = "GetMaxProperty.exe"
        path = "../../rayvision/max"
        cmd = '{} "{}"'.format(
            os.path.join(path, exe_name),
            cg_file,
        )
        returncode, stdout, stderr = self.cmd.run(cmd, shell=True)

        if returncode != 0:
            self.tips.add(tips_code.cginfo_failed)
            self.tips.save()
            raise RayvisionError("Load max info fail")
        # pprint(stdout1)
        lines = stdout.splitlines()
        lines = [line for line in lines if line]
        # TODO 如果有用到其他(除vray外) 下面需要修复
        # info = self.parse_lines(lines)
        # pprint(info)
        # if "Render Data" in info:
        #     renderer_data = info["Render Data"]
        #     vray = renderer_data.get("Renderer Name", None)
        #     self.vray = vray

        # Max 的 Vray 版本在这里赋值
        self._find_vray_version(stdout)
        # 兼容中文或其他...TODO

        patterns = [
            r"3ds Max Version: (\d+\.\d+)",
            r"3ds Max 版本: (\d+\.\d+)",
        ]
        for pattern in patterns:
            result = re.search(pattern, stdout)
            if result is not None:
                break
        if result is not None:
            file_version = result.groups()[0]
            file_version = int(float(file_version))
            #
            if file_version > 9:
                cg_version = str(int(file_version) + 1998)
            # version = "20" + str(file_version - 2).zfill(2)
            print(file_version, type(file_version))
            print(cg_version, type(cg_version))
        else:
            raise MaxDamageError(error9900_max_damage)

        # cg_version_str = "3ds Max " + cg_version
        # self.version = cg_version
        # self.version_str = cg_version_str
        print(cg_version, file_version)
        print(self.version, self.version_str)
        return (cg_version, file_version)

    def _find_vray_version(self, string):
        """find vray version by re"""
        p = "Renderer Name=(.*) \r"
        result = re.search(p, string)
        if result is not None:
            renderer_name = result.groups()[0].lower()
            if "missing" in renderer_name:
                print("missing renderer")
                self.tips.add(tips_code.realflow_missing)
                raise RayvisionError("missing renderer")
                pass
            else:
                vray = renderer_name.replace('v-ray ', 'vray').replace('v_ray ', 'vray').replace('adv ', '').replace('edu ', '').replace('demo ', '').replace(' ', '')
                self.vray = vray
        else:
            self.tips.add(tips_code.cginfo_failed)
            raise RayvisionError("max info failed")

    def _find_max_version(self, string):
        pass

    def parse_lines(self, lines):
        """deprecated"""
        index = 0
        d = {}
        now = ""
        pprint(lines)
        while index < len(lines):
            line = lines[index]
            index += 1
            try:
                next_line = lines[index]
            except IndexError as e:
                next_line = ""
            if not line.startswith("\t"):
                key = line.strip()
                now = key
                if next_line.startswith("\t"):
                    if ":" in next_line or "=" in next_line:
                        d[key] = {}
                    else:
                        d[key] = []
                    continue
                else:
                    d[key] = None
            else:
                line = line.strip()
                if "=" in line:
                    char = "="
                elif ":" in line:
                    char = ":"
                else:
                    try:
                        d[now].append(line)
                    except AttributeError as e:
                        # traceback.print_exc()
                        d[now][line] = None  # 预防 "Uncompressed"
                    continue

                # if "&" in line:
                #     ss = line.split("&")
                #     for item in ss:
                #         k, v = item.split(char)
                #         k, v = k.strip(), v.strip()
                #         if "," in v:
                #             print(222, d)
                #             print(333, d[now])
                #             print(now, k, v)
                #             print(type(now), type(k), type(v))
                #             # d[now] 有时是一个列表
                #             d[now][k] = v.split(",")
                #         else:
                #             d[now][k] = v

                k, v = line.split(char)
                k, v = k.strip(), v.strip()
                d[now][k] = v
        # pprint(d)
        return d

    def template_ms(self, sdk_path, cg_file, task_json, asset_json, tips_json, ingore_texture="false"):
        ms = """
(DotNetClass "System.Windows.Forms.Application").CurrentCulture = dotnetObject "System.Globalization.CultureInfo" "zh-cn"
filein @"{sdk_path}/analyse.ms"
fn analyse = (
rayvision #("{cg_file}", "{task_json}", "{asset_json}", "{tips_json}", "{ingore_texture}")
)
        """.format(
            sdk_path=sdk_path,
            cg_file=cg_file,
            task_json=task_json,
            asset_json=asset_json,
            tips_json=tips_json,
            ingore_texture=ingore_texture,
        )
        return ms

    def _zip_file(self, zip_exe_path, source_path, dest_path):
        """
        压缩文件
        :param zip_exe_path: 7z 路径
        :param source_path: 要压缩的文件(全路径)
        :param dest_path: 压缩文件路径
        :return:
        """
        f = source_path
        zip_name = dest_path
        # TODO 用 Zip7z && 不同系统
        cmd = '"{}" a "{}" "{}"  -mx3 -ssw '.format(
            zip_exe_path,
            zip_name,
            f,
        )
        returncode, stdout, stderr = self.cmd.run(cmd, shell=True)
        return returncode

    def zip_max(self, max_list):
        """

        :param max_list:
        :return:
        """
        zip_exe = self.job_info.zip_path

        temp_project_path = self.job_info.json_dir

        zip_list = []
        for max_file in max_list:
            basename = os.path.basename(max_file)
            zip_name = os.path.join(temp_project_path, basename + '.7z')
            returncode = self._zip_file(zip_exe, max_file, zip_name)
            if returncode != 0:
                self.tips.add(tips_code.cg_zip_failed)
                self.tips.save()
                raise CGFileZipFailError("zip fail")
            zip_list.append(zip_name)

        return zip_list

    def assemble_upload_json(self, asset_json, zip_result_list):
        """
        组装 upload.json,
        1. 处理 max 的压缩文件 .7z
        2. 处理 asset.json 的其他资产
        upload.json format:
        {
            "asset":[
                {
                    "local":"local_path1",
                    "server":"server_path1"
                },
                {
                    "local":"local_path2",
                    "server":"server_path2"
                }
            ]
        }
        """
        upload_json = {}
        asset = []
        # 先处理 .max 的压缩文件, [xxx.7z, xxx.7z]
        for zip_result in zip_result_list:
            d = {}
            d["local"] = zip_result
            d["server"] = util.convert_path(self.user_input, zip_result)
            asset.append(d)

        # 处理 asset.json 里面的其他资产
        # 可能的键不止 `texture`
        for k, v in asset_json.items():
            if "missing" in k.lower():
                continue
            for f in v:
                d = {}
                d["local"] = f
                d["server"] = util.convert_path(self.user_input, f)
                asset.append(d)

        upload_json["asset"] = asset
        return upload_json

    def plugin_conflict(self, max='', plugin1='', plugin2=''):
        vray_multiscatter = ['2010_2.00.01_1.0.18a', '2010_2.00.02_1.0.18a', '2010_2.10.01_1.0.18a', '2010_2.20.02_1.0.18a', '2010_2.40.03_1.0.18a',
                             '2010_2.00.01_1.1.05', '2010_2.00.02_1.1.05', '2010_2.10.01_1.1.05', '2010_2.20.02_1.1.05', '2010_2.40.03_1.1.05',
                             '2010_2.00.01_1.1.05a', '2010_2.10.01_1.1.05a', '2010_2.20.02_1.1.05a', '2010_2.40.03_1.1.05a', '2010_2.00.01_1.1.07a',
                             '2010_2.20.02_1.1.07a', '2010_2.40.03_1.1.07a', '2010_2.00.01_1.1.08b', '2010_2.20.02_1.1.08b', '2010_2.40.03_1.1.08b',
                             '2010_2.00.01_1.1.09', '2010_2.00.02_1.1.09', '2010_2.10.01_1.1.09', '2010_2.20.02_1.1.09', '2010_2.40.03_1.1.09',
                             '2010_2.00.01_1.1.09a', '2010_2.40.03_1.1.09a', '2010_2.00.01_1.1.09c', '2010_2.40.03_1.1.09c', '2010_2.00.01_1.1.09d',
                             '2010_2.40.03_1.1.09d', '2010_2.00.01_1.2.0.3', '2010_2.00.02_1.2.0.3', '2010_2.10.01_1.2.0.3', '2010_2.20.02_1.2.0.3',
                             '2010_2.40.03_1.2.0.3', '2010_2.00.01_1.3.1.3a', '2010_2.00.02_1.3.1.3a',
                             '2010_2.10.01_1.3.1.3a', '2010_2.20.02_1.3.1.3a', '2010_2.40.03_1.3.1.3a', '2011_2.00.01_1.0.18a', '2011_2.00.02_1.0.18a',
                             '2011_2.10.01_1.0.18a', '2011_2.20.02_1.0.18a', '2011_2.20.03_1.0.18a', '2011_2.40.03_1.0.18a', '2011_3.30.04_1.0.18a',
                             '2011_3.30.05_1.0.18a', '2011_2.00.02_1.1.05', '2011_2.10.01_1.1.05', '2011_2.20.02_1.1.05', '2011_2.20.03_1.1.05',
                             '2011_2.40.03_1.1.05', '2011_3.30.04_1.1.05', '2011_3.30.05_1.1.05', '2011_2.10.01_1.1.05a', '2011_2.20.02_1.1.05a',
                             '2011_2.20.03_1.1.05a', '2011_2.40.03_1.1.05a', '2011_3.30.04_1.1.05a', '2011_3.30.05_1.1.05a', '2011_2.20.02_1.1.07a',
                             '2011_2.20.03_1.1.07a', '2011_2.40.03_1.1.07a', '2011_3.30.04_1.1.07a', '2011_3.30.05_1.1.07a', '2011_2.20.02_1.1.08b',
                             '2011_2.20.03_1.1.08b', '2011_2.40.03_1.1.08b', '2011_3.30.04_1.1.08b', '2011_3.30.05_1.1.08b', '2011_3.30.04_1.1.09',
                             '2011_3.30.05_1.1.09', '2011_2.40.03_1.1.09a', '2011_3.30.04_1.1.09a', '2011_3.30.05_1.1.09a', '2011_2.40.03_1.1.09c',
                             '2011_3.30.04_1.1.09c', '2011_3.30.05_1.1.09c', '2011_2.40.03_1.1.09d', '2011_3.30.04_1.1.09d', '2011_3.30.05_1.1.09d',
                             '2011_3.30.04_1.2.0.3', '2011_3.30.05_1.2.0.3', '2011_2.00.01_1.3.1.3a', '2011_2.00.02_1.3.1.3a',
                             '2011_2.10.01_1.3.1.3a', '2011_2.20.02_1.3.1.3a', '2011_2.20.03_1.3.1.3a', '2011_2.40.03_1.3.1.3a', '2011_3.30.04_1.3.1.3a',
                             '2011_3.30.05_1.3.1.3a', '2012_2.20.02_1.1.07a', '2012_2.20.03_1.1.07a', '2012_2.30.01_1.1.07a', '2012_2.40.03_1.1.07a',
                             '2012_3.30.04_1.1.07a', '2012_3.30.05_1.1.07a', '2012_3.40.01_1.1.07a', '2012_2.20.02_1.1.08b', '2012_2.20.03_1.1.08b',
                             '2012_2.30.01_1.1.08b', '2012_2.40.03_1.1.08b', '2012_3.30.04_1.1.08b', '2012_3.30.05_1.1.08b', '2012_3.40.01_1.1.08b',
                             '2012_2.30.01_1.1.09', '2012_2.40.03_1.1.09', '2012_3.30.04_1.1.09', '2012_3.30.05_1.1.09', '2012_3.40.01_1.1.09',
                             '2012_2.30.01_1.1.09a', '2012_2.40.03_1.1.09a', '2012_3.30.04_1.1.09a', '2012_3.30.05_1.1.09a', '2012_3.40.01_1.1.09a',
                             '2012_2.40.03_1.1.09c', '2012_3.30.04_1.1.09c', '2012_3.30.05_1.1.09c', '2012_3.40.01_1.1.09c',
                             '2012_3.30.04_1.1.09d', '2012_3.30.05_1.1.09d', '2012_3.40.01_1.1.09d', '2012_3.30.04_1.2.0.3', '2012_3.30.05_1.2.0.3',
                             '2012_3.40.01_1.2.0.3', '2012_2.00.03_1.3.1.3a', '2012_2.10.01_1.3.1.3a',
                             '2012_2.20.02_1.3.1.3a', '2012_2.20.03_1.3.1.3a', '2012_2.30.01_1.3.1.3a', '2012_2.40.03_1.3.1.3a', '2012_3.30.04_1.3.1.3a',
                             '2012_3.30.05_1.3.1.3a', '2012_3.40.01_1.3.1.3a', '2013_2.40.03_1.1.09c', '2013_2.40.04_1.1.09c', '2013_3.30.04_1.1.09c',
                             '2013_3.30.05_1.1.09c', '2013_3.40.01_1.1.09c', '2013_2.40.03_1.1.09d', '2013_2.40.04_1.1.09d', '2013_3.30.04_1.1.09d',
                             '2013_3.30.05_1.1.09d', '2013_3.40.01_1.1.09d',
                             '2013_3.30.04_1.2.0.3', '2013_3.30.05_1.2.0.3', '2013_3.40.01_1.2.0.3',
                             '2013_2.30.01_1.3.1.3a', '2013_2.40.03_1.3.1.3a', '2013_2.40.04_1.3.1.3a', '2013_3.30.04_1.3.1.3a', '2013_3.30.05_1.3.1.3a',
                             '2013_3.40.01_1.3.1.3a', '2014_2.40.03_1.1.09c', '2014_2.40.04_1.1.09c', '2014_3.30.04_1.1.09c', '2014_3.30.05_1.1.09c',
                             '2014_3.40.01_1.1.09c', '2014_2.40.03_1.1.09d', '2014_2.40.04_1.1.09d', '2014_3.30.04_1.1.09d', '2014_3.30.05_1.1.09d',
                             '2014_3.40.01_1.1.09d', '2014_3.30.04_1.2.0.3',
                             '2014_3.30.05_1.2.0.3', '2014_3.40.01_1.2.0.3', '2014_2.30.01_1.3.1.3a', '2014_2.40.03_1.3.1.3a', '2014_2.40.04_1.3.1.3a',
                             '2012_3.40.02_1.1.09c', '2012_3.40.02_1.1.09d', '2012_3.40.02_1.2.0.3',
                             '2012_3.50.03_1.1.09c', '2012_3.50.03_1.1.09d', '2012_3.50.03_1.2.0.3',
                             '2012_2.30.01_1.1.09d']
        str_a = max + "_" + plugin1 + "_" + plugin2
        if str_a in vray_multiscatter:
            return True
        else:
            return False

    # def kill(self, parent_id):
    #     """暂时没用"""
    #     print("kill max")
    #     cmd_str = 'wmic process where name="3dsmax.exe" get Caption,Parent_process_id,Process_id'
    #     p = subprocess.Popen(cmd_str, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    #     while True:
    #         buff = p.stdout.readline().strip()
    #         if buff == '' and p.poll() is not None:
    #             break
    #         if buff is not None and buff != '':
    #             try:
    #                 buff_arr = buff.split()
    #                 # print buff
    #                 if int(buff_arr[1]) == parent_id:
    #                     # print 'kill...'+buff
    #                     os.system("taskkill /f /pid %s" % (buff_arr[2]))
    #             except Exception as e:
    #                 traceback.print_exc()

    def pre_analyse_custom_script(self):
        super(Max, self).pre_analyse_custom_script()

    def analyse_cg_file_info(self):
        self.find_location()

    def valid(self):
        super(Max, self).valid()
        software_config = self.job_info.task_info["software_config"]
        cg_version = software_config["cg_version"]

        year = cg_version
        plugins = software_config["plugins"]
        if "multiscatter" in plugins:
            multiscatter = plugins["multiscatter"]
            vray_version = self.vray.replace("vray", "")
            if self.plugin_conflict(year, vray_version, multiscatter) is True:
                self.tips.add(tips_code.conflict_multiscatter_vray, vray_version, "Multiscatter" + multiscatter)
                self.tips.save()
                raise MultiscatterandvrayConfilictError(error_multiscatterandvray_confilict.format(vray_version, multiscatter))

    def dump_task_json(self):
        super(Max, self).dump_task_json()

    def analyse(self):
        # TODO sdk_path
        sdk_path = os.getcwd()
        cg_file = self.cg_file
        # 暂时是目录, 以后会改成 json 文件
        task_json = self.job_info.json_dir
        asset_json = task_json
        tips_json = task_json
        # ####
        ms = self.template_ms(sdk_path, cg_file, task_json, asset_json, tips_json, ingore_texture="false").replace("\\", "/")
        print(ms)
        now = datetime.datetime.now()
        now = now.strftime("%Y%m%d%H%M%S")
        # 暂时先在当前目录
        path = os.path.join("Analyse{}.ms".format(now))
        util.write(path, ms)
        #
        cmd = "\"{}\" -silent -mip -mxs \"filein \\\"{}/{}\\\";analyse()\"".format(
            self.exe_path,
            sdk_path.replace("\\", "/"),
            path,
        )

        returncode, stdout, stderr = self.cmd.run(cmd, shell=True)
        print("returncode", returncode)
        # 如果returncode 不是0, 写入 tips
        if returncode != 0:
            # TODO 如果软件返回码不为0, 生成的json是空字典
            self.tips.add(tips_code.unknow_err, stdout, stderr)
            self.tips.save()
            raise AnalyseFailError

    def load_output_json(self):
        super(Max, self).load_output_json()

    def handle_analyse_result(self):
        asset_json = self.asset_json
        if "max" in asset_json:
            maxs = asset_json["max"]
            assert type(maxs) == list
            # 先压缩 .max 文件, 然后把压缩后的文件的路径写进json
            zip_result_list = self.zip_max(maxs)
        else:
            zip_result_list = []
        # 把 包括 max.zip 的全路径 和 asset.json 里面应该上传的路径 放到 upload.json
        upload_json = self.assemble_upload_json(asset_json, zip_result_list)
        self.upload_json = upload_json
        self.job_info.upload_info = upload_json

    def post_analyse_custom(self):
        pass

    def run(self):
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
        # 
        self.post_analyse_custom()
