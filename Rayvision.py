#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
Main module.
"""

import sys

from RayvisionAPI import RayvisionAPI
from RayvisionJob import RayvisionJob
from RayvisionTransfer import RayvisionTransfer


def get_os():
    """
    sys.platform:
        Linux (2.x and 3.x)     'linux2'
        Windows                 'win32'
        Windows/Cygwin          'cygwin'
        Mac OS X                'darwin'
        OS/2                    'os2'
        OS/2 EMX                'os2emx'
        RiscOS                  'riscos'
        AtheOS                  'atheos'
    :return:
    """
    local_os = 'windows'
    if not sys.platform.startswith('win'):
        local_os = 'linux'
    return local_os


class Rayvision(object):
    def __init__(self, domain_name, platform, account, access_key, **kargs):
        self.user_info = {
            'domain_name': domain_name,  # task.foxrenderfarm.com/task.renderbus.com
            'platform': platform,  # 2：www2；5：pic；8：www8；9：www9；10：gpu
            'account': account,
            'access_key': access_key,
            'channel': '4',  # 1: web local analysis 2: web cloud analysis 3: plugin analysis 4: SDK analysis
            'local_os': get_os()
        }

        self.api_obj = RayvisionAPI(self.user_info)
        self.login()
        self.transfer_obj = RayvisionTransfer(self.user_info, self.api_obj)

    def login(self):
        """
        1.login
        2.get storage id
        3.get user custom setup
        :return: True
        """
        data = self.api_obj.login(self.user_info['account'], self.user_info['access_key'])
        self.user_info['user_id'] = data['id']
        self.user_info['login_date'] = data['loginDate']
        self.user_info['signature'] = data['signature']
        self.user_info['user_key'] = data['userKey']
        self.user_info['user_name'] = data['userName']
        self.user_info['platform'] = data['platform']
        self.user_info['main_user_id'] = data['mainUserId']

        data = self.api_obj.get_storage_id()
        self.user_info['storage_id'] = data['storageId']
        self.user_info['download_id'] = data['downloadId']
        self.user_info['cfg_id'] = data['cfgId']

        data = self.api_obj.get_user_custom_setup()
        self.user_info['single_node_render_frames'] = data['singleNodeRenderFrames']
        self.user_info['main_child_account_setup'] = data['mainChildAccountSetup']
        self.user_info['maya_not_analyse_mi_file'] = data['mayaNotAnalyseMiFile']
        self.user_info['maya_not_analyse_ass_file'] = data['mayaNotAnalyseAssFile']
        self.user_info['maya_force_analyse_all_agent'] = data['mayaForceAnalyseAllAgent']

        return True

    def set_job_config(self, cg_name, cg_version=None, plugin_config={}, edit_name=None, project_name=None):
        """
        1.set job plugins info
            (1)set job config by edit_name, input:cg_name, edit_name
            (2)set job config by custom plugin config, input:cg_name, cg_version, plugin_config
            (3)set job config by custom plugin config and add to user plugin config group(named by edit_name), input:edit_name, cg_name, cg_version, plugin_config
        2.Add a project label to the job(Unnecessary).

        :param str cg_name:
        :param str cg_version:
        :param dict plugin_config: {"plugins":{"3dhippiesterocam":"2.0.13"},"cg_version":"2014","cg_name":"3ds Max"}
        :param str edit_name:
        :param str project_name:
        :return: job_id
        :rtype: str
        """
        self.cg_name = cg_name
        self.job_id = self.api_obj.get_job_id()
        self.job_info = RayvisionJob(self.job_id, self.user_info['local_os'])

        self.job_info.task_info['system_info']['common']['channel'] = self.user_info['channel']
        self.job_info.task_info['system_info']['common']['task_id'] = self.job_id
        self.job_info.task_info['system_info']['common']['platform'] = self.user_info['platform']
        self.job_info.task_info['system_info']['common']['user_id'] = self.user_info['user_id']

        if project_name is not None:
            self.job_info.task_info['advanced_option']['project_name'] = project_name

        software_config_dict = {}
        if edit_name is not None and cg_version is None:
            # (1)set job config by edit_name
            data = self.api_obj.get_user_single_plugin_config(cg_name, edit_name)
            software_config_dict['cg_name'] = data['cgName']
            software_config_dict['cg_version'] = data['cgVersion']
            software_config_dict['plugins'] = {}

            plugins_info_list = data['pluginsInfo']
            for plugin_info in plugins_info_list:
                key = plugin_info['pluginName']
                value = plugin_info['pluginVersion']
                software_config_dict['plugins'][key] = value

        elif edit_name is None and cg_version is not None:
            # (2)set job config by custom plugin config
            software_config_dict = plugin_config
        elif edit_name is not None and cg_version is not None:
            # (3)set job config by custom plugin config and add to user plugin config group(named by edit_name)
            software_config_dict = plugin_config

            plugins_info = []
            for plugin_name, plugin_version in plugin_config['plugins']:
                single_plugin_dict = {}
                single_plugin_dict['pluginName'] = plugin_name
                single_plugin_dict['pluginVersion'] = plugin_version
                plugins_info.append(single_plugin_dict)

            self.api_obj.edit_user_plugin_config(edit_name, cg_name, cg_version, plugins_info)

        else:
            # TODO 4
            warn_info = r'''
                            Please set job plugins info
                            (1)set job config by edit_name, input:cg_name, edit_name
                            (2)set job config by custom plugin config, input:cg_name, cg_version, plugin_config
                            (3)set job config by custom plugin config and add to user plugin config group(named by edit_name), input:edit_name, cg_name, cg_version, plugin_config
                        '''
            raise Exception(warn_info)

        self.job_info.task_info['software_config'] = software_config_dict

        return True

    def analyse(self, cg_file):
        """
        Analyse cg file.
        :param str job_id:
        :param str cg_file: cg file path
        :return:
        """
        # 传self.job_info过去，直接修改job_info
        pass

    def check_error_warn_info(self):
        if len(self.job_info.tips_info) > 0:
            data = self.api_obj.get_all_error_code_info(self.cg_name)
            for code, value in self.job_info.tips_info:
                if code in data.keys():
                    return data[code]
                else:
                    raise Exception('unknown error code!')
        else:
            return None

    def edit_param(self, param_dict={}):
        """
        1.input dict
        2.A set method for each attribute
        :param dict param_dict: scene_info_render
        :return:
        """
        self.job_info.task_info['scene_info_render'] = param_dict

    def upload(self):
        self.transfer_obj.upload(self.job_info.upload_info)

    def submit_task(self):
        self.api_obj.submit_job(self.job_id)

    def download(self, job_id, local_dir):
        self.transfer_obj.download(job_id, local_dir)


def main():
    rayvision = Rayvision(domain_name='task.foxrenderfarm.com', platform='8', account='AboutSange1',
                          access_key='helloworld')
    rayvision.set_job_config(edit_name='nihao', project_name='test')
    rayvision.analyse(cg_file='c:/nihao.max')
    rayvision.check_error_warn_info()
    rayvision.edit_param()
    rayvision.upload()  # 包括上传配置文件
    rayvision.submit_task()
    rayvision.download(job_id=11111, local_dir=r"v:\project\output")


if __name__ == '__main__':
    main()