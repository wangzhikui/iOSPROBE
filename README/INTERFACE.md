# 探针发送云端接口格式

## APP应用信息
```json
[{
	"header":{
		"tid":"JsVkXHdqTG1878285484",
		"appid":"TZbafrPAmp1880722139",
		"pt":"app",
		"srid":"-1",
		"platform":"Android"
	},
	"content":[
		{
			"name": "办公OA",
			"packageid": "com.rock.xinhuapk",
			"version": "1.1.5"
		}
	]
}]
```  
## DEVICE设备信息
```json
[{
	"header":{
		"tid":"JsVkXHdqTG1878285484",
		"appid":"TZbafrPAmp1880722139",
		"pt":"device",
		"srid":"-1",
		"platform":"Android"
	},
	"content":[
		{
			"agentname": "AndroidAgent",
			"agentver": "1.0.0",
			"country": "",
			"deviceid": "cde336a7-6921-4d07-9a92-d37f8d915dd7",
			"manufacturer": "HUAWEI",
			"misc": {
				"platform": "Native",
				"platver": "1.0.0",
				"size": "normal"
			},
			"model": "KNT-AL20",
			"osname": "Android",
			"osversion": "7.0",
			"region": "",
			"hostip":"10.6.225.112",
			"province":"北京",
			"city":"北京"
		}
	]
}]
```  
## ANR卡顿信息
```json
[
    {
        "header": {
            "tid": "JsVkXHdqTG1878285484",
            "appid": "JsVkXHdqTG1878285484",
            "pt": "anr",
            "srid": "-1",
            "platform": "ios",
            "name": "友云音测试",
            "version": "1.0.0",
            "packageid": "",
            "osname": "ios",
            "osversion": "10.0.3",
            "model": "",
            "agentname": "ios-iprobe",
            "agentver": "1.0.0",
            "deviceid": "111-ddqw-123-qwesd-fsf-zcxc-",
            "province": "北京",
            "city": "北京",
            "manufacturer": "iphone6s"
        },
        "content": [
            {
                "uuid": "",
                "pid": 22327,
                "describe": "",
                "occurpackage": "",
                "stacktrace": "",
                "occurlocation": "",
                "otherthreads": "",
                "trace": "null",
                "message": "",
                "ts": 1504577221876,
                "root": false,
                "sdcardtotal": 0,
                "sdcardavai": 0,
                "totalspace": 56838112,
                "freespace": 30923808,
                "totalmemory": 3813596,
                "freememory": 867404
            }
        ]
    }
]
```  
## CRASH崩溃信息
```json
[
    {
        "content": [
            {
                "activity": [
                    {
                        "name": "Display MainActivity",
                        "timestamp": 1498099516204
                    },
                    {
                        "name": "Display LoginActivity",
                        "timestamp": 1498099518578
                    }
                ],
                "app": {
                    "build": "5",
                    "bundle": "com.rock.xinhuapk",
                    "name": "办公OA",
                    "process": 0,
                    "ver": "1.1.5"
                },
                "apptoken": "JsVkXHdqTG1878285484#TZbafrPAmp1880722139",
                "buildid": "a6ce07db-0f3f-4481-a17b-c2e2d45e9c88",
                "device": {
                    "archit": "aarch64",
                    "deviceid": "e647ede3-3023-4019-8ef6-51658e8224bf",
					"hostip":"10.6.225.112",
					"province":"北京",
					"city":"北京",
                    "disk": {
                        "extern": 37458702336,
                        "root": 70361088
                    },
                    "dvname": "HUAWEI",
                    "memory": 69,
                    "model": "KNT-AL20",
                    "netsts": "wifi",
                    "orient": 1,
                    "osbuild": "C00B385",
                    "osver": "7.0",
                    "runtime": "2.1.0",
                    "screen": "normal"
                },
                "ex": {
                    "cause": "Test by YYY",
                    "name": "java.lang.NullPointerException"
                },
                "platform": "Android",
                "protocol": 1,
                "thread": [
                    {
                        "crashed": true,
                        "id": "main",
                        "number": 1,
                        "priority": 5,
                        "stack": [
                            {
                                "class": "com.rock.xinhuapk.LoginActivity",
                                "file": "LoginActivity.java",
                                "lineno": 128,
                                "method": "logincheck"
                            },
                            {
                                "class": "com.rock.xinhuapk.LoginActivity",
                                "file": "LoginActivity.java",
                                "lineno": 73,
                                "method": "ViewClick"
                            }
                        ],
                        "state": "RUNNABLE"
                    },
                    {
                        "crashed": false,
                        "id": "Timer-0",
                        "number": 30583,
                        "priority": 5,
                        "stack": [
                            {
                                "class": "java.lang.Object",
                                "file": "Object.java",
                                "lineno": -2,
                                "method": "wait"
                            },
                            {
                                "class": "java.util.TimerThread",
                                "file": "Timer.java",
                                "lineno": 526,
                                "method": "mainLoop"
                            },
                            {
                                "class": "java.util.TimerThread",
                                "file": "Timer.java",
                                "lineno": 505,
                                "method": "run"
                            }
                        ],
                        "state": "WAITING"
                    }
                ],
                "ts": 1498099527,
                "uuid": "20217a21-2dd3-4cbd-8c46-a6b2ff3469e5"
            }
        ],
        "header": {
            "appid": "TZbafrPAmp1880722139",
            "platform": "Android",
            "pt": "crash",
            "srid": "-1",
            "tid": "JsVkXHdqTG1878285484"
        }
    }
]
```  
## HTTPXN网络信息
```json
[{
	"header":{
		"tid":"JsVkXHdqTG1878285484",
		"appid":"TZbafrPAmp1880722139",
		"pt":"httptxn",
		"srid":"-1",
		"platform":"Android"
	},
	"content":[
		{
			"appdata": "null",
			"busiid": "15cce61545c0000d3ba102d1f13ffc450d2",
			"bytercv": 370,
			"bytesent": 50,
			"carrier": "wifi",
			"deviceid": "cde336a7-6921-4d07-9a92-d37f8d915dd7",
			"error": 0,
			"method": "POST",
			"status": 200,
			"total": 193.0,
			"txid": "null",
			"url": "http://10.2.112.58/xinhu/api.php",
			"wan": "wifi"
		}
	]
}]
```  