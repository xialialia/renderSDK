# -*-coding: utf-8 -*-
import os

from rayvision_SDK.cmd import Cmd


class CompressionFailedError(Exception):
    pass


class DecompressionFailedError(Exception):
    pass


class Zip7z(object):
    def __init__(self, exe_path):
        self.exe_path = exe_path
        self.cmd = Cmd()

    def pack(self, files, dest, level=3):
        """
        pack files by 7z
        :param files: file list, iterable
        :param dest: c:\\xxx\\xxx.7z
        :param level:
                0: no compress
                1: the most fast compress
                3: fast compress
                5: standard compress
                7: maximum compress
                9: extreme compress
        :return:
        """
        if not (0 <= level <= 9):
            raise NotImplementedError("level {} is not allowed".format(level))
        if len(files) < 1:
            print("no file to be compressed")
            return 0

        files_str = ""
        for f in files:
            files_str += '"{}" '.format(f)
        zip_name = dest
        cmd = '"{exe_path}" a "{target_path}" {files_str} -mx{level} -ssw'.format(
            exe_path=self.exe_path,
            target_path=zip_name,
            files_str=files_str,
            level=level,
        )
        returncode, stdout, stderr = self.cmd.run(cmd)
        if returncode != 0:
            raise CompressionFailedError
        return returncode

    def unpack(self, zip_file, dest):
        cmd = '{} x "{}" -y -aos -o"{}"'.format(
            self.exe_path,
            zip_file,
            dest,
        )
        returncode, stdout, stderr = self.cmd.run(cmd)
        if returncode != 0:
            raise DecompressionFailedError
        return returncode


def main():
    exe_path = os.path.abspath(os.path.join("tool/zip", "windows", "7z.exe"))
    zip = Zip7z(exe_path)
    files = [
        r"D:\30089034\_STP00000_大餐厅全景_142344_0000.exr",
        r"D:\30089034\_STP00001_大餐厅全景_142344_0000.exr",
        r"D:\30089034\_STP00002_大餐厅全景_142344_0000.exr",
        r"D:\30089034\_STP00003_大餐厅全景_142344_0000.exr",
        r"D:\30089034\_STP00004_大餐厅全景_142344_0000.exr",
        r"D:\30089034\_STP00005_大餐厅全景_142344_0000.exr",
    ]

    # zip.pack(files=files, dest="d:\\30089034\\testall.jpg.7z")

    zip_name = r"D:\30089034/testall.jpg.7z"
    dest = r"D:\test_unpack"  # 目录不存在 7z 会自己新建
    zip.unpack(zip_name, dest)


if __name__ == '__main__':
    pass
    main()
