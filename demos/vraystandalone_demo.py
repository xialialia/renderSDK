#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import sys

# Add renderSDK path to sys.path
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

workspace=r'C:\RenderFarm\sdk_test'

# 1.Log in
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='$apr1$sqNiqnvN$2hBywlncv3aVJScCNrBkW/', access_key='$apr1$//xgcB9F$6Q3gHKcoHJPvt7BM4tq6e1', workspace=workspace)

# 2.Set up rendering environment(plug-in configuration, project name)
job_id = rayvision.set_render_env(cg_name='VR Standalone', cg_version='standalone_vray3.10.03', plugin_config={}, label_name='dasdd')

# 3.Set up render parameter

task_info = {
    'input_cg_file': r'H:\test2014vr_vraystandaloneaCopy.vrscene',
    'is_distribute_render': '1',
    'distribute_render_node': '3'
}

upload_info = {
    "asset": [
    ]
}

# 4.Submit job
rayvision.submit_job(task_info=task_info, upload_info=upload_info, max_speed=100)

# 5.Download
# rayvision.download(job_id_list=[370271], local_dir=r"/root/chensr/renderSDK/output", max_speed=100)
