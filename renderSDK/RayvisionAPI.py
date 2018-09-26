#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""
API
"""

from compat import *  # 20180925 debug

import urllib
import urllib2
import logging
import time
import random
import hashlib
import hmac
import base64
import copy
import collections
from numbers import Number

from RayvisionException import APIError  # 20180925 debug

class RayvisionAPI(object):
    def __init__(self, domain_name, platform, access_id, access_key, log_obj=None):
        """
        API initialization.
        :param str domain_name:  域名，如：task.renderbus.com
        :param str platform:  平台号，如：2
        :param str access_id:  授权id，用于标识API调用者身份
        :param str access_key:  授权密钥，用于加密签名字符串和服务器端验证签名字符串
        :param log_obj: 日志对象，有则会打印API的日志
        """
        # 是否需要打印API日志（POST, HTTP Headers, HTTP Body, HTTP Response）
        if log_obj is None:
            self.need_log = False
        else:
            self.need_log = True
            self.G_SDK_LOG = log_obj

        api_version = '1.0.0'  # API版本号
        protocol = 'https'  # 20180925 debug
        
        self.domain_name = domain_name
        self.access_key = access_key
        self._protocol_domain = r'{0}://{1}'.format(protocol, domain_name)  # 如https://task.renderbus.com
        self._headers = {
            'accessId': access_id,  # 授权ID，由渲染平台提供
            'channel': '4',  # 提交方式，固定值: 4
            'platform': platform,  # 平台标识
            'UTCTimestamp': '',  # UTC时间戳（秒）
            'nonce': '',  # 六位随机数（100000-999999），防止重放攻击
            'signature': '',  # 数据签名（不参与签名）
            'version': '1.0.0',  # 版本号，如1.0.0
            'Content-Type': 'application/json'  # 内容类型
        }
        
        self._uri_dict = {
            'queryPlatforms': '/api/render/common/queryPlatforms',  # 获取平台列表
            'queryUserProfile': '/api/render/user/queryUserProfile',  # 获取用户详情
            'queryUserSetting': '/api/render/user/queryUserSetting',  # 获取用户设置
            'updateUserSetting': '/api/render/user/updateUserSetting',  # 更新用户设置
            'getTransferBid': '/api/render/task/getTransferBid',  # 获取用户传输BID
            'createTask': '/api/render/task/createTask',  # 创建任务号
            'submitTask': '/api/render/task/submitTask',  # 提交任务
            'queryErrorDetail': '/api/render/common/queryErrorDetail',  # 获取分析错误码
            'getTaskList': '/api/render/task/getTaskList',  # 获取任务列表
            'stopTask': '/api/render/task/stopTask',  # 停止任务
            'startTask': '/api/render/task/startTask',  # 开始任务
            'abortTask': '/api/render/task/abortTask',  # 放弃任务
            'deleteTask': '/api/render/task/deleteTask',  # 删除任务
            'queryTaskFrames': '/api/render/task/queryTaskFrames',  # 获取任务总渲染帧概况
            'queryAllFrameStats': '/api/render/task/queryAllFrameStats',  # 重提失败帧
            'restartFailedFrames': '/api/render/task/restartFailedFrames',  # 重提任务指定帧
            'restartFrame': '/api/render/task/restartFrame',  # 获取任务详情
            'queryTaskInfo': '/api/render/task/queryTaskInfo',  # 添加自定义标签
            'addLabel': '/api/render/common/addLabel',  # 删除自定义标签
            'deleteLabel': '/api/render/common/deleteLabel',  # 获取自定义标签
            'getLabelList': '/api/render/common/getLabelList',  # 获取支持的渲染软件
            'querySupportedSoftware': '/api/render/common/querySupportedSoftware',  # 获取支持的渲染软件插件
            'querySupportedPlugin': '/api/render/common/querySupportedPlugin',  # 新增用户渲染环境配置
            'addRenderEnv': '/api/render/common/addRenderEnv',  # 修改用户渲染环境配置
            'updateRenderEnv': '/api/render/common/updateRenderEnv',  # 删除用户渲染环境配置
            'deleteRenderEnv': '/api/render/common/deleteRenderEnv',  # 设置默认渲染环境配置
            'setDefaultRenderEnv': '/api/render/common/setDefaultRenderEnv'  # 获取用户渲染环境配置
            
            # 'login': '/api/rendering/user/sdk/login',  # 登录
            # 'get_storage_id': '/api/rendering/task/sdk/getTaskPathInfo',  # 获取用户存储ID
            # 'get_user_balance': '/api/rendering/user/sdk/getUserBalance',  # 获取用户余额
            # 'get_user_plugin_config': '/api/rendering/task/sdk/getPluginUserList',  # 获取用户插件配置
            # 'add_user_plugin_config': '/api/rendering/task/sdk/addUserPluginConfig',  # 新增用户插件配置
            # 'edit_user_plugin_config': '/api/rendering/task/sdk/editUserPluginConfig',  # 编辑用户插件配置
            # 'del_user_plugin_config': '/api/rendering/task/sdk/delUserPluginConfigOrSetDefault',  # 删除用户插件配置
            # 'get_plugins_supported_by_platform': '/api/rendering/task/sdk/getPluginList',  # 获取平台支持的插件
            # 'get_project': '/api/rendering/task/sdk/getProject',  # 获取项目标签
            # 'get_job_id': '/api/rendering/task/sdk/createSdkJobId',  # 获取作业号
            # 'submit_job': '/api/rendering/task/sdk/sdkSubmitJob',  # 提交作业
            # 'get_job_info': '',  # 获取作业信息
            # 'get_job_list': '/api/rendering/task/sdk/getRenderTaskList',  # 获取作业列表
            # 'search_job': '',  # 搜索作业
            # 'start_job': '',  # 开始作业
            # 'pause_job': '',  # 暂停作业
            # 'get_error_code_info': '/api/rendering/task/sdk/getErrorCodeByCode'  # 根据错误码获取该错误码的详细信息
        }

    def generate_UTCTimestamp(self):
        """
        生成时间戳（秒）
        这里对时间戳的理解：
            UTC时间的时间戳 = UTC当前时间 - 本地起始时间
            本地时间戳 = 本地当前时间 - 本地起始时间

        :return: UTCTimestamp
        :rtype: str
        """
        return str(int(time.time() + time.timezone))
        
    def generate_nonce(self):
        """
        生成6位随机数(100000-999999)，防止重放攻击
        :return: nonce
        :rtype: str
        """
        return str(random.randrange(100000, 999999))
        
    def generate_signature(self, key, msg):
        """
        生成签名字符串，先用sha256算法将msg加盐key计算出摘要，再将摘要用base64算法得出签名字符串
        :param str key: salt
        :param str msg: source string
        :return: signature
        :rtype: str
        """
        key = to_bytes(key)
        msg = to_bytes(msg)

        hash_obj = hmac.new(key, msg=msg, digestmod=hashlib.sha256)
        digest = hash_obj.digest()  # 摘要

        signature = base64.b64encode(digest)  # 签名
        return to_unicode(signature)
        
    def generate_header_body_str(self, api_uri, header, body):
        """
        根据Header和Body生成格式化字符串，用于生成签名（signature和Content-Type不参与签名）
        请求方法 + 域名 + API URI + 请求字符串
        :param str api_uri:
        :param dict header:
        :param dict body:
        """
        result_str = ''
        header = copy.deepcopy(header)
        body = copy.deepcopy(body)
        try:
            header.pop('signature')
        except:
            pass
        try:
            header.pop('Content-Type')
        except:
            pass
        header_body_dict = self.header_body_sort(header, body)
        
        header_body_list = []
        for key, value in header_body_dict.items():
            header_body_list.append('{0}={1}'.format(key, value))
        header_body_str = '&'.join(header_body_list)
        
        result_str = '[POST]{domain_name}:{api_uri}&{header_body_str}'.format(
            domain_name=self.domain_name,
            api_uri=api_uri,
            header_body_str=header_body_str
        )
        
        return result_str
    
    def header_body_sort(self, header, body):
        """
        对所有 自定义 http请求头 和 请求参数 按参数名的字典序（ASCII 码）升序排序
        :param dict header: 请求头
        :param dict body: 请求参数
        :return: 请求头与请求参数排序后的有序字典对象
        :rtype: OrderedDict
        """
        mix_dict = copy.deepcopy(header)
        body = copy.deepcopy(body)
        mix_dict.update(body)
        
        # 处理复杂对象
        mix_dict_new = self.handle_complex_dict(mix_dict)
        
        sorted_key_list = sorted(mix_dict_new)  # 排序好的字典
        
        new_dict = collections.OrderedDict()  # 有序字典
        for key in sorted_key_list:
            new_dict[key] = mix_dict[key]
            
        return new_dict
        
    def handle_complex_dict(self, mix_dict):
        """
        "格式化"字典
        该字典中可能的数据类型：numbers.Number, str, bytes, list, dict, None（json的key只能为string，json的value可能为数字、字符串、逻辑值、数组、对象、null）
        如
        {
            "taksId":2,
            "renderEnvs":[
                {
                    "envId":1,
                    "pluginIds":[
                        2,
                        3,
                        4
                    ]
                },
                {
                    "envId":3,
                    "pluginIds":[
                        7,
                        8,
                        10
                    ]
                }
            ]
        }
        #格式化结果如下
        {
            "taksId":2
            "renderEnvs0.envId":1
            "renderEnvs0.pluginIds0":2
            "renderEnvs0.pluginIds1":3
            "renderEnvs0.pluginIds2":4
            "renderEnvs1.envId":3
            "renderEnvs1.pluginIds0":7
            "renderEnvs1.pluginIds1":8
            "renderEnvs1.pluginIds2":10
        }
       
        """
        new_dict = {}
        def format_dict(value, key=None):
            """
            :param value: 
            :param key: None/str, key若为None，说明value为源字典对象
            """
            if isinstance(value, dict):
                for key_new_part, value in value.items():
                    if key is None:
                        new_key = key_new_part
                    else:
                        new_key = '{0}.{1}'.format(key, key_new_part)
                    format_dict(value, new_key)
                    
            elif isinstance(value, list):
                for index, value in enumerate(value):
                    new_key = '{0}{1}'.format(key, index)
                    format_dict(value, new_key)
                   
            elif isinstance(value, Number):
                new_dict[key] = value
            elif isinstance(value, (str, bytes)):
                new_dict[key] = value
            elif value is None:
                new_dict[key] = value
                
        format_dict(mix_dict)
        return new_dict
        
    def _post(self, api_uri, data={}):
        """
        Send an post request and return data object if no error occurred.
        :param str api_uri: The api uri.
        :param dict data:
        :return:
        :rtype: dict/List/None
        """
        url = r'{}{}'.format(self._protocol_domain, api_uri)
        
        headers = copy.deepcopy(self._headers)
        headers['UTCTimestamp'] = self.generate_UTCTimestamp()
        headers['nonce'] = self.generate_nonce()
        
        msg = self.generate_header_body_str(api_uri, headers, data)
        headers['signature'] = self.generate_signature(self.access_key, msg)
        
        # http_body = urllib.urlencode(data)
        http_headers = json.dumps(headers)
        http_body = json.dumps(data)
        
        # 20180925 debug
        print('POST: {}'.format(url))
        print('HTTP Headers: {}'.format(http_headers))
        print('HTTP Body: {}'.format(http_body))
        
        if self.need_log:
            self.G_SDK_LOG.info('POST: {}'.format(url))
            self.G_SDK_LOG.debug('HTTP Headers: {}'.format(http_headers))
            self.G_SDK_LOG.debug('HTTP Body: {}'.format(http_body))
        
        request = urllib2.Request(url, data=http_body, headers=headers)
        
        try:
            response = urllib2.urlopen(request, timeout=5)
        except Exception as e:
            return_message = e
            raise APIError(100001, return_message, url)  # URL ERROR

        content = response.read().decode('utf-8')
        r = json.loads(content)
        if self.need_log:
            self.G_SDK_LOG.debug('HTTP Response: {}'.format(r))
            
        # 20180925 debug
        print('HTTP Response: {}'.format(r))

        return_code = r.get('code', -1)
        return_message = r.get('message', 'No message!!!')
        return_data = r.get('data', None)

        if return_code != 200:
            raise APIError(return_code, return_message, url)
        return return_data

    def query_platforms(self):
        """
        获取平台列表
        """
        api_uri = self._uri_dict.get('queryPlatforms')
        zone = 1 if 'renderbus' in self.domain_name.lower() else 2
        data = {
            'zone': zone
        }
        r_data = self._post(api_uri, data)
        return r_data
        
        
    # 1.登录
    def _login(self, account, access_key):
        """
        Login.
        :param str account:
        :param str access_key: Need to apply.
        :return: userId...
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('login'))
        data = {
            "account": account,
            "accessKey": access_key
        }
        r_data = self._post(url, data)
        user_id = r_data.get('id')
        self._headers['userId'] = long(user_id)
        return r_data

    # 2.获取用户存储ID
    def _get_storage_id(self):
        """
        Get user storage id, download id, cfg id.
        :param str user_id:
        :return: storageId, downloadId, cfgId
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_storage_id'))
        data = {}
        r_data = self._post(url, data)
        return r_data

    # 3.查询用户余额
    def _get_user_balance(self):
        """
        Get user's balance information.
        :return:  rmbBalance, usdBalance, coupon
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_user_balance'))
        data = {}
        r_data = self._post(url, data)
        return r_data

    # 4.获取用户插件配置
    def _get_user_plugin_config(self, cg_name):
        """
        Get user plugin configs according to the cg name.
        :param str cg_name: cg name
        :return: editName, cgName, cgVersion, pluginsInfoSdkVos
        :rtype: list
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_user_plugin_config'))
        data = {
            "cgName": cg_name
        }
        r_data = self._post(url, data)
        return r_data

    # 5.新增用户插件配置
    def _add_user_plugin_config(self, config_name, cg_id, cg_name, cg_version, plugins_info):
        """
        Add user plugin config.
        :param str config_name:
        :param str cg_id:
        :param str cg_name:
        :param str cg_version:
        :param list plugins_info:[{"pluginName":"multiscatter","pluginVersion":"1.3.6.9"}]
        :return: None
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('add_user_plugin_config'))
        data = {
            "cgId": cg_id,
            "editName": config_name,
            "cgName": cg_name,
            "cgVersion": cg_version,
            "pluginsInfo": plugins_info
        }
        r_data = self._post(url, data)
        return r_data

    # 6.编辑用户插件配置
    def _edit_user_plugin_config(self, config_name, cg_id, cg_name, cg_version, plugins_info):
        """
        Edit plugin config.
        :param str config_name:
        :param str cg_name:
        :param str cg_version:
        :param list plugins_info:
        :return: None
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('edit_user_plugin_config'))
        data = {
            "cgId": cg_id,
            "editName": config_name,
            "cgName": cg_name,
            "cgVersion": cg_version,
            "pluginsInfo": plugins_info
        }
        r_data = self._post(url, data)
        return r_data

    # 7.删除用户插件配置 -- deleteUserPluginConfig
    def _del_user_plugin_config(self, config_name):
        """
        Delete plugin config.
        :param str config_name:
        :return: None
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('del_user_plugin_config'))
        data = {
            "editName": config_name,
            "type":"1"  # 1:删除 2:设为默认
        }
        r_data = self._post(url, data)
        return r_data

    # 8.获取平台支持的插件
    def _get_plugins_supported_by_platform(self, cg_name):
        """
        Add plugin config.
        :param str cg_name:
        :return:
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_plugins_supported_by_platform'))
        data = {
            "cgName": cg_name
        }
        r_data = self._post(url, data)
        return r_data

    # 9.获取项目标签
    def _get_project(self):
        """
        Get project list.
        :return: projectName
        :rtype: list
        """
        url = r'%s%s' % (self._protocol_domain, self._uri_dict.get('get_project'))
        data = {}
        r_data = self._post(url, data)
        return r_data

    # 10.获取作业号
    def _get_job_id(self, count=1):
        """
        Get job id.
        :return: jobId
        :rtype: list
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_job_id'))
        data = {
            'count': count
        }
        r_data = self._post(url, data)
        return r_data

    # 11.提交作业
    def _submit_job(self, task_id):
        """
        Submit job.
        :param int task_id:
        :return: taskId, cameraName, layerName, nodeName, submitResult
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('submit_job'))
        data = {
            "taskId": int(task_id)
        }
        r_data = self._post(url, data)
        return r_data

    # 12.获取作业信息
    def _get_job_info(self, job_id):
        """
        Get job information.
        :param str job_id:
        :return:
        :rtype: dict
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_job_info'))
        data = {
            "jobId": job_id
        }
        r_data = self._post(url, data)
        return r_data

    # 13.获取作业列表
    def _get_job_list(self, page_size, page_num, search_keyword=""):
        """
        Get job list.
        :param page_size:
        :param page_num:
        :param search_keyword:
        :return:
        :rtype: list
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_job_list'))
        data = {
            "pageSize": page_size,
            "pageNum": page_num,
            "renderStatus": 1,  # default is 10
            "searchKeyword": str(search_keyword)
        }
        r_data = self._post(url, data)
        return r_data

    # 14.搜索作业 -- searchJob
    # 15.开始作业 -- startJob
    # 16.暂停作业 -- pauseJob

    # 17.根据错误码获取该错误码的详细信息
    def _get_error_code_by_code(self, code):
        """
        Get error code information.
        :param code: error code
        :return:
        :rtype: list
        """
        url = r'{}{}'.format(self._protocol_domain, self._uri_dict.get('get_error_code_info'))
        data = {
            "code": code
        }
        r_data = self._post(url, data)
        return r_data


if __name__ == '__main__':
    access_id = r'AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPPP'
    access_key = r'Gu5t9xGARNpq86cd98joQYCN3EXAMPLEXX'
    domain_name = r'test.renderbus.com'
    platform = '20'
    
    rayvision = RayvisionAPI(domain_name, platform, access_id, access_key, log_obj=None)
    r_data = rayvision.query_platforms()
    print(r_data)
        