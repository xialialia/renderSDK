## <center> Python Rener SDK(本地分析版) </center>

### 一、了解RenderSDK
    我们提供了一个简单的基于Python的RenderSDK来使用我们的云渲染服务。
    这是Fox Render Farm / Renderbus RD&TD团队维护的官方RenderSDK。
    SDK已经通过python2.7.10测试。
#### 支持的软件
- [x] Maya
- [x] 3ds Max
- [x] Houdini
    
### 二、使用RenderSDK
**注意：**

    1.您必须有一个瑞云账号
    2.您需要申请使用RenderSDK，获取accessKey来进行登录
    3.下载RenderSDK
    4.根据使用流程提交作业

**使用流程：**

```
graph TD
A[登录] --> B(设置作业配置)
B --> C(分析)
C --> D(用户自行处理警告和错误)
D --> E(提交作业)
B --> E
E --> F(下载)
```

### 三、示例代码

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
示例代码一：调用瑞云分析
"""
from Rayvision import Rayvision

# 1.登录
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test')

# 2.设置作业配置（插件配置、所属项目）
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={})

# 3.分析
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\chensr\SDK\test_maya.mb')

# 4.用户自行处理错误、警告
error_info_list = rayvision.check_error_warn_info()

# 5.提交任务（可修改作业参数）
rayvision.submit_job()

# 6.下载
rayvision.download(job_id='5134', local_dir=r"d:\project\output")

```

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
示例代码二：不调用瑞云分析
"""
from Rayvision import Rayvision

# 1.登录
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test')

# 2.设置作业配置（插件配置、所属项目）
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={})

# 3.提交任务（scene_info_render,task_info详细信息见使用文档）
rayvision.submit_job(scene_info_render, task_info)

# 4.下载
rayvision.download(job_id='5134', local_dir=r"d:\project\output")

```

### 四、方法解析

---

#### 1.登录
```
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test', workspace='c:/renderfarm/sdk_test')
```

**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
domain_name | str | task.foxrenderfarm.com, task.renderbus.com | 
platform | str | 2, 8, 9, 10 | 2: www2平台<br/>8: www8平台<br/>9: www9平台<br/>10: gpu平台
account | str | test | 用户名
access_key | str | test | 申请使用RenderSDK，将会获取accessKey
workspace | str |  | 可不设置，设置SDK工作路径（存放配置文件、日志文件等），默认为SDK程序所在路径的workspace目录


**返回：**<br/>
Rayvision的对象，可通过此对象调用其他的方法


---

#### 2.设置作业配置（插件配置、所属项目）

**三种不同的使用方法：**<br/>
```
# （1）如您账号中存在名为hello的插件配置，则可设置为此次作业插件配置
rayvision.set_job_config(cg_name='3ds Max', edit_name='hello')

# （2）设置此次作业的插件配置，不保存该插件配置到您账号中
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={“mentalray”:"3.14", "mtoa":"1.2.2.0"})

# （3）设置此次作业的插件配置，并保存该配置到您账号中（如同名则覆盖）
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={“mentalray”:"3.14", "mtoa":"1.2.2.0"}, edit_name='test')
```
**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
cg_name | str | Maya, 3ds Max, Houdini | 大小写最好一致
cg_version | str | 2014, 2015 ... | 
plugin_config | dict | {"fumefx":"4.0.5", "redshift":"2.0.76"} | 如果没用插件就不需要填
edit_name | str | hello | 插件配置名，唯一标识一个插件配置组合
project_name | str | defaultProject | 可不设置，标明作业所属项目


**返回：**<br/>
True


---

#### 3.分析
```
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\chensr\SDK\test_maya.mb', project_dir=r'D:\chensr\SDK')
```

**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
cg_file | str |  | 场景路径
project_dir | str |  | 可不设置，项目目录（如设置，则只在您项目目录中查找渲染所需资产文件）


**返回：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
scene_info_render | dict |  | 分析出的场景参数（用于渲染），可修改
task_info | dict |  | 作业参数（用于渲染），可修改

---

#### 4.用户自行处理错误、警告
```
error_info_list = rayvision.check_error_warn_info()  # 用户处理错误、警告信息
```

**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
 |  |  | 


**返回：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
error_info_list | list |  | 分析出的错误、警告信息，需要用户自行处理（如有错误则SDK不能往下执行）

---

#### 5.提交任务（可修改作业参数）
```
scene_info_render_new = scene_info_render
task_info_new = task_info
rayvision.submit_job(scene_info_render_new, task_info_new)
```

**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
scene_info_render | dict |  | 场景参数（用于渲染）
task_info | dict |  | 作业参数（用于渲染）


**返回：**<br/>
True

---

#### 6.下载
```
rayvision.download(job_id='5134', local_dir=r"c:\renderfarm\project\5154\output")
```

**参数：**<br/>

参数 | 类型 | 值 | 说明
---|---|---|---
job_id | str |  | 任务id
local_dir | str |  | 本地下载目录


**返回：**<br/>
True


### 五、python模块解析

#### 1.Rayvision.py

参数 | 类型 | 值 | 说明
---|---|---|---
G_SDK_LOG | 日志对象 |  | SDK日志对象，使用方法：self.G_SDK_LOG.info('hello world')
_user_info | dict | {u'max_ignore_map_flag': u'1', u'share_main_capital': '0', u'assfile_switch_flag': '0', 'user_id': '100001', u'zone': '0', 'domain_name': 'dev.renderbus.com', u'sub_delete_task': '0', 'platform': '1', u'version': None, u'manually_start_analysis_flag': '0', u'storage_id': u'3441', u'use_main_balance': '0', u'auto_commit': u'1', u'email': u'100001@139.com', u'channel': '4', u'login_time': None, u'single_node_render_frames': u'1', u'download_id': u'3441', u'account_type': '1', u'download_disable': '0', 'local_os': 'windows', u'phone': u'18654169229', u'mifile_switch_flag': '0', u'cfg_id': u'3441', 'access_key': 'test', u'separate_account_flag': '0', 'account': 'xiexianguo', u'user_name': u'test', u'info_status': '2', 'workspace': 'c:/renderfarm/sdk_test', u'signature': None} | 主要有domain_name, platform, account, access_key, local_os, workspace，其他是API(login, getTaskPathInfo)的response经过变量名转换（驼峰转下划线, id转成user_id）而来
_api_obj | 实例 |  | 类RayvisionAPI的实例
_transfer_obj | 实例 |  | 类RayvisionTransfer的实例
is_analyse | bool | True,False | 是否调用了瑞云分析方法，初始值为False，调用analyse()之后赋值为True；用于submit_job()方法判断是否需要写task.json中的scene_info
errors_number | int | 0 | tips.json中的错误数量，初始值为0
error_warn_info_list | list |  | 错误、警告信息
_job_info | 实例 |  | 类RayvisionJob的实例

#### 2.RayvisionJob.py

参数 | 类型 | 值 | 说明
---|---|---|---
_job_id | str |  | 作业号
_local_os | str | windows, linux | 用户操作系统类型
_work_dir | str | <workspace>/work/<_job_id> | SDK工作目录（存放配置文件等），workspace用户可设置，默认为SDK程序所在路径的workspace目录
_log_dir | str | <workspace>/log/analyse | 软件分析日志文件目录（SDK日志：<workspace>/log/sdk/run_<timestamp>.log）
_zip_path | str | <current_dir>/tool/zip/<_local_os>/7z.exe, <current_dir>/tool/zip/<_local_os>/7z | 7z程序的路径（分windows,linux）
_task_json_path | str | <_log_dir>/task.json | task.json路径
_asset_json_path | str | <_log_dir>/asset.json | asset.json路径
_tips_json_path | str | <_log_dir>/tips.json | tips.json路径
_upload_json_path | str | <_log_dir>/upload.json | upload.json路径
_task_info | dict |  | task.json的内容
_asset_info | dict |  | asset.json的内容
_tips_info | dict |  | tips.json的内容
_upload_info | dict |  | upload.json的内容


#### 3.RayvisionTransfer.py

参数 | 类型 | 值 | 说明
---|---|---|---
_user_info |  |  | 见上
_api_obj |  |  | 见上
G_SDK_LOG |  |  | 见上
_domain_name | str | task.renderbus.com,task.foxrenderfarm.com | 域名
_platform | str | 2,5,8,9,10 | 平台号
_local_os | str | windows,linux | 用户操作系统类型
_user_id | str |  | 传给传输工具用户上传下载，一般为用户id（主子账号例外）
_rayvision_exe | str | <current_dir>/tool/transmission/<_local_os>/rayvision_transmitter.exe, <current_dir>/tool/transmission/<_local_os>/rayvision_transmitter | 传输工具路径
_transports_json | str | <current_dir>/rayvision/transmission/transports.json | transports.json文件路径，存放了传输引擎信息
_engine_type | str | aspera,rayvision | 传输引擎类型
_server_name | str | HKCT,ALVS,CTCC,MAIN | 传输服务名
_server_ip | str | app2.foxrenderfarm.com,45.251.92.2,</br>app8.foxrenderfarm.com,42.123.114.164,</br>app9.foxrenderfarm.com,45.251.92.18,</br>app-gpu.foxrenderfarm.com,42.123.114.170,</br>42.123.110.60,pic-main.renderbus.com,</br>42.123.110.47 | 传输服务器ip或域名
_server_port | str | 33001,8885 | 传输服务器端口


#### 4.RayvisionAPI.py

参数 | 类型 | 值 | 说明
---|---|---|---
G_SDK_LOG |  | | 见上
_protocol_domain | str | https://task.renderbus.com | 带协议的网址
_uri_dict | dict | | api的uri字典
_headers | dict | {'accessKey': 'test', 'userId': '100001', 'platform': '1', 'version': '1.0.0', 'signature': 'Rayvision2017', 'Content-Type': 'application/json', 'channel': '4'} | 请求头


#### 5.RayvisionUtil.py
实用方法类

#### 6.RayvisionException.py
异常类


### 六、异常码参照
api错误可以用：api编号+异常码

异常码 | 异常码描述 | 说明
---|---|---
100 | FAIL | 失败
200 | SUCCESS | 接口正常返回
404 | RESOURCE_NOT_FOUND | 资源不存在
500 | INTERNAL_ERROR | 服务器处理失败
600 | PARAMETER_INVALID | 非法参数
601 | PARAMETER_CANT_BE_EMPTY | 缺少必要参数
602 | NEED_USER_LOGIN | 需要用户登录
603 | ILLEGAL_PROTOCOL | 非法请求
604 | VALIDATE_CODE_ERROR | 手机验证码错误
605 | VINSUFFICIENT_PERMISSIONS | 权限不足
606 | VALIDATE_COMMOM_CODE_ERROR | 验证码错误
607 | VALIDATE_SEND_CODE_ERROR | 验证码发送失败
700 | DO_NOT_HAVE_ANY_MORE_RECORD | 没有更多记录
800 | ACCOUNT_BINDING_USER_NULL | 账号不存在
801 | ACCOUNT_NOT_BINDING | 未绑定设备
802 | ACCOUNT_BINDING_FAIL | 设备绑定失败
804 | ACCOUNT_LOCKED | 账号已被禁用
805 | ACCOUNT_USERNAME_PASSWORD_FAIL | 用户名或密码错误
806 | ACCOUNT_UNIONID_FAIL | 账号未绑定第三方用户
807 | ACCOUNT_PHONE_FAIL | 手机未绑定第三方用户
808 | ACCOUNT_UNIONID_PHONE | 手机已绑定其他第三方用戶
809 | ACCOUNT_WEIXIN_FAIL | 微信登录失败
810 | ACCOUNT_WEIBO_FAIL | 微博登录失败
811 | ACCOUNT_LOGOUT_FAIL | 登出失败
812 | ACCOUNT_LOGIN_IPLIMITFAIL | IP被限制
813 | ACCOUNT_QQ_FAIL | QQ登录失败
900 | VALIDATE_PHONE_FAIL | 手机号已存在
901 | VALIDATE_EMAIL_FAIL | 邮箱已存在
902 | VALIDATE_USERNAME_FAIL | 用户名已存在
903 | ACCOUNT_EMAIL_FAIL | 邮箱未绑定账户
904 | CURRENCY_NOT_SUPPORT | 币种不支持
905 | AGENT_NOT_SUPPORT | 代理商不支持
906 | AMOUNT_NOT_SUPPORT | 请输入合理的充值范围
908 | COUPONNO_NOT_SUPPORT | 优惠码不支持
909 | PAYMETHOD_NOT_SUPPORT | 支付方式不支持
1000 | REDIS_CACHE_FAIL | redis缓存异常
100001 | URL_ERROR | 访问API出错
100002 | TIPS_JSON_EXIST_ERROR | tips.json存在错误
100003 | SDK_PARAMETER_INVALID | 调用SDK方法参数不合法
100004 |  | edit_name is not exists
100005 |  | project_name is not exists
100006 |  | cg_name is not exists

