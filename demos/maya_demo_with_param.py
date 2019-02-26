#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
必填参数：
-s <int> ：  动画序列的开始帧。
-e <int> ：  动画序列的结束帧。
-proj <string> ：当前场景文件的工程目录。

可选参数:
-rl ：渲染层，每次只能填写一个渲染层，如果没有该参数，则将渲染场景中所有设置好的渲染层
-cam : 渲染相机，每次只能填写一个相机，如果没有该参数，则将渲染场景中所有设置好的相机
-x <int> : 设置最终图像的 X 分辨率。
-y <int> : 设置最终图像的 Y 分辨率。
-renderer <string> 或 -r <string>  ： 渲染器，每次只能填写一个渲染器（为arnold，vray，mr，sw，redshift中的一个）
-b <int>	: 动画序列的隔帧数或步长。

示例：
python maya_demo.py -s 100 -e 200 -proj "X:/IG/proj" -rl "renderSetupLayer1" -cam "camera1" -x 800 -y 600 -renderer "mr" -b 1 
"""

import sys
import argparse
import pprint

# Add renderSDK path to sys.path
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

# 0.Accept params
# python maya_demo.py -s 100 -e 200 --proj "X:/IG/proj" --rl "renderSetupLayer1" --cam "camera1" -x 800 -y 600 --renderer "mr" -b 1 
parser = argparse.ArgumentParser(description='Process Some Params.')
parser.add_argument("-s", dest="start_frame", help="start frame", metavar="int")
parser.add_argument("-e", dest="end_frame", help="end frame", metavar="int")
parser.add_argument("-b", dest="by_frame", help="by frame", metavar="int")
parser.add_argument("-x", dest="x_resolution", help="x resolution", metavar="int")
parser.add_argument("-y", dest="y_resolution", help="y resolution", metavar="int")
parser.add_argument("--proj", dest="project_path", help="project path", metavar="string")
parser.add_argument("--rl", dest="render_setup_layer", help="render setup layer", metavar="string")
parser.add_argument("--cam", dest="render_camera", help="render camera", metavar="string")
parser.add_argument("--renderer", dest="renderer", help="renderer", metavar="string")

(args, other_arg_list) = parser.parse_known_args()

start_frame = args.start_frame
end_frame = args.end_frame
by_frame = args.by_frame
x_resolution = args.x_resolution
y_resolution = args.y_resolution
project_path = args.project_path
render_setup_layer = args.render_setup_layer
render_camera = args.render_camera
renderer = args.renderer

# If the parameter value is None, the parameter is not customized
if start_frame is None:
    print '[error]Please input start_frame, usage: [-s 100]'
    sys.exit(-1)
if end_frame is None:
    print '[error]Please input end_frame, usage: [-e 200]'
    sys.exit(-1)
if project_path is None:
    print '[error]Please input project_path, usage: [--proj "X:/pro"]'
    sys.exit(-1)

# 1.Log in
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='kz5uwhPULZ2SgosYHL1eJIIBaSgWVkZp', access_key='3a3251ac700db507f806874a68f1fd8a', workspace='c:/renderfarm/sdk_test')

# 2.Set up rendering environment(plug-in configuration, project name）
job_id = rayvision.set_render_env(cg_name='Maya', cg_version='2016', plugin_config={}, label_name='dasdd')

# 3.Analysis
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\gitlab\renderSDK\scenes\TEST_maya2016_ocean.mb')

# 4. User can Manage the errors or warnings manually, if applicable
error_info_list = rayvision.check_error_warn_info()

# 5.User can modify the parameter list(optional), and then proceed to job submitting
if project_path is not None:
    task_info['input_project_path'] = project_path
    
if render_setup_layer is not None:
    # 将该层的renderable置为"1"，并修改该层的其他信息；其他层置为"0"
    if render_setup_layer in scene_info_render:
        # 层名存在
        for layer in scene_info_render.keys():
            if layer == render_setup_layer:
                # 该层
                scene_info_render[layer]['renderable'] = "1"
                if start_frame is not None:
                    scene_info_render[layer]['common']['start'] = start_frame
                if end_frame is not None:
                    scene_info_render[layer]['common']['end'] = end_frame
                if by_frame is not None:
                    scene_info_render[layer]['common']['by_frame'] = by_frame
                if x_resolution is not None:
                    scene_info_render[layer]['common']['width'] = x_resolution
                if y_resolution is not None:
                    scene_info_render[layer]['common']['height'] = y_resolution
                if render_camera is not None:
                    scene_info_render[layer]['common']['render_camera'] = [render_camera]
                if renderer is not None:
                    scene_info_render[layer]['common']['renderer'] = renderer
                scene_info_render[layer]['common']['frames'] = '{0}-{1}[{3}]'.format(scene_info_render[layer]['common']['start'], scene_info_render[layer]['common']['end'], scene_info_render[layer]['common']['by_frame'])
            else:
                # 其他层
                scene_info_render[layer]['renderable'] = "0"
    else:
        # 层名不存在
        print '[error]The layer({0}) was not found in the scene, please enter the layer already in the scene'.format(render_setup_layer)
        sys.exit(-1)
else:
    # 修改所有层的信息
    for layer in scene_info_render.keys():
        if start_frame is not None:
            scene_info_render[layer]['common']['start'] = start_frame
        if end_frame is not None:
            scene_info_render[layer]['common']['end'] = end_frame
        if by_frame is not None:
            scene_info_render[layer]['common']['by_frame'] = by_frame
        if x_resolution is not None:
            scene_info_render[layer]['common']['width'] = x_resolution
        if y_resolution is not None:
            scene_info_render[layer]['common']['height'] = y_resolution
        if render_camera is not None:
            scene_info_render[layer]['common']['render_camera'] = [render_camera]
        if renderer is not None:
            scene_info_render[layer]['common']['renderer'] = renderer
        scene_info_render[layer]['common']['frames'] = '{0}-{1}[{3}]'.format(scene_info_render[layer]['common']['start'], scene_info_render[layer]['common']['end'], scene_info_render[layer]['common']['by_frame'])
pprint.pprint(scene_info_render)
pprint.pprint(task_info)
    
# scene_info_render_new = scene_info_render
# task_info_new = task_info
# rayvision.submit_job(scene_info_render_new, task_info_new)

# 6.Download
# rayvision.auto_download(job_id_list=[job_id], local_dir=r"c:/renderfarm/sdk_test/output")
# rayvision.auto_download_after_job_completed(job_id_list=[job_id], local_dir=r"c:/renderfarm/sdk_test/output")
