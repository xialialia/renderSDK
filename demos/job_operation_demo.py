#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import os
import codecs
import json

# 将rayvision_SDK目录加入python的搜索模块的路径集
CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
rayvision_sdk_path = os.path.join(CURRENT_DIR, 'rayvision_SDK')

sys.path.append(rayvision_sdk_path)
from Rayvision import Rayvision

# 登录
rayvision = Rayvision(domain_name='dev.renderbus.com', platform='1', account='xiexianguo', access_key='$apr1$X5Q4lau1$tkyi4wvBXoQhKOP0G87e51', workspace='c:/renderfarm/sdk_test')

# 查询所有渲染任务信息
result = rayvision.get_rendering_list()

# 根据关键字查询任务信息
result = rayvision.search_job(search_word="mb")

# 根据作业号查询任务信息
result = rayvision.get_job_status(job_id="5541")

with codecs.open(r'C:\renderfarm\sdk_test\log\sdk\result.json', 'w', 'utf-8') as f:
    json.dump(result, f, indent=4, ensure_ascii=False)




