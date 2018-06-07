#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
Transfer Module.
"""
import os
import sys
import json
import codecs
import subprocess

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))


class RayvisionTransfer(object):
    def __init__(self, user_info, api_obj):
        self.user_info = user_info
        self.api_obj = api_obj

        self.domain_name = user_info.get('domain_name')
        self.platform = user_info.get('platform')
        self.local_os = user_info.get('local_os')
        self.user_id = user_info.get('user_id')
        self.storage_id = user_info.get('storage_id')
        self.download_id = user_info.get('download_id')
        self.cfg_id = user_info.get('cfg_id', None)

        if self.local_os == 'windows':
            self.rayvision_exe = os.path.join(CURRENT_DIR, 'rayvision', 'transmission', self.local_os, 'rayvision_transmitter.exe')
        else:
            self.rayvision_exe = os.path.join(CURRENT_DIR, 'rayvision', 'transmission', self.local_os, 'rayvision_transmitter')

        self.transports_json = os.path.join(CURRENT_DIR, 'rayvision', 'transmission', 'transports.json')
        transport_info = self.parse_transports_json()
        self.engine_type = transport_info['engine_type']
        self.server_name = transport_info['server_name']
        self.server_ip = transport_info['server_ip']
        self.server_port = transport_info['server_port']

    def parse_transports_json(self):
        if 'foxrenderfarm' in self.domain_name:
            key_first_half = 'foxrenderfarm'
        else:
            key_first_half = 'renderbus'

        if self.platform == '2':
            key_second_half = 'www2'
        elif self.platform == '5':  # pic
            key_second_half = 'pic'
        elif self.platform == '8':
            key_second_half = 'www8'
        elif self.platform == '9':
            key_second_half = 'www9'
        elif self.platform == '10':  # gpu
            key_second_half = 'gpu'
        else:
            key_second_half = 'default'

        if key_second_half == 'default':
            key = key_second_half
        else:
            key = '%s_%s' % (key_first_half, key_second_half)

        with codecs.open(self.transports_json, 'r', 'utf-8') as f:
            transports_info = json.load(f)
        return transports_info[key]

    def upload(self, upload_info, **kwargs):
        transmit_type = "upload_files"  # upload_files/upload_file_pairs/download_files

        for file_local_server in upload_info['asset']:
            local_path = file_local_server['local']
            server_path = file_local_server['server']
            if not os.path.exists(local_path):
                print '{} is not exists.'.format(local_path)
                continue

            transmit_cmd = 'echo y|"{exe_path}" "{engine_type}" "{server_name}" "{server_ip}" "{server_port}" \
            "{storage_id}" "{user_id}" "{transmit_type}" "{local_path}" "{server_path}" "{max_connect_failure_count}" \
            "{keep_path}"'.format(
                exe_path=self.rayvision_exe,
                engine_type=self.engine_type,
                server_name=self.server_name,
                server_ip=self.server_ip,
                server_port=self.server_port,
                storage_id=self.user_info['storage_id'],
                user_id=self.user_info['user_id'],
                transmit_type=transmit_type,
                local_path=local_path,
                server_path=server_path,
                max_connect_failure_count=1,
                keep_path='false',
            )
            print transmit_cmd
            sys.stdout.flush()
            os.system(transmit_cmd)

    def download(self, task_id, local_dir, **kwargs):
        transmit_type = 'download_files'

        data = self.api_obj.get_job_info(task_id)
        if data:
            server_folder = '{}_{}'.format(task_id, os.path.splitext(data['sceneName'])[0].strip())
            transmit_cmd = 'echo y|"{exe_path}" "{engine_type}" "{server_name}" "{server_ip}" "{server_port}" \
                           "{download_id}" "{user_id}" "{transmit_type}" "{local_path}" "{server_path}"'.format(
                exe_path=self.rayvision_exe,
                engine_type=self.engine_type,
                server_name=self.server_name,
                server_ip=self.server_ip,
                server_port=self.server_port,
                download_id=self.user_info['download_id'],
                user_id=self.user_info['user_id'],
                transmit_type=transmit_type,
                local_path=local_dir,
                server_path=server_folder,
            )
            print transmit_cmd
            sys.stdout.flush()
            os.system(transmit_cmd)


if __name__ == '__main__':
    user_info = {
        'domain_name':'task.renderbus.com',
        'platform': 'default',
        'local_os': 'windows',
        'user_id': '1852991',
        'storage_id': '3441',
        'download_id': '3431',
    }
    upload_info = {
        "asset":[
            {
                "local":"E:/Workspaces/3dmax/2014/test.txt",
                "server":"/E/Workspaces/3dmax/2014/test.txt"
            },
            {
                "local":"E:/Workspaces/3dmax/2014/OGLdpf.log",
                "server":"/E/Workspaces/3dmax/2014/OGLdpf.log"
            }
        ]
    }

    obj = RayvisionTransfer(user_info, api_obj=None)
    obj.upload(upload_info)