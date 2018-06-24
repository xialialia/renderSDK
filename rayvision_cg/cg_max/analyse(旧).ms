
-- global taskjson = @"G:/新版客户端SDK/task.json"
-- global assetjson = @"G:/新版客户端SDK/asset.json"
-- global tipsjson = @"G:/新版客户端SDK/tips.json"



fn createAssembly dotnetcode className = (
    provider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
    param = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
    param.GenerateInMemory = on
    compiled = provider.CompileAssemblyFromSource param #(dotnetcode)
    compiled.CompiledAssembly.CreateInstance className
)

fn debugLog str= (
-- 	if G_OBJ_CON.isDebugLog==true then (
-- 		SetINISetting "c:/rayvision.log" "log" (G_OBJ_CON.debugLogCount as string) ("["+(localTime as string)+"]"+str)
-- 		G_OBJ_CON.debugLogCount=G_OBJ_CON.debugLogCount+1
-- 	)
	print (str as string)
)

struct STConstanst(

-- 	myMaxVersionInt=((maxversion())[1])/1000,

-- 	myCustomerPluginCfg="c:/plugins.cfg",
-- 	logCount=1,
-- 	configFile,
-- 	myIngoreWarn,
-- 	myEnableParam,
-- 	mySkipUpload,
-- 	myClientZone,
-- 	myCustomClient,
-- 	mySeperateAccount,
	isDebugLog,
-- 	debugLogCount,
-- 	configList=#(),
-- 	fileList=#(),
-- 	missingFileList=#(),
-- 	cacheList=#(),
-- 	warnList=#(),
-- 	errorList=#(),
-- 	infoList=#(),
-- 	framesArr=#(),
-- 	driverArr=#(),
-- 	
-- 	fileList2=#(),
-- 	cacheList2=#(),
-- 	badMaterialList=#(),
-- 	
	resultList=#()
	
)
G_OBJ_CON=STConstanst()


struct STConst (
	
	
	MAX_FILE,
	JSON_PATH,
	PARAM_ARRAY,

	fn init paramArray =(
		
		PARAM_ARRAY=paramArray
		
		MAX_FILE = PARAM_ARRAY[1]
		JSON_PATH = PARAM_ARRAY[2]
		format "_________________________________________%\n" JSON_PATH
	)
)
G_STCON=STConst()

struct STCode(
	
	----------------------------------error
	VRMESH_EXT_NULL="15018",
	PROXY_ENABLE="15010",
	RENDERER_MISSING="15005",
	RENDERER_NOTSUPPORT="15004",
	OUTPUTNAME_NULL="15007",
	CAMERA_NULL="15006",
	HAS_BAD_SYMPOL="15027",
	TASK_FOLDER_FAILED="15011",
	TASK_CREATE_FAILED="15012",
	VRAY_VERSION_ERR="15034",
	MULTIFRAME_NOTSUPPORT="10015",--Irradiance map mode :  \"Multiframe incremental\" not supported

	ADDTOCMAP_NOTSUPPORT="10014",--Irradiance map mode : Add to current map not supported
	--BUCKET_MODE_NOTSUPPORT="33",--Irradiance map mode : Bucket mode not supported
	PPT_NOTSUPPORT="10016",--"Light cache mode : \"Progressive path tracing\" not supported "
	VRAY_HDRI_NOTSUPPORT="999",
	
	MAXINFO_FAILED="15002",
	
	ELEM_MISSING="15025",
	
	----------------------------------warn
	GAMMA_ON="10013",
	XREFFILES="10025",
	XREFOBJ="10026",
	--WARN_AREARENDER="3",
	
	VDB_MISSING="10028",
	REALFLOW_VERSION="15022",

	
	MISSING_FILE="10012",
	HDRI_MISSING="10012",
	VRMAP_MISSING="10023",
	VRLMAP_MISSING="10024",
	
	RENDER_TYPE="10036",
	
	FUMEFX_MISSING="10011",

	PHOENIFX_MISSING="10022",

	FIRESMOKESIM_MISSING="10022",

	LIQUIDSIM_MISSING="10022",

	KK_MISSING="10019",

	ABC_MISSING="10018",

	XMESH_MISSING="10020",

	ANIMATION_MAP_MISSING="10027",
	REALFLOW_MISSING="10021",

	BAD_MATERIAL="10010",
	BAD_OBJ="10034",


	VRIMG_UNDEFINED="10017",--"\"Render to V-Ray raw image file\" Checked but *.vrimg is undefined "

	CHANNEL_FILE_UNDEFINED="15017",--"Save separate render channels Checked but channels file is error"
	
	RENDERABLE_CAMERA_NULL="10035"  --"When the switch on 'Enable scene parameter modification' is opened, if the renderable camera is not selected, a warning is required to prevent the batch submission"
	
)
G_TIPS_CODE=STCode()

struct MXSJson
(
	__keys__ = #(),
	__value__ = #(),
		
	fn format_type value =(
		local f_value = stringstream ""
		
		class_type = classof value

		if superclassof value == StructDef do(
			format "%" ("{" +value.__json__()+"}") to:f_value
			return f_value as string
			)

		if class_type == String do(
			format "\"%\"" value to:f_value
			return f_value as string
		)
		
		if class_type == Integer do(
			format "%" value to:f_value
			return f_value as string
		)

		if class_type == Array do(
			format "["  to:f_value
			for a in value do(
				l_value = this.format_type a
				
				format_s = "%,"
				if a == value[value.count] do(
					format_s = "%"
					)
				format format_s l_value to:f_value
				)

			format "]" to:f_value	
		)

		return f_value as string
	),
	
	fn __json__ = (
		data = ""
		
		for a in __keys__ do(

			data += "\""+ a + "\":"
			item = __value__[finditem __keys__ a]
			if superclassof item == StructDef then(
				data += "{"+item.__json__()+"}"
				
				)else(

					end_s = ","
					if finditem __keys__ a >= __keys__.count do(
						
						end_s = ""
					)
					
					data += this.format_type(item)+end_s
					)
		)
		data = (substituteString data "\\" "/")
		return data
	),
	
	fn json = (
		return "{"+ this.__json__()+"}"
	),
		
	fn items = (
		return this.__keys__
	),

	fn item key =(
		index = finditem this.__keys__ key 
		if index != 0 do(
			return this.__value__[index]
		)
	),

	fn add key value= (
		index = finditem this.__keys__ key
		if index == 0 do(
			append this.__keys__ key
			index = finditem this.__keys__ key
		)
		this.__value__[index] = value
		
	)
)
G_TASKJSON = MXSJson()
G_ASSETJSON = MXSJson()
G_TIPSJSON = MXSJson()

struct STUtil(
	
	fn compareGuyVersion version1 version2=(
		local compareResult = 0
		if version1==version2 then (
			compareResult = 0
		)else(
			compareResult = 1
			local versionArr1= filterString version1 ","
			local versionArr2= filterString version2 ","
			for i=1 to versionArr1.count do (
				local v1= versionArr1[i] as integer
				local v2= versionArr2[i] as integer
				if v1<v2 then(
					compareResult=-1
					exist
				)
				
			)
		)
		
		compareResult
	),
	

	
	fn requestClient action= (--client login 1 ;not 0
		local result 
		
		
		debugLog "STUtil.requestClient.001"
		local cmd = "\""+G_OBJ_CON.myGuy +"\" "+action
		if G_OBJ_CON.myMaxVersionInt>11 then (
			HiddenDOSCommand cmd exitCode:&result	
		)else(
			result= DOSCommand    cmd	
		)
		debugLog "STUtil.requestClient.002"	
		
		result = result as string
		result 
		
		
	),
	
	
	fn RBhideCmd cmdStr argStr=(
		local cmdline=("\""+cmdStr+"\" " +argStr)
		format "hiddencmd...%\n" cmdline
		hiddendoscommand cmdline ExitCode:&myExitCode
		local myExitCodeStr ="-1"
		try(
		myExitCodeStr = myExitCode as string
		)catch()
		myExitCodeStr
	),
	

	
	
			
	Fn RBCmd  cmdStr argStr= (
		
		
		local DotNetProcess
		local CmdOutput
		
		DotNetProcess = DotNetObject "System.Diagnostics.Process"
		DotNetProcess.StartInfo.FileName=cmdStr
		
		if argStr!=undefined and argStr!="" then (
			DotNetProcess.StartInfo.Arguments=argStr
		)
		
		
		
		
		DotNetProcess.StartInfo.WindowStyle   =  (DotNetClass  "System.Diagnostics.ProcessWindowStyle").Hidden
		DotNetProcess.StartInfo.CreateNoWindow   =   true
		DotNetProcess.StartInfo.UseShellExecute   =   false
		DotNetProcess.StartInfo.RedirectStandardOutput = true;
		DotNetProcess.StartInfo.RedirectStandardError = true;
		DotNetProcess.Start()--  "@-V"
		DotNetProcess.WaitForExit();
		CmdOutput = DotNetProcess.StandardOutput.ReadToEnd()
		DotNetProcess.close()
		--format "--%\n" CmdOutput
		CmdOutput
		
		
	),
	

	
	fn setIni  type myKey val   = (	
		--format "configfile...%\n" G_OBJ_CON.configFile
		format "type.%..key.%...val...%_____%\n"  type myKey val G_OBJ_CON.configFile
		
		if G_OBJ_CON.myMaxVersionInt >= 15 then(
			SetINISetting G_OBJ_CON.configFile type myKey val forceUTF16:true
		)else(
			SetINISetting G_OBJ_CON.configFile type myKey val
		)
	),
	
	fn setIniWithList type msgList=(
		debugLog "STUtil.setIniWithList.001"	
		for i=1 to msgList.count do (
			local msg = msgList[i]
			if msg!=undefined and msg!="" then (
				if G_OBJ_CON.myMaxVersionInt >= 15 then(
					SetINISetting G_OBJ_CON.configFile type (type+(i as string)) msg forceUTF16:true
				)else(
					SetINISetting G_OBJ_CON.configFile type (type+(i as string)) msg 
				)
			)
		)
		debugLog "STUtil.setIniWithList.002"
		
	),
	
	fn ooToLower str =(
		stRet = ""
		for i=1 to str.count do(
			s = str[i]
			ascii = bit.charasint s
			if  ascii >= 65 AND ascii <= 90 then 
				stRet = stRet + (bit.intaschar (ascii + 32))
			else
				stRet = stRet + s
		)
		return stRet
	),

	fn isStandardName myName= (
		allowed = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-. "
		if myName==undefined or myName=="" then (
			return false
		)
		for i = 1 to myName.count do(
			if (findstring allowed myName[i]) == undefined then(			
				return false
			)
		)
		true
	),

	fn isStandardPath myPath= (
		local allowed = "abcdefghijklmnopqrstuvwxyz{}`~ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_&'()+,-0123456789;=?\\/:. "
		
		if myPath==undefined or myPath=="" then (
			return false
		)
		for i = 1 to myPath.count do(
			if (findstring allowed myPath[i]) == undefined then(			
				return false
			)
		)
		true
	),
	
	fn hasSpecificSymbol myStr symbolList:#("*\n*","*\r*","*\\*")= (
		
		format "\r\n\r\nsymbol....................%\n" myStr
		if myStr==undefined or myStr=="" then (
			return false
		)
		for sym in symbolList do (
			if (matchPattern myStr pattern:sym)  then (
				format "...........symbol..........checked..........\n" 
				return true
			)
		)
		
		
		false
		
	),


	fn changeName myName =
	(
		local allowed = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-. "
		local result = ""
		if myName==undefined then result=""
		for i = 1 to myName.count do(
			if (findstring allowed myName[i]) != undefined then(
				result = result+myName[i]
			)
		)
		result
	),



	fn getExeVersion = (
		local v = GetFileVersion (getDir #maxRoot + "\\3dsmax.exe")
		v
	),



	fn isExtSupported ext =
	(
		if ext==undefined or ext=="" then (
			return false
		)else(
			return true 
		)
		
		/*
		if (stricmp ext ".jpg") != 0 AND (stricmp ext ".jpeg") != 0 AND (stricmp ext ".bmp") != 0 AND
				 (stricmp ext ".rpf") != 0 AND (stricmp ext ".tif") != 0 AND (stricmp ext ".tiff") != 0 AND
				 (stricmp ext ".tga") != 0 AND (stricmp ext ".png") != 0 AND (stricmp ext ".exr") != 0 AND 
				(stricmp ext ".hdr") != 0 then
			return false
		else
			return true
		*/
	),

	fn isNameSupported fileName =
	(
		allowed = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-. "
		for i = 1 to fileName.count do
		(
			if (findstring allowed filename[i]) == undefined then
			(
				print ("unsupported char "+(i as string)+" of path " +filename)
				return FALSE
			)
		)
		return TRUE
	),
	
	fn filtRightChar str char=(
		if str==undefined then(return undefined )
		count=0
		for i=str.count to  1 by -1 do (
			
			if str[i]==char then (
				format "...%______%___%\n" i count str[i]
				count=count+1
			)else(
				exit
			)
		)
		format "c...%\n"count
		if count>0 then (
			local result=substring str 1 (str.count-count)
			format "r.....%\n" result
			return result
		)else(
			return str
		)
		
		
		
	),

	fn filtName fileName =(
		
		if fileName==undefined then(return undefined )
		allowed = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-. "
		
		for i = 1 to fileName.count do (
			if (findstring allowed fileName[i])==undefined then(
				print ("unsupported char "+(i as string)+" of path " +fileName)
				fileName[i] = "_"	
			)
		)
		return filename
	),
	
	fn filtTaskId taskid =(--temp
		
		local result=""
		if taskid==undefined then(result="" )
		allowed = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_-. "
		
		for i = 1 to taskid.count do (
			
			if (findstring allowed taskid[i]) != undefined then(
				result = result+taskid[i]
			)
			
		)
		result
	),
	
	fn convertPath fpath =
	(
		
		for i = 1 to fpath.count do
		(
			if fpath[i]=="\\" then
			(
				fpath[i]="/"
			)
		)
		fpath
	),

	fn ooReplace sourceStr oldStr newStr  = (
		/*
		local maxvi = getMaxvi()
		if (maxvi >9000 ) then(
			substituteString sourceStr oldStr toStr
		)else(
		*/	
		
		if sourceStr ==undefined then return sourceStr
		local resultArr = #()
		for i=1 to sourceStr.count do (
			local index = findString sourceStr oldStr
			if index!=undefined then (
				local startStr = substring sourceStr 1 (index-1) 
				sourceStr = substring sourceStr (index+oldStr.count) sourceStr.count				
				append resultArr (startStr + newStr)
				
			)
		)
		append resultArr sourceStr
		local result = ""	
		for  rr in resultArr do (			
			append result rr
			
		)
		
		result
	),


	fn getFramesArr = (
		debugLog "STUtil.getFramesArr.001"	
		local frameStart = rendStart.frame as integer
		local frameEnd = rendEnd.frame as integer
		local framesArr = #()
		local nth = (rendNThFrame as integer)
		debugLog "STUtil.getFramesArr.002"
		if rendtimetype==1 then (--single
			
			frameStart=currenttime.frame as integer
			frameEnd=currenttime.frame as integer
			append framesArr frameStart
		)else if rendtimetype==2 then (--Active Time segment
			frameStart = animationRange.start.frame as integer
			frameEnd = animationRange.end.frame as integer
			if frameStart == frameEnd then (
				append framesArr frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append framesArr i
				)
			)		
			
		)else if rendtimetype==3 then (--Ranage
			if frameStart == frameEnd then (
				append framesArr frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append framesArr i
				)
			)
		)else if rendtimetype==4 then(--Frames
			local frames = rendPickupFrames 
			local fArr = filterString frames ","
			for f in fArr do (			
				
				if (matchPattern f pattern:"*-*") then (
					local ffArr = filterString f "-"
					if ffArr.count>1 then (
						local ss = ffArr[1] as integer
						local ee = ffArr[2] as integer
						for k=ss to ee do (						
							append framesArr k
						)
					)
				)else(
					append framesArr (f as integer)
				)
			)
		)
		debugLog "STUtil.getFramesArr.003"
		local result = #()
		for b in framesArr do (
			if findItem result b ==0 then (
				append result b			
			)
			
		)
		debugLog "STUtil.getFramesArr.004"
		result
	),

	fn fillLeftZero str count= (
		if str ==undefined or str =="" then return str
		local zeroCount = count - str.count
		if zeroCount<0 then (
			
		)else (
			for i=1 to zeroCount do (
				str = "0" + str
			)
		)
		str
	),
	
	fn dosFN myCode str=(
		doscommand ("echo [maxscript]="+myCode+"="+str)
		--HiddenDOSCommand ("echo [maxscript]="+myCode+"="+str)
		--doscommand ("echo \"<cmd><code>"+myCode+"</code><des>"+str+"</des></cmd>\"")
	),
	
	fn HiddenDotNetCommand Command=
	(
		Process = DotNetObject "System.Diagnostics.Process"
		Process.StartInfo.WindowStyle   =  (DotNetClass  "System.Diagnostics.ProcessWindowStyle").Hidden
		Process.StartInfo.FileName = "cmd.exe"
		Process.StartInfo.Arguments = "/C " + Command
		Process.Start()
	),
	fn dosWrite myCode str=(
		local resultStr= ("[maxscript]="+myCode+"="+str)
		doscommand ("echo "+resultStr)
		format "[maxscript]...%\n" resultStr
	),
	fn donetWrite myCode str=(
		local resultStr= ("[maxscript]="+myCode+"="+str)
		
		
		G_OBJ_CON.myStdout.print resultStr
		--doscommand ("echo "+resultStr)
		--dotnetOut = DotNetClass "System.Console"
		--dotnetOut.WriteLine resultStr
		format "[maxscript]...%\n" resultStr
	),
	
	
	
	fn isNumber myStr =(
		
		if myStr==undefined or myStr=="" then (return false)
		
		local numberStr = "0123456789"
		for i = 1 to myStr.count do(
			if (findstring numberStr myStr[i]) == undefined then(
				return FALSE
			)
		)
		
		return true
			
		
		
		
	),
	
	fn getIpFromPath myPath=(
		if myPath==undefined or myPath=="" then (
			return undefined
		)
		
		if pathConfig.isUncPath myPath then (
			local ipStr = pathConfig.stripPathToTopParent myPath
			ipStr= ooReplace ipStr "\\" ""
			ipStr= ooReplace ipStr "/" ""
			local ipNumberArr =filterString ipStr "."
			
			if ipNumberArr!=undefined and ipNumberArr.count==4 then (
				local resultIp=""
				for i=1 to ipNumberArr.count do (
					local myIp = ipNumberArr[i]
					if (isNumber myIp)==true then (
						if i==4 then (
							resultIp=resultIp+myIp
						)else(
							resultIp=resultIp+myIp+"."
						)
						
					)else(
						return undefined 
					)
				)
				return resultIp
			)
			
		)
		
		return undefined 
		
		
	),
	
	fn isTexInFilelist  fileList reallyPath inScenePath=(
		if reallyPath==undefined then (
			return true
		)
		for myTex in fileList do (
			if myTex.reallyPath==reallyPath and  myTex.inScenePath==inScenePath then (
				return true
			)
			
		)
		return false
	),
	
	fn isSameInArr myArr str =(
		for lineArr in myArr do(
			if str==lineArr then (
				return true 
				
			)
		)
		false
	),
	
	fn getPreUserId userId= (
		local preUserId=((userId as integer)/500)*500
		(preUserId as string)
	),
	
	fn isBigVersion nowVersion flagVersion =(
		--format "%---%\n" nowVersion flagVersion
		local result=false
		local nowVersionArr = filterString nowVersion "."
		local flagVersionArr = filterString flagVersion "."
		
		local flagCount=0
		for i=1 to nowVersionArr.count do (
			local nowStr = nowVersionArr[i]
			local flagStr = flagVersionArr[i]
			nowStr=fillLeftZero nowStr 4
			flagStr=fillLeftZero flagStr 4
			--format "%--%\n" nowStr flagStr
			if (nowStr as integer)>=(flagStr as integer) then (
				flagCount=flagCount+1
			)
		)
		
		if flagCount==nowVersionArr.count then (
			result=true
		)
		
		result
		
			
	),
	
	fn convertPythonList msList=(
		local pythonListStr="["
		if msList.count>0 then (
			for itemCount=1 to msList.count do (
				item = msList[itemCount]
				if itemCount==msList.count then (
					pythonListStr=pythonListStr+"\""+item+"\""
				)else(
					pythonListStr=pythonListStr+"\""+item+"\","
				)
				
			)
		)
		pythonListStr=pythonListStr+"]"
		pythonListStr
	)


)
G_OBJ_UTIL = STUtil()

struct STFileUtil(
	
	fn getFileNameOO file= (
		local ext = getFilenameType file
		local bname = getFileNameFile file
		local result = bname + ext
		result
	),
	
	fn getPrePath = (
		
		local prePath="/"+(G_OBJ_UTIL.getPreUserId G_OBJ_CON.myUserId)+"/"+G_OBJ_CON.myUserId+"/"
		--local prePath="/"+(G_OBJ_UTIL.getPreUserId G_OBJ_CON.myUserId)+"/"+G_OBJ_CON.myUserId+"/"+G_OBJ_CON.myProjectName+"/max/"
		
		if G_OBJ_CON.mySeperateAccount=="2" then (
			prePath="/"+(G_OBJ_UTIL.getPreUserId G_OBJ_CON.myFatherId)+"/"+G_OBJ_CON.myFatherId+"/"
		)
		
		if   G_OBJ_CON.myPlatform=="1007"   then (
			prePath="/max/"
		)
		
		prePath
	),
	--fn convert2RenderbusPath
	fn analysePath myPath=(
		
		
		
		local mName = getFilenameFile myPath
		local mType = getFilenameType myPath
		--if G_OBJ_CON.myPlatform=="1005" or G_OBJ_CON.myPlatform=="1004" or G_OBJ_CON.myPlatform=="1002"  then (
		if G_OBJ_CON.myPlatform=="1004"  then (
			local resultPath = "/"+G_OBJ_CON.myTaskId+"/temp/"+mName+mType
			return resultPath
		)else(
			
			/*
			local prePath="/max/"
			--if G_OBJ_CON.myPlatform=="1100" or G_OBJ_CON.myPlatform=="10051"  then (
			if   G_OBJ_CON.myPlatform=="1005"  or G_OBJ_CON.myPlatform=="1002" or G_OBJ_CON.myPlatform=="1100" or G_OBJ_CON.myPlatform=="10051"  then (
				prePath="/"+(G_OBJ_UTIL.getPreUserId G_OBJ_CON.myUserId)+"/"+G_OBJ_CON.myUserId+"/"+G_OBJ_CON.myProjectName+"/max/"
			)
			*/
			local prePath=getPrePath()
			local driverArr=#()
		
			if myPath==undefined or myPath=="" then (
				return ""
			)
			myPath=G_OBJ_UTIL.ooReplace myPath "\\" "/"
			
			
		
			local myFileType = getfilenametype myPath
			/*
			if myFileType==".max" then (
				return (prePath+mName+mType) 
			)
			*/
			if (findstring myPath "/")==1 then (--\\serverA\bbgg\gg\abdd.pic>>/serverA/bbgg/gg/abdd.pic
				local pathArr = filterString myPath "/"
				resultPath=""
				for i=1 to pathArr.count do (
					if i==pathArr.count then (
						resultPath=resultPath+pathArr[i]
					)else(
						resultPath=resultPath+pathArr[i]+"/"
					)
						
					
				)
				/*
				if myFileType==".max" then (
					return (prePath+mName+mType) 
				)
				*/
				return (prePath+"net/"+resultPath)
				
			)
			
			lowerMyPath = G_OBJ_UTIL.ooToLower myPath
			
			
							
			if (findstring lowerMyPath "a:")==1 then (--c:/img/feee.jpg>>/max/d/img/feee.jpg
				local pathArr = filterString myPath ":"
				myDriver = pathArr[1]
				mySubPath= pathArr[2]
				return (prePath+"a"+mySubPath)
			)
			
			if (findstring lowerMyPath "b:")==1 then (--c:/img/feee.jpg>>/max/d/img/feee.jpg
				local pathArr = filterString myPath ":"
				myDriver = pathArr[1]
				mySubPath= pathArr[2]
				return (prePath+"b"+mySubPath)
			)
			if (findstring lowerMyPath "c:")==1 then (--c:/img/feee.jpg>>/max/c/img/feee.jpg
				local pathArr = filterString myPath ":"
				myDriver = pathArr[1]
				mySubPath= pathArr[2]
				return (prePath+"c"+mySubPath)
			)
			
			if (findstring lowerMyPath "d:")==1 then (--c:/img/feee.jpg>>/max/d/img/feee.jpg
				local pathArr = filterString myPath ":"
				myDriver = pathArr[1]
				mySubPath= pathArr[2]
				return (prePath+"d"+mySubPath)
			)

			
			
			if (findstring myPath ":")==2 then (--e:/img/feee.jpg>>max/e/img/feee.jpg
				local pathArr = filterString myPath ":"
				myDriver = pathArr[1]
				mySubPath= pathArr[2]
				if (findItem G_OBJ_CON.driverArr myDriver)==0 then (
					append G_OBJ_CON.driverArr myDriver
				)
				return (prePath+myDriver+mySubPath)
			)
			
			
			
			--aakk.jpg>>/default/aakk.jpg
			return (prePath+"default/"+myPath)
			
		)
		
		
		
	
	),
	fn getReallyFilePath mfile = (--check towice  1.absolute path 1.max file path
		local result = undefined
		
		if mfile==undefined or mfile=="" then (		
			return undefined 
		)
		
		
		
		if pathConfig.isAbsolutePath mfile then (
			if doesFileExist mfile then (
				return mfile
			)else(
				local resultPath =mapPaths.getFullFilePath mfile
				if resultPath!=undefined and resultPath!="" and doesFileExist resultPath then (
					return resultPath
				)
			)
			
		)else(
			local abMfile=pathConfig.convertPathToAbsolute  mfile
			if doesFileExist abMfile then (
				return abMfile
			)else(
				local resultPath =mapPaths.getFullFilePath abMfile
				if resultPath!=undefined and resultPath!="" and doesFileExist resultPath then (
					return resultPath
				)
			)
		)
		
		
		local mName = getFilenameFile  mfile
		local mType = getFilenameType mfile
		local withMaxFile = maxfilePath+mName+mType
		if doesFileExist withMaxFile then (
			return withMaxFile
		)
		
		return undefined
	),


	fn readFile iflFile= (
		format "ifl....%\n" iflFile
		local lineArr = #()
		
		local defaultCodeClass = dotNetClass "System.Text.Encoding"
		local gbkCode=defaultCodeClass.GetEncoding "gb2312"
		local streamReader = dotnetobject "System.IO.Streamreader" iflFile gbkCode
		
		while (lineStr=streamReader.Readline()) !=undefined  do(
			append lineArr lineStr
		)
		streamReader.Close()
		
		lineArr
	),
	
	fn getIflFile iflFileRealyPath iflFileInscenePath = (
		debugLog "STFileUtil.getIflFile.001"
		local fileList = #()
		if iflFileRealyPath!=undefined and doesFileExist iflFileRealyPath   then(
			
			debugLog "STFileUtil.getIflFile.002"
			local iflFileParentInscenePath = getfilenamepath iflFileInscenePath
			local iflFileParentReallyPath = getfilenamepath iflFileRealyPath
			
			local fileListTemp = readFile iflFileRealyPath
			debugLog "STFileUtil.getIflFile.003"
			for fileLine in fileListTemp do (
				debugLog "STFileUtil.getIflFile.004"
				if fileLine==undefined then (continue)
				
				G_OBJ_UTIL.oolog ("getIflFile.fileLine="+fileLine)
				local iflImgBaseName =getfilenamefile fileLine
				local iflImgType =getfilenametype fileLine
				local iflImgTypeArr = filterString iflImgType " "
				debugLog "STFileUtil.getIflFile.005"
				if iflImgTypeArr!=undefined and iflImgTypeArr.count>0 then (
					iflImgType=iflImgTypeArr[1]
				)
				local iflImgName=iflImgBaseName+iflImgType
				local rootStr = getfilenamepath fileLine
				debugLog "STFileUtil.getIflFile.006"
				G_OBJ_UTIL.oolog ("getIflFile.iflImgrootStr="+rootStr+";iflImgName="+iflImgName)
				local iflImgInIflFileDir = iflFileParentReallyPath+iflImgName
				local iflImgInMaxfileDir=maxfilePath+iflImgName
				G_OBJ_UTIL.oolog ("getIflFile.iflImgInIflFileDir="+iflImgInIflFileDir)
				G_OBJ_UTIL.oolog ("getIflFile.iflImgInMaxfileDir="+iflImgInMaxfileDir)
				if rootStr==undefined or rootStr==""  then (-- only file name
					debugLog "STFileUtil.getIflFile.007"
					if doesFileExist iflImgInIflFileDir then(
						append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInIflFileDir inScenePath:(iflFileParentInscenePath+iflImgName))
					)else(--check again maxfile dir
						debugLog "STFileUtil.getIflFile.008"
						local iflImgInScenePath = iflFileParentInscenePath+iflImgName--iflImgInMaxfileDir+iflImgName
						if doesFileExist iflImgInMaxfileDir then(
							append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInMaxfileDir inScenePath:iflImgInScenePath)
						)else(
							if fileLine!=undefined and fileLine!="" and G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList fileLine==false then (
								append G_OBJ_CON.missingFileList fileLine
							)
						)
						debugLog "STFileUtil.getIflFile.009"
						
					)
				)else(-- with  path
					debugLog "STFileUtil.getIflFile.010"
					local iflImg =rootStr+iflImgName
					local iflImgInScenePath = iflFileParentInscenePath+iflImgName--iflImgInMaxfileDir+iflImgName
					G_OBJ_UTIL.oolog ("getIflFile.iflImg="+iflImg)
					if doesFileExist iflImg then(
						append G_OBJ_CON.fileList (STTexture reallyPath:iflImg inScenePath:iflImgInScenePath)
					)else if doesFileExist iflImgInIflFileDir then (
						append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInIflFileDir inScenePath:(iflFileParentInscenePath+iflImgName))
						
					)else if doesFileExist iflImgInMaxfileDir then(--check again maxfile dir
						append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInMaxfileDir inScenePath:iflImgInScenePath)
					)else(
						if fileLine!=undefined and fileLine!="" and G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList fileLine==false then (
							append G_OBJ_CON.missingFileList fileLine
						)
					)
					debugLog "STFileUtil.getIflFile.011"
					
					
				)
				
				
			)
			
		)
	),
	
	fn getFilesFrom mpath matchStr= (
		--1.check absolute path
		--2.check max dir folder
		--3.check max dir file
-- 		debugLog "STFileUtil.getFilesFrom.001"
		local fileArr = #()
		
		if mpath!=undefined then (
			if doesfileexist mpath then (
				fileArr=getfiles (mpath +"/"+matchStr)	
			)
-- 			debugLog "STFileUtil.getFilesFrom.002"
			if fileArr==undefined or fileArr.count==0 then (
				debugLog "STFileUtil.getFilesFrom.003"
				local mpathTemp =G_OBJ_UTIL.ooReplace mpath "\\" "/"
				format "mpathTemp___%\n" mpathTemp
				local mpathArr = filterstring mpathTemp "/"
				if mpathArr!=undefined and mpathArr.count>1 then (
					debugLog "STFileUtil.getFilesFrom.004"
					local cacheFolder = mpathArr[mpathArr.count]
					format "cacheFolder__%\n" cacheFolder
					local resultMatchStr= (maxfilePath +cacheFolder+"/"+matchStr)
					resultMatchStr =G_OBJ_UTIL.ooReplace resultMatchStr "\\" "/"
					format "maxdir folder----%\n" resultMatchStr
					fileArr=getfiles resultMatchStr	
				)	
			)
			debugLog "STFileUtil.getFilesFrom.005"
			if fileArr==undefined or fileArr.count==0 then (
				debugLog "STFileUtil.getFilesFrom.006"
				local resultMatchStr= (maxfilePath +matchStr)	
				resultMatchStr =G_OBJ_UTIL.ooReplace resultMatchStr "\\" "/"
				format "maxdir folder----%\n" resultMatchStr
				fileArr = getfiles resultMatchStr	
			)
			debugLog "STFileUtil.getFilesFrom.007"
		)
		
		
		
		
		fileArr
		
	),
	
	fn writeFileFN myFilePath msgList=(
		if doesFileExist myFilePath then (
			deleteFile myFilePath
			
		)
		
		local myfile=undefined 
		if G_OBJ_CON.myMaxVersionInt >= 15 then(
			myfile = createFile myFilePath encoding:#utf8
		)else(
			myfile = createFile myFilePath
		)
		
		for msg in msgList do (
			
			print msg to:myfile
		)
		flush myfile
		close myfile
		
	),
	
	fn handleFileSkipUpload myFile=(
		
		if myFile !=undefined   then (
			
			append G_OBJ_CON.fileList (STTexture reallyPath:myFile inScenePath:myFile)
				
			local myFileType= getfilenametype myFile
			if myFileType==".ifl" then (
				local reallPath = getReallyFilePath myFile
				getIflFile reallPath myFile
				
			)else if myFileType==".xml" then (
				local reallPath = getReallyFilePath myFile
				if reallPath!=undefined and reallPath!="" then (
					local pcFileNameFolder=getFilenamePath myFile
					local mcpath = getFilenamePath reallPath + getFilenameFile reallPath + "*.mc"
					local mcfiles = getFiles mcpath
					
					for f in mcfiles do (															
						--append fileList f
						local inScenePcName =getFileNameFile f
						local inScenePcType = getFileNameType f
						local inScenePc=pcFileNameFolder+inScenePcName+inScenePcType
						append G_OBJ_CON.fileList (STTexture reallyPath:f inScenePath:inScenePc)
					)
						
					local mcxpath = getFilenamePath reallPath + getFilenameFile reallPath + "*.mcx"
					local mcxfiles = getFiles mcxpath
					for f in mcxfiles do (															
						--append fileList f
						local inScenePcName =getFileNameFile f
						local inScenePcType = getFileNameType f
						local inScenePc=pcFileNameFolder+inScenePcName+inScenePcType
						append G_OBJ_CON.fileList (STTexture reallyPath:f inScenePath:inScenePc)
					)
				)
			)else if myFileType==".vrmap" then (
				local reallPath = getReallyFilePath myFile
				if reallPath!=undefined and reallPath!="" then (
					append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:reallPath type:"vray")
				)
				--append G_OBJ_CON.configList (STConfig key:"fromPhoton" val:reallPath type:"vray")
			)else if myFileType==".vrlmap" then (
				local reallPath = getReallyFilePath myFile
				if reallPath!=undefined and reallPath!="" then (
					append G_OBJ_CON.configList (STConfig key:"lightcachefile" val:reallPath type:"vray")
				)
				--append G_OBJ_CON.configList (STConfig key:"fromLightcache" val:reallPath type:"vray")
			)
		)
	),
	
	fn handleFileUpload myFile= (
		
		
		local reallPath = getReallyFilePath	myFile
		--G_OBJ_UTIL.oolog ((myFile as string)+"====>>"+ (reallPath as string))
		
		if reallPath!=undefined   then (
			if not pathConfig.isAbsolutePath myFile then (
				myFile=pathConfig.appendPath maxfilepath myFile
			)
			
			
			if  (G_OBJ_UTIL.isTexInFilelist  G_OBJ_CON.fileList reallPath myFile)==false  then (
				
				append G_OBJ_CON.fileList (STTexture reallyPath:reallPath inScenePath:myFile)
				local myFileType= getfilenametype reallPath
				if myFileType==".ifl" then (
					getIflFile reallPath myFile
					
				)else if myFileType==".xml" then (
					local pcFileNameFolder=getFilenamePath myFile
					
					local mcpath = getFilenamePath reallPath + getFilenameFile reallPath + "*.mc"
					local mcfiles = getFiles mcpath
					
					for f in mcfiles do (															
						--append fileList f
						local inScenePcName =getFileNameFile f
						local inScenePcType = getFileNameType f
						local inScenePc=pcFileNameFolder+inScenePcName+inScenePcType
						append G_OBJ_CON.fileList (STTexture reallyPath:f inScenePath:inScenePc)
					)
						
					local mcxpath = getFilenamePath reallPath + getFilenameFile reallPath + "*.mcx"
					local mcxfiles = getFiles mcxpath
					for f in mcxfiles do (															
						--append fileList f
						local inScenePcName =getFileNameFile f
						local inScenePcType = getFileNameType f
						local inScenePc=pcFileNameFolder+inScenePcName+inScenePcType
						append G_OBJ_CON.fileList (STTexture reallyPath:f inScenePath:inScenePc)
					)
				)else if myFileType==".vrmap" then (
					append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:reallPath type:"vray")
					--append G_OBJ_CON.configList (STConfig key:"fromPhoton" val:reallPath type:"vray")
				)else if myFileType==".vrlmap" then (
					append G_OBJ_CON.configList (STConfig key:"lightcachefile" val:reallPath type:"vray")
					--append G_OBJ_CON.configList (STConfig key:"fromLightcache" val:reallPath type:"vray")
				)
			)
			
				
		)else(
			if myFile!=undefined and myFile!="" and (G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList myFile)==false then (
				local myFileType= getfilenametype myFile
				append G_OBJ_CON.missingFileList myFile
				if myFileType==".vrmap" then (
					append G_OBJ_CON.warnList ("Missing vrmap:"+myFile)
					
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#(myFile) code:G_TIPS_CODE.VRMAP_MISSING)
					
				)else if myFileType==".vrlmap" then (
					append G_OBJ_CON.warnList ("Missing vrlmap:"+myFile)
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#(myFile) code:G_TIPS_CODE.VRLMAP_MISSING)
				)
			)
			
			
		)
		
	),
	
	fn handleFile myFile=(
		if G_OBJ_CON.mySkipUpload=="1" then (
			handleFileSkipUpload myFile
		)else(
			handleFileUpload myFile
		)
	)
	
)
G_OBJ_FILEUTIL = STFileUtil()

struct STTask(
		
	fn commonInfo =(
		--format "-------commonINFO------\n"
		
		local frameStr = "0"
		if rendtimetype==1 then (--single
			frameStr= (currentTime.Frame as integer) as string --sliderTime.Frame
		)else if rendtimetype==2 then (--Active Time segment
			local anStart = (animationRange.start.frame as integer) as string
			local anEnd =  (animationRange.end.frame as integer) as string 
			local nth = (rendNThFrame as integer) as string
			frameStr=anStart+"-"+anEnd +"["+nth+"]"
		)else if rendtimetype==3 then (--Ranage
			local nth =(rendNThFrame as integer) as string
			local start = (rendStart.frame as integer) as string
			local end = (rendEnd.frame as integer) as string
			frameStr=start+"-"+end +"["+nth+"]"				
			
		)else if rendtimetype==4 then(--Frames
			local frames = rendPickupFrames 
			if frames!=undefined and frames!="" then (			
				frameStr=frames
			)			
		)
		

		G_TASKJSON.add "filegamma" (IDisplayGamma.colorCorrectionMode as string)
		G_TASKJSON.add "kg" "0" 
		G_TASKJSON.add "from" "3dsmax" 
	-- 	G_TASKJSON.add "update" renderbusUpdate 
		G_TASKJSON.add "sceneproject" maxfilepath
		G_TASKJSON.add "scenefile" (maxfilepath+maxfilename) 
		G_TASKJSON.add "cgfile" (maxfilepath+maxfilename) 
		G_TASKJSON.add "original_cg_file" (maxfilepath+maxfilename) 
		G_TASKJSON.add "alloutputtype" #("tga","tif","jpg","png","rla","rpf","exr")
		G_TASKJSON.add "allelemtype" #("tga","tif","jpg","png","rla","rpf","exr")
		G_TASKJSON.add "color" (Color_channel as string)
		
		
		
		if (Color_channel == true) or (Vray_AO == true )then
		(
			G_TASKJSON.add "channel" "true"
		)
		else
		(
			G_TASKJSON.add "channel" "false"
		)

			G_TASKJSON.add "isPicture" "true" 
					
			G_TASKJSON.add "cameradelimiter" "[,]" 
					
			G_TASKJSON.add "distributenode" (ThreadCount as string) 
			G_TASKJSON.add "distributenodelist" "3:48,6:96" 
			G_TASKJSON.add "distributenodecore" (Nodecore as string) 
			G_TASKJSON.add "frames" (((sliderTime as string ) as integer) as string) 

			
		if (classof renderers.production) == A360_Cloud_Rendering then
		(
			local tipsStr="当前渲染器 “" +(classof renderers.production) as string +"” 不受支持 请检查"
			G_TASKJSON.add "error" #(tipsStr)
		)
		
				
		G_TASKJSON.add "width" (renderWidth as string) 
		G_TASKJSON.add "height" (renderheight as string)  
		G_TASKJSON.add "RenderType" (getRenderType() as string)
		
		local animationRangeStart=((animationRange.Start as string)as integer) as string
		local animationRangeEnd=((animationRange.End as string)as integer) as string


		G_TASKJSON.add "rendSaveFile" (rendSaveFile as string)  
		G_TASKJSON.add "locationoutput" (getfilenamepath rendOutputFilename) 
		G_TASKJSON.add "rendOutputFilename" (rendOutputFilename as string)  

		
		local outBaseName=getfilenamefile rendOutputFilename
		local outBaseType=getfilenametype rendOutputFilename
		local ltime = getlocaltime()
		local hz = ""
		for i = ltime.count-4 to ltime.count-2 do (append hz (ltime[i] as string))
		
		G_TASKJSON.add "output" (outBaseName+"_"+hz+"_"+outBaseType)  
			
		G_TASKJSON.add "cgv" ("3ds Max "+(1998+(((maxversion())[1])/1000 )) as string) 
		
		G_TASKJSON.add "max" ((maxFilePath+maxFileName) as string)   
		
		if IDisplayGamma.colorCorrectionMode == #gamma then(
			G_TASKJSON.add "gamma" "on"  
			G_TASKJSON.add "gammaval" (IDisplayGamma.gamma as string)  
			G_TASKJSON.add "ingamma" (fileInGamma as string)  
			G_TASKJSON.add "outgamma" (fileOutGamma as string)  
		)else(
			G_TASKJSON.add "gamma" "off"  
		)
	),
	
	fn cameraInfo =(
		
		--format "-------checkCameraInfo--------\n"
		
		local allcamList = ""
		local errCam = ""
		local inicamList = #()
		local dupCameraList=#()
		for Allcam in cameras do 
		(
			if ((classof Allcam) as string )!="Targetobject" then
				(
					append  allcamList (Allcam.name as string +"[,]")
					append  inicamList Allcam.name as string
				)
		)
		
		G_TASKJSON.add "allcamera" (allcamList as string)
		--append myResult.configlist (STConfig ckey:"allcamera" cval:(allcamList as string) ctype:"renderSettings")	
-- 		if inicamList.count <=0 then
-- 		(
-- 			append tipsList "场景中没有相机"
-- 		)
		for G_cam in inicamList do 
		(
			local eqcount = 0
			for GG_cam in inicamList do 
			(
				if G_cam == GG_cam then 
				(
					eqcount =eqcount+1
				)
			)
			if eqcount >1 then 
			(
				format "当前有重名的相机________%\n" G_cam
				append errCam G_cam
				--append tipsList G_cam
				append dupCameraList G_cam
			)
		)
		
		for i in inicamList do 
		(
			if (matchPattern i pattern:"*&*")or(matchPattern i pattern:"*\n*") or(matchPattern i pattern:"*\r*") \
			or (matchPattern i pattern:"*\\*")or(matchPattern i pattern:"*/*") or(matchPattern i pattern:"*:*") \
			or (matchPattern i pattern:"*\\?*")or(matchPattern i pattern:"*\\**") or(matchPattern i pattern:"*\"*") \
			or (matchPattern i pattern:"*<*")or(matchPattern i pattern:"*>*") or(matchPattern i pattern:"*|*") \
			then
			(
				local tipsStr="相机“" +i+"”内有特殊符号 请修改后重新提交"
				--append myResult.tipsList (STTips tipsType:"error" tipsList:#(tipsStr) tipsLink:with_All)
				G_TIPSJSON.add (G_TIPS_CODE.CAMERA_NULL+"1") (tipsStr as string)
			)
			
			--local badsymbol = #("\\","/",":","\\*","\\?","\"","<",">","|")

		)
		
		if dupCameraList.count>0 then 
		(
			local camStr = ""
			for dupCam in dupCameraList do 
			(
				camStr = camStr + dupCam+","
			)
			local tipsList = ("有同名相机:"+camStr)
			
			G_TIPSJSON.add G_TIPS_CODE.CAMERA_NULL tipsList
			--append myResult.tipsList (STTips tipsType:"error" tipsList:tipsList tipsLink:with_Cam) 
		)
		
	),
	
	fn writetaskjson =(
		taskjsonfile=fopen taskjson "wb"
		WriteString taskjsonfile (G_TASKJSON.json())
		fclose taskjsonfile
	),
	
	fn check = (
		commonInfo()
		cameraInfo()
-- 		writetaskjson()
	)
)
G_Write_Task = STTask()
G_Write_Task.check()

struct STAsset(
	
	fn textureInfo =(
	-- 		local maxFileScene = G_RAYVISION_DOT.analysePath (maxfilepath+maxfilename)
			texList = #() 
			local exist_texture = #()
			local missing_texture = #()
			ATSOps.Refresh()
			Atsops.getFiles &texList
			for tex in texList do(
				if tex==undefined or tex=="" then(
					continue
				)
				if tex!=(maxfilepath+maxfilename) and  (ATSOps.IsInputFile tex) then(
					
					local ConvertPath = pathConfig.convertPathToAbsolute tex
					local Truepath = mapPaths.getFullFilePath  ConvertPath
	-- 				if ((tex[1] as string)+(tex[2] as string)) == ".." then
	-- 				(
	-- 					txtScene = (maxfilepath+(filenamefrompath  tex))
	-- 				)
	-- 				else if (getfilenamepath tex) == "" then
	-- 				(
	-- 					txtScene = (maxfilepath+(filenamefrompath  tex))
	-- 				)
	-- 				else
	-- 				(
	-- 					txtScene =  tex
	-- 				)
					if doesFileExist Truepath then 
					(
						append exist_texture Truepath
						--G_ASSETJSON.add "texture" #(Truepath)
					)
					else
					(
						append missing_texture tex
						--G_ASSETJSON.add "texture_missing" #(Truepath)
					)
					--append myResult.configlist (STConfig ckey:"Asset" cval:tex ctype:"TD")	
				)
			)
			if exist_texture.count != 0 then
			(
				G_ASSETJSON.add "texture" exist_texture
			)
			if missing_texture.count != 0 then
			(
				G_ASSETJSON.add "texture_missing" missing_texture
			)
			format "exist_texture   %  missing_texture   %\n" exist_texture missing_texture
	),

	fn checkRealflow = (--------------------------------------------------------------20170824
		local missingRealflowList=#()
		local existRealflowList=#()
		local AllreMesh = #()
		try(
			try(
			local rfMeshesa = getClassInstances RFMeshLoader	
			join AllreMesh rfMeshesa
			)catch()
			
			try(
			local rfMeshesb = getClassInstances MeshLoader	
			join AllreMesh rfMeshesb
			)catch()
			format "----------------------%\n" AllreMesh
			for rfMesh in AllreMesh do(	

				local meshPath = rfMesh.path			
				if meshPath!=undefined and meshPath!="" then (
					debugLog "STPlugin.checkRealflow.002"
					local prefix = rfMesh.prefix	
					local rfFormat = rfMesh.Format	
					debugLog "STPlugin.checkRealflow.003"						
					if rfFormat==0 then (--name.#.ext
						prefix = prefix+".*.bin"
					)else if rfFormat==1 then (--name.ext.#
						prefix = prefix+".bin.*"
					)else if rfFormat==2 then (--name#.ext
						prefix = prefix+"*.bin"
					)else if rfFormat==3 then (--name_#.ext
						prefix = prefix+"_*.bin"
					)else(
						prefix = prefix+".*.bin"
					)	
					debugLog "STPlugin.checkRealflow.004"
-- 					format "realflow---%---->>%\n" meshPath prefix
					local fileArr = G_OBJ_FILEUTIL.getFilesFrom meshPath prefix
					debugLog "STPlugin.checkRealflow.005"
					if fileArr==undefined or fileArr.count==0 then (
						debugLog "STPlugin.checkRealflow.006"
						if G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList meshPath==false then (
							--append G_OBJ_CON.missingFileList meshPath
							append missingRealflowList meshPath
						)
					)else(
						debugLog "STPlugin.checkRealflow.007"
						for existref in fileArr do (
							local inScenePath = meshPath+( G_OBJ_FILEUTIL.getFileNameOO existref)
								if  (finditem existRealflowList existref) == 0 then
								(
									append existRealflowList existref
									format "_____     %\n" existref
								)
						)
					)
					
					debugLog "STPlugin.checkRealflow.008"
				)
				
			)
		)catch()
		
		if missingRealflowList.count>0 then (
			append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_MISSING)
			append G_OBJ_CON.warnList "Missing realflow"
		)
		

		
		local isValidVersionParticleLoader = true

		try
		(
			local rfParticles = getClassInstances ParticleLoader
			if rfParticles.count > 0 then(
				debugLog "STPlugin.checkRealflow.010"
				if not hasProperty rfParticles[1] "binPath" then(
					isValidVersionParticleLoader=false
					append G_OBJ_CON.warnList G_OBJ_LANG.WARN_REALFLOW_VERSIONERR	
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_VERSION)
				)
				debugLog "STPlugin.checkRealflow.011"
				if isValidVersionParticleLoader then (
					debugLog "STPlugin.checkRealflow.012"
					for rfp in rfParticles do (
						local bpath = rfp.binPath
						
						if bpath!=undefined and bpath!="" then (
							debugLog "STPlugin.checkRealflow.013"
							local prefix = rfp.binPrefix	
							prefix = prefix+"*.bin"
							local fileArr = G_OBJ_FILEUTIL.getFilesFrom bpath prefix
							debugLog "STPlugin.checkRealflow.014"
							for f in fileArr do (
								local inScenePath = bpath+( G_OBJ_FILEUTIL.getFileNameOO f)
								
								--append G_OBJ_CON.cacheList (STTexture reallyPath:f inScenePath:inScenePath)
								if  (finditem existRealflowList f) == 0 then
								(
									append existRealflowList f
									format "_____     %\n" f
								)
							)
							debugLog "STPlugin.checkRealflow.015"
						)
						
					)
				)
			)
			
		)catch()
		
		

		local isValidVersionRFSoftBody = true
		try(
			
			local rfEditableMeshPaths = getClassInstances RFSoftBody
			debugLog "STPlugin.checkRealflow.017"
			if rfEditableMeshPaths.count>0 then (
				if not hasProperty rfEditableMeshPaths[1] "SD_Filename" then (
					debugLog "STPlugin.checkRealflow.018"
					isValidVersionRFSoftBody = false
					append G_OBJ_CON.warnList G_OBJ_LANG.WARN_REALFLOW_VERSIONERR
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_VERSION)
				)
				
				if isValidVersionRFSoftBody then (
					debugLog "STPlugin.checkRealflow.019"
					for rfMesh in rfEditableMeshPaths do(
						
						local f = rfMesh.SD_Filename
						if f==undefined or f=="" then continue
						G_OBJ_FILEUTIL.handleFile f				
					)
					
				)
			)
			
		)catch()
		
		format "___________%______________%" existRealflowList missingRealflowList
		
		if existRealflowList.count != 0 then
		(
			G_ASSETJSON.add "realflow" existRealflowList
		)
		if missingRealflowList.count != 0 then
		(
			G_ASSETJSON.add "realflow_missing" missingRealflowList
		)
		
	),

	fn checkFumeFX = (
-- 		G_OBJ_UTIL.oolog "checkFumeFX.check"
		debugLog "STPlugin.checkFumeFX.001"
		local cacheList=#()
		local missingCacheList=#()
		local existCacheList=#()
		try(
			local arr = getclassinstances FumeFX
			debugLog "STPlugin.checkFumeFX.002"
			local missing
			for a in arr do(
				local defaultPath = a.GetPath "default"
				local waveletPath = a.GetPath "wavelet"
				local retimerPath = a.GetPath "retimer"
				
				local defaultFumefxFolder = getFilenamePath defaultPath
				local matchStr=G_OBJ_FILEUTIL.getFileNameOO defaultPath+"*.fxd"
				local defaultArr = G_OBJ_FILEUTIL.getFilesFrom defaultFumefxFolder matchStr
				if defaultArr==undefined or defaultArr.count==0 then (
					append G_OBJ_CON.warnList ("Missing FumeFX Default cache")
					append missingCacheList defaultPath
				)else(
					for defaultFumefx in defaultArr do (
						local inScenePath = defaultFumefxFolder+( G_OBJ_FILEUTIL.getFileNameOO defaultFumefx)
						--append G_OBJ_CON.cacheList (STTexture reallyPath:defaultFumefx inScenePath:inScenePath)
						
						if  (finditem existCacheList defaultFumefx) == 0 then
							(
								append existCacheList defaultFumefx
								format "_____     %\n" defaultFumefx
							)
					)
				)
				
				local waveletFumefxFolder = getFilenamePath waveletPath
				local waveletMatchStr=G_OBJ_FILEUTIL.getFileNameOO waveletFumefxFolder+"*.fxd"
				local waveletArr = G_OBJ_FILEUTIL.getFilesFrom waveletFumefxFolder waveletMatchStr
				if waveletArr==undefined or waveletArr.count==0 then (
					--append G_OBJ_CON.warnList ("Missing FumeFX Wavelet cache")
					append missingCacheList waveletPath
				)else(
					for waveletFumefx in waveletArr do (
						local inScenePath = waveletFumefxFolder+( G_OBJ_FILEUTIL.getFileNameOO waveletFumefx)
						--append G_OBJ_CON.cacheList (STTexture reallyPath:waveletFumefx inScenePath:inScenePath)
						if  (finditem existCacheList waveletFumefx) == 0 then
							(
								append existCacheList waveletFumefx
								format "_____     %\n" waveletFumefx
							)
					)
				)
				
				
				local retimerFumefxFolder = getFilenamePath retimerPath
				local retimerMatchStr=G_OBJ_FILEUTIL.getFileNameOO retimerPath+"*.fxd"
				local retimerArr = G_OBJ_FILEUTIL.getFilesFrom retimerFumefxFolder retimerMatchStr
				if retimerArr==undefined or retimerArr.count==0 then (
					--append G_OBJ_CON.warnList ("Missing FumeFX Retimer cache")
					append missingCacheList retimerPath
				)else(
					for retimerFumefx in retimerArr do (
						local inScenePath = retimerFumefxFolder+( G_OBJ_FILEUTIL.getFileNameOO retimerFumefx)
						--append G_OBJ_CON.cacheList (STTexture reallyPath:retimerFumefx inScenePath:inScenePath)
						if  (finditem existCacheList retimerFumefx) == 0 then
							(
								append existCacheList retimerFumefx
								format "_____     %\n" retimerFumefx
							)
					)
				)
				
				--join cacheList defaultArr
				--join cacheList waveletArr
				--join cacheList retimerArr
			)
			
			debugLog "STPlugin.checkFumeFX.003"
			if missingCacheList.count>0 then (
				
				G_TIPSJSON.add G_TIPS_CODE.FUMEFX_MISSING missingCacheList
				--append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingCacheList code:G_TIPS_CODE.FUMEFX_MISSING)
				--append G_OBJ_CON.warnList "Missing FumeFX Retimer cache"
				
			)
			
			if existCacheList.count != 0 then
			(
				G_ASSETJSON.add "fumefx" existCacheList
			)
			if missingCacheList.count != 0 then
			(
				G_ASSETJSON.add "fumefx_missing" missingCacheList
			)
			
			
		)catch()
	),
	
	fn checkHair=(
		G_OBJ_UTIL.oolog "checkHair.check"
		debugLog "STPlugin.checkHair.001"
		local myResult=STResult()
		myResult.oName="hair"
		try(
			local arr = getclassinstances HairMod
			local missingHairList=#()
			local hairCount=1
			for a in arr do (
				
				local hairStart = a.simulationStart as string
				local hairEnd = a.simulationEnd as string
				local hairFile=getHair a
				local str = hairStart+"|"+hairEnd+"|"+hairFile
				
				append myResult.cfgList (STCfg okey:"path" oval:(str ) otype:"hair")
				
			)
			
		)catch(
			format "checkHair....\n"
			format "%\n" (getcurrentexception() as string)
		)
		append G_OBJ_CON.resultList myResult
	),
	
	fn checkNewFumefx=(
		G_OBJ_UTIL.oolog "checkHair.check"
		debugLog "STPlugin.checkHair.001"
		local myResult=STResult()
		myResult.oName="fumefx"
				
		try(
			local arr = getclassinstances FumeFX
			for a in arr do(
				local defaultPath = a.GetPath "default"
				local waveletPath = a.GetPath "wavelet"
				local retimerPath = a.GetPath "retimer"
				
				format "defaultPath...%\n" defaultPath
				format "waveletPath...%\n" waveletPath
				format "retimerPath...%\n" retimerPath
				
				local frameStr=(a.startframe as string)+"|"+(a.endframe as string)+"|"+(a.offset as string)+"|"
				
				
				if not (matchPattern defaultPath pattern:"*.fxd") then (
					defaultPath=defaultPath+".fxd"
				)
				if not (matchPattern waveletPath pattern:"*.fxd") then (
					waveletPath=waveletPath+".fxd"
				)
				if not (matchPattern retimerPath pattern:"*.fxd") then (
					retimerPath=retimerPath+".fxd"
				)
				
				
				if a.SelectedCache==0 then (
					append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"default|"+defaultPath) otype:"fumefx")
				)else if a.SelectedCache==1 then (
					append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"wavlet|"+waveletPath) otype:"fumefx")
				)else if a.SelectedCache==2 then (
					append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"post|"+retimerPath) otype:"fumefx")
				)
			)
			
		)catch(
			format "checkHair....\n"
			format "%\n" (getcurrentexception() as string)
		)
		append G_OBJ_CON.resultList myResult
	),
		
	----------------------------------------------------------------------------------------------------------------Vrmesh
	fn checkVrmesh = (
		G_OBJ_UTIL.oolog "checkVrmesh.check"
        local myResult=STResult()
        myResult.oName="vrmesh"
		try(
			local vrMeshArr=getclassinstances vrayproxy
			for omesh in vrMeshArr do (
				if omesh!=undefined and omesh.Filename!=undefined then (
					append myResult.cfgList (STCfg okey:"path" oval:omesh.Filename otype:"vrmesh")	
					
				)
			)
			
		)catch()
        append G_OBJ_CON.resultList myResult	
	),
		
	----------------------------------------------------------------------------------------------------------------VRayScannedMtl  ----------------20170824
	fn checkVrscanned = (
		G_OBJ_UTIL.oolog "checkVrscanned.check"
		local myResult=STResult()
		 myResult.oName="scanned"
		try(
			local vrScanned = getclassInstances VRayScannedMtl
			for vrS in vrScanned do 
			(
				if vrS != undefined and vrS.filename !=undefined then
					(
						append myResult.cfgList (STCfg okey:"path" oval:vrS.Filename otype:"scanned")
					
						local inScenePath = (getFilenamePath vrS.Filename)+( G_OBJ_FILEUTIL.getFileNameOO vrS.Filename)
						append G_OBJ_CON.cacheList (STTexture reallyPath:vrS.Filename inScenePath:inScenePath)
					)
			)
			
			)catch()
		append G_OBJ_CON.resultList myResult
	),
	
	----------------------------------------------------------------------------------------------------------------RF_Cache  ---------------20170824
	fn checkRfcache = (
		G_OBJ_UTIL.oolog "checkRfcache.check"
		local myResult=STResult()
		 myResult.oName="rfcache"
		try(
			local rffile = getclassInstances RF_Cache
			for rfc in rffile do 
			(
				if rfc != undefined and rfc.filename !=undefined then
					(
						append myResult.cfgList (STCfg okey:"path" oval:rfc.Filename otype:"rfcache")
						
						local inScenePath = (getFilenamePath rfc.Filename)+( G_OBJ_FILEUTIL.getFileNameOO rfc.Filename)
						append G_OBJ_CON.cacheList (STTexture reallyPath:rfc.Filename inScenePath:inScenePath)
					)
			)
			
			)catch()
		append G_OBJ_CON.resultList myResult
	),
	
	---------------------------------------------------------------------------------------------------------------Phoenix
	fn checkPhoenix2 = (
		G_OBJ_UTIL.oolog "checkPhoenix2.check"
		local myResult=STResult()
		myResult.oName="Phoenix"
		
		local PHXSimulatorArr = #()
		try(
			PHXSimulatorArr = getclassinstances PHXSimulator
		)catch()
		for a in PHXSimulatorArr do(
			local phoenixNode=refs.dependentNodes a firstOnly:true baseObjectOnly:true
			local phoenixNodeName=phoenixNode.name as string
			format "p......%____%\n" a.rendinput a.simoutput
			frameStr=a.startframe as string +"|"+a.stopframe as string
			append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"|phxsimulator|"+phoenixNodeName+"|"+(a.rendinput as string)+"|"+(a.simoutput)) otype:"phoenix")	
		)
		
		try(
			--D:\work\scene\phoenixfd\fd_####.aur
			arr = getclassinstances FireSmokeSim
			for a in arr do(
				local phoenixNode=refs.dependentNodes a firstOnly:true baseObjectOnly:true
				local phoenixNodeName=phoenixNode.name as string
				format "f......%____%\n" a.rendinput a.simoutput
				frameStr=a.startframe as string +"|"+a.stopframe as string
				append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"|firesmokesim|"+phoenixNodeName+"|"+(a.rendinput as string)+"|"+(a.simoutput)) otype:"phoenix")	
			)
		)catch()
		
	
		local LiquidSimArr =#()
		try(
			LiquidSimArr =getclassinstances LiquidSim
		)catch()
		
			
			for a in LiquidSimArr do(
				local phoenixNode=refs.dependentNodes a firstOnly:true baseObjectOnly:true
				local phoenixNodeName=phoenixNode.name as string
				format "s......%____%\n" a.rendinput a.simoutput
				--if hasProperty a simoutput then 
				frameStr=(a.startframe as string) +"|"+(a.stopframe as string)
				
				append myResult.cfgList (STCfg okey:"path" oval:(frameStr+"|liquidsim|"+phoenixNodeName+"|"+(a.rendinput as string)+"|"+(a.simoutput)) otype:"phoenix")	
			)
		
		append G_OBJ_CON.resultList myResult
	),
	
	-----------------------------------------------------------------------------------------------------------------------KrakatoaPRTLoader---------------st
	fn checkKrakatoaPRTLoader = (
		--G_OBJ_UTIL.oolog "checkKrakatoaPRTLoader.check"
		--debugLog "STPlugin.checkKrakatoaPRTLoader.001"
		try(
			local arrxs = getclassinstances KrakatoaPRTLoader
			local missingKKList=#()
			for i = 1 to arrxs.count do (
				for ii  = 1 to arrxs[i].fileList.count do (
					debugLog "STPlugin.checkKrakatoaPRTLoader.001"
					local PRTLoaderFolder = getFilenamePath arrxs[i].fileList[ii]
					local PRTLoaderName = getFileNameFile arrxs[i].fileList[ii]
					local PRTLoaderExt = getFilenameType arrxs[i].fileList[ii]
					format "PRTLoaderExt...%\n" PRTLoaderExt
					--local PRTLoaderName_Get = G_OBJ_UTIL.ooReplace PRTLoaderName "0" "*"
					local PRTLoaderName_Get = substring PRTLoaderName 1 (PRTLoaderName.count-4)
					local matchStr=PRTLoaderName_Get+"*"+PRTLoaderExt
					local nixArr = G_OBJ_FILEUTIL.getFilesFrom PRTLoaderFolder matchStr
					debugLog "STPlugin.checkKrakatoaPRTLoader.002"
					if nixArr==undefined or nixArr.count==0 then (
						append G_OBJ_CON.warnList ("Missing PRTLoader cache")
						append missingKKList arrxs[i].fileList[ii]
					)else(
						for nix in nixArr do (
							local inScenePath = PRTLoaderFolder+( G_OBJ_FILEUTIL.getFileNameOO nix)
							--format "nix.% >>..%\n" nix inScenePath
							
							append G_OBJ_CON.cacheList (STTexture reallyPath:nix inScenePath:inScenePath)
						)
					)
					debugLog "STPlugin.checkKrakatoaPRTLoader.003"
				)
			)
			if missingKKList.count>0 then (
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingKKList code:G_TIPS_CODE.KK_MISSING)
				append G_OBJ_CON.warnList "Missing PRTLoader cache"
				
			)
			
		)catch(
			format "PRTLoader....\n"
			format "%\n" (getcurrentexception() as string)
		)
	),
--------------------------------------------------------------------------------------------------------------------------KrakatoaPRTLoader-----------------end		
--------------------------------------------------------------------------------------------------------------------------Alembic---------------------------st
	fn checkAlembic = 
	(
		local missingAlembic=#()
		try(
			local arrxs = getclassinstances Alembic_Mesh_Geometry 
			
			for i = 1 to arrxs.count do (
				debugLog "STPlugin.checkAlembic.001"
				local AlembicFolder = getFilenamePath arrxs[i].path
				local AlembicName = getFileNameFile arrxs[i].path
				local AlembicExt = getFilenameType arrxs[i].path
				--format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
				format "AlembicExt...%\n" AlembicExt
				local matchStr=AlembicName+"*"+AlembicExt
				local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr
				debugLog "STPlugin.checkAlembic.002"
				if nixArr==undefined or nixArr.count==0 then(
					append G_OBJ_CON.warnList ("Missing Alembic cache")
					append missingAlembic arrxs[i].path
				)else(
					for nix in nixArr do (
						local inScenePath = AlembicFolder+( G_OBJ_FILEUTIL.getFileNameOO nix)
						--format "nix.% >>..%\n" nix inScenePath
						
						append G_OBJ_CON.cacheList (STTexture reallyPath:nix inScenePath:inScenePath)
					)
				)
				debugLog "STPlugin.checkAlembic.003"
			)
			
		)catch(
			format "PRTLoader....\n"
			format "%\n" (getcurrentexception() as string)
		)
		
		try(
			local arrxs = getclassinstances AlembicCamera       ------------------------------20170824
			
			for i = 1 to arrxs.count do (
				debugLog "STPlugin.checkAlembic.001"
				local AlembicFolder = getFilenamePath arrxs[i].source
				local AlembicName = getFileNameFile arrxs[i].source
				local AlembicExt = getFilenameType arrxs[i].source
				--format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
				format "AlembicExt...%\n" AlembicExt
				local matchStr=AlembicName+"*"+AlembicExt
				local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr
				debugLog "STPlugin.checkAlembic.002"
				if nixArr==undefined or nixArr.count==0 then(
					append G_OBJ_CON.warnList ("Missing Alembic cache")
					append missingAlembic arrxs[i].source
				)else(
					for nix in nixArr do (
						local inScenePath = AlembicFolder+( G_OBJ_FILEUTIL.getFileNameOO nix)
						--format "nix.% >>..%\n" nix inScenePath
						
						append G_OBJ_CON.cacheList (STTexture reallyPath:nix inScenePath:inScenePath)
					)
				)
				debugLog "STPlugin.checkAlembic.003"
			)
			
		)catch(
			format "PRTLoader....\n"
			format "%\n" (getcurrentexception() as string)
		)			
			
		try (
			local arrxs = getclassinstances AlembicObject
		for i = 1 to arrxs.count do 
			(
				debugLog "STPlugin.checkAlembic.001"
				local AlembicFolder = getFilenamePath arrxs[i].source
				local AlembicName = getFileNameFile arrxs[i].source
				local AlembicExt = getFilenameType arrxs[i].source
				format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
				format "AlembicExt...%\n" AlembicExt
				local matchStr=AlembicName+"*"+AlembicExt
				local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr
				debugLog "STPlugin.checkAlembic.002"
				if nixArr==undefined or nixArr.count==0 then (
					append G_OBJ_CON.warnList ("Missing Alembic cache")
					append missingAlembic arrxs[i].source
				)else(
					for nix in nixArr do (
						local inScenePath = AlembicFolder+( G_OBJ_FILEUTIL.getFileNameOO nix)
						--format "nix.% >>..%\n" nix inScenePath
						
						append G_OBJ_CON.cacheList (STTexture reallyPath:nix inScenePath:inScenePath)
					)
				)
				debugLog "STPlugin.checkAlembic.003"
			)
		
		)
		catch(
			format "PRTLoader....\n"
			format "%\n" (getcurrentexception() as string)
		)
		if missingAlembic.count>0 then (
			append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingAlembic code:G_TIPS_CODE.ABC_MISSING)
			append G_OBJ_CON.warnList "Missing Alembic cache"
		)
	),		
----------------------------------------------------------------------------------------------Alembic---------------------------end
	fn checkXmesh = (
			G_OBJ_UTIL.oolog "checkXmesh.check.start"
			try(
				local cacheArr = getclassinstances XMeshLoader
				local missingXmeshList=#()
				for mycache in cacheArr do (
					format "STPlugin.checkXmesh.002\n"
					local renderSequencePath = mycache.renderSequence
					local proxySequencePath = mycache.proxySequence
					
					if renderSequencePath!=undefined and renderSequencePath!="" then (
						local renderSequenceBaseName=getfilenamefile renderSequencePath
						local renderSequencePattern = renderSequenceBaseName
						if renderSequenceBaseName!=undefined and renderSequenceBaseName.count>4 then (--remove serial
							renderSequencePattern = substring renderSequenceBaseName 1 (renderSequenceBaseName.count-4)
						)
						renderSequencePattern="*"+renderSequencePattern+"*"
						format "renderSequencePattern-----%\n" renderSequencePattern
					
					
						format "STPlugin.checkXmesh.003\n"
						renderSequencePath = pathConfig.removePathLeaf renderSequencePath
						format "renderSequencePath...%\n" renderSequencePath
						local renderSequenceArr = G_OBJ_FILEUTIL.getFilesFrom renderSequencePath renderSequencePattern
						if renderSequenceArr==undefined or renderSequenceArr.count==0 then (
							append G_OBJ_CON.warnList ("Missing XMeshLoader Render Sequence cache")
							append missingXmeshList renderSequencePath
						)else(
							for rs in 	renderSequenceArr do (
								local inScenePath = renderSequencePath+"/"+( G_OBJ_FILEUTIL.getFileNameOO rs)
								format "rs--%-->\n" rs
								format "inScenePath1...%\n" inScenePath
								append G_OBJ_CON.cacheList (STTexture reallyPath:rs inScenePath:inScenePath)
							)
						)
						
						
					)
					
					if proxySequencePath!=undefined and proxySequencePath!="" then (
						local proxySequenceBaseName=getfilenamefile proxySequencePath
						local proxySequencePattern = proxySequenceBaseName
						if proxySequenceBaseName!=undefined and proxySequenceBaseName.count>4 then (--remove serial
							proxySequencePattern = substring proxySequenceBaseName 1 (proxySequenceBaseName.count-4)
						)
						proxySequencePattern="*"+proxySequencePattern+"*"
						format "proxySequencePattern-----%\n" proxySequencePattern
					
					
						debugLog "STPlugin.checkXmesh.004"
						proxySequencePath = pathConfig.removePathLeaf proxySequencePath
						format "proxySequencePath...%\n" proxySequencePath
						local proxySequenceArr = G_OBJ_FILEUTIL.getFilesFrom  proxySequencePath proxySequencePattern 
						if proxySequenceArr==undefined or proxySequenceArr.count==0 then (
							append G_OBJ_CON.warnList ("Missing XMeshLoader Proxy Sequence cache")
							append missingXmeshList proxySequencePath
						)else(
							for ps in 	proxySequenceArr do (
								local inScenePath = renderSequencePath+"/"+( G_OBJ_FILEUTIL.getFileNameOO ps)
								format "ps--%-->\n" ps
								format "inScenePath2...%\n" inScenePath
								append G_OBJ_CON.cacheList (STTexture reallyPath:ps inScenePath:inScenePath)
							)
						)	
					)
					
					format "STPlugin.checkXmesh.005\n"
				)
				if missingXmeshList.count>0 then (
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingXmeshList code:G_TIPS_CODE.XMESH_MISSING)
					append G_OBJ_CON.warnList "Missing XMeshLoader Proxy Sequence cache"
				)
			
			)catch()
			format "STPlugin.checkXmesh.006\n"
			G_OBJ_UTIL.oolog "checkXmesh.check.end"
	),
		
	fn writeassetjson =(
		assetjsonfile=fopen assetjson "wb"
		WriteString assetjsonfile (G_ASSETJSON.json())
		fclose assetjsonfile
	),
	
	fn check = (
		textureInfo()
		checkRealflow()
		checkFumeFX()
-- 		writeassetjson()
	)	
	
)
G_Write_Asset = STAsset()
G_Write_Asset.check()

struct STWriteJson(
	
	fn write_file file_text file_path  = (
		if doesFileExist  file_path then (
			deleteFile file_path
		)
		local my_file = createFile file_path
		format file_text to:my_file
		close my_file
		
	),

	fn writetaskjson =(
		write_file (G_TASKJSON.json()) (G_STCON.JSON_PATH as string + "task.json")
	),
	
	fn writeassetjson =(
		write_file (G_ASSETJSON.json()) (G_STCON.JSON_PATH as string + "asset.json")
	),
	
	fn writetipsjson =(
		write_file (G_TIPSJSON.json()) (G_STCON.JSON_PATH as string + "tips.json")
	),
	
	fn check = (
		
		writetaskjson()
		writeassetjson()
		writetipsjson()
	)
)
-- G_Write_Json = STWriteJson()
-- G_Write_Json.check()
-- format "%" (MYJSON.json())


fn rayvision paramArray deleteModel:#() rendModel:#()  = (

	G_STCON.init paramArray	
	format "______________%\n" paramArray
	local loadResult = loadMaxFile G_STCON.MAX_FILE useFileUnits:true quiet:true 

	if loadResult then
	(
		format "+++++++%\n" G_STCON.JSON_PATH
		G_Write_Json = STWriteJson()
		G_Write_Json.check()
	)	
)