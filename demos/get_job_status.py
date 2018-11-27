#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import codecs
import json
import time

# Add renderSDK path to sys.path
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

# 1.Log in
rayvision = Rayvision(domain_name='task.foxrenderfarm.com', platform='2', access_id='YHLMWoZHoMz51vNVoxnxNA8HBURCzP1o', access_key='3500a75ce65fecbb29db003ca780f7db', workspace='c:/renderfarm/sdk_test')

while True:
    result = rayvision._manage_job_obj.is_job_done([895153])
    print(result)
    if result is True:
        break
    time.sleep(10)
    
rayvision.download(job_id_list=[895153], local_dir=r"d:\project\output")


# result = rayvision._manage_job_obj.get_job_status([895059])
# with codecs.open('d:/demo.json', 'w', 'utf-8') as f:
    # json.dump(result, f, indent=4, ensure_ascii=False)




