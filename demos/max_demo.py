#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import os

# 将rayvision_SDK目录加入python的搜索模块的路径集
CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
rayvision_sdk_path = os.path.join(CURRENT_DIR, 'rayvision_SDK')

sys.path.append(rayvision_sdk_path)
from Rayvision import Rayvision

# 1.登录
rayvision = Rayvision(domain_name='dev.renderbus.com', platform='1', account='xiexianguo', access_key='$apr1$X5Q4lau1$tkyi4wvBXoQhKOP0G87e51', workspace='c:/renderfarm/sdk_test')

# 2.设置作业配置（插件配置、所属项目）
rayvision.set_job_config(cg_name='3ds Max', cg_version='2014', plugin_config={}, project_name='dasdd')

# 3.分析
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\chensr\Scene\max2014.max')

# 4.用户自行处理错误、警告
error_info_list = rayvision.check_error_warn_info()

# 5.用户修改参数列表
scene_info_render_new = scene_info_render
task_info_new = task_info

rayvision._user_info['cfg_id'] = '3450'

rayvision.submit_job(scene_info_render_new, task_info_new)

# 8.下载
# rayvision.download(job_id='5134', local_dir=r"d:\project\output")
