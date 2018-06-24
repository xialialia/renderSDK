#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
Store job information module.
"""

import os
import json
import codecs

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

class RayvisionJob(object):
    def __init__(self, user_info, job_id):
        self._job_id = job_id
        self._local_os = user_info['local_os']  # "windows"/"linux"
        
        # work目录
        self._work_dir = os.path.join(user_info['workspace'], 'work', self._job_id)
        if not os.path.exists(self._work_dir):
            os.makedirs(self._work_dir)
        
        # log目录
        self._log_dir = os.path.join(user_info['workspace'], 'log', 'analyse')
        if not os.path.exists(self._log_dir):
            os.makedirs(self._log_dir)

        if self._local_os == 'windows':
            self._zip_path = os.path.join(CURRENT_DIR, 'tool', 'zip', self._local_os, '7z.exe')
        else:
            self._zip_path = os.path.join(CURRENT_DIR, 'tool', 'zip', self._local_os, '7z')

        self._task_json_path = os.path.join(self._work_dir, 'task.json')
        self._asset_json_path = os.path.join(self._work_dir, 'asset.json')
        self._tips_json_path = os.path.join(self._work_dir, 'tips.json')
        self._upload_json_path = os.path.join(self._work_dir, 'upload.json')

        self._task_info = {
            'task_info': {
                'input_cg_file': '',  # 提交场景文件路径
                'is_picture': 'false',  # 是否渲染效果图true/false
                'task_id': self._job_id,  # 作业id
                'frames_per_task': '1',  # 一机渲多帧的帧数量
                'test_frames': '000',  # 优先渲染
                'time_out': '12',  # 超时时间
                'stop_after_test': '2',  # 优先渲染完成后是否暂停任务,1:优先渲染完成后暂停任务 2.优先渲染完成后不暂停任务
                'project_name': '',  # 项目名称
                'project_id': '',  # 项目id
                'channel': user_info['channel'],  # 提交方式
                'cg_id': '',  # 渲染软件id
                'platform': user_info['platform'],  # 提交平台
                'is_split_render': '0',  # 是否开启分块渲染 1开启
                'split_tiles': '1',  # 分块数量
                'is_layer_rendering': '1',  # maya是否开启分层
                'is_distribute_render': '0',  # 是否开启分布式渲染
                'distribute_render_node': '3',  # 分布式渲染机器数
                'user_id': user_info['user_id'],  # 用户id
                'input_project_path':''  # 项目路径
            },
            'software_config': {},
            'scene_info': {},
            'scene_info_render': {}
        }  # task.json
        self._asset_info = {}  # asset.json
        self._tips_info = {}  # tips.json
        self._upload_info = {}  # upload.json
        
        self.job_id = self._job_id
        self.local_os = self._local_os
        self.json_dir = self._work_dir
        self.zip_path = self._zip_path
        self.task_json_path = self._task_json_path
        self.asset_json_path = self._asset_json_path
        self.tips_json_path = self._tips_json_path
        self.upload_json_path = self._upload_json_path
        self.task_info = self._task_info
        self.asset_info = self._asset_info
        self.tips_info = self._tips_info
        self.upload_info = self._upload_info

"""
===========task.json===========
{
    "system_info":{
        "common":{
 
        }
    },
    "software_config":{
        "plugins":{
            "mtoa":"2.1.0.2",
            "redshift":"2.5.56"
        },
        "cg_version":"2018",
        "cg_name":"maya"
    },
    "scene_info":{
 
    },
    "scene_info_render":{
    },
    "miscellaneous":{
        "only_photon":"0"
    },
    "advanced_option":{
        "project_name":"test"
    }
}

===========asset.json===========
{
    "asset":[
        {
            "node":"nodename.attributename1",
            "path":[
                "p:/dir1/dir2/abc001.exr",
                "m:/dir33/mere.jpg"
            ]
        },
        {
            "node":"nodename.attributename2",
            "path":[
                "p:/dir1/dir2/abc002.exr",
                "e:/dir3/pict.jpg"
            ]
        }
    ],
    "scene_file":"M:/jdjjdj/XXX.ma",
    "missing_file":[
        {
            "node":"nodename.attributename11",
            "path":[
                "p:/dir1/dir2/abc0011.exr",
                "m:/dir33/mere11.jpg"
            ]
        },
        {
            "node":"nodename.attributename12",
            "path":[
                "p:/dir1/dir2/abc0012.exr",
                "e:/dir3/pict12.jpg"
            ]
        }
    ]
}

===========tips.json===========
{
    "10013":[

    ]
}

===========upload.json(SDK)============
{
    "asset":[
        {
            "local":"E:/Workspaces/3dmax/2014/max2014.max",
            "server":"/E/Workspaces/3dmax/2014/max2014.max"
        },
        {
            "local":"E:/Workspaces/3dmax/2014/新建文件夹/readme.txt",
            "server":"/E/Workspaces/3dmax/2014/新建文件夹/readme.txt"
        }
    ]
}
"""