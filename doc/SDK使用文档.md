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
