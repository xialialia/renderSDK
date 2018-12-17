#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys

# Add renderSDK path to sys.path
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

# 1.Log in
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='kz5uwhPULZ2SgosYHL1eJIIBaSgWVkZp', access_key='3a3251ac700db507f806874a68f1fd8a', workspace='c:/renderfarm/sdk_test')

# 2.Set up rendering environment(plug-in configuration, project name）
rayvision.set_render_env(cg_name='3ds Max', cg_version='2014', plugin_config={}, label_name='dasdd')

# 3.Analysis
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\gitlab\renderSDK\scenes\max2014_vray3.00.03.max')

# 4.User can Manage the errors or warnings manually, if applicable
error_info_list = rayvision.check_error_warn_info()

# 5.User can modify the parameter list(optional), and then proceed to job submitting
scene_info_render_new = scene_info_render
task_info_new = task_info
rayvision.submit_job(scene_info_render_new, task_info_new)

# 6.Download
rayvision.auto_download(job_id_list=[job_id], local_dir=r"D:\gitlab\renderSDK\sdk_test\output")
# rayvision.auto_download_after_job_completed(job_id_list=[job_id], local_dir=r"c:/renderfarm/sdk_test/output")
