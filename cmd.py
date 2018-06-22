# -*-coding: utf-8 -*-
from __future__ import print_function
import subprocess

import util


class Cmd(object):
    def __init__(self):
        pass

    def tasklist(self, filter=None):
        exe_name = filter
        if exe_name is not None:
            cmd = 'tasklist /FI "imagename eq {}"'.format(exe_name)
        else:
            cmd = 'tasklist'
        returncode = self.run(cmd)
        return returncode

    def run(self, cmd, shell=False):
        log = print

        log("run command:\n{}".format(cmd))
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=shell)
        stdout, stderr = p.communicate()
        stdout = util.ensure_str(stdout)
        stderr = util.ensure_str(stderr)
        log("stdout:\n{}".format(stdout))
        if stderr:
            log("stderr:\n{}".format(stderr))
        return p.returncode, stdout, stderr

    def power_run(self, cmd):
        pass

    def wrap_subprocess(self, cmd):
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        p = subprocess.Popen(cmd, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, startupinfo=si)
        return p


def main():
    cmd = Cmd()
    command = "tasklist"
    cmd.run(command)


if __name__ == '__main__':
    main()
