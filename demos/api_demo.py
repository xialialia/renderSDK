#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
import os

# 将最外层renderSDK目录加入python的搜索模块的路径集
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.RayvisionAPI import RayvisionAPI

access_id = r'AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPPP'
access_key = r'Gu5t9xGARNpq86cd98joQYCN3EXAMPLEXX'
domain_name = r'test.renderbus.com'
platform = '2'

rayvision = RayvisionAPI(domain_name, platform, access_id, access_key, log_obj=True)
r_data = rayvision.submit_task(370000)
print(r_data)
