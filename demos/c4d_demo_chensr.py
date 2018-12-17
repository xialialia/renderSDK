#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import sys

# Add renderSDK path to sys.path
renderSDK_path = r'D:\gitlab\renderSDK'
sys.path.append(renderSDK_path)

from renderSDK.Rayvision import Rayvision

workspace=r'D:\gitlab\renderSDK\sdk_test'

# 1.Log in
rayvision = Rayvision(domain_name='test.renderbus.com', platform='2', access_id='kz5uwhPULZ2SgosYHL1eJIIBaSgWVkZp', access_key='3a3251ac700db507f806874a68f1fd8a', workspace=workspace)

# 2.Set up rendering environment(plug-in configuration, project name）
job_id = rayvision.set_render_env(cg_name='Cinema 4D', cg_version='R19', plugin_config={}, label_name='dasdd')

# 3.Set up render parameter
scene_info_render = {
    "renderer": {
      "name": "Physical",
      "physical_sampler_mode": "Infinite",
      "physical_sampler": "Adaptive"
    },
    "common": {
      "frames": "0-10[1]",
      "multipass_saveonefile": "1",
      "fps": "30",
      "multipass_save_enabled": "1",
      "frame_rate": "30",
      "multi_pass": {
      "Post Effects": []
    },
    "saved_version": "MAXON CINEMA 4D Studio (R16) 16.038",
    "regular_image_format": "TIFF",
    "multi_pass_format": "PSD",
    "regular_image_saveimage_path": "test_c4d",
    "all_format": [
      "RLA",
      "HDR",
      "PSB",
      "TIFF",
      "TGA",
      "BMP",
      "IFF",
      "JPEG",
      "PICT",
      "PSD",
      "DDS",
      "RPF",
      "B3D",
      "PNG",
      "DPX",
      "EXR"
    ],
    "regular_image_save_enabled": "1",
    "created_version": "MAXON CINEMA 4D Studio (R16) 16.038",
    "all_camera": [
      "Camera.1",
      "Camera"
    ],
    "width": "1080",
    "isConstrained": 0,
    "multipass_saveimage_path": "",
    "height": "1080",
    "c4d_software_version": 19024
  }
}

task_info = {
    'input_cg_file': r'X:/Test_c4d/test_c4d.c4d',
    'frames_per_task': '3'
}

upload_info = {
    "asset": [
        {
            "local": "X:/Test_c4d/test_c4d.c4d",
            "server": "/X/Test_c4d/test_c4d.c4d"
        }
    ]
}

# 4.Submit job
rayvision.submit_job(scene_info_render, task_info, upload_info, max_speed=100)

# 5.Download
rayvision.auto_download(job_id_list=[job_id], local_dir=r"D:\gitlab\renderSDK\sdk_test\output")
# rayvision.auto_download_after_job_completed(job_id_list=[job_id], local_dir=r"c:/renderfarm/sdk_test/output")
