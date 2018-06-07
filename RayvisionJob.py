#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
Store job information module.
"""

import os

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))


class RayvisionJob(object):
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
            self.zip_path = os.path.join(CURRENT_DIR, 'rayvision', 'zip', local_os, '7z.exe')
        else:
            self.zip_path = os.path.join(CURRENT_DIR, 'rayvision', 'zip', local_os, '7z')

        self.task_json_path = os.path.join(self.json_dir, 'task.json')
        self.asset_json_path = os.path.join(self.json_dir, 'asset.json')
        self.tips_json_path = os.path.join(self.json_dir, 'tips.json')
        self.upload_json_path = os.path.join(self.json_dir, 'upload.json')

        self.task_info = {
            'system_info': {
                'common': {}
            },
            'software_config': {},
            'scene_info': {},
            'scene_info_render': {},
            'miscellaneous': {},
            'advanced_option': {}
        }  # task.json
        self.asset_info = {}  # asset.json
        self.tips_info = {}  # tips.json
        self.upload_info = {}  # upload.json

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