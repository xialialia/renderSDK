## <center> Python Render SDK(Local Analysis Version) </center>

### 1: About RenderSDK
    We are providing an easily executing Python-based RenderSDK to apply with our cloud rendering service.
    This is the official version of RenderSDK maintained by the Fox Render Farm / Renderbus RD&TD team.
The SDK has been tested with python 2.7.10.
#### Supported software
- [x] Maya
- [x] 3ds Max
- [x] Houdini
    
### 2: RenderSDK user guide
**Attention：**

    1. A Rayvision account is required for starters
    2. You need to apply for the RenderSDK and obtain the accessKey to log in. 
    3. Download RenderSDK
4. Submit jobs follow the routine

**User guide：**

```
graph TD
A[Log in] --> B(Set up job configuration)
B --> C(Analysis)
C --> D(Manually Check & fix errors and cautions before proceeding)
D --> E(Job sumbit)
B --> E
E --> F(Download)
```

![flow_chart](../image/flow_chart.png)

### 3: Sample code

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
Sample code 1: If calling Rayvision analysis routine """
from Rayvision import Rayvision

# 1.Log in
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test')

# 2. Set up job configuration（Plug-in settings、Project settings）
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={})

# 3.Analysis
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\chensr\SDK\test_maya.mb')

# 4. Manually check errors and cautions before proceeding.
error_info_list = rayvision.check_error_warn_info()

# 5. Job submit（Job parameters can be changed）
rayvision.submit_job()

# 6. Download
rayvision.download(job_id='5134', local_dir=r"d:\project\output")

```

```
#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
Sample code 2：If not calling Rayvision analysis routine
"""
from Rayvision import Rayvision

# 1. Log in
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test')

# 2. Set up job configuration（Plug-in settings、Project settings）rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={})

# 3.Job submit（scene_info_render,task_info, see user guide document for details）
rayvision.submit_job(scene_info_render, task_info)

# 4. Download
rayvision.download(job_id='5134', local_dir=r"d:\project\output")

```

### 4: Method Analysis

---

#### 1. Log in
```
rayvision = Rayvision(domain_name='task.renderbus.com', platform='2', account='test', access_key='test', workspace='c:/renderfarm/sdk_test')
```

**Parameter：**<br/>

Parameter | Category | Value | Instruction
---|---|---|---
domain_name | str | task.foxrenderfarm.com, task.renderbus.com | 
platform | str | 2, 8, 9, 10 | 2: www2 platform<br/>8: www8 platform <br/>9: www9 platform <br/>10: gpu platform
account | str | test | User ID
access_key | str | test | Apply a RenderSDK account，obtain accessKey
workspace | str |  | If not set up, the default path of SDK(configuration files and log files saving path) is under workspace catalogue


**Return：**<br/>
Rayvision’s object, may use this object to call other methods


---

#### 2. Set up job configuration（Plug-in settings、Project settings）

**Three different approaches：**<br/>
```
# （1）If there is a plug-in configuration named hello in your account, you can set it to this job plug-in configuration.
rayvision.set_job_config(cg_name='3ds Max', edit_name='hello')

# （2）Set the plug-in configuration for this job without saving the plug-in configuration to your account
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={“mentalray”:"3.14", "mtoa":"1.2.2.0"})

# （3）Set the plugin configuration for this job and save the configuration to your account (name will be overwritten if same names occurred)
rayvision.set_job_config(cg_name='Maya', cg_version='2016', plugin_config={“mentalray”:"3.14", "mtoa":"1.2.2.0"}, edit_name='test')
```
** Parameter：**<br/>

Parameter | Category | Value | Instruction
---|---|---|---
cg_name | str | Maya, 3ds Max, Houdini | Spelling is case sensitive
cg_version | str | 2014, 2015 ... | 
plugin_config | dict | {"fumefx":"4.0.5", "redshift":"2.0.76"} | No need to fill in if no plug-in is setting up
edit_name | str | hello | Plug-in configuration name, which represents the plug-in configuration 
project_name | str | defaultProject | Setting is optional, indicate the belonged job project 


**Return：**<br/>
True 


---

#### 3. Analysis
```
scene_info_render, task_info = rayvision.analyse(cg_file=r'D:\chensr\SDK\test_maya.mb', project_dir=r'D:\chensr\SDK')
```

** Parameter：**<br/>

Parameter | Category | Value | Instruction
---|---|---|---
cg_file | str |  | Scene path
project_dir | str |  | Setting is optional, project catalogue(if setting up, just detect according asset files required for rendering in your project catalogue)  


**Return：**<br/>

Parameter | Category | Value | Instruction
---|---|---|---
scene_info_render | dict |  | The analyzed scene parameters（for rendering）, able to edit task_info | dict |  | Job parameter(for rendering), can be edited 

---

#### 4. Manually check errors and cautions before proceeding
```
error_info_list = rayvision.check_error_warn_info()  # Manually check & fix errors and cautions before proceeding
```

** Parameter：**<br/>

Parameter | Category | Value | Instruction
---|---|---|---
 |  |  | 


**Return：**<br/>

Parameter | Category | Value | Instruction 
---|---|---|---
error_info_list | list |  | Manually check & fix errors and cautions before proceeding（If errors and alert occurred, SDK is not able to be proceeded）

---

#### 5.Job submit（Job parameter can be edited）
```
scene_info_render_new = scene_info_render
task_info_new = task_info
rayvision.submit_job(scene_info_render_new, task_info_new)
```

**Parameter：**<br/>

Parameter | Category | Value | Instruction 
---|---|---|---
scene_info_render | dict |  | Scene parameter(for rendering)
task_info | dict |  | Job parameter（for rendering）


**Return：**<br/>
True

---

#### 6.Download
```
rayvision.download(job_id='5134', local_dir=r"c:\renderfarm\project\5154\output")
```

** Parameter：**<br/>

Parameter | Category | Value | Instruction 
---|---|---|---
job_id | str |  | Job id
local_dir | str |  | Local download


**Return：**<br/>
True

