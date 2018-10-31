#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import sys
import json
import codecs

# 将最外层renderSDK目录加入python的搜索模块的路径集
renderSDK_path = r'/root/chensr/renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

workspace='/root/chensr/renderSDK/sdk_test'

# 1.登录
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPPP', access_key='Gu5t9xGARNpq86cd98joQYCN3EXAMPLEXX', workspace=workspace)

# 2.设置渲染环境（插件配置、所属项目）
rayvision.set_render_env(cg_name='Katana', cg_version='2.5v3', plugin_config={}, label_name='dasdd')

# 3.设置参数，并提交作业
rayvision._job_info._task_info['task_info']['input_cg_file'] = r'/root/chensr/renderSDK/scenes/001_005_test.katana'
rayvision._job_info._task_info['task_info']['os_name'] = '0'  # Linux
# rayvision._job_info._task_info['task_info']['input_project_path'] = r''

# write upload.json
rayvision._job_info._upload_info = {
  "asset": [
    {
      "server": "/root/chensr/renderSDK/scenes/001_005_test.katana",
      "local": "/root/chensr/renderSDK/scenes/001_005_test.katana"
    }
  ]
}

upload_json_path = rayvision._job_info._upload_json_path
if not os.path.exists(upload_json_path):
    with codecs.open(upload_json_path, 'w', 'utf-8') as f_upload_json:
        json.dump(rayvision._job_info._upload_info, f_upload_json, ensure_ascii=False, indent=4)

# write tips.json
tips_json_path = rayvision._job_info._tips_json_path
if not os.path.exists(tips_json_path):
    with codecs.open(tips_json_path, 'w', 'utf-8') as f_tips_json:
        json.dump(rayvision._job_info._tips_info, f_tips_json, ensure_ascii=False, indent=4)
        
scene_info_render_new = {
    "rendernodes":{
        "001_005_Render":{
            "renderable":"1",
            "denoise":"0",
            "frames":"1-1[1]",
            "aov":{
                "specular":"/w/aovs/specular_1001.exr",
                "diffuse":"/w/aovs/diffuse_1001.exr",
                "primary":"/w/aovs/beauty_1001.exr"
            }
        }
    }
}
rayvision.submit_job(scene_info_render_new)

# 6.下载
# rayvision.download(job_id_list=[370271], local_dir=r"d:\project\output")
