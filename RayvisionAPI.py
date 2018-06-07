#!/usr/bin/env python
# -*- coding:utf-8 -*-

import urllib
import urllib2
import logging
import json


class APIError(StandardError):
    """
    raise APIError if receiving json message indicating failure.
    """

    def __init__(self, error_code, error, request):
        self.error_code = error_code
        self.error = error
        self.request = request
        StandardError.__init__(self, error)

    def __str__(self):
        return 'APIError: %s: %s, request: %s' % (self.error_code, self.error, self.request)

    __repr__ = __str__


class RayvisionAPI(object):
    def __init__(self, user_info={}):
        """
        API initialization.
        :param dict user_info:
        """
        # necessary
        domain_name = user_info.get('domain_name', 'task.foxrenderfarm.com')
        platform = user_info.get('platform', '8')  # 2：www2；5：pic；8：www8；9：www9；10：gpu

        # unnecessary, Advanced options
        signature = user_info.get('signature', 'rayvision2017')
        version = user_info.get('version', '1.0.0')
        user_key = user_info.get('user_key', '')
        channel = user_info.get('channel', '4')  # 1: web local analysis 2: web cloud analysis 3: plugin analysis 4: SDK analysis
        protocol = user_info.get('protocol', 'https')  # http/https

        self.protocol_domain = r'%s://%s' % (protocol, domain_name)
        self.uri_dict = {
            'userLogin': '/api/rendering/sdk/user/userLogin',  # 登录
            'getStorageId': '',  # 获取存储ID
            'getUserRenderSetting': '',  # 获取用户自定义设置
            'getUserBalance': '',  # 获取用户余额
            'getPluginUserList': '/api/rendering/task/sdk/getPluginUserList',  # 根据软件名称获取用户的插件配置
            'getUserSinglePluginConfig': '',  # 根据软件名称和插件配置名（editName）获取用户的插件配置
            'addUserPluginConfig': '',  # 新增用户插件配置
            'editUserPluginConfig': '',  # 编辑用户插件配置
            'deleteUserPluginConfig': '',  # 删除用户插件配置
            'getAllSupportPlugin': '',  # 根据软件名称获取平台支持的所有插件信息
            'getSupportCgName': '',  # 获取平台支持软件名称列表
            'getSupportCgVersion': '',  # 根据软件名称获取平台支持的软件版本列表
            'getSupportPluginName': '',  # 根据软件版本获取平台支持的插件名称
            'getSupportPluginVersion': '',  # 根据软件版本和插件名称获取平台支持的插件版本列表
            'getProject': '',  # 获取项目标签列表
            'getJobId': '',  # 获取作业号
            'submitJob': '',  # 提交作业
            'getJobInfo': '',  # 获取作业信息
            'getJobList': '',  # 获取作业列表
            'searchJob': '',  # 搜索作业
            'startJob': '',  # 开始作业
            'pauseJob': '',  # 暂停作业
            'getAllErrorCodeInfo': '',  # 根据软件获取所有错误码详细信息
            'getErrorCodeInfo': ''  # 根据错误码获取该错误码的详细信息
        }

        self.headers = {
            'Content-Type': 'application/json',
            'channel': channel,
            'platform': platform,
            'signature': signature,
            'version': version,
            'userKey': user_key
        }

    def post(self, url, data={}):
        """
        Send an post request and return data object if no error occurred.
        :param String url: The api path.
        :param dict data:
        :return:
        :rtype: dict/List/None
        """
        logging.info('POST %s' % url)
        # http_body = urllib.urlencode(data)
        http_body = json.dumps(data)
        request = urllib2.Request(url, data=http_body, headers=self.headers)
        try:
            response = urllib2.urlopen(request, timeout=5)
            content = response.read().decode('utf-8')
            r = json.loads(content)

            return_code = r.get('code', '-1')
            return_message = r.get('message', 'No message!!!')
            return_data = r.get('data', None)

            if return_code != 200:
                raise APIError(return_code, return_message, url)
            return return_data
        except urllib2.HTTPError as e:
            raise e

    # 1.登录 -- userLogin
    def login(self, account, access_key):
        """
        Login.
        :param str account:
        :param str access_key: Need to apply.
        :return: userId, loginDate, signature, userKey, userName, platform, mainUserId
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('userLogin'))
        data = {
            "account": account,
            "accessKey": access_key
        }
        r_data = self.post(url, data)
        user_key = r_data.get('userKey')
        self.headers['userKey'] = user_key
        return r_data

    # 2.获取用户存储ID -- getStorageId
    def get_storage_id(self):
        """
        Get user storage id, download id, cfg id.
        :return: storageId, downloadId, cfgId
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getStorageId'))
        data = {}
        r_data = self.post(url, data)
        return r_data

    # 3.获取用户自定义设置 -- getUserRenderSetting
    def get_user_custom_setup(self):
        """
        Get user custom setup.
        :return: singleNodeRenderFrames, mainChildAccountSetup, mayaNotAnalyseMiFile, mayaNotAnalyseAssFile, mayaForceAnalyseAllAgent
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getUserRenderSetting'))
        data = {}
        r_data = self.post(url, data)
        return r_data

    # 4.查询用户余额 -- getUserBalance
    def get_user_balance(self):
        """
        Get user's balance information.
        :return:  rmbBalance, usdBalance, coupon
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getUserBalance'))
        data = {}
        r_data = self.post(url, data)
        return r_data

    # 5.根据软件名称获取插件配置 -- getPluginUserList
    def get_plugin_user_list(self, cg_name):
        """
        Get user plugin configs according to the cg name.
        :param str cg_name: cg name
        :return: editName, cgName, cgVersion, pluginsInfo
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getPluginUserList'))
        data = {
            "cgName": cg_name
        }
        r_data = self.post(url, data)
        return r_data

    # 6.根据软件名称和插件配置名（editName）获取用户已配置的插件配置 -- getUserSinglePluginConfig
    def get_user_single_plugin_config(self, cg_name, edit_name):
        """
        Get user single plugin configs according to the cg name and edit name.
        :param str cg_name: cg name
        :param str edit_name: plugin config group name
        :return: editName, cgName, cgVersion, pluginsInfo
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getUserSinglePluginConfig'))
        data = {
            "cgName": cg_name,
            "editName": edit_name
        }
        r_data = self.post(url, data)
        return r_data

    # 7.新增插件配置 -- addUserPluginConfig
    def add_user_plugin_config(self, edit_name, cg_name, cg_version, plugins_info):
        """
        Add user plugin config.
        :param str edit_name:
        :param str cg_name:
        :param str cg_version:
        :param list plugins_info:[{"pluginName":"multiscatter","pluginVersion":"1.3.6.9"}]
        :return: None
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('addUserPluginConfig'))
        data = {
            "editName": edit_name,
            "cgName": cg_name,
            "cgVersion": cg_version,
            "pluginsInfo": plugins_info
        }
        r_data = self.post(url, data)
        return r_data

    # 8.编辑插件配置 -- editUserPluginConfig
    def edit_user_plugin_config(self, edit_name, cg_name, cg_version, plugins_info):
        """
        Edit plugin config.
        :param str edit_name:
        :param str cg_name:
        :param str cg_version:
        :param list plugins_info:
        :return: None
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('editUserPluginConfig'))
        data = {
            "editName": edit_name,
            "cgName": cg_name,
            "cgVersion": cg_version,
            "pluginsInfo": plugins_info
        }
        r_data = self.post(url, data)
        return r_data

    # 9.删除插件配置 -- deleteUserPluginConfig
    def delete_user_plugin_config(self, edit_name):
        """
        Delete plugin config.
        :param str edit_name:
        :return: None
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('deleteUserPluginConfig'))
        data = {
            "editName": edit_name
        }
        r_data = self.post(url, data)
        return r_data

    # 10.根据软件名称获取平台支持的所有插件信息 -- getAllPluginsInfo
    def get_all_plugins_info(self, cg_name):
        """
        Add plugin config.
        :param str cg_name:
        :return:
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getAllPluginsInfo'))
        data = {
            "cgName": cg_name
        }
        r_data = self.post(url, data)
        return r_data

    # 11.获取平台支持软件名称列表 -- getSupportCgName
    def get_support_cg_name(self):
        """
        Add plugin config.
        :return:
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getSupportCgName'))
        data = {}
        r_data = self.post(url, data)
        return r_data['cgNameList']

    # 12.根据软件名称获取平台支持的软件版本列表 -- getSupportCgVersion
    def get_support_cg_version(self, cg_name):
        """
        Add plugin config.
        :return:
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getSupportCgVersion'))
        data = {}
        r_data = self.post(url, data)
        return r_data['cgNameList']

    # 13.根据软件版本获取平台支持的插件名称 -- getSupportPluginName
    def get_support_plugin_name(self):
        """
        Add plugin config.
        :return:
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getSupportPluginName'))
        data = {}
        r_data = self.post(url, data)
        return r_data['cgNameList']

    # 14.根据软件版本和插件名称获取平台支持的插件版本列表 -- getSupportCgName
    def get_support_cg_name(self):
        """
        Add plugin config.
        :return:
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getSupportCgName'))
        data = {}
        r_data = self.post(url, data)
        return r_data['cgNameList']

    # 15.获取项目标签列表 -- getProject
    def get_project(self):
        """
        Get project list.
        :return: projectName
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getProject'))
        data = {}
        r_data = self.post(url, data)
        return r_data

    # 16.获取作业号 -- getJobId
    def get_job_id(self):
        """
        Get job id.
        :return: jobId
        :rtype: str
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getJobId'))
        data = {}
        r_data = self.post(url, data)
        return r_data['jobId']

    # 17.提交作业 -- submitJob
    def submit_job(self, job_id):
        """
        Submit job.
        :param str job_id:
        :return: taskId, cameraName, layerName, nodeName, submitResult
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('submitJob'))
        data = {
            "jobId": job_id
        }
        r_data = self.post(url, data)
        return r_data

    # 18.获取作业信息 -- getJobInfo
    def get_job_info(self, job_id):
        """
        Get job information.
        :param str job_id:
        :return:
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getJobInfo'))
        data = {
            "jobId": job_id
        }
        r_data = self.post(url, data)
        return r_data

    # 19.获取作业列表 -- getJobList
    def get_job_list(self, page_size, page_num, render_status):
        """
        Get job list.
        :param page_size:
        :param page_num:
        :param render_status:
        :return:
        :rtype: list
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getJobInfo'))
        data = {
            "pageSize": page_size,
            "pageNum": page_num,
            "renderStatus": render_status
        }
        r_data = self.post(url, data)
        return r_data

    # 20.搜索作业 -- searchJob
    # 21.开始作业 -- startJob
    # 22.暂停作业 -- pauseJob

    # 23.根据软件获取所有错误码详细信息 -- getAllErrorCodeInfo
    def get_all_error_code_info(self, cg_name):
        """
        Get all error code information.
        :param cg_name: software name
        :return:
        :rtype: dict
        """
        url = r'%s%s' % (self.protocol_domain, self.uri_dict.get('getAllErrorCodeInfo'))
        data = {
            "cgName": cg_name
        }
        r_data = self.post(url, data)
        return r_data

        # 24.根据错误码获取该错误码的详细信息 -- getErrorCodeInfo


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    api_obj = RayvisionAPI(domain_name='10.60.96.142:8980', platform="1")
    api_obj.headers['userKey'] = '04b12300cacfd4ab4fd6ed7e176b88ab'
    print api_obj.headers
    data = api_obj.get_plugin_user_list('3ds Max')
    for i in data:
        print i.get('editName')
