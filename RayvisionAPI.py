#!/usr/bin/env python
# -*- coding:utf-8 -*-

import urllib
import urllib2
import logging
import json

from RayvisionException import APIError


class RayvisionAPI(object):
    def __init__(self, user_info={}, log_obj=None):
        """
        API initialization.
        :param dict user_info:
        """
        if log_obj is None:
            self.need_log = False
        else:
            self.need_log = True
            self.G_SDK_LOG = log_obj
        domain_name = user_info.get('domain_name', 'task.renderbus.com')
        platform = user_info.get('platform', '2')  # 2：www2；5：pic；8：www8；9：www9；10：gpu
        access_key = user_info.get('access_key')
        protocol = 'http'  # http/https

        self._protocol_domain = r'{}://{}'.format(protocol, domain_name)
        self._uri_dict = {
            'login': '/api/rendering/user/sdk/login',  # 登录
            'get_storage_id': '/api/rendering/task/sdk/getTaskPathInfo',  # 获取用户存储ID
            'get_user_balance': '/api/rendering/user/sdk/getUserBalance',  # 获取用户余额
            'get_user_plugin_config': '/api/rendering/task/sdk/getPluginUserList',  # 获取用户插件配置
            'add_user_plugin_config': '/api/rendering/task/sdk/addUserPluginConfig',  # 新增用户插件配置
            'edit_user_plugin_config': '/api/rendering/task/sdk/editUserPluginConfig',  # 编辑用户插件配置
            'del_user_plugin_config': '/api/rendering/task/sdk/delUserPluginConfigOrSetDefault',  # 删除用户插件配置
            'get_plugins_supported_by_platform': '/api/rendering/task/sdk/getPluginList',  # 获取平台支持的插件
            'get_project': '/api/rendering/task/sdk/getProject',  # 获取项目标签
            'get_job_id': '/api/rendering/task/sdk/createSdkJobId',  # 获取作业号
            'submit_job': '/api/rendering/task/sdk/sdkSubmitJob',  # 提交作业
            'get_job_info': '',  # 获取作业信息
            'get_job_list': '/api/rendering/task/sdk/getRenderTaskList',  # 获取作业列表
            'search_job': '',  # 搜索作业
            'start_job': '',  # 开始作业
            'pause_job': '',  # 暂停作业
            'get_error_code_info': '/api/rendering/task/sdk/getErrorCodeByCode'  # 根据错误码获取该错误码的详细信息
        }

        self._headers = {
            'Content-Type': 'application/json',
            'channel': '4',  # 1: web local analysis 2: web cloud analysis 3: plugin analysis 4: SDK analysis
            'platform': str(platform),
            'signature': 'Rayvision2017',
            'version': '1.0.0',
            'userId': '',
            'accessKey': str(access_key)
        }

    def _post(self, url, data={}):
        """
        Send an post request and return data object if no error occurred.
        :param String url: The api path.
        :param dict data:
        :return:
        :rtype: dict/List/None
        """
        if self.need_log:
            self.G_SDK_LOG.info('POST: {}'.format(url))
            self.G_SDK_LOG.debug('HTTP Headers: {}'.format(self._headers))
            self.G_SDK_LOG.debug('HTTP Body: {}'.format(data))

        # http_body = urllib.urlencode(data)
        http_body = json.dumps(data)
        request = urllib2.Request(url, data=http_body, headers=self._headers)
        try:
            response = urllib2.urlopen(request, timeout=5)
        except Exception as e:
            return_message = e
            raise APIError(100001, return_message, url)  # URL ERROR

        content = response.read().decode('utf-8')
        r = json.loads(content)
        if self.need_log:
            self.G_SDK_LOG.debug('HTTP Response: {}'.format(r))

        return_code = r.get('code', -1)
        return_message = r.get('message', 'No message!!!')
        return_data = r.get('data', None)

        if return_code != 200:
            raise APIError(return_code, return_message, url)
        return return_data

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

