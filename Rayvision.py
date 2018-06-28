#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
Main module.
"""

import os
import sys
import json
import logging
import codecs
import time

from RayvisionUtil import get_os, hump2underline, get_cg_id, decorator_use_in_class, format_time
from RayvisionAPI import RayvisionAPI
from RayvisionJob import RayvisionJob
from RayvisionTransfer import RayvisionTransfer
from RayvisionException import RayvisionError

from analyse import RayvisionAnalyse

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
SDK_LOG = logging.getLogger('sdk_log')

class Rayvision(object):
    def __init__(self, domain_name, platform, account, access_key, workspace=None, *args, **kwargs):
        """
        :param str domain_name: task.foxrenderfarm.com/task.renderbus.com
        :param str platform: 2：www2；5：pic；8：www8；9：www9；10：gpu
        :param str account: userName
        :param str access_key: needs to be applied for
        :param str protocol: https/http
        :param kwargs:
        """
        domain_name = str(domain_name)
        platform = str(platform)
        account = str(account)
        access_key = str(access_key)
        if workspace is None:
            workspace = os.path.join(CURRENT_DIR, 'workspace')  # default workspace
        else:
            workspace = str(workspace)
        
        # init log
        self.G_SDK_LOG = SDK_LOG
        sdk_log_filename = 'run_{}.log'.format(format_time('%Y%m%d'))
        sdk_log_path = os.path.join(workspace, 'log', 'sdk', sdk_log_filename)
        self._init_log(self.G_SDK_LOG, sdk_log_path)
        self.G_SDK_LOG.info('='*50)
        
        self._user_info = {
            'domain_name': domain_name,
            'platform': platform,
            'account': account,
            'access_key': access_key,
            'local_os': get_os(),
            'workspace': workspace
        }
        self._api_obj = RayvisionAPI(self._user_info, log_obj=self.G_SDK_LOG)
        self._login()
        self._transfer_obj = RayvisionTransfer(self._user_info, self._api_obj, log_obj=self.G_SDK_LOG)
    
    def _init_log(self, log_obj, log_path, is_print_log=True):
        log_dir = os.path.dirname(log_path)
        
        # 如果log_dir路径为文件，则在日志文件夹名后加timestamp
        if os.path.exists(log_dir):
            if not os.path.isdir(log_dir):
                log_dir = '{}{}'.format(log_dir, format_time())

        if not os.path.exists(log_dir):
            os.makedirs(log_dir)

        # 如果log_path路径为文件夹，则在日志文件名后加timestamp
        if os.path.isdir(log_path):
            log_dir = '{}{}'.format(log_path, format_time())
        
        log_obj.setLevel(logging.DEBUG)
        # FileHandler
        file_handler = logging.FileHandler(log_path, encoding='utf-8')
        fm=logging.Formatter("%(asctime)s  %(levelname)s - %(message)s","%Y-%m-%d %H:%M:%S")
        file_handler.setFormatter(fm)
        log_obj.addHandler(file_handler)
        
        # StreamHandler
        if is_print_log:
            stream_handler = logging.StreamHandler()
            stream_handler.setLevel(logging.INFO)
            log_obj.addHandler(stream_handler)
    
    def _login(self):
        """
        1.login
        2.get storage id
        :return: True
        """
        self.G_SDK_LOG.info('[Rayvision.login.start.....]')
        
        data1 = self._api_obj._login(self._user_info['account'], self._user_info['access_key'])
        data2 = self._api_obj._get_storage_id()
        data1.update(data2)
        
        # 将login和get_storage_id的response中的data放进user_info中（变量采用下划线命名方式）
        for key, value in data1.items():
            if isinstance(value, (int, long, float)):
                value = str(value)
            key_underline = hump2underline(key)  # 变量名：驼峰转下划线
            if key_underline == 'id':
                key_underline = 'user_id'
            self._user_info[key_underline] = value
            
        self.G_SDK_LOG.info('USER INFO:{}'.format(self._user_info))
        
        self.G_SDK_LOG.info('[Rayvision.login.end.....]')
        return True

    @decorator_use_in_class(SDK_LOG)
    def set_job_config(self, cg_name, cg_version=None, plugin_config={}, edit_name=None, project_name=None):
        """
        1.set job plugins info
            (1)set job config by edit_name, input:cg_name, edit_name
            (2)set job config by custom plugin config, input:cg_name, cg_version, plugin_config
            (3)set job config by custom plugin config and add to user plugin config group(named by edit_name), input:edit_name, cg_name, cg_version, plugin_config
        2.Add a project label to the job(Unnecessary).

        :param str cg_name:
        :param str cg_version:
        :param dict plugin_config: {"3dhippiesterocam":"2.0.13"}
        :param str edit_name:
        :param str project_name:
        :return: job_id
        :rtype: str
        """
        cg_name = str(cg_name)
        if cg_version is not None:
            cg_version = str(cg_version)
        if edit_name is not None:
            edit_name = str(edit_name)
        if project_name is not None:
            project_name = str(project_name)
        
        self.G_SDK_LOG.info('INPUT:')
        self.G_SDK_LOG.info('='*20)
        self.G_SDK_LOG.info('cg_name:{}'.format(cg_name))
        self.G_SDK_LOG.info('cg_version:{}'.format(cg_version))
        self.G_SDK_LOG.info('plugin_config:{}'.format(plugin_config))
        self.G_SDK_LOG.info('edit_name:{}'.format(edit_name))
        self.G_SDK_LOG.info('project_name:{}'.format(project_name))
        self.G_SDK_LOG.info('='*20)
        
        # 初始化作业所需的变量
        self.is_analyse = False  # 是否调用分析方法
        self.errors_number = 0  # tips.json中错误数量
        self.error_warn_info_list = []  # 错误、警告信息
        # self.cg_name = str(cg_name)  # 软件名（3ds Max、Maya、Houdini）
        cg_id = get_cg_id(cg_name)  # 软件id
        job_id = str(self._api_obj._get_job_id()[0])  # 作业号
        
        self.G_SDK_LOG.info('JOB ID:{}'.format(job_id))
        
        self._job_info = RayvisionJob(self._user_info, job_id)

        self._job_info._task_info['task_info']['cg_id'] = cg_id

        if project_name is not None:
            project_dict_list = self._api_obj._get_project()
            is_project_exist = False
            for project_dict in project_dict_list:
                if project_dict['projectName'] == project_name:
                    is_project_exist = True
                    break
            
            if not is_project_exist:
                # TODO 项目名不存在则创建项目
                return_message = r'project_name is not exists:{}'.format(project_name)
                raise RayvisionError(100005, return_message)  # project_name is not exists!
                
            self._job_info._task_info['task_info']['project_name'] = project_name
            self._job_info._task_info['task_info']['project_id'] = str(project_dict['projectId'])
            
        # user_plugins_list = self._api_obj._get_user_plugin_config(cg_name)
        software_config_dict = {}

        if edit_name is not None and cg_version is None:
            # (1)set job config by edit_name
            user_plugins_list = self._api_obj._get_user_plugin_config(cg_name)
            is_edit_name_exist = False
            for plugin_dict in user_plugins_list:
                if plugin_dict['editName'] == edit_name:
                    is_edit_name_exist = True
                    software_config_dict['cg_name'] = plugin_dict['cgName']
                    software_config_dict['cg_version'] = plugin_dict['cgVersion']
                    software_config_dict['plugins'] = {}

                    plugins_info_list = plugin_dict['pluginsInfoSdkVos']
                    for plugin_info in plugins_info_list:
                        key = plugin_info['pluginName']
                        value = plugin_info['pluginVersion']
                        if key is not None and value is not None:
                            software_config_dict['plugins'][key] = value
            if not is_edit_name_exist:
                return_message = r'edit_name is not exists:{}'.format(edit_name)
                raise RayvisionError(100004, return_message) # edit_name is not exists!

        elif edit_name is None and cg_version is not None:
            # (2)set job config by custom plugin config
            software_config_dict['cg_name'] = cg_name
            software_config_dict['cg_version'] = cg_version
            software_config_dict['plugins'] = plugin_config
        elif edit_name is not None and cg_version is not None:
            # (3)set job config by custom plugin config and add/edit to user plugin config group(named by edit_name)
            user_plugins_list = self._api_obj._get_user_plugin_config(cg_name)
            software_config_dict['cg_name'] = cg_name
            software_config_dict['cg_version'] = cg_version
            software_config_dict['plugins'] = plugin_config

            plugins_info = []
            for plugin_name, plugin_version in plugin_config.items():
                single_plugin_dict = {}
                single_plugin_dict['pluginName'] = plugin_name
                single_plugin_dict['pluginVersion'] = plugin_version
                plugins_info.append(single_plugin_dict)

            is_edit_name_exist = False
            for plugin_dict in user_plugins_list:
                if plugin_dict['editName'] == edit_name:
                    is_edit_name_exist = True

            if is_edit_name_exist:
                self._api_obj._edit_user_plugin_config(edit_name, cg_id, cg_name, cg_version, plugins_info)
            else:
                self._api_obj._add_user_plugin_config(edit_name, cg_id, cg_name, cg_version, plugins_info)

        else:
            return_message = r'''PARAMETER_INVALID:
(1)cg_name + edit_name: set job config by edit_name
(2)cg_name + cg_version + plugin_config: set job config by custom plugin config
(3)edit_name + cg_name + cg_version + plugin_config: set job config by custom plugin config and add to user plugin config group(named by edit_name)
                        '''
            raise RayvisionError(100003, return_message)  # PARAMETER_INVALID

        self._job_info._task_info['software_config'] = software_config_dict

        return True

    @decorator_use_in_class(SDK_LOG)
    def analyse(self, cg_file, project_dir=None):
        """
        Analyse cg file.
        :param str job_id:
        :param str cg_file: cg file path
        :return:
        """
        cg_file = str(cg_file)
        if project_dir is not None:
            project_dir = str(project_dir)
        
        self.G_SDK_LOG.info('INPUT:')
        self.G_SDK_LOG.info('='*20)
        self.G_SDK_LOG.info('cg_file:{}'.format(cg_file))
        self.G_SDK_LOG.info('project_dir:{}'.format(project_dir))
        self.G_SDK_LOG.info('='*20)
        
        self.is_analyse = True
        # 传self.job_info过去，直接修改job_info
        self._job_info._task_info['task_info']['input_cg_file'] = cg_file
        if project_dir is not None:
            self._job_info._task_info['task_info']['input_project_path'] = project_dir
            
        # self.G_SDK_LOG.info(json.dumps(self._job_info.__dict__))
        
        RayvisionAnalyse.analyse(cg_file, self._job_info)
        
        scene_info_data = self._job_info._task_info['scene_info']
        
        # add frames to scene_info_render.<layer>.common.frames
        if self._job_info._task_info['task_info']['cg_id'] == '2000':  # Maya
            for layer_name, layer_dict in scene_info_data.items():
                start_frame = layer_dict['common']['start']
                end_frame = layer_dict['common']['end']
                by_frame = layer_dict['common']['by_frame']
                frames = '{}-{}[{}]'.format(start_frame, end_frame, by_frame)
                scene_info_data[layer_name]['common']['frames'] = frames
        
        self._job_info._task_info['scene_info_render'] = scene_info_data
        
        return_scene_info_render = self._job_info._task_info['scene_info_render']
        return_task_info = self._job_info._task_info['task_info']
        
        return  return_scene_info_render, return_task_info

    @decorator_use_in_class(SDK_LOG)
    def check_error_warn_info(self):
        if len(self._job_info._tips_info) > 0:
            for code, value in self._job_info._tips_info.items():
                code_info_list = self._api_obj._get_error_code_by_code(code)
                for code_info in code_info_list:
                    code_info['details'] = value
                    if str(code_info['type']) == '1':  # 0:warning  1:error
                        self.errors_number += 1
                    self.error_warn_info_list.append(code_info)

        self.G_SDK_LOG.info('error_warn_info_list:{}'.format(self.error_warn_info_list))
        return self.error_warn_info_list


    def _edit_param(self, scene_info_render=None, task_info=None):
        """
        1.input dict
        2.A set method for each attribute
        :param dict param_dict: scene_info_render
        :return:
        """

        self.G_SDK_LOG.info('INPUT:')
        self.G_SDK_LOG.info('='*20)
        self.G_SDK_LOG.info('scene_info_render:{}'.format(scene_info_render))
        self.G_SDK_LOG.info('task_info:{}'.format(task_info))
        self.G_SDK_LOG.info('='*20)
        
        if scene_info_render is not None:
            self._job_info._task_info['scene_info_render'] = scene_info_render
            if not self.is_analyse:
                self._job_info._task_info['scene_info'] = scene_info_render
                
        if task_info is not None:
            modifiable_param = [
                'frames_per_task',  # 一机渲多帧的帧数量
                'test_frames',  # 优先渲染
                'time_out',  # 超时时间
                'stop_after_test',  # 优先渲染完成后是否暂停任务,1:优先渲染完成后暂停任务 2.优先渲染完成后不暂停任务
                'is_split_render',  # 是否开启分块渲染 1开启
                'split_tiles',  # 分块数量
                'is_layer_rendering',  # maya是否开启分层
                'is_distribute_render',  # 是否开启分布式渲染
                'distribute_render_node',  # 分布式渲染机器数
                'input_project_path',  # 工程目录路径
                'render_layer_type'  # 渲染层类型
            ]  # 可修改的参数列表
            for key, value in task_info.items():
                if key in modifiable_param:
                    if isinstance(value, (int, long, float)):
                        value = str(value)
                    self._job_info._task_info['task_info'][key] = value
        
        with codecs.open(self._job_info._task_json_path, 'w', 'utf-8') as f:
            json.dump(self._job_info._task_info, f)
        
        return True


    def _upload(self):
        cfg_list = []
        root = self._job_info._work_dir
        for file_name in os.listdir(self._job_info._work_dir):
            if file_name.endswith('.7z'):
               continue
            file_path = os.path.join(root, file_name)
            cfg_list.append(file_path)

        self._transfer_obj._upload(self._job_info._job_id, cfg_list, self._job_info._upload_info)  # 上传配置文件和资产
        return True


    def _submit_job(self):
        self._api_obj._submit_job(int(self._job_info._job_id))
        return True
    
    
    @decorator_use_in_class(SDK_LOG)
    def submit_job(self, scene_info_render=None, task_info=None):
        self._is_scene_have_error()  # check error
        
        self._edit_param(scene_info_render, task_info)
        self._upload()
        self._submit_job()
    

    @decorator_use_in_class(SDK_LOG)
    def download(self, job_id, local_dir):
    
        self.G_SDK_LOG.info('INPUT:')
        self.G_SDK_LOG.info('='*20)
        self.G_SDK_LOG.info('job_id:{}'.format(job_id))
        self.G_SDK_LOG.info('local_dir:{}'.format(local_dir))
        self.G_SDK_LOG.info('='*20)
        
        self._transfer_obj._download(job_id, local_dir)
        return True

    def _is_scene_have_error(self):
        if self.errors_number > 0:
            return_message = r'There are {} errors, Please check self.error_warn_info_list!'.format(self.errors_number)
            raise RayvisionError(100002, return_message)  # errors_number > 0

