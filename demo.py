#!/usr/bin/env python
# -*- coding:utf-8 -*-
from renderSDK.compat import *
import hmac
import hashlib
import base64
import collections
from numbers import Number
from pprint import pprint

def to_bytes(data):
    """若输入为str（即unicode），则转为utf-8编码的bytes；其他则原样返回"""
    if isinstance(data, str):
        return data.encode(encoding='utf-8')
    else:
        return data

def generate_signature(src_str, access_key):
    """
    生成签名字符串，先用sha256算法将src_str加盐access_key计算出摘要，再将摘要用base64算法得出签名字符串
    :param str src_str:
    :param str access_key:
    :return: signature string
    :rtype: str
    """
    salt = to_bytes(access_key)
    msg = to_bytes(src_str)

    h = hmac.new(salt, msg=msg, digestmod=hashlib.sha256)
    digest = h.digest()  # 摘要

    signature = base64.b64encode(digest)  # 签名
    return signature

def header_body_simple_sort(header, body):
    """
    对所有 自定义 http请求头 和 请求参数 按参数名的字典序（ASCII 码）升序排序（简单对象）
    :param dict header: 请求头
    :param dict body: 请求参数
    :return: 请求头与请求参数排序后的有序字典对象
    :rtype: OrderedDict
    """
    mix_dict = header
    mix_dict.update(body)
    
    sorted_key_list = sorted(mix_dict)  # 排序好的字典
    
    print(sorted_key_list)
    
    new_dict = collections.OrderedDict()
    for key in sorted_key_list:
        new_dict[key] = mix_dict[key]
        
    return new_dict
    
new_dict_obj = {}
def header_body_complex_sort(header, body):
    """
    对所有 自定义 http请求头 和 请求参数 按参数名的字典序（ASCII 码）升序排序（复杂对象）
    """
    mix_dict = header
    mix_dict.update(body)
    
    # format mix_dict
    format_dict(mix_dict)
    
    pprint(new_dict_obj)
    
    sorted_key_list = sorted(new_dict_obj)  # 排序好的字典
    
    
    new_dict = collections.OrderedDict()
    for key in sorted_key_list:
        new_dict[key] = mix_dict[key]
        
    return new_dict
    
def format_dict(value, key=None):
    """
    格式化字典
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
    
    :param value: 
    :param parent_key: None/str, parent_key若为None，说明value为源字典对象
    :return:
    :rtype:
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
        new_dict_obj[key] = value
    elif isinstance(value, (str, bytes)):
        new_dict_obj[key] = value
    elif value is None:
        new_dict_obj[key] = value


if __name__ == '__main__':
    # srcsecretKey = 'Gu5t9xGARNpq86cd98joQYCN3EXAMPLE'
    # srcmsg = '[POST]task.renderbus.com:/api/render/common/queryPlatforms&UTCTimestamp=1535957371&accessId=AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPLE&channel=7&languageFlag=0&nonce=11886&platform=1&version=1.0.0&zone=2'

    # signature = generate_signature(srcmsg, srcsecretKey)
    # print(signature)
    
    header = {
        "accessId": "AKIDz8krbsJ5yKBZQpn74WFkmLPx3EXAMPLE",
        "channel": 7,
        "platform": 1,
        "UTCTimestamp": 1535957371,
        "nonce": 11886,
        "version": "1.0.0"
    }
    
    # body = {
        # "zone":2
    # }
    
    body = {
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
    
    # new_dict = header_body_simple_sort(header, body)
    # print(new_dict)
    
    
    header_body_complex_sort(header, body)
    
    