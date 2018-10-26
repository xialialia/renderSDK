#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys

# 将最外层renderSDK目录加入python的搜索模块的路径集
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

workspace='c:/renderfarm/sdk_test'

# 1.登录
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPPP', access_key='Gu5t9xGARNpq86cd98joQYCN3EXAMPLEXX', workspace=workspace)

# 2.设置渲染环境（插件配置、所属项目）
rayvision.set_render_env(cg_name='Katana', cg_version='2.5v3', plugin_config={}, label_name='dasdd')

# 3.分析
# scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\gitlab\renderSDK\scenes\001_005_test.katana')

# 4.用户自行处理错误、警告
# error_info_list = rayvision.check_error_warn_info()

# 5.用户修改参数列表（可选），并提交作业

rayvision._job_info._upload_info = {
  "asset": [
    {
      "server": "/D/gitlab/renderSDK/scenes/001_005_test.katana",
      "local": "D:/gitlab/renderSDK/scenes/001_005_test.katana"
    }
  ]
}


scene_info_render_new = {
    "rendernodes":{
        "825_100_r1_envir_Din_Apt_VOL":[
            {
                "VOL":"/W/WDN/misc/user/tho/825_100_v2/images/r1/envir/Din_AptVOL/Din_Apt_VOL.0150.exr",
                "denoise_VOL":"/tmp/katana_tmpdir_26692/825_100_done_825_100_r1_envir_Din_Apt_VOL_denoise_VOL_misc_raw.150.exr",
                "denoise_primary":"/tmp/katana_tmpdir_26692/825_100_done_825_100_r1_envir_Din_Apt_VOL_denoise_primary_misc_raw.150.exr",
                "primary":"/W/WDN/misc/user/tho/825_100_v2/images/r1/envir/Din_Aptprimary/Din_Apt_primary.0150.exr",
                "denoiseVariance":"/W/WDN/misc/user/tho/825_100_v2/images/r1/envir/Din_Apt/preDenoise/denoiseVariance/beauty_variance.0150.exr"
            },
            {
                "start":1,
                "end":1
            }
        ],
        "825_100_r1_char_din_MATTE":[
            {
                "MATTE":"/W/WDN/misc/user/tho/825_100_v2/images/r1/char/dinMATTE/din_MATTE.0150.exr",
                "DATA":"/W/WDN/misc/user/tho/825_100_v2/images/r1/char/dinDATA/din_DATA.0150.exr",
                "primary":"/tmp/katana_tmpdir_26692/825_100_done_825_100_r1_char_din_MATTE_primary_rgba_misc_linear.150.exr"
            },
            {
                "start":1,
                "end":1
            }
        ]
    }
}
rayvision.submit_job(scene_info_render_new)

# 6.下载
# rayvision.download(job_id_list=[370271], local_dir=r"d:\project\output")
