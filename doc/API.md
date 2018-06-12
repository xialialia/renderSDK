## <center> RenerSDK </center>

### 一、API

#### 1.登录
- [ ] 获取平台
- [ ] 获取用户信息
- [ ] 获取存储id
- [ ] 获取用户自定义设置
- [ ] 获取用户余额

#### 2.设置作业配置
- [x] 根据cgName获取用户已有的插件配置
- [ ] 根据cgName及editName获取用户的插件配置
- [x] 根据cgName获取平台支持的插件配置
- [x] 新增插件配置
- [x] 编辑插件配置
- [x] 删除插件配置
- [ ] 获取作业id
- [ ] 获取项目列表

#### 3.检查错误信息
- [x] 根据cgName和errorCode获取错误信息

#### 4.提交任务
- [ ] 提交任务

#### 5.获取作业信息
- [x] 获取作业列表
- [ ] 获取作业信息
- [ ] 搜索作业
- [ ] 开始作业
- [ ] 暂停作业


### 二、客户操作

```
graph TD
    A[申请使用RenderSDK] --> B(获取平台)
    B --> C(登录)
    C --> D(设置作业配置)
    D --> E(分析)
    E --> F(展示错误信息)
    F --> G(修改参数设置)
    G --> H(上传资产)
    H --> I(提交作业)
    I --> J(下载)
```


### 三、API详情

#### 0.请求头
所有接口如无说明都必须携带请求头参数

key | value | Description
---|---|---
Content-Type | application/json | 
channel | 4 | 
platform | 1 | 
signature | Rayvision2017 | 
version | 1.0.0 | 
userKey | 771b98aed097aba9aa16ec9171750b3e | xiexianguo
languageFlag | 0 | 

#### 1.登录
- [ ] 获取平台
- [ ] 获取用户信息
- [ ] 获取存储id
- [ ] 获取用户自定义设置
- [ ] 获取用户余额

#### 2.设置作业配置
- [x] 根据cgName获取用户已有的插件配置
- request:
```
{
    "cgName":"3ds Max"
}
```
- response:
```
{
    "version":"1.0.0",
    "result":true,
    "message":"success",
    "code":200,
    "data":[
        {
            "editName":"2014_33004",
            "cgName":"3ds Max",
            "cgVersion":"2014",
            "pluginsInfoSdkVos":[
                {
                    "pluginName":"vray",
                    "pluginVersion":"3.30.04",
                    "osName":"1",
                    "renderType":1,
                    "renderLayerType":0
                }
            ]
        },
        {
            "editName":"rwerw",
            "cgName":"3ds Max",
            "cgVersion":"2014",
            "pluginsInfoSdkVos":[
                {
                    "pluginName":"forestpack",
                    "pluginVersion":"4.4.1",
                    "osName":"1",
                    "renderType":1,
                    "renderLayerType":0
                }
            ]
        }
    ],
    "serverTime":1528767925885
}
```
- [ ] 根据cgName及editName获取用户的插件配置
- [x] 根据cgName获取平台支持的插件配置
- request:
```
{
    "cgName":"3ds Max"
}
```
- response:
```
{
    "version":"1.0.0",
    "result":true,
    "message":"success",
    "code":200,
    "data":[
        {
            "2017":{
                "autograss":[
                    "1.0.7vray3.0"
                ],
                "clone":[
                    "2.4"
                ],
                "colorcorrect":[
                    "3.4"
                ],
                "coloredge":[
                    "1.0.4"
                ],
                "complexfresnel":[
                    "106"
                ],
                "coronarender":[
                    "1.3",
                    "1.4",
                    "1.5",
                    "1.52"
                ],
                "domemaster3d":[
                    "2.1.1mentalray"
                ],
                "forestpack":[
                    "5.2.0"
                ],
                "fumefx":[
                    "4.0.5"
                ],
                "greeble":[
                    "11"
                ],
                "gwivy":[
                    "0.976b"
                ],
                "kymikyway":[
                    "3.0.2"
                ],
                "kytrail":[
                    "3.7.3",
                    "1.2.0"
                ],
                "kytrailpro":[
                    "1.2"
                ],
                "mtoa":[
                    "0.5.198"
                ],
                "multitexture":[
                    "2.01"
                ],
                "ornatrix":[
                    "4.5.5.8275",
                    "4.40"
                ],
                "railclone":[
                    "2.7.4",
                    "2.7.0"
                ],
                "realflow":[
                    "2015.0.1"
                ],
                "redshift":[
                    "2.0.76",
                    "2.0.58",
                    "2.0.79",
                    "2.0.59"
                ],
                "test":[
                    "0.1"
                ]
            }
        },
        {
            "2016":{
                "afterburn":[
                    "4.2"
                ],
                "autograss":[
                    "1.0.7vray3.0"
                ],
                "berconmaps":[
                    "3_04"
                ],
                "citytraffic":[
                    "2.0"
                ],
                "clone":[
                    "2.4"
                ],
                "colorcorrect":[
                    "3.4"
                ],
                "coloredge":[
                    "1.0.4"
                ],
                "coronarender":[
                    "1.3",
                    "1.4",
                    "1.5",
                    "1.52"
                ],
                "domemaster3d":[
                    "2.1.1vray_3.2_2016",
                    "2.1.1mentalray"
                ],
                "dreamscape":[
                    "2.5f"
                ],
                "exocortexalembic":[
                    "1.1.148"
                ],
                "floorgenerator":[
                    "2.0"
                ],
                "forestpack":[
                    "5.2.0",
                    "5.0.5",
                    "4.4.0",
                    "4.4.1"
                ],
                "fumefx":[
                    "4.0.0",
                    "4.0.6",
                    "4.0.5"
                ],
                "gwivy":[
                    "0.975b",
                    "0.976b"
                ],
                "hairfarm":[
                    "2.5.7.182",
                    "2.4.1.161",
                    "2.6.1.001"
                ],
                "krakatoa":[
                    "2.5.2",
                    "2.4.3",
                    "2.4.1"
                ],
                "kymikyway":[
                    "3.0.2"
                ],
                "kytrail":[
                    "3.7.3",
                    "1.2.0"
                ],
                "kytrailpro":[
                    "1.2"
                ],
                "maxwell":[
                    "3.2.7"
                ],
                "multiscatter":[
                    "1.3.5.6",
                    "1.3.6.3"
                ],
                "multitexture":[
                    "2.01"
                ],
                "ornatrix":[
                    "4.5.2.8067",
                    "4.5.5.8275",
                    "4.40"
                ],
                "ozone":[
                    "7_vray3.0"
                ],
                "phoenixFD":[
                    "2.2.0_scanline",
                    "2.2.0_vray3.0",
                    "3.0.1_vray3.0"
                ],
                "quadchamfer":[
                    "1.1.6"
                ],
                "railclone":[
                    "2.4.7",
                    "2.7.4",
                    "2.6.0",
                    "2.7.0",
                    "2.5.0"
                ],
                "rayfire":[
                    "1.68"
                ],
                "realflow":[
                    "2015.0.1"
                ],
                "redshift":[
                    "2.0.76",
                    "2.0.58",
                    "2.0.79",
                    "2.0.59"
                ],
                "thinkingparticles":[
                    "6.2.0.33",
                    "6.2.0.44"
                ],
                "vray":[
                    "3.20.01",
                    "3.30.03",
                    "3.40.01",
                    "3.40.02",
                    "3.30.05",
                    "3.40.03",
                    "3.30.04"
                ],
                "vrayedu":[
                    "3.30.04"
                ],
                "vue":[
                    "2015"
                ]
            }
        }
    ],
    "serverTime":1528776394494
}
```
- [x] 新增插件配置
- request:
```
{
	"cgId":"2001",
    "editName":"api_test",
    "cgName":"3ds Max",
    "cgVersion":"2014",
    "pluginsInfo": [
         {
            "pluginName":"redshift",
            "pluginVersion":"2.0.53"
        },
         {
            "pluginName":"multiscatter",
            "pluginVersion":"1.3.6.9"
        }
    ]
}
```
- response:
```
{
    "version": "1.0.0",
    "result": true,
    "message": "success",
    "code": 200,
    "data": null,
    "serverTime": 1528776081890
}
```
- [x] 编辑插件配置
- request:
```
{
	"cgId":"2001",
    "editName":"api_test",
    "cgName":"3ds Max",
    "cgVersion":"2014",
    "pluginsInfo": [
         {
            "pluginName":"redshift",
            "pluginVersion":"2.0.53"
        },
         {
            "pluginName":"multiscatter",
            "pluginVersion":"1.3.6.8"
        }
    ]
}
```
- response:
```
{
    "version": "1.0.0",
    "result": true,
    "message": "success",
    "code": 200,
    "data": null,
    "serverTime": 1528776179425
}
```
- [x] 删除插件配置
- request:
```
{
    "editName":"api_test",
    "type":"1"
}
```
- response:
```
{
    "version": "1.0.0",
    "result": true,
    "message": "success",
    "code": 200,
    "data": null,
    "serverTime": 1528631463377
}
```
- [ ] 获取作业id
- [ ] 获取项目列表

#### 3.检查错误信息
- [x] 根据cgName和errorCode获取错误信息
- request:
```
{
    "code":"15000"
}
```
- response:
```
{
    "version": "1.0.0",
    "result": true,
    "message": "success",
    "code": 200,
    "data": [
        {
            "id": 97,
            "code": "15000",
            "type": 1,
            "languageFlag": 1,
            "desDescriptionCn": "Starting 3ds Max stuck or failed",
            "desSolutionCn": "1. Check whether the corresponding version of the 3ds max has a special pop-up, if any manually closed.",
            "solutionPath": "http://note.youdao.com/noteshare?id=d8f1ea0c46dfb524af798f6b1d31cf6f",
            "isRepair": 0,
            "isDelete": 1
        }
    ],
    "serverTime": 1528767944547
}
```


#### 4.提交任务
- [ ] 提交任务

#### 5.获取作业信息
- [x] 获取作业列表
- request:
```
{
    "pageSize":20,
    "pageNum":1,
    "renderStatus":1
}
```
- response:
```
{
    "version":"1.0.0",
    "result":true,
    "message":"success",
    "code":200,
    "data":{
        "pageCount":19,
        "pageNum":1,
        "total":364,
        "size":20,
        "items":[
            {
                "sceneName":"max2014.max",
                "id":1031,
                "taskStatus":20,
                "statusText":"render_task_status_20",
                "totalFrames":5,
                "abortFrames":0,
                "executingFrames":0,
                "doneFrames":5,
                "failedFrames":0,
                "framesRange":"2,3,4,5,6",
                "projectName":null,
                "renderConsume":1.23,
                "taskArrears":0,
                "submitDate":1514950019000,
                "startTime":1514950043000,
                "completedDate":1515221982000,
                "renderDuration":271939,
                "userName":"xiexianguo",
                "producer":null,
                "taskLevel":80,
                "taskLimit":3,
                "taskOverTime":43200000,
                "userId":100001,
                "outputFileName":"1031_max2014",
                "munuTaskId":"2018010300004",
                "layerParentId":0,
                "cgId":2001,
                "keyValue":"filter_kernel:Area::gi_width:640::element_type:tga::secondary_gi_engine:2::reflection_refraction:true::element_list:[""]::all_camera:["Camera001]"]::renderable_camera:["Camera001]"]::displacement:true::light_cache_mode:0::height:480::gi:0::frames:2,3,4,5,6::subdivs:8::gi_height:480::output_file_type:.tga::output_file:Renderbus.tga::element_active:1::filter_on:true::photonnode:0::secbounce:3::output_file_basename:Renderbus::gi_frames:0::onlyphoton:false::renderNum:1::width:640::irradiance_map_mode:0::primary_gi_engine:0::image_sampler_type:1::",
                "userAccountConsume":1.23,
                "couponConsume":0,
                "isOpen":0,
                "taskType":"",
                "renderCamera":"Camera001]",
                "cloneParentId":null,
                "cloneOriginalId":null,
                "respRenderingTaskList":null,
                "layerName":null,
                "taskTypeText":null
            }
        ]
    },
    "serverTime":1528776227902
}
```
- [ ] 获取作业信息
- [ ] 搜索作业
- [ ] 开始作业
- [ ] 暂停作业
