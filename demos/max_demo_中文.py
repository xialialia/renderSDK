#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import os


# 将最外层renderSDK目录加入python的搜索模块的路径集
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

# 1.登录
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPPP', access_key='Gu5t9xGARNpq86cd98joQYCN3EXAMPLEXX', workspace='c:/renderfarm/sdk_test')

# 2.设置作业配置（插件配置、所属项目）
rayvision.set_render_env(cg_name='3ds Max', cg_version='2014', plugin_config={}, label_name='中文测试')

# 3.分析
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\gitlab\renderSDK\scenes\中文测试\max2014_vray3.00.03_中文.max')

# 4.用户自行处理错误、警告
error_info_list = rayvision.check_error_warn_info()

# 5.用户修改参数列表
scene_info_render_new = scene_info_render
task_info_new = task_info

rayvision.submit_job(scene_info_render_new, task_info_new)

# 8.下载
# rayvision.download(job_id_list=[370276], local_dir=r"d:\project\output")
