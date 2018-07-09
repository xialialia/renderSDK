#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import os
import codecs
import json

# ��rayvision_SDKĿ¼����python������ģ���·����
CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
rayvision_sdk_path = os.path.join(CURRENT_DIR, 'rayvision_SDK')

sys.path.append(rayvision_sdk_path)
from Rayvision import Rayvision

# ��¼
rayvision = Rayvision(domain_name='dev.renderbus.com', platform='1', account='xiexianguo', access_key='$apr1$X5Q4lau1$tkyi4wvBXoQhKOP0G87e51', workspace='c:/renderfarm/sdk_test')

# ��ѯ������Ⱦ������Ϣ
result = rayvision.get_rendering_list()

# ���ݹؼ��ֲ�ѯ������Ϣ
result = rayvision.search_job(search_word="mb")

# ������ҵ�Ų�ѯ������Ϣ
result = rayvision.get_job_status(job_id="5541")

with codecs.open(r'C:\renderfarm\sdk_test\log\sdk\result.json', 'w', 'utf-8') as f:
    json.dump(result, f, indent=4, ensure_ascii=False)




