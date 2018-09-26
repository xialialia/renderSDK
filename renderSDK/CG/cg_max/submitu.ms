









/*
2051001 vray param
2050918
1005,1002...=3443
1007=3444
2050916
path with driver a,driver b convert to folder a,folder b
sysinfo.GetMaxLanguage()


sysinfo.getLanguage  user:true
1.net not add becouse of client version
log.rayvision

*/

dotnetcode = "
using System;
 
class StdOutPrinter {
    static public bool print(string txt) {
        Console.WriteLine(txt);
        return true;
    }
}
 
class StdErrPrinter {
    static public bool print(string txt) {
        Console.Error.WriteLine(txt);
        return true;
    }
}
class WriteToFile{
	static public bool write(string txt) {
        Console.Error.WriteLine(txt);
        return true;
    }

}

class Common {
	public int compareVersion(string AsVer1,string AsVer2){

		Version v1 = new Version(AsVer1);
		Version v2 = new Version(AsVer2);
		if (v1 > v2){
			return 1;
		}else if (v1 < v2){
			return -1;
		}else{
			return 0;
		}
	}
}
	
"
 
 
 
dotnetcode2 = "
using System;
 

class Common {
	public int compareVersion(string AsVer1,string AsVer2){

		Version v1 = new Version(AsVer1);
		Version v2 = new Version(AsVer2);
		if (v1 > v2){
			return 1;
		}else if (v1 < v2){
			return -1;
		}else{
			return 0;
		}
	}
}
	
"
fn createAssembly dotnetcode className = (
    provider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
    param = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
    param.GenerateInMemory = on
    compiled = provider.CompileAssemblyFromSource param #(dotnetcode)
    compiled.CompiledAssembly.CreateInstance className
)

struct STInfo(-----------abort
    level,--0=info, 1=error, 2=warn
    msgList=#(),
	code
    
)

struct STConfig (------------abort
	key,
	val,
	type
)


struct STTips(-----------replace STInfo
    level,--0=info, 1=error, 2=warn
    msgList=#(),
	code
    
)

struct STCfg (-----------replace STConfig
    okey,
    oval,
    otype
)

struct STResult (
    oName,
    tipsList=#(),
    cfgList=#()
    
    
)


	struct STConstanst(
		allOutputType="tga,tif,jpg,png,rla,rpf,exr",
		allElemType="tga,tif,jpg,png,rla,rpf,exr",
		myStdout = createAssembly dotnetcode "StdOutPrinter",
		dotCommon = createAssembly dotnetcode2 "Common",
		myUserName,
		myUserId,
		myFatherId,
		kg="0",
		myGuy,
		myGuyVersion,
		myProjectId,
		myProjectName,
		myPlatform="1005",
		myProjectPath,
		myMaxVersionInt=((maxversion())[1])/1000,
		myMaxVersionStr,
		myRenderVersion,
		myMaxFile=maxfilePath +maxFileName,
		myRender,
		myTaskId,
		myTaskProjectPath,
		myRenderFarm,
		myTempPath,
		myErrorFile,
		myWarnFile,
		myCustomerPluginCfg="c:/plugins.cfg",
		logCount=1,
		configFile,
		myIngoreWarn,
		myEnableParam,
		mySkipUpload,
		myClientZone,
		myCustomClient,
		mySeperateAccount,
		isDebugLog,
		debugLogCount,
		configList=#(),
		fileList=#(),
		missingFileList=#(),
		cacheList=#(),
		warnList=#(),
		errorList=#(),
		infoList=#(),
		framesArr=#(),
		driverArr=#(),
		
		fileList2=#(),
		cacheList2=#(),
		badMaterialList=#(),
		
		resultList=#()
		
	)
	global G_OBJ_CON=STConstanst()
	
fn debugLog str= (
	if G_OBJ_CON.isDebugLog==true then (
		SetINISetting "c:/rayvision.log" "log" (G_OBJ_CON.debugLogCount as string) ("["+(localTime as string)+"]"+str)
		G_OBJ_CON.debugLogCount=G_OBJ_CON.debugLogCount+1
	)
)
	
	struct STErrorInfo (
		myCode,
		myInfo
		
	)
	struct STTexture(
		inScenePath,
		reallyPath
		
	)
	
	struct RenderBus(
		myFile,
		myPlugin
		
	)
	
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
	global G_TIPS_CODE=STCode()
	
	struct STLang (
		STEP_COUNT="9",
		STEP1_CREATETASK_START="[1/"+STEP_COUNT+"]Create task...",
			
		STEP2_MAXFILE_LOAD_START="[2/"+STEP_COUNT+"]Loading max file...",
		STEP3_COMMON_START="[3/"+STEP_COUNT+"]Common info...",
		STEP4_RENDER_START="[4/"+STEP_COUNT+"]Render info...",
		STEP5_RENDERER_START="[5/"+STEP_COUNT+"]Renderer Info...",
		STEP6_TEXTURE_START="[6/"+STEP_COUNT+"]Texture info...",
		STEP7_PLUGIN_START="[7/"+STEP_COUNT+"]Plugin Info...",
		STEP8_CONFIG_TASK_START="[8/"+STEP_COUNT+"]Config task info...",
		STEP9_SUBMIT_TASK_START="[9/"+STEP_COUNT+"]Submit Task...",
		STEP9_SUBMIT_TASK_END="[9/"+STEP_COUNT+"]Submit task successed",
		
		WARN_XREFFILES="Recommended merge file with reference files detected by the system",
		WARN_XREFOBJ="Stronggly recommended merge file with reference objects detected by the system",
		WARN_RENDERER_NOTSUPPORT="Renderer unsupported",
		
		--WARN_SAVEFILE_INVALID="Invalid file output path or file name",
		--WARN_SAVEFILE_INVALID2="Save files with English letters, numbers and underscore",
		--WARN_SAVEFILE_LONG="Save files with less than 60 characters",
		
		WARN_REALFLOW_VERSIONERR="Please upgrade your realflow version to at least 5.0.4",
		WARN_RENDERABLE_CAMERA_NULL="Renderable camera is null",
		
		ERR_CAMERA_NULL="Missing camera",
		ERR_OUTPUTNAME_NULL="Missing output file name",
		ERR_OUTPUTTYPE_NULL="Missing output file type",
		ERR_PROXY_ENABLE="Enable Proxy System",
		ERR_VRAY_MATCH="Vray don't match",
		--self.error_code9900='3ds max file damage'
		--self.error_code9899='The 3ds Max program does not exist'
		ERROR9001_CREATETASK_FAILED="Create task failed",
		ERROR9003_SUBMIT_TASK_FAILED="Submit task failed",
		
		


		fn enVersion=(
			--if G_OBJ_CON.myMaxVersionStr=="3ds Max 2010" then (
				
			STEP1_CREATETASK_START="[1/"+STEP_COUNT+"]Create task..."
			
			STEP2_MAXFILE_LOAD_START="[2/"+STEP_COUNT+"]Loading max file..."
			STEP3_COMMON_START="[3/"+STEP_COUNT+"]Common info..."
			STEP4_RENDER_START="[4/"+STEP_COUNT+"]Render info..."
			STEP5_RENDERER_START="[5/"+STEP_COUNT+"]Renderer Info..."
			STEP6_TEXTURE_START="[6/"+STEP_COUNT+"]Texture info..."
			STEP7_PLUGIN_START="[7/"+STEP_COUNT+"]Plugin Info..."
			STEP8_CONFIG_TASK_START="[8/"+STEP_COUNT+"]Config task info..."
			STEP9_SUBMIT_TASK_START="[9/"+STEP_COUNT+"]Submit Task..."
			STEP9_SUBMIT_TASK_END="[9/"+STEP_COUNT+"]Submit task successed"
			
			
			
			ERR_PROXY_ENABLE="Enable Proxy System"
			ERR_VRAY_MATCH="Vray don't match"
			ERR_CAMERA_NULL="Missing camera"
			ERR_OUTPUTNAME_NULL="Missing output file name"
			ERR_OUTPUTTYPE_NULL="Missing output file type"
			ERROR9001_CREATETASK_FAILED="Create task failed"
			ERROR9003_SUBMIT_TASK_FAILED="Submit task failed"
			
			
			
			--)
			
		)
		
	)

	global G_OBJ_LANG = STLang()
		
	
	struct STMsg(
		level,--0:error, 1?warn,2:info,3:??(General,Render Settings,Vray....)
		msg,
		key=undefined,
		more--click for more info
		
	)
	
	

	
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
		
		
		fn oolog myval = (
			
			local logPath = G_OBJ_CON.myTaskProjectPath+"/check.log"
			
			if G_OBJ_CON.myMaxVersionInt >= 15 then(
				SetINISetting logPath "log" (G_OBJ_CON.logCount as string) ("["+(localTime as string)+"]"+myval) forceUTF16:true
			)else(
				SetINISetting logPath "log" (G_OBJ_CON.logCount as string) ("["+(localTime as string)+"]"+myval)
			)
			format "%\n" ("["+(localTime as string)+"]"+myval)
			G_OBJ_CON.logCount=G_OBJ_CON.logCount+1
		),
		
		

		
	
		
		fn requestClient action= (--client login 1 ;not 0
			local result 
			
			

			local cmd = "\""+G_OBJ_CON.myGuy +"\" "+action
			if G_OBJ_CON.myMaxVersionInt>11 then (
				HiddenDOSCommand cmd exitCode:&result	
			)else(
				result= DOSCommand    cmd	
			)

			
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


		fn getFormatRender  = (

			local rendStr = ( classof renderers.production ) as string
			local rend = undefined 
			if (rendStr == (vray as string)) then (
				rend="vray"
			) else if (rendStr == (default_scanline_renderer as string)) then (
				rend = "scanline"
			) else if rendStr == (finalRender_stage_1 as string) then (
				rend = "finalrender"
			) else if (rendStr == (MaxwellRenderer as string)) then (
				rend = "maxwell"
			) else if (rendStr == (mental_ray_renderer as string)) then (
				rend = "mentalray"
			) else if (rendStr == (mental_ray_iray_Renderer as string)) then (
				rend = "mentalray_iray"
			) else if (rendStr == (Quicksilver_Hardware_Renderer as string)) then (
				rend = "hardware"
			) 

			rend	
			
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

			local frameStart = rendStart.frame as integer
			local frameEnd = rendEnd.frame as integer
			local framesArr = #()
			local nth = (rendNThFrame as integer)

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

			local result = #()
			for b in framesArr do (
				if findItem result b ==0 then (
					append result b			
				)
				
			)

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

	global G_OBJ_UTIL = STUtil()
	
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

			local fileList = #()
			if iflFileRealyPath!=undefined and doesFileExist iflFileRealyPath   then(
				

				local iflFileParentInscenePath = getfilenamepath iflFileInscenePath
				local iflFileParentReallyPath = getfilenamepath iflFileRealyPath
				
				local fileListTemp = readFile iflFileRealyPath

				for fileLine in fileListTemp do (

					if fileLine==undefined then (continue)
					
					G_OBJ_UTIL.oolog ("getIflFile.fileLine="+fileLine)
					local iflImgBaseName =getfilenamefile fileLine
					local iflImgType =getfilenametype fileLine
					local iflImgTypeArr = filterString iflImgType " "

					if iflImgTypeArr!=undefined and iflImgTypeArr.count>0 then (
						iflImgType=iflImgTypeArr[1]
					)
					local iflImgName=iflImgBaseName+iflImgType
					local rootStr = getfilenamepath fileLine

					G_OBJ_UTIL.oolog ("getIflFile.iflImgrootStr="+rootStr+";iflImgName="+iflImgName)
					local iflImgInIflFileDir = iflFileParentReallyPath+iflImgName
					local iflImgInMaxfileDir=maxfilePath+iflImgName
					G_OBJ_UTIL.oolog ("getIflFile.iflImgInIflFileDir="+iflImgInIflFileDir)
					G_OBJ_UTIL.oolog ("getIflFile.iflImgInMaxfileDir="+iflImgInMaxfileDir)
					if rootStr==undefined or rootStr==""  then (-- only file name

						if doesFileExist iflImgInIflFileDir then(
							append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInIflFileDir inScenePath:(iflFileParentInscenePath+iflImgName))
						)else(--check again maxfile dir

							local iflImgInScenePath = iflFileParentInscenePath+iflImgName--iflImgInMaxfileDir+iflImgName
							if doesFileExist iflImgInMaxfileDir then(
								append G_OBJ_CON.fileList (STTexture reallyPath:iflImgInMaxfileDir inScenePath:iflImgInScenePath)
							)else(
								if fileLine!=undefined and fileLine!="" and G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList fileLine==false then (
									append G_OBJ_CON.missingFileList fileLine
								)
							)

							
						)
					)else(-- with  path

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

						
						
					)
					
					
				)
				
			)
		),
		
		fn getFilesFrom mpath matchStr= (
			--1.check absolute path
			--2.check max dir folder
			--3.check max dir file

			local fileArr = #()
			
			if mpath!=undefined then (
				if doesfileexist mpath then (
					fileArr=getfiles (mpath +"/"+matchStr)	
				)

				if fileArr==undefined or fileArr.count==0 then (

					local mpathTemp =G_OBJ_UTIL.ooReplace mpath "\\" "/"
					format "mpathTemp___%\n" mpathTemp
					local mpathArr = filterstring mpathTemp "/"
					if mpathArr!=undefined and mpathArr.count>1 then (

						local cacheFolder = mpathArr[mpathArr.count]
						format "cacheFolder__%\n" cacheFolder
						local resultMatchStr= (maxfilePath +cacheFolder+"/"+matchStr)
						resultMatchStr =G_OBJ_UTIL.ooReplace resultMatchStr "\\" "/"
						format "maxdir folder----%\n" resultMatchStr
						fileArr=getfiles resultMatchStr	
					)	
				)

				if fileArr==undefined or fileArr.count==0 then (

					local resultMatchStr= (maxfilePath +matchStr)	
					resultMatchStr =G_OBJ_UTIL.ooReplace resultMatchStr "\\" "/"
					format "maxdir folder----%\n" resultMatchStr
					fileArr = getfiles resultMatchStr	
				)

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
	global G_OBJ_FILEUTIL = STFileUtil()
	
	
	struct STCommon (
		
		
		fn check = (
			G_OBJ_UTIL.oolog "STCommon...check...Start "
			
			
			append G_OBJ_CON.configList (STConfig key:"cgv" val:G_OBJ_CON.myMaxVersionStr type:"common")
			
			G_OBJ_UTIL.oolog ("BitmapProxyMgr.globalProxyEnable " +(BitmapProxyMgr.globalProxyEnable as string))
			if BitmapProxyMgr.globalProxyEnable==true then (
				append G_OBJ_CON.errorList G_OBJ_LANG.ERR_PROXY_ENABLE
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.PROXY_ENABLE)
				
			)

			
			local xrefcount = xrefs.getXRefFileCount()
			if xrefcount > 0 then(			
				append G_OBJ_CON.warnList G_OBJ_LANG.WARN_XREFFILES
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.XREFFILES)
			)

			local xrefobjcount = objXRefs.getNumfiles()
			if xrefobjcount > 0 then	(	
				append G_OBJ_CON.warnList G_OBJ_LANG.WARN_XREFOBJ
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.XREFOBJ)
			)

			local sceneProject="A:/"
			local sceneFile=sceneProject+maxFileName--G_OBJ_CON.myTaskId+".max"
			--if G_OBJ_CON.myPlatform=="1005" or G_OBJ_CON.myPlatform=="1004"  or G_OBJ_CON.myPlatform=="1002" then (
			if G_OBJ_CON.myPlatform=="1004"   then (
				sceneProject="C:/work/render/"+G_OBJ_CON.myTaskId+"/"
				sceneFile=sceneProject+maxFileName--G_OBJ_CON.myTaskId+".max"
			)
			

			G_OBJ_CON.framesArr=G_OBJ_UTIL.getFramesArr()
			

			
			append G_OBJ_CON.configList (STConfig key:"original_cg_file" val:((maxfilepath+maxfilename) as string) type:"common")
			append G_OBJ_CON.configList (STConfig key:"project" val:"max" type:"common")
			append G_OBJ_CON.configList (STConfig key:"projectId" val:G_OBJ_CON.myProjectId type:"common")
			append G_OBJ_CON.configList (STConfig key:"projectSymbol" val:G_OBJ_CON.myProjectName type:"common")
			append G_OBJ_CON.configList (STConfig key:"taskId" val:G_OBJ_CON.myTaskId type:"common")
			append G_OBJ_CON.configList (STConfig key:"cgSoftName" val:"max" type:"common")

			append G_OBJ_CON.configList (STConfig key:"zone" val:"1" type:"common")
			append G_OBJ_CON.configList (STConfig key:"userId" val:G_OBJ_CON.myUserId type:"common")
			append G_OBJ_CON.configList (STConfig key:"sceneProject" val:sceneProject type:"common")
			append G_OBJ_CON.configList (STConfig key:"sceneFile" val:sceneFile type:"common")
			append G_OBJ_CON.configList (STConfig key:"cgFile" val:sceneFile type:"common")

			
			append G_OBJ_CON.configList (STConfig key:"platform" val:G_OBJ_CON.myPlatform type:"common")
					--------------------------------
			G_OBJ_UTIL.oolog "STCommon...check...completed "
			try(
				local File_Gamma = IDisplayGamma.colorCorrectionMode as string
				G_OBJ_UTIL.setIni   "common" "fileGamma"  File_Gamma
				)
			catch()
		
		)
	)
	
	struct STRender(
		fn getMyCamera=(

			local myCamera = getActiveCamera()
			local renderView

			try(
				if (rendUseActiveView) then ( 
					renderView = viewport.activeViewport 
				)else ( 
					renderView = rendViewIndex 
				)
				myCamera =  (viewport.getCamera index:renderView)
				
			)catch()

			local cameraStr = undefined 
			if myCamera!=undefined then (
				cameraStr=myCamera.name
				
			)

			cameraStr
		),
		fn getAllCameras = (
			
			local allCamera=""
			local cameraList = #()
			for i=1 to cameras.count do(
				
				local c=cameras[i]
				if ((classof c) as string )!="Targetobject" then (
					format "c>>>>%____%\n" (classof c) c.name
					append cameraList c.name
				)
			)
			
			for i=1 to cameraList.count do(
				
				local cName=cameraList[i]
				if i==cameraList.count then (
					allCamera= allCamera+ cName
				)else(
					allCamera= allCamera+ cName+"[,]"
				)
					
				
			)
			
			format "allCam...%\n" allCamera
			allCamera
		),
		
		fn elem  = (
			-- vfb setting in vray

			local rend = renderers.production
			local renderElementsMgr = maxOps.GetRenderElementMgr #Production
			local elementActive=renderElementsMgr.GetElementsActive()

			if elementActive==true then (
				append G_OBJ_CON.configList (STConfig key:"ElementActive" val:"on" type:"renderSettings")
			)else(
				append G_OBJ_CON.configList (STConfig key:"ElementActive" val:"off" type:"renderSettings")
			)

			elementStr=""
			if renderElementsMgr.numrenderelements()>0 then (

				local elemPath = renderElementsMgr.getRenderElementFilename 0 
				
				local elemType=undefined
				if elemPath!=undefined then (
					elemType=getfilenametype elemPath
				)

				if elemType==undefined or elemType=="" then (
					if  rendOutputFilename!=undefined then (
						local outputType = getfilenametype rendOutputFilename
						elemType=outputType
					)
					
				)

				if elemType==undefined or elemType=="" then (
					elemType="tga"
				)

				elemType=G_OBJ_UTIL.ooReplace elemType "." ""
				append G_OBJ_CON.configList (STConfig key:"elemType" val:elemType type:"renderSettings")

			)
			
			local elemCount=1
			
			for n = 0 to (renderElementsMgr.numrenderelements()- 1) do(
				
				el = renderElementsMgr.GetRenderElement n
				if ((classof el))==Missing_Render_Element_Plug_in then (
					format "missing----------\n"
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.ELEM_MISSING)
					exit
				)
				if not hasProperty el "elementName" then(
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.ELEM_MISSING)
					exit
				)
				
				format "elementName.....%\n" el.elementName
				if (el.enabled as string) =="true" then
				(
					local elemName = ((el.elementName as string)+" [On]")  ------------2017-12-26
				)
				else
				(
					local elemName = ((el.elementName as string)+" [Off]")  ------------2017-12-26
				)
				
				local elemPath = renderElementsMgr.getRenderElementFilename n 
				
				--if el.enabled == true  then (
				if elemName==undefined then (elemName="")
				if n==0 then (
					elementStr=elemName
					
				)else(
					elementStr=elementStr+"[,]"+elemName
					
				)
				--)
				if elemPath==undefined then (elemPath="")
				local eeStr = elemName+"|"+elemPath
				append G_OBJ_CON.configList (STConfig key:("renderelement"+(elemCount as string)) val:eeStr type:"renderSettings")
				elemCount=elemCount+1
				
						
				
				
			)

			append G_OBJ_CON.configList (STConfig key:"Render Element" val:elementStr type:"renderSettings")
		-------------------Render Element
			
			
		),

		fn check =(	
			--------------Time Output
			G_OBJ_UTIL.oolog "STRender...check...start "

			local rend = renderers.production
			local rendc = classof rend 
			
			G_OBJ_CON.myRender=rendc as string

			local mi = findstring G_OBJ_CON.myRender "miss"
			local rt = findstring G_OBJ_CON.myRender "rt"

			if mi!=undefined then (
				append G_OBJ_CON.errorList "Missing renderer"
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_MISSING)
				
			)

			if rt!=undefined then (
				append G_OBJ_CON.errorList (G_OBJ_LANG.WARN_RENDERER_NOTSUPPORT+" RT renderer" )
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_NOTSUPPORT)
				
				
			)

			append G_OBJ_CON.configList (STConfig key:"render" val:G_OBJ_CON.myRender type:"common")
			
			if G_OBJ_CON.myRender== mental_ray_iray_Renderer or G_OBJ_CON.myRender == Quicksilver_Hardware_Renderer or G_OBJ_CON.myRender == Brazil_r_s_Rio_Learning_Edition_v2_0__build_1618 then(
				append G_OBJ_CON.errorList (G_OBJ_LANG.WARN_RENDERER_NOTSUPPORT+" "G_OBJ_CON.myRender)	
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_NOTSUPPORT)				
			)

			
			
			append G_OBJ_CON.configList (STConfig key:"cameraDelimiter" val:"[,]" type:"renderSettings")
			
			local rendTimeTypeOld =rendTimeType as string
			append G_OBJ_CON.configList (STConfig key:"rendTimeType" val:rendTimeTypeOld type:"renderSettings")
			
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

			
			if getrendertype() != #view and getrendertype() != #normal then -----2017-12-26
			(
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#("Area to Render :"+(getrendertype() as string )) code:G_TIPS_CODE.RENDER_TYPE)
				append G_OBJ_CON.warnList ("Area to Render "+getrendertype() as string )
			)
			
			append G_OBJ_CON.configList (STConfig key:"customclient" val:G_OBJ_CON.myCustomClient type:"common")
			append G_OBJ_CON.configList (STConfig key:"clientzone" val:G_OBJ_CON.myClientZone type:"common")
			
			if G_OBJ_CON.myCustomClient=="yunwu" then(
				append G_OBJ_CON.configList (STConfig key:"isPicture" val:"false" type:"common")
			)else(
				if G_OBJ_CON.myClientZone=="renderbus" then(
					local compareVersion=G_OBJ_CON.dotCommon.compareVersion  G_OBJ_CON.myGuyVersion "4.0.2.7"
					if compareVersion==0 or compareVersion==1 then(
						if (matchPattern frameStr pattern:"*,*") or (matchPattern frameStr pattern:"*-*")  then (
							append G_OBJ_CON.configList (STConfig key:"isPicture" val:"false" type:"common")
						)else(
							append G_OBJ_CON.configList (STConfig key:"isPicture" val:"true" type:"common")
						)
					)
				)else(
					append G_OBJ_CON.configList (STConfig key:"isPicture" val:"false" type:"common")
				)
				
			)
			
			

			
			append G_OBJ_CON.configList (STConfig key:"frames" val:frameStr type:"renderSettings")
			local animationRangeStart=((animationRange.Start as string)as integer) as string
			local animationRangeEnd=((animationRange.End as string)as integer) as string
			append G_OBJ_CON.configlist (STConfig key:"animationRange" val:(animationRangeStart+"-"+animationRangeEnd) type:"renderSettings")
        
			if G_OBJ_CON.myCustomClient=="yunwu" then(
				append G_OBJ_CON.configList (STConfig key:"width" val:"4096" type:"renderSettings")
				append G_OBJ_CON.configList (STConfig key:"height" val:"2048" type:"renderSettings")
				append G_OBJ_CON.configList (STConfig key:"giwidth" val:"1800" type:"vray")
				append G_OBJ_CON.configList (STConfig key:"giheight" val:"900" type:"vray")
			)else(
				append G_OBJ_CON.configList (STConfig key:"width" val:(renderWidth as string) type:"renderSettings")
				append G_OBJ_CON.configList (STConfig key:"height" val:(renderHeight as string) type:"renderSettings")
				
				append G_OBJ_CON.configList (STConfig key:"giwidth" val:(renderWidth as string) type:"vray")
				append G_OBJ_CON.configList (STConfig key:"giheight" val:(renderHeight as string) type:"vray")
			)
			

			append G_OBJ_CON.configList (STConfig key:"giframes" val:frameStr type:"vray")

			
			-------------Render Output		
			
			/*
			
			if rendOutputFilename==undefined or rendOutputFilename=="" then(
				append G_OBJ_CON.warnList G_OBJ_LANG.WARN_SAVEFILE_INVALID
			)
			local outfilename = G_OBJ_FILEUTIL.getFileNameOO rendOutputFilename
			if G_OBJ_UTIL.isNameSupported outfilename == false then(
				append G_OBJ_CON.warnList G_OBJ_LANG.WARN_SAVEFILE_INVALID2
			)
			if outfilename.count > 60 then(			
				append G_OBJ_CON.warnList G_OBJ_LANG.WARN_SAVEFILE_LONG
				
			)
			*/
			local outfilename = G_OBJ_FILEUTIL.getFileNameOO rendOutputFilename
			append G_OBJ_CON.configList (STConfig key:"rendSaveFile" val:(rendSaveFile as string) type:"renderSettings")
			append G_OBJ_CON.configList (STConfig key:"rendOutputFilename" val:(rendOutputFilename as string) type:"renderSettings")
			

			if outfilename==undefined or outfilename=="" then (

				if G_OBJ_CON.myEnableParam=="2" then (
					if G_OBJ_CON.myCustomClient=="yunwu" then(
						outfilename="rayvision.jpg"
					)else(
						outfilename="rayvision.tga"
					)
					
					append G_OBJ_CON.configList (STConfig key:"output" val:outfilename type:"renderSettings")
				)else(
					append G_OBJ_CON.errorList G_OBJ_LANG.ERR_OUTPUTNAME_NULL
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.OUTPUTNAME_NULL)
				)
			)else(

				
				local outBaseName=getfilenamefile outfilename
				local outBaseType=getfilenametype outfilename
				if G_OBJ_CON.myEnableParam=="2" then (

					if outBaseName==undefined or outBaseName=="" then (
						outBaseName="rayvision"
					)
					if outBaseType==undefined or outBaseType=="" then (
						if G_OBJ_CON.myCustomClient=="yunwu" then(
							outBaseType=".jpg"
						)else(
							outBaseType=".tga"
						)
						
					)
					outfilename=outBaseName+outBaseType
					append G_OBJ_CON.configList (STConfig key:"output" val:outfilename type:"renderSettings")
				)else(

					if outBaseName==undefined or outBaseName=="" then (
						append G_OBJ_CON.errorList G_OBJ_LANG.ERR_OUTPUTNAME_NULL
						append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.OUTPUTNAME_NULL)
					)

					if outBaseType==undefined or outBaseType=="" then (
						append G_OBJ_CON.errorList G_OBJ_LANG.ERR_OUTPUTTYPE_NULL
						append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.OUTPUTNAME_NULL)
					)
					append G_OBJ_CON.configList (STConfig key:"output" val:outfilename type:"renderSettings")
				)
				
				
			)
			
			
			

			
			local oldRendOutputFilename=rendOutputFilename
			local cam = getActiveCamera()		
			if G_OBJ_CON.myMaxVersionInt>= 11 then(
				if rendUseActiveView == false and rendViewIndex != undefined then (-- viewport locked
					cam = viewport.getCamera index:rendViewIndex
				)
				
			)

			
			local allCameras = getAllCameras()
			
			if allCameras==undefined or allCameras=="" or allCameras=="[,]" then (

				append G_OBJ_CON.errorList G_OBJ_LANG.ERR_CAMERA_NULL
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.CAMERA_NULL)
			)
			

			append G_OBJ_CON.configList (STConfig key:"allCamera" val: allCameras type:"renderSettings")
            
            if G_OBJ_CON.myCustomClient=="yunwu" then(
                append G_OBJ_CON.configList (STConfig key:"renderableCamera" val: allCameras type:"renderSettings")
            )else(
				local renderableCamera = getMyCamera()
			
				if renderableCamera!=undefined and renderableCamera!="" then (
					append G_OBJ_CON.configList (STConfig key:"renderableCamera" val:renderableCamera type:"renderSettings")
					--append G_OBJ_CON.configList (STConfig key:"renderableCameras" val:renderableCamera type:"renderSettings")
				)else(
					if G_OBJ_CON.myEnableParam=="2" then (
						append G_OBJ_CON.warnList G_OBJ_LANG.WARN_RENDERABLE_CAMERA_NULL
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.RENDERABLE_CAMERA_NULL)
					)else(
						append G_OBJ_CON.errorList G_OBJ_LANG.ERR_CAMERA_NULL
						append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.CAMERA_NULL)
					)
					
				)
			)
            
			

			
			if IDisplayGamma.colorCorrectionMode == #gamma then(

				append G_OBJ_CON.configList (STConfig key:"gamma" val: "on" type:"renderSettings")
				
				append G_OBJ_CON.configList (STConfig key:"gammaval" val: (IDisplayGamma.gamma as string) type:"renderSettings")
				append G_OBJ_CON.configList (STConfig key:"ingamma" val: (fileInGamma as string) type:"renderSettings")
				append G_OBJ_CON.configList (STConfig key:"outgamma" val: (fileOutGamma as string) type:"renderSettings")
				
				
				append G_OBJ_CON.warnList "Gamma on"
				append G_OBJ_CON.warnList ("Input Gamma " +  fileInGamma as string)
				append G_OBJ_CON.warnList ("Output Gamma " +  fileOutGamma as string)
				
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#(("Input Gamma " +  fileInGamma as string),("Output Gamma " +  fileOutGamma as string)) code:G_TIPS_CODE.GAMMA_ON)
				
				
			)else(
				append G_OBJ_CON.configList (STConfig key:"gamma" val: "off" type:"renderSettings")
			)

					-------------------Render Element
			elem()

			--join G_OBJ_CON.preExec preExec
			--join G_OBJ_CON.postExec postExec
			
			G_OBJ_UTIL.oolog "STRender...check...completed "

			
		)
		
	)

	

	
	struct STAsset(
		
		
		fn checkAsset = (
			G_OBJ_UTIL.oolog "checkAsset.check"

			
			local env = useEnvironmentMap	--extremely weird bug in max: if a special hdr file is in the env slot it activates the env map. nobody knows why... FUCK MAX
			rend = renderers.production

				
			try(
				if classof rend == vray   then(
					if rend.environment_gi_on and rend.environment_gi_map != undefined then(
						

						envGimap = getMeditMaterial 1 
						setMeditMaterial 1 rend.environment_gi_map 
						
					)
					if rend.environment_rr_on and rend.environment_rr_map != undefined then(

						envRrmap = getMeditMaterial 2 
						setMeditMaterial 2 rend.environment_rr_map 
						
					)
					if rend.environment_refract_on and rend.environment_refract_map != undefined then(

						envRefractmap = getMeditMaterial 3 					
						setMeditMaterial 3 rend.environment_refract_map 
						
					)
				
				)
			)catch()

			useEnvironmentMap = env
			G_OBJ_UTIL.oolog "checkAsset.check1"
			local texList = #()
			Atsops.Refresh()
			Atsops.getFiles &texList
			for tex in texList do (
				if tex==(maxfilepath+maxfilename) then(
					continue
				)
				if  (matchpattern tex pattern:"*.vdb" ignoreCase:true) then( 
					continue
				)
				if  (matchpattern tex pattern:"*.fxd" ignoreCase:true) then( 
					continue
				)
						local rawFile=""
				try(
					rawFile=renderers.current.output_rawFileName
				)catch()
				local splitFile=""
				try(
					splitFile=renderers.current.output_splitfilename
				)catch()

				if  (ATSOps.IsInputFile tex) and tex!=rawFile and tex!=splitFile then(
					--appendIfUnique G_OBJ_CON.fileList2 tex
					append G_OBJ_CON.fileList2 tex
					format "--------------------->%\n" tex
				)
				
			)
			

			
		),
		
		fn checkBitmap = (
			G_OBJ_UTIL.oolog "STAsset.checkBitmap.start"

			local bitmapList = #()
			try(
				local allBitmaps1 = getClassInstances bitmapTex processChildren:True
				join bitmapList allBitmaps1
				
			)catch(
			
				G_OBJ_UTIL.oolog  "bitmapTex...."
				G_OBJ_UTIL.oolog  (getcurrentexception() as string) 
			)

			G_OBJ_UTIL.oolog "checkBitmap.check1"
			try(
				local allBitmaps2 = getClassInstances bitmapHDR processChildren:True 
				join bitmapList allBitmaps2
			)catch(
				G_OBJ_UTIL.oolog  "---bitmapHDR...." 
				G_OBJ_UTIL.oolog  (getcurrentexception() as string)
			)

			
			for myBitmap in bitmapList do (
				format "%___%\n" myBitmap G_OBJ_CON.fileList2
				try(
					--appendIfUnique G_OBJ_CON.fileList2 myBitmap.filename
					append G_OBJ_CON.fileList2 myBitmap.filename
				)catch(
					G_OBJ_UTIL.oolog  "---bitmapHDR...." 
					G_OBJ_UTIL.oolog  (getcurrentexception() as string)
				)
			)
			G_OBJ_UTIL.oolog "checkBitmap.check.end"
			
		),
		

		
		fn checkPointCache=(
			G_OBJ_UTIL.oolog "checkPointCache.check"

			local pcArr = #()
			
			try(
				pcArr = getClassInstances  Point_Cache
				local pcwsmArr =  getClassInstances Point_CacheSpacewarpModifier
				join pcArr pcwsmArr
			)catch()		

			for pc in pcArr do (
				--G_OBJ_FILEUTIL.handleFile pc.fileName
				--appendIfUnique G_OBJ_CON.fileList2 pc.fileName
				append  G_OBJ_CON.fileList2 pc.fileName
			)

		),
		
		fn checkVrayAsset=(
			G_OBJ_UTIL.oolog "checkVrayAsset.check" 

			/*
			try(
				local hdris = getClassInstances VRayHDRI
				for hd in hdris do	(
					
					G_OBJ_FILEUTIL.handleFile hd.HDRIMapName
				)
			)catch()
			
			*/

			
			try
			(
				local hdris = getClassInstances VRayHDRI
				
				
				/*
				if hdris.count>0 then (
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.VRAY_HDRI_NOTSUPPORT)
				)
				
				*/
				
				local missingHdrList=#()
				for hd in hdris do	(
					format "hdri...%___%\n" hd hd.HDRIMapName
					
					if hd!=undefined and hd.HDRIMapName!=undefined and hd.HDRIMapName!="" then (
						local hdriMap= hd.HDRIMapName
						local hdriMapName = getfilenamefile hdriMap
						local hdriMapType = getfilenametype hdriMap
						local defaultHdriMapFolder = getFilenamePath hdriMap
						format "hdriMap...%\n" hdriMap
						format "hdriMapName...%\n" hdriMapName
						format "hdriMapType...%\n" hdriMapType
						format "defaultHdriMapFolder...%\n" defaultHdriMapFolder
						if (matchpattern hdriMapName pattern:"*<UDIM>*" ignoreCase:true) then (
							local matchStr=(G_OBJ_UTIL.ooReplace hdriMapName "<UDIM>" "*")+hdriMapType
							format "matchStr...%\n" matchStr
							local defaultArr = G_OBJ_FILEUTIL.getFilesFrom defaultHdriMapFolder matchStr
							format "defaultArr...%\n" defaultArr
							if defaultArr==undefined or defaultArr.count==0 then (
								append G_OBJ_CON.warnList ("Missing VRayHDRI<UDIM> "+hdriMap)
								append missingHdrList hdriMap
							)else(
								for myMap in defaultArr do (
									format "result...%\n" myMap
									--appendIfUnique G_OBJ_CON.fileList2 myMap
									append  G_OBJ_CON.fileList2 myMap
								)
							
							)
						
						)else(
							--appendIfUnique G_OBJ_CON.fileList2 hd.HDRIMapName
							append  G_OBJ_CON.fileList2 hd.HDRIMapName
						)
					)
				)
				if missingHdrList.count>0 then (
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingHdrList code:G_TIPS_CODE.HDRI_MISSING)
					append G_OBJ_CON.warnList "Missing VRayHDRI<UDIM> "
				)
				
				
			)catch(
				format "excet....%\n" (getcurrentexception() as string)
			)
		
		
		
			try
			(
				local cams = getClassInstances VRayStereoscopic
				for cam in cams do(
					
					if  cam.enabled == true and cam.shademap_mode == 2 then(
						local p = cam.shademap_file
						if p != undefined then(
							local pInsceneRootPath=getFilenamePath p				
							local sp = (substring p 1 (p.count - (filenameFromPath p).count)) + "*.vrst"
							local spFiles = getFiles sp
							for pp in spFiles do(

								local ppResultName= G_OBJ_FILEUTIL.getFileNameOO pp
								local ppInsceneFile=pInsceneRootPath+ppResultName
								append G_OBJ_CON.fileList (STTexture reallyPath:pp inScenePath:ppInsceneFile)
							
							)
							
						)
					)
				)
			)catch()

			--VRayPhysicalCamera
			try(
				local cams = getClassInstances VRayPhysicalCamera
				for cam in cams do(
					if cam.distortion_type == 2 then(
						--G_OBJ_FILEUTIL.handleFile  cam.lens_file
						--appendIfUnique G_OBJ_CON.fileList2 cam.lens_file
						append  G_OBJ_CON.fileList2 cam.lens_file
					)
				)
			)catch()

			
			try(
				local vrbmp = getClassInstances VRayBmpFilter
				for b in vrbmp do (
					--G_OBJ_FILEUTIL.handleFile b.bitmapname
					--appendIfUnique G_OBJ_CON.fileList2 b.bitmapname
					append  G_OBJ_CON.fileList2 b.bitmapname
				)
			)catch()

			
			try(
				local ies = getClassInstances VRayIES
				for i in ies do(
					--G_OBJ_FILEUTIL.handleFile i.ies_file
					--appendIfUnique G_OBJ_CON.fileList2 i.ies_file
					append  G_OBJ_CON.fileList2 i.ies_file
					
				)
			)catch()
			

			try(
				local vrayBmpArr = getClassInstances VRayBmpFilter
				for myFile in vrayBmpArr do (
					--G_OBJ_FILEUTIL.handleFile myFile.filename
					--appendIfUnique G_OBJ_CON.fileList2 myFile.filename
					append  G_OBJ_CON.fileList2 myFile.filename
				)
			)catch()
			

			try(
				local errVrmeshList=#()
				local vrMeshArr=getclassinstances vrayproxy
				for myMesh in vrMeshArr do (
					
					local aax = getfilenametype myMesh.Filename
					--appendIfUnique G_OBJ_CON.fileList2  myMesh.filename
					append G_OBJ_CON.fileList2  myMesh.filename
					
				)
				
				
					
			)catch()
			

	
	
			

			format "start ...vRayVolumeGridArr..\n"
			try(
				local vRayVolumeGridArr=getclassinstances VRayVolumeGrid
				format "vRayVolumeGridArr...%\n" vRayVolumeGridArr
				local vdbMissingList=#()
				for volumeGrid in vRayVolumeGridArr do (
					if volumeGrid.rendinput!=undefined and  (matchPattern volumeGrid.rendinput pattern:"*####.vdb") then (
						local volumeGridBasename=getfilenamefile volumeGrid.rendinput
						local volumeGridFolder=getfilenamepath volumeGrid.rendinput
						local matchStr = substring volumeGridBasename 1 (volumeGridBasename.count-4)
						matchStr=matchStr+"*.vdb"
						format "match...%\n" matchStr
						local volumeGridArr = G_OBJ_FILEUTIL.getFilesFrom volumeGridFolder matchStr

						if volumeGridArr==undefined or volumeGridArr.count==0 then (
							append G_OBJ_CON.warnList ("Missing VRayVolumeGrid cache")
							append vdbMissingList volumeGrid.rendinput
						)else(
							for volumeGrid in volumeGridArr do (
								local inScenePath = volumeGridFolder+( G_OBJ_FILEUTIL.getFileNameOO volumeGrid)
								append G_OBJ_CON.cacheList (STTexture reallyPath:volumeGrid inScenePath:inScenePath)
							)
						)

						
						
					)else(
						--G_OBJ_FILEUTIL.handleFile volumeGrid.rendinput
						--appendIfUnique G_OBJ_CON.fileList2  volumeGrid.rendinput
						append  G_OBJ_CON.fileList2  volumeGrid.rendinput
					)
					
					
					
				)
				
				if vdbMissingList.count>0 then (
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:vdbMissingList code:G_TIPS_CODE.VDB_MISSING)
					append G_OBJ_CON.warnList "missing vdb"
				)
			)catch()
		),
		

		

		fn getObjectByMaterial  materialList=(--get refrence object by materail or texture
			local materialCount=1
			for myMaterial in materialList do (
				
				local objectList=refs.dependents myMaterial
				local refObjStr="("
				for myObj in objectList where superclassof myObj == geometryclass do (
					refObjStr=refObjStr+myObj.name +","
				)
				refObjStr=refObjStr+")"
				local mKey="BAD."+((classof myMaterial as string)+(materialCount as string))
				local mValue=myMaterial.name+refObjStr
				if mValue!=undefined then(
                    format "%=%\n"  mKey mValue
                    mValue=substituteString mValue "[" "\["
                    mValue=substituteString mValue "]" "\]"
                    mValue=substituteString mValue "\"" "\\\""
                    mValue=substituteString mValue "{" "\{"
                    mValue=substituteString mValue "}" "\}"
                    
                    append G_OBJ_CON.configList (STConfig key:mKey val:mValue type:"maxInfo")
                    append G_OBJ_CON.badMaterialList mValue
                    materialCount=materialCount+1
                )
			)
			
			
		),


		fn getBadMaterailAndTexture=(
			append G_OBJ_CON.configList (STConfig key:"-----------BAD Material or Texture" val:"-----------" type:"maxInfo")
			try(
				local raytraceMaterialList=getclassinstances RaytraceMaterial 
				getObjectByMaterial  raytraceMaterialList
			)catch()
			
			try(
				local raytracelList=getclassinstances Raytrace 
				getObjectByMaterial  raytracelList
			)catch()
			
			try(
				local flatMirrorList =getclassinstances FlatMirror
				getObjectByMaterial   flatMirrorList
			)catch()
			
			try(
				local reflectRefractList =getclassinstances ReflectRefract
				getObjectByMaterial  reflectRefractList
			)catch()
			
			try(
				local autodeskMaterialList =getclassinstances Autodesk_Material
				getObjectByMaterial   autodeskMaterialList
			)catch()
			
			try(
				local architecturalList =getclassinstances Architectural
				getObjectByMaterial   architecturalList
			)catch()
			
			try(
				local mList =getclassinstances blend
				getObjectByMaterial   mList
			)catch()
			
			try(
				local mList =getclassinstances normal_bump
				getObjectByMaterial   mList
			)catch()
			
			try(
				local mList =getclassinstances Shellac
				getObjectByMaterial   mList
			)catch()
			
			
			if G_OBJ_CON.badMaterialList.count>0 then (
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:G_OBJ_CON.badMaterialList code:G_TIPS_CODE.BAD_MATERIAL)
				append G_OBJ_CON.warnList "Bad Material"
			)
		),
		
		
		fn getBadObjects=(
			local badObjList = #()
			try(
				for obj in geometry do (
					
					local fv=getPolygonCount obj 
					if fv[1]==0 do (
						append badObjList obj.name
						
					) 
				)
			)catch()
			
			if badObjList.count>0 then (
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:badObjList code:G_TIPS_CODE.BAD_OBJ)
				append G_OBJ_CON.warnList "Bad Object"
			)
		),

		fn check =(
			G_OBJ_UTIL.oolog "STAsset.start"

			checkAsset()

			checkBitmap()
			

			checkPointCache()

			checkVrayAsset()

			for mfile in G_OBJ_CON.fileList2 do (
				
				G_OBJ_FILEUTIL.handleFile mfile
				
				
			)

			--getBadMaterailAndTexture()
			--getBadObjects()
			
			G_OBJ_UTIL.oolog "STAsset.end"
		)
		
	)
	
	struct STPlugin(
				
		fn checkRealflow = (--------------------------------------------------------------20170824
			G_OBJ_UTIL.oolog "checkRealflow.check"
			G_OBJ_UTIL.oolog "--RFMeshLoader--"

			local missingRealflowList=#()
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
				
				for rfMesh in AllreMesh do(	

					local meshPath = rfMesh.path			
					if meshPath!=undefined and meshPath!="" then (

						local prefix = rfMesh.prefix	
						local rfFormat = rfMesh.Format	

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

						format "realflow---%---->>%\n" meshPath prefix
						local fileArr = G_OBJ_FILEUTIL.getFilesFrom meshPath prefix

						if fileArr==undefined or fileArr.count==0 then (

							if G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList meshPath==false then (
								append G_OBJ_CON.missingFileList meshPath
								append missingRealflowList meshPath
							)
						)else(

							for f in fileArr do (
								local inScenePath = meshPath+( G_OBJ_FILEUTIL.getFileNameOO f)
								append G_OBJ_CON.cacheList (STTexture reallyPath:f inScenePath:inScenePath)
							)
						)
						

					)
					
				)
			)catch()
			
			if missingRealflowList.count>0 then (
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_MISSING)
				append G_OBJ_CON.warnList "Missing realflow"
			)
			
			G_OBJ_UTIL.oolog "--ParticleLoader--"
			
			local isValidVersionParticleLoader = true

			try
			(
				local rfParticles = getClassInstances ParticleLoader
				if rfParticles.count > 0 then(

					if not hasProperty rfParticles[1] "binPath" then(
						isValidVersionParticleLoader=false
						append G_OBJ_CON.warnList G_OBJ_LANG.WARN_REALFLOW_VERSIONERR	
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_VERSION)
					)

					if isValidVersionParticleLoader then (

						for rfp in rfParticles do (
							local bpath = rfp.binPath
							
							if bpath!=undefined and bpath!="" then (

								local prefix = rfp.binPrefix	
								prefix = prefix+"*.bin"
								local fileArr = G_OBJ_FILEUTIL.getFilesFrom bpath prefix

								for f in fileArr do (
									local inScenePath = bpath+( G_OBJ_FILEUTIL.getFileNameOO f)
									append G_OBJ_CON.cacheList (STTexture reallyPath:f inScenePath:inScenePath)
								)

							)
							
						)
					)
				)
				
			)catch()
			
			

			
			G_OBJ_UTIL.oolog "--RFSoftBody--"
			local isValidVersionRFSoftBody = true
			try(
				
				local rfEditableMeshPaths = getClassInstances RFSoftBody

				if rfEditableMeshPaths.count>0 then (
					if not hasProperty rfEditableMeshPaths[1] "SD_Filename" then (

						isValidVersionRFSoftBody = false
						append G_OBJ_CON.warnList G_OBJ_LANG.WARN_REALFLOW_VERSIONERR
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.REALFLOW_VERSION)
					)
					
					if isValidVersionRFSoftBody then (

						for rfMesh in rfEditableMeshPaths do(
							
							local f = rfMesh.SD_Filename
							if f==undefined or f=="" then continue
							G_OBJ_FILEUTIL.handleFile f
							/*
							local fResult = G_OBJ_FILEUTIL.getReallyFilePath f
							if  fResult==undefined then(

								if f!=undefined and f!="" and G_OBJ_UTIL.isSameInArr G_OBJ_CON.missingFileList f==false then (
									append G_OBJ_CON.missingFileList f
								)
								
							)else(	
								append G_OBJ_CON.cacheList (STTexture reallyPath:fResult inScenePath:f)					
							)
							*/
							
						)
						
					)
				)
				
			)catch()

		),
		
		fn checkFumeFX = (
			G_OBJ_UTIL.oolog "checkFumeFX.check"

			local cacheList=#()
			local missingCacheList=#()
			try(
				local arr = getclassinstances FumeFX

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
							append G_OBJ_CON.cacheList (STTexture reallyPath:defaultFumefx inScenePath:inScenePath)
						)
					)
					
					local waveletFumefxFolder = getFilenamePath waveletPath
					local waveletMatchStr=G_OBJ_FILEUTIL.getFileNameOO waveletFumefxFolder+"*.fxd"
					local waveletArr = G_OBJ_FILEUTIL.getFilesFrom waveletFumefxFolder waveletMatchStr
					if waveletArr==undefined or waveletArr.count==0 then (
						append G_OBJ_CON.warnList ("Missing FumeFX Wavelet cache")
						append missingCacheList waveletPath
					)else(
						for waveletFumefx in waveletArr do (
							local inScenePath = waveletFumefxFolder+( G_OBJ_FILEUTIL.getFileNameOO waveletFumefx)
							append G_OBJ_CON.cacheList (STTexture reallyPath:waveletFumefx inScenePath:inScenePath)
						)
					)
					
					
					local retimerFumefxFolder = getFilenamePath retimerPath
					local retimerMatchStr=G_OBJ_FILEUTIL.getFileNameOO retimerPath+"*.fxd"
					local retimerArr = G_OBJ_FILEUTIL.getFilesFrom retimerFumefxFolder retimerMatchStr
					if retimerArr==undefined or retimerArr.count==0 then (
						append G_OBJ_CON.warnList ("Missing FumeFX Retimer cache")
						append missingCacheList retimerPath
					)else(
						for retimerFumefx in retimerArr do (
							local inScenePath = retimerFumefxFolder+( G_OBJ_FILEUTIL.getFileNameOO retimerFumefx)
							append G_OBJ_CON.cacheList (STTexture reallyPath:retimerFumefx inScenePath:inScenePath)
						)
					)
					
					--join cacheList defaultArr
					--join cacheList waveletArr
					--join cacheList retimerArr
				)
				

				if missingCacheList.count>0 then (
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missingCacheList code:G_TIPS_CODE.FUMEFX_MISSING)
					append G_OBJ_CON.warnList "Missing FumeFX Retimer cache"
				)
			)catch()
		),
		
		
		fn setHair modifyObj val=(
			setCommandPanelTaskMode #modify
			modPanel.setCurrentObject modifyObj
			local modify_task_window = for c in windows.getchildrenHWND #max where c[4] == "ModifyTask" do exit with c[1]
			local radio_bt_precomputed = windows.getchildHWND modify_task_window "Precomputed"
			local text_box_stat_name = uiaccessor.getnextwindow radio_bt_precomputed[1]
			local stat_file_name = uiaccessor.setwindowtext text_box_stat_name val
			format "stat....file.........%\n" stat_file_name
		),

		fn getHair modifyObj=(
			setCommandPanelTaskMode #modify
			modPanel.setCurrentObject modifyObj
			local modify_task_window = for c in windows.getchildrenHWND #max where c[4] == "ModifyTask" do exit with c[1]
			local radio_bt_precomputed = windows.getchildHWND modify_task_window "Precomputed"
			local text_box_stat_name = uiaccessor.getnextwindow radio_bt_precomputed[1]
			local stat_file_name = uiaccessor.getwindowtext text_box_stat_name
			format "stat....file.........%\n" stat_file_name
			stat_file_name
		),

		fn checkHair=(
			G_OBJ_UTIL.oolog "checkHair.check"

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

			try(
				local arrxs = getclassinstances KrakatoaPRTLoader
				local missingKKList=#()
				for i = 1 to arrxs.count do (
					for ii  = 1 to arrxs[i].fileList.count do (

						local PRTLoaderFolder = getFilenamePath arrxs[i].fileList[ii]
						local PRTLoaderName = getFileNameFile arrxs[i].fileList[ii]
						local PRTLoaderExt = getFilenameType arrxs[i].fileList[ii]
						format "PRTLoaderExt...%\n" PRTLoaderExt
						--local PRTLoaderName_Get = G_OBJ_UTIL.ooReplace PRTLoaderName "0" "*"
                        local PRTLoaderName_Get = substring PRTLoaderName 1 (PRTLoaderName.count-4)
						local matchStr=PRTLoaderName_Get+"*"+PRTLoaderExt
						local nixArr = G_OBJ_FILEUTIL.getFilesFrom PRTLoaderFolder matchStr

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

					local AlembicFolder = getFilenamePath arrxs[i].path
					local AlembicName = getFileNameFile arrxs[i].path
					local AlembicExt = getFilenameType arrxs[i].path
					--format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
					format "AlembicExt...%\n" AlembicExt
					local matchStr=AlembicName+"*"+AlembicExt
					local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr

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

				)
				
			)catch(
				format "PRTLoader....\n"
				format "%\n" (getcurrentexception() as string)
			)
			
			try(
				local arrxs = getclassinstances AlembicCamera       ------------------------------20170824
				
				for i = 1 to arrxs.count do (

					local AlembicFolder = getFilenamePath arrxs[i].source
					local AlembicName = getFileNameFile arrxs[i].source
					local AlembicExt = getFilenameType arrxs[i].source
					--format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
					format "AlembicExt...%\n" AlembicExt
					local matchStr=AlembicName+"*"+AlembicExt
					local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr

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

				)
				
			)catch(
				format "PRTLoader....\n"
				format "%\n" (getcurrentexception() as string)
			)			
				
			try (
				local arrxs = getclassinstances AlembicObject
			for i = 1 to arrxs.count do 
				(

					local AlembicFolder = getFilenamePath arrxs[i].source
					local AlembicName = getFileNameFile arrxs[i].source
					local AlembicExt = getFilenameType arrxs[i].source
					format "AlembicName...%\n" (AlembicName + "XXXXXXXXXXX")
					format "AlembicExt...%\n" AlembicExt
					local matchStr=AlembicName+"*"+AlembicExt
					local nixArr = G_OBJ_FILEUTIL.getFilesFrom AlembicFolder matchStr

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
		
		fn check=(
			G_OBJ_UTIL.oolog "STPlugin.start"

			checkRealflow()

			checkFumeFX()

			checkPhoenix2()
						
			

			checkXmesh()

			checkKrakatoaPRTLoader()

			checkAlembic()
			--checkHair()
			checkNewFumefx()

			checkVrmesh()

			checkVrscanned()

			checkRfcache()

			G_OBJ_UTIL.oolog "STPlugin.end"
		)
		
	)
		
	
	struct STVray (
		
		
		-------------------------

		fn primaryGiEngine = (
			local rend = renderers.production
			-- 0: Irradiance Map,1:Photon map,2:Brute force,3:Light cache
			append G_OBJ_CON.configList (STConfig key:"PrimaryGIEngine" val:(rend.gi_primary_type as string) type:"vray")
			/*
			local primaryGIEngineStr=""
			if rend.gi_primary_type==0 then (
				primaryGIEngineStr="Irradiance map"
			)else if (rend.gi_primary_type==1) then(
				primaryGIEngineStr="Photon map"
			)else if (rend.gi_primary_type==2) then(
				primaryGIEngineStr="Brute force"
			)else if (rend.gi_primary_type==3) then(
				primaryGIEngineStr="Light cache"
			)
			append G_OBJ_CON.configList (STConfig key:"PrimaryGIEngineMAX" val:primaryGIEngineStr type:"vray")
			*/
		),
		
		fn secondaryGiEngine = (
			local rend = renderers.production
			--0: -- None  2:--Brute force  3:--Light cache
			append G_OBJ_CON.configList (STConfig key:"SecondaryGIEngine" val:(rend.gi_secondary_type as string) type:"vray")
			/*
			local giSecondaryTypeStr=""
			if rend.gi_secondary_type==0 then (
				giSecondaryTypeStr="None"
			)else if (rend.gi_secondary_type==1) then(
				giSecondaryTypeStr="Photon map"
			)else if (rend.gi_secondary_type==2) then(
				giSecondaryTypeStr="Brute force"
			)else if (rend.gi_secondary_type==3) then(
				giSecondaryTypeStr="Light cache"
			)
			append G_OBJ_CON.configList (STConfig key:"SecondaryGIEngineMAX" val:giSecondaryTypeStr type:"vray")
			*/
		),
		fn findAnimationMap  =	(

			local rend = renderers.production
			
			local loadFileMap = rend.adv_irradmap_loadFileName
			G_OBJ_UTIL.oolog "vr.........findAnimationMap.......... "

			if loadFileMap != undefined and loadFileMap.count > 6 and matchPattern loadFileMap pattern:"*.vrmap" then	(
				local loadFileMapInsceneRootPath=getFilenamePath loadFileMap
				local loadFileMapInsceneRootFolder=pathConfig.stripPathToLeaf loadFileMapInsceneRootPath

				local vrmapName=getfilenamefile loadFileMap
				local loadFileMapMatchName = vrmapName + "*.vrmap"
				local loadFileMapMatch1 = loadFileMapInsceneRootPath+loadFileMapMatchName

				local loadFileMapMatch2 = maxfilepath+loadFileMapInsceneRootFolder+loadFileMapMatchName
				local loadFileMapMatch3 = maxfilepath+loadFileMapMatchName
				
				G_OBJ_UTIL.oolog ("loadFileMapMatch1 " +loadFileMapMatch1 as string)
				G_OBJ_UTIL.oolog ("loadFileMapMatch2 " +loadFileMapMatch2 as string)
				G_OBJ_UTIL.oolog ("loadFileMapMatch3 " +loadFileMapMatch3 as string)

				local irrFiles =  getFiles loadFileMapMatch1--check absolute file
				if irrFiles==undefined or irrFiles.count==0 then (-- check vrmap dir in max dir 
					 irrFiles =  getFiles loadFileMapMatch2
				)

				if irrFiles==undefined or irrFiles.count==0 then (--check vrmap file in max dir
					 irrFiles =  getFiles loadFileMapMatch3
				)

				if irrFiles!=undefined and irrFiles.count>0 then (
					G_OBJ_UTIL.oolog ("irrFiles.count " +irrFiles.count as string)

					
					local missMap = #()
					local missingFlg=false
					for f in G_OBJ_CON.framesArr do (
						local mapfile = undefined
						for irr in irrFiles do (
							local bname = getFilenameFile irr
							local serialStr = substring bname (bname.count-3) bname.count
							local serial = serialStr as integer
							if serial==f then (
								mapfile =irr						
								continue
							)
						)
						
						if mapfile!=undefined and mapfile.count>6 then (

							local vrmapWithoutSerail=(getFilenamePath mapfile)+ vrmapName+".vrmap"
							append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:vrmapWithoutSerail type:"vray")
							
							local mapfileName= G_OBJ_FILEUTIL.getFileNameOO mapfile
							local mapfileInscenePath =loadFileMapInsceneRootPath+ mapfileName
							append G_OBJ_CON.fileList (STTexture reallyPath:mapfile inScenePath:mapfile)
							--append G_OBJ_CON.fileList (STTexture reallyPath:mapfile inScenePath:mapfileInscenePath)
						)else(

							local serF = G_OBJ_UTIL.fillLeftZero (f as string) 4
							append missMap (vrmapName+serF+".vrmap")
						)
					)

					if missMap.count>0 then (
						append G_OBJ_CON.warnList ("------------------------")
						append G_OBJ_CON.warnList ("Missing animation vrmap:")
						join G_OBJ_CON.warnList missMap
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:missMap code:G_TIPS_CODE.ANIMATION_MAP_MISSING)


					)

				)else(
					
					append G_OBJ_CON.warnList ("Missing all animation vramp")
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.ANIMATION_MAP_MISSING)
				)
				
				
				

				
			)
		),

		fn engineIrradianceMapMode = (

			local rend = renderers.production		
			
			--if rend.gi_irradmap_detail_on == true then(
				--append G_OBJ_CON.warnList ("Irradiance map : Detail enhancement is active ")
			--)

			append G_OBJ_CON.configList (STConfig key:"irradianceMapMode" val:(rend.adv_irradmap_mode as string) type:"vray")
			
			case rend.adv_irradmap_mode of(
				0:( --single frame
					format "single frame\n"

				)
				1:( --multiframe incremental
					append G_OBJ_CON.warnList ("Irradiance map mode :  \"Multiframe incremental\" not supported")
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.MULTIFRAME_NOTSUPPORT)

				)
				2: --from file
				( 
					local loadFileMap = rend.adv_irradmap_loadFileName
					G_OBJ_FILEUTIL.handleFile loadFileMap

					
				)
				3: --add to current map
				(
					append G_OBJ_CON.warnList ("Irradiance map mode : Add to current map not supported")
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.ADDTOCMAP_NOTSUPPORT)

				)
				4: --incremental add to current map
				(
					local incAutoSave = rend.adv_irradmap_autoSave 
					local incSaveFile = rend.adv_irradmap_autoSaveFileName
					G_OBJ_CON.kg="100"

					if incAutoSave then (					
						if incSaveFile!=undefined and  incSaveFile!="" then (
							
							append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:incSaveFile type:"vray")
						)
						
					)

					
				)
				5: --bucket mode
				(

					format "Irradiance map mode : \"Bucket mode\" \n"
					--append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.BUCKET_MODE_NOTSUPPORT)
				)
				6: --animation (prepass) rend map
				(

					local animAutoSave = rend.adv_irradmap_autoSave 
					G_OBJ_CON.kg="101"
					if animAutoSave then (	

						local animSaveFile = rend.adv_irradmap_autoSaveFileName
						if animSaveFile!=undefined and animSaveFile!="" then (
							append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:animSaveFile type:"vray")
							
						)
					)

				)
				7: --animation (rendering) rend pic
				(

					local irrmapfile=""
					if rend.adv_irradmap_loadFileName!=undefined then (

						irrmapfile=rend.adv_irradmap_loadFileName
					)
					--append G_OBJ_CON.configList (STConfig key:"irrmapfile" val:irrmapfile type:"vray")

					findAnimationMap()

				)
			)

		),
		
		fn engineLightCacheMode = (

			local rend = renderers.production
			--append G_OBJ_CON.configList ("lightcacheMode=" + rend.lightcache_mode as string)
			append G_OBJ_CON.configList (STConfig key:"lightcacheMode" val:(rend.lightcache_mode as string) type:"vray")

			case rend.lightcache_mode  of(
				0:( --single frame			
					format "single frame\n"

				)
				1:( --Fly-through

					local lcAutoSave = rend.lightcache_autoSave
					if lcAutoSave then (
						local lcAutoSaveFile = rend.lightcache_autoSaveFileName
						if lcAutoSaveFile!=undefined and lcAutoSaveFile!="" then (

							append G_OBJ_CON.configList (STConfig key:"lightcachefile" val:lcAutoSaveFile type:"vray")	
							
						)
					)
				)
				2: --from file
				(

					local loadFileMap = rend.lightcache_loadFileName 
					
					G_OBJ_FILEUTIL.handleFile loadFileMap
					
				)
				3: --progressive path tracting
				(

					append G_OBJ_CON.warnList ("Light cache mode : \"Progressive path tracing\" not supported " )
					append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.PPT_NOTSUPPORT)
				)			
			)

		),
		
		fn bruteForceMode = (

			local rend =renderers.production
			local subdivs =""
			local secbounce=""

			if hasProperty rend "dmcgi_subdivs" then (

				subdivs=rend.dmcgi_subdivs as string
			)
			if hasProperty rend "qmcgi_subdivs" then (

				subdivs=rend.qmcgi_subdivs as string
			)
			local secbounce=""
			if hasProperty rend "dmcgi_depth" then (

				secbounce=rend.dmcgi_depth as string
			)
			if hasProperty rend "qmcgi_depth" then (

				secbounce=rend.qmcgi_depth as string
			)
			--append G_OBJ_CON.configList ("subdivs="+subdivs)
			--append G_OBJ_CON.configList ("secbounce="+secbounce)
			append G_OBJ_CON.configList (STConfig key:"subdivs" val:subdivs type:"vray")
			append G_OBJ_CON.configList (STConfig key:"secbounce" val:secbounce type:"vray")

		),
		
		fn getFilterKernel=(
			local myfilter=classof renderers.production.filter_kernel
			format "myFilter.....%\n" myfilter
			local clientfilter=""
			if myfilter ==	Area	then(	
				clientfilter =	"Area"
			)else if myfilter ==	Sharp_Quadratic 	then(	
				clientfilter =	"Sharp Quadratic" 
			)else if myfilter ==	Catmull_Rom	then(	
				clientfilter =	"Catmull-Rom"
			)else if myfilter ==	Plate_Match_MAX_R2	then(	
				clientfilter =	"Plate Match/MAX R2"
			)else if myfilter ==	Quadratic	then(	
				clientfilter =	"Quadratic"
			)else if myfilter ==	cubic	then(	
				clientfilter =	"cubic"
			)else if myfilter ==	Video	then(	
				clientfilter =	"Video"
			)else if myfilter ==	Soften	then(	
				clientfilter =	"Soften"
			)else if myfilter ==	Cook_Variable	then(	
				clientfilter =	"Cook Variable"
			)else if myfilter ==	Blendfilter	then(	
				clientfilter =	"Blend"
			)else if myfilter ==	Blackman	then(	
				clientfilter =	"Blackman"
			)else if myfilter ==	Mitchell_Netravali	then(	
				clientfilter =	"Mitchell-Netravali"
			)else if myfilter ==	VRayLanczosFilter	then(	
				clientfilter =	"VRayLanczosFilter"
			)else if myfilter ==	VRaySincFilter	then(	
				clientfilter =	"VRaySincFilter"
			)else if myfilter ==	VRayBoxFilter	then(	
				clientfilter =	"VRayBoxFilter"
			)else if myfilter ==	VRayTriangleFilter	then(	
				clientfilter =	"VRayTriangleFilter"
			)
			format "clientfilter....%\n" clientfilter
			append G_OBJ_CON.configList (STConfig key:"filterKernel" val:clientfilter type:"vray")
			
			
		),
		
		fn tabVray = (

			local rend =renderers.production
			
			
			-------------VFB------------
			local enableFrameBuffer = rend.output_on
			
			append G_OBJ_CON.configList (STConfig key:"displacement" val:(rend.options_displacement as string) type:"vray")
			append G_OBJ_CON.configList (STConfig key:"reflectionRefraction" val:(rend.options_reflectionRefraction as string) type:"vray")
			
			if(enableFrameBuffer==true) then (

				append G_OBJ_CON.configList (STConfig key:"vfb" val:"on" type:"vray")
				local enableFrameBuffer = rend.output_on
				
				local renderToRwFile = rend.output_saveRawFile
				local rawImgName = rend.output_rawFileName
				local splitBuffer = rend.output_splitgbuffer

				if(renderToRwFile==true ) then (				
					if ( rawImgName==undefined or rawImgName=="" ) then (	

						append G_OBJ_CON.warnList "\"Render to V-Ray raw image file\" Checked but *.vrimg is undefined "
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.VRIMG_UNDEFINED)
					)else (

						local rawImgNameF = rawImgName
						local rawImgT = getFilenameType rawImgName
						local rawImgN = getFileNameFile rawImgName
						local rawImg =rawImgN + rawImgT					
						append G_OBJ_CON.configList (STConfig key:"rendRawImgName" val:"on" type:"vray")
						append G_OBJ_CON.configList (STConfig key:"rawImgName" val:rawImg type:"vray")

					)
					
				)
				
				if(splitBuffer==true) then (

					local splitFileName = rend.output_splitfilename				
					
					if( splitFileName==undefined or splitFileName=="") then (

						append G_OBJ_CON.warnList "Save separate render channels Checked but channels file is error"
						append G_OBJ_CON.infoList (STInfo level:"warn" msgList:#() code:G_TIPS_CODE.CHANNEL_FILE_UNDEFINED)
					)else(

						local splitFileNameF =splitFileName
						local splitFileT = getFilenameType splitFileName
						local splitFileN = getFileNameFile splitFileName
						local splitFile =splitFileN + splitFileT		

						append G_OBJ_CON.configList (STConfig key:"saveSepChannel" val:"on" type:"vray")
						append G_OBJ_CON.configList (STConfig key:"channelFile" val:splitFile type:"vray")
					)
				)
			)else(
				append G_OBJ_CON.configList (STConfig key:"vfb" val:"off" type:"vray")
			)

			
			if renderers.production.options_displacement==true then (
				append G_OBJ_CON.configList (STConfig key:"displacement" val:"1" type:"vray")
			)else(
				append G_OBJ_CON.configList (STConfig key:"displacement" val:"0" type:"vray")
			)
			

			if renderers.production.options_reflectionRefraction==true then (
				append G_OBJ_CON.configList (STConfig key:"reflectionRefraction" val:"1" type:"vray")
			)else(
				append G_OBJ_CON.configList (STConfig key:"reflectionRefraction" val:"0" type:"vray")
			)

			
			local imageSamplerType=renderers.production.imageSampler_type as string
			local filterOnBoolean=renderers.production.filter_on
			if filterOnBoolean then (
				filterOn="on"
			)else(
				filterOn="off"
			)

			
            --filterKernel=substituteString filterKernel "_" "-"
			append G_OBJ_CON.configList (STConfig key:"imageSamplerType" val:imageSamplerType type:"vray")
			append G_OBJ_CON.configList (STConfig key:"filterOn" val:filterOn type:"vray")
			getFilterKernel()--(classof renderers.production.filter_kernel as string)
			

			
		),
		
		fn tabInDirectIllumination = (
			G_OBJ_UTIL.oolog "tabInDirectIllumination"

			local rend = renderers.production
			if rend.gi_on == true then (

				append G_OBJ_CON.configList (STConfig key:"gi" val:"on" type:"vray")
				

				primaryGiEngine()			

				secondaryGiEngine()

				--primary Gi Engine
				if rend.gi_primary_type==0 then (--Irradiance map	

					engineIrradianceMapMode()
				)else if rend.gi_primary_type==2 then (--brute force 			

					bruteForceMode()
				)else if rend.gi_primary_type==3 then (--light cache

					engineLightCacheMode()
					
				)
				
				--secondary Gi Engine
				if rend.gi_secondary_type == 2 and rend.gi_primary_type!=2 then (--brute force 

					bruteForceMode()
				)else if rend.gi_secondary_type == 3 and rend.gi_primary_type!=3 then (--Light cache

					engineLightCacheMode()	
				)

				
			)else (
				append G_OBJ_CON.configList (STConfig key:"gi" val:"off" type:"vray")
			)

				
		),
		
		fn tabSetting = (
			
		),
		
		fn other = (
			--TODO vrayMtl 
			--TODO vray light 
			--TODO VRayPhysicalCamera
			--TODO VRayHDRI
		),
		
		
		
		fn getVrayInfo=(
			local myRender = renderers.production -- as string 
			local renderType=classOf myRender as string --
			 
			try(
				
				if classof myRender == vray   then(
					append G_OBJ_CON.configList (STConfig key:"-----------VRAY info" val:"-----------" type:"maxInfo")
					if myRender.gi_on == true then(
						append G_OBJ_CON.configList (STConfig key:"gi" val:"on" type:"maxInfo")
						if myRender.gi_primary_type==0 then(
							append G_OBJ_CON.configList (STConfig key:"Primary engine" val:"Irradiance map" type:"maxInfo")
							if myRender.adv_irradmap_mode == 0 then(	
									append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Single Frame" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 1 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Multiframe incremental" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 2 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"From file" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 3 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Add to current map" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 4 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Incremental add to current map" type:"maxInfo")						
							)else if myRender.adv_irradmap_mode == 5 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Bucket mode" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 6 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Animation(prepass)" type:"maxInfo")
							)else if myRender.adv_irradmap_mode == 7 then(
								append G_OBJ_CON.configList (STConfig key:"Irradiance map mode" val:"Animation(rendering)" type:"maxInfo")
							)
						)else if myRender.gi_primary_type==1 then(
							append G_OBJ_CON.configList (STConfig key:"Primary engine" val:"Photon map" type:"maxInfo")
							if myRender.photonMap_mode == 0 then (
								append G_OBJ_CON.configList (STConfig key:"Photon map mode" val:"New map" type:"maxInfo")
							)
							else if myRender.photonMap_mode == 1 then (
								append G_OBJ_CON.configList (STConfig key:"Photon map mode" val:"From map" type:"maxInfo")
							)				
						)else if myRender.gi_primary_type==2 then(
							append G_OBJ_CON.configList (STConfig key:"Primary engine" val:"Brute force" type:"maxInfo")
						)else if myRender.gi_primary_type==3 then (
							append G_OBJ_CON.configList (STConfig key:"Primary engine" val:"Light cache" type:"maxInfo")
							if myRender.lightcache_mode == 0 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Single Frame" type:"maxInfo")
							)else if myRender.lightcache_mode == 1 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Fly-through" type:"maxInfo")
							)else if myRender.lightcache_mode == 2 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"From file" type:"maxInfo")
							)else if myRender.lightcache_mode == 3 then (
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Progressive path tracing" type:"maxInfo")
							)
						)
						
						if myRender.gi_secondary_type==0 then(
							append G_OBJ_CON.configList (STConfig key:"secondary engine" val:"None" type:"maxInfo")
						)else if myRender.gi_secondary_type==1 then(
							append G_OBJ_CON.configList (STConfig key:"secondary engine" val:"Photon map" type:"maxInfo")
							if myRender.photonMap_mode == 0 then(
								append G_OBJ_CON.configList (STConfig key:"Photon map mode" val:"New map" type:"maxInfo")
							)else if myRender.photonMap_mode == 1 then(
								append G_OBJ_CON.configList (STConfig key:"Photon map mode" val:"From map" type:"maxInfo")
							)	
						)else if myRender.gi_secondary_type==2 then(
							append G_OBJ_CON.configList (STConfig key:"secondary engine" val:"Brute force" type:"maxInfo")
						)else if myRender.gi_secondary_type==3 then(
							append G_OBJ_CON.configList (STConfig key:"secondary engine" val:"Light cache" type:"maxInfo")
							if myRender.lightcache_mode == 0 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Single Frame" type:"maxInfo")
							)else if myRender.lightcache_mode == 1 then (
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Fly-through" type:"maxInfo")
							)else if myRender.lightcache_mode == 2 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"From file" type:"maxInfo")
							)else if myRender.lightcache_mode == 3 then(
								append G_OBJ_CON.configList (STConfig key:"Light cache mode" val:"Progressive path tracing" type:"maxInfo")
							)
						)
					)else(
						append G_OBJ_CON.configList (STConfig key:"gi" val:"off" type:"maxInfo")
					)
				
					
					append G_OBJ_CON.configList (STConfig key:"camera_type" val:(myRender.camera_type as string) type:"vray")
					append G_OBJ_CON.configList (STConfig key:"camera_overridefov" val:(myRender.camera_overrideFOV as string) type:"vray")
					append G_OBJ_CON.configList (STConfig key:"camera_fov" val:(myRender.camera_fov as string) type:"vray")
				
				)
				
				
				if myRender.output_on ==true then(
					append G_OBJ_CON.configList (STConfig key:"VFB" val:"on" type:"maxInfo")
					local renderToRwFile = myRender.output_saveRawFile
						
					if(renderToRwFile==true ) then (				
						append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file" val:"on" type:"maxInfo")
					)else(
						append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file" val:"off" type:"maxInfo")
					)
					local rawImgName = myRender.output_rawFileName
					append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file path" val: (rawImgName as string) type:"maxInfo")
					
					local splitBuffer = myRender.output_splitgbuffer
					if(splitBuffer==true) then (
						append G_OBJ_CON.configList (STConfig key:"VFB.Save separate render channels" val:"on" type:"maxInfo")		
					)else(
						append G_OBJ_CON.configList (STConfig key:"VFB.Save separate render channels" val:"off" type:"maxInfo")
					)
					local splitFileName = myRender.output_splitfilename
					append G_OBJ_CON.configList (STConfig key:"VFB.Save separate render channels  path" val: (splitFileName as string) type:"maxInfo")				
							
					if myRender.output_saveRawFile ==true  then(
						append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file" val:"on" type:"maxInfo")
					)else(
						append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file" val:"off" type:"maxInfo")				
					)
					
					if myRender.output_useram ==true then (	
						append G_OBJ_CON.configList (STConfig key:"VFB_Elements" val:"on" type:"maxInfo")
						if myRender.output_splitgbuffer = on then(
							append G_OBJ_CON.configList (STConfig key:"VFB_Elements_out" val:"on" type:"maxInfo")
						)else(
							append G_OBJ_CON.configList (STConfig key:"VFB_Elements_out" val:"off" type:"maxInfo")
						)
					)else(
						append G_OBJ_CON.configList (STConfig key:"VFB_Elements" val:"off" type:"maxInfo")
					)
					local vfboutpath = myRender.output_splitfilename
						append G_OBJ_CON.configList (STConfig key:"VFB.Render to V-Ray raw image file path" val: (rawImgName as string) type:"maxInfo")
				)else(
					append G_OBJ_CON.configList (STConfig key:"VFB" val:"off" type:"maxInfo")
				)

				
				if myRender.imageSampler_type == 0 then(
					append G_OBJ_CON.configList (STConfig key:"imageSampler_type" val:"Fixed" type:"maxInfo")			
				)else if myRender.imageSampler_type == 1 then(	
					append G_OBJ_CON.configList (STConfig key:"imageSampler_type" val:"Adaptive" type:"maxInfo")
				)else if myRender.imageSampler_type == 2 then(
					append G_OBJ_CON.configList (STConfig key:"imageSampler_type" val:"Adaptive subdivvision" type:"maxInfo")			
				)else if myRender.imageSampler_type == 3 then(
					append G_OBJ_CON.configList (STConfig key:"imageSampler_type" val:"Progressive" type:"maxInfo")
				)
				
				
				--Dynamic memory
				append G_OBJ_CON.configList (STConfig key:"Dynamic memory limit" val:((myRender.system_raycaster_memLimit as string)+"MB") type:"maxInfo")
				if myRender.system_instancedObjects == 0 then (
					append G_OBJ_CON.configList (STConfig key:"Default geometry" val:"Static" type:"maxInfo")
				) else if myRender.system_instancedObjects == 1 then (
					append G_OBJ_CON.configList (STConfig key:"Default geometry" val:"Dynamic" type:"maxInfo")
				) else if myRender.system_instancedObjects == 2 then (
					append G_OBJ_CON.configList (STConfig key:"Default geometry" val:"Auto" type:"maxInfo")
				)
				
			)catch(
				
				
			)

			
			
			
			
		),

		
		fn info = (
			G_OBJ_UTIL.oolog "vray tabVray... "

			tabVray()
			G_OBJ_UTIL.oolog "vray tabInDirectIllumination- "

			tabInDirectIllumination()

			G_OBJ_UTIL.oolog "vray tabSetting... " 
			tabSetting()

			getVrayInfo()

		),
		
		
			
		fn check = (
			
			
			G_OBJ_UTIL.oolog "vray info.... " 

			info()
			G_OBJ_UTIL.oolog "vray other.... "

			other()

			
		)
		
		
	)

	struct STScanline(
		
		fn check = (
		)
	)
	struct STFinalrender(
		
		
		
		fn tabIndirectIllumination = (

			local rend = renderers.production
			
			if rend.useAntialiasing==true then(

				if rend.aaSamplerRef != undefined then(

					sampref = rend.aaSamplerRef
					
				)
				
				if rend.filterImage==false then(

					append G_OBJ_CON.warnList "Anti-Aliasing: Filter Image is off"
				)
			)else(

				append G_OBJ_CON.warnList "Global Options: Antialiasing is off"
			)
				
			if NOT rend.filterMaps then(

				append G_OBJ_CON.warnList "Anti-Aliasing: Filter Maps is off"
			)
	--General Options
			if rend.useMaterialOverwrite then(

				append G_OBJ_CON.warnList "Global Options: Material Override Checked." 
			)
			if rend.useDistributedRendering then(

				append G_OBJ_CON.warnList "Global Options: Distributed Rendering Checked."
			)
			if rend.useInformationStamp then(

				append G_OBJ_CON.warnList  "Global Options: Information Stamp Checked."
			)
				
			local enable = rend.giEnable		
			if enable  then (

				append G_OBJ_CON.configList (STConfig key:"gi" val:"on" type:"FinalRender")
				local solutionMode = rend.giSolutionMode--single Frame /Animation  0=single Frame 1=Animation		
				local solutionAnimationPass = rend.giSolutionAnimationPass   --0=Prepass 1=Rendering
				local solutionMultipleFiles = rend.giSolutionMultipleFiles   --0=Single File 1=Multiple Files	
				local useSolutionFile = rend.giUseSolutionFile   --Solution  true:checked
				local solutionFile = rend.giSolutionFile   --gis file

				append G_OBJ_CON.configList (STConfig key:"solutionMode" val:(solutionMode as string) type:"FinalRender")
				if solutionMode==0 then (--single Frame

				)else if solutionMode==1 then (--animation

					append G_OBJ_CON.configList (STConfig key:"solutionAnimationPass" val:(solutionAnimationPass as string) type:"FinalRender")			
					append G_OBJ_CON.configList (STConfig key:"solutionMultipleFiles" val:(solutionMultipleFiles as string) type:"FinalRender")			
					append G_OBJ_CON.configList (STConfig key:"useSolutionFile" val:(useSolutionFile as string)  type:"FinalRender")			
					
				)

			
				if useSolutionFile   then (
					append G_OBJ_CON.configList (STConfig key:"Solution:" val:"On" type:"FinalRender")

					
					if solutionFile!=undefined and solutionFile!="" then(

						append G_OBJ_CON.configList (STConfig key:"gisFile" val:solutionFile type:"FinalRender")
						
						if solutionMultipleFiles==0 then (--single file

							if solutionFile.count>4 and  matchPattern solutionFile pattern:"*.gis" then (
								G_OBJ_FILEUTIL.handleFile solutionFile
								/*
								local solutionFileResult = G_OBJ_FILEUTIL.getReallyFilePath solutionFile

								if solutionFileResult !=undefined then (
									append G_OBJ_CON.fileList (STTexture reallyPath:solutionFileResult inScenePath:solutionFile)	
								)
								*/
							)
							
						)else if solutionMultipleFiles==1 then (--Multiple Files

							
							
							if solutionFile.count>4 and  matchPattern solutionFile pattern:"*.gis" then (

								local solutionFileInsceneRootPath=getFilenamePath solutionFile	
								
								local photonName = (substring solutionFile 1 (solutionFile.count - 4))
								local photonNameMatch = photonName + "*.gis"
								local photonNames = getFiles photonNameMatch	

								if photonNames==undefined or photonNames.count==0 then (-- check maxfile dir again
									G_OBJ_UTIL.oolog "again....check  " 

									local photonName2 = G_OBJ_FILEUTIL.getFileNameOO solutionFile
									local photonNameMatch2 = pathConfig.appendPath maxfilePath photonName2
									G_OBJ_UTIL.oolog ("photonNameMatch2 "+ photonNameMatch2 as string)
									photonNames = getFiles photonNameMatch2

								)

								for photon in photonNames do (	
									local photonResultName= G_OBJ_FILEUTIL.getFileNameOO photon
									local photonInsceneFile=solutionFileInsceneRootPath+loadFileMapResultName
									
									append G_OBJ_CON.fileList (STTexture reallyPath:photon inScenePath:photonInsceneFile)
													
									
								)

							)
						)
					)else(
						
					)
					
				)else(
					append G_OBJ_CON.configList (STConfig key:"Solution:" val:"Off" type:"FinalRender")
				)
				
			)else (
				--append G_OBJ_CON.configList "gi=off"

				append G_OBJ_CON.configList (STConfig key:"gi" val:"off" type:"FinalRender")
				
				append G_OBJ_CON.warnList "Global Illumination Off"
			)
			
			
		),
		
		fn info = (
			tabIndirectIllumination()
		),
		fn tex = (
			
		),
		fn check = (
			
			info()
			tex()
		)
	)
	struct STMaxWell (
		fn check = (
		)
	)


	struct STTask(
		
		
		fn writeTips=(
			
			
			if G_OBJ_CON.infoList.count>0 then (
				for infoObj in G_OBJ_CON.infoList do (
					
					G_OBJ_UTIL.setIni  "tips" (infoObj.code ) (G_OBJ_UTIL.convertPythonList infoObj.msgList )
				)
				
			)	

		),
		fn createTask projectId=(
			local exitCode=-1
			local cmdline=("\""+G_OBJ_CON.myGuy+"\" -task " +projectId)
			format "hiddencmd...%\n" cmdline
			
			local taskIdInt =-1
			try(
				hiddendoscommand cmdline ExitCode:&exitCode
				taskIdInt= exitCode as integer
			)catch(
				taskIdInt=-1
			)
			
			if taskIdInt>1 then (
				
		

				local taskId=taskIdInt as string
				
				G_OBJ_UTIL.donetWrite "200" (taskId as string)
				G_OBJ_UTIL.donetWrite "300" taskId
				G_OBJ_UTIL.dosWrite "200" taskId
				G_OBJ_UTIL.dosWrite "300" taskId
				
				
				
				G_OBJ_CON.myTaskId=taskid
				G_OBJ_CON.myTaskProjectPath = pathconfig.appendPath G_OBJ_CON.myProjectPath G_OBJ_CON.myTaskId
				G_OBJ_UTIL.oolog  ("taskid......." +taskId as string)
				G_OBJ_UTIL.oolog  ("myTaskProjectPath.."+ G_OBJ_CON.myTaskProjectPath as string)
				
				local m = makeDir G_OBJ_CON.myTaskProjectPath all:true
				 
				if not m then (

					append G_OBJ_CON.errorList "Create task folder failed"
					append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.TASK_FOLDER_FAILED)
					writeTips()
                    /*
					G_OBJ_FILEUTIL.writeFileFN G_OBJ_CON.myErrorFile G_OBJ_CON.errorList
					G_OBJ_UTIL.donetWrite "204" "Create task folder failed"
					G_OBJ_UTIL.dosWrite "204" "Create task folder failed"
                    */
					sleep 3
					return false 
				)else(
					
					if G_OBJ_CON.myMaxVersionInt < 15 then(
						G_OBJ_CON.configFile = pathconfig.appendPath G_OBJ_CON.myTaskProjectPath ("renderTemp.cfg")
					)else(
						G_OBJ_CON.configFile = pathconfig.appendPath G_OBJ_CON.myTaskProjectPath ("render.cfg")
					)
					return true
				)
				
			)else(

				append G_OBJ_CON.errorList G_OBJ_LANG.ERROR9001_CREATETASK_FAILED
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.TASK_CREATE_FAILED)
				--writeTips()
				
				G_OBJ_UTIL.donetWrite "300" "-1"
				G_OBJ_UTIL.dosWrite "300" "-1"
                
                /*20170609[remove exit code]
				G_OBJ_FILEUTIL.writeFileFN G_OBJ_CON.myErrorFile G_OBJ_CON.errorList
				G_OBJ_UTIL.donetWrite "301" G_OBJ_LANG.ERROR9001_CREATETASK_FAILED
				G_OBJ_UTIL.dosWrite "301" G_OBJ_LANG.ERROR9001_CREATETASK_FAILED
				*/
				return false
			)
			
			
			
			
			
		),
		fn getMaxvStr = (

			if G_OBJ_CON.myMaxVersionInt<=9 then (
				return G_OBJ_CON.myMaxVersionInt
			)else(
				return (2008+G_OBJ_CON.myMaxVersionInt-10)
			)

			
		),
		
		fn init  userId projectId projectName maxFile pluginCfg myRenderer myPlatform renderfarm tempPath guyVersion projectPath ingoreTexture enableParam skipUpload clientZone customClient fatherId seperateAccount= (
			if doesfileexist "c:/log.rayvision" then(
				G_OBJ_CON.debugLogCount=0
				G_OBJ_CON.isDebugLog=true
			)
			
			G_OBJ_CON.myPlatform=myPlatform
			G_OBJ_CON.myRenderFarm=renderfarm
			G_OBJ_CON.myTempPath=tempPath
			G_OBJ_CON.myErrorFile=G_OBJ_CON.myTempPath+"/error.txt"
			G_OBJ_CON.myWarnFile=G_OBJ_CON.myTempPath+"/warning.txt"
			G_OBJ_CON.myGuy=renderfarm+"/rendercmd.exe"
			G_OBJ_CON.myProjectPath=projectPath
			G_OBJ_CON.myGuyVersion=guyVersion
			G_OBJ_CON.myIngoreWarn=ingoreTexture
			G_OBJ_CON.myEnableParam=enableParam
			G_OBJ_CON.mySkipUpload=skipUpload
			G_OBJ_CON.myClientZone=clientZone
			G_OBJ_CON.myCustomClient=customClient
			G_OBJ_CON.myProjectId=projectId
			G_OBJ_CON.myProjectName=projectName
			G_OBJ_CON.myMaxVersionStr="3ds Max "+(getMaxvStr() as string)
			
			--defaultPath = getFileNamePath(getSourceFilename())
			G_OBJ_CON.myUserId=userId
			G_OBJ_CON.myFatherId=fatherId
			G_OBJ_CON.mySeperateAccount=seperateAccount

			--G_OBJ_UTIL.init()
			if not (createTask  projectId) then (
				return false
			)
			
			G_OBJ_LANG.enVersion()
			
			G_OBJ_UTIL.oolog  ("userId..."+ userId as string)
			G_OBJ_UTIL.oolog  ("fatherId..."+ fatherId as string)
			G_OBJ_UTIL.oolog  ("maxFile..." +maxFile as string)
			
			G_OBJ_UTIL.oolog ( "myRenderer......." +myRenderer as string)
			G_OBJ_UTIL.oolog  ("myPlatform......."+ myPlatform as string)
			
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.configFile......."+ G_OBJ_CON.configFile as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myRenderFarm......."+ G_OBJ_CON.myRenderFarm as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myTempPath......."+ G_OBJ_CON.myTempPath as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myErrorFile......."+ G_OBJ_CON.myErrorFile as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myWarnFile......."+ G_OBJ_CON.myWarnFile as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myIngoreWarn......."+ G_OBJ_CON.myIngoreWarn as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.myEnableParam......."+ G_OBJ_CON.myEnableParam as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.mySkipUpload......."+ G_OBJ_CON.mySkipUpload as string)
			G_OBJ_UTIL.oolog  ("G_OBJ_CON.mySeperateAccount......."+ G_OBJ_CON.mySeperateAccount as string)
			
			
			if doesfileexist G_OBJ_CON.myErrorFile then (
				try(
					deleteFile G_OBJ_CON.myErrorFile
				)catch()
			)

			if doesfileexist G_OBJ_CON.myWarnFile then (
				try(
					deleteFile G_OBJ_CON.myWarnFile
				)catch()
			)
			------------------------------------------------------------
			
			
			
			
			return true
		),
		

		fn validRenderer=(
			local rend = renderers.production
			local rendc = classof rend 
			G_OBJ_CON.myRender=rendc as string

			local mi = findstring G_OBJ_CON.myRender "miss"
			local rt = findstring G_OBJ_CON.myRender "rt"

			if mi!=undefined then (
				append G_OBJ_CON.errorList "Missing renderer"
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_MISSING)
				
			)

			if rt!=undefined then (
				append G_OBJ_CON.errorList (G_OBJ_LANG.WARN_RENDERER_NOTSUPPORT+" RT renderer" )
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_NOTSUPPORT)
				
				
			)

			
			if G_OBJ_CON.myRender== mental_ray_iray_Renderer or G_OBJ_CON.myRender == Quicksilver_Hardware_Renderer or G_OBJ_CON.myRender == Brazil_r_s_Rio_Learning_Edition_v2_0__build_1618 then(
				append G_OBJ_CON.errorList (G_OBJ_LANG.WARN_RENDERER_NOTSUPPORT+" "G_OBJ_CON.myRender)	
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.RENDERER_NOTSUPPORT)				
			)

			if G_OBJ_CON.infoList.count>0 then (
				writeTips()
                /*20170609[remove exit code]
				G_OBJ_UTIL.donetWrite "104" "Analyse End with  Error"
				G_OBJ_UTIL.dosWrite "104" "Analyse End with  Error"
                */
				return false
			)
				
				
			return true
		),
		
		
		fn validProperties = (
			
			prop=fileproperties.getPropertyValue #contents 1
			if prop!=undefined and prop.count>1 then (
				
				return true
			)else(
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.MAXINFO_FAILED)	
				writeTips()
                /*20170609[remove exit code]
				G_OBJ_UTIL.donetWrite G_TIPS_CODE.MAXINFO_FAILED "Analyse End with  Error"
				G_OBJ_UTIL.dosWrite G_TIPS_CODE.MAXINFO_FAILED "Analyse End with  Error"
                */
				return false
				
			)
		),
		
		fn validSpecificSymbol=(
			
			local ssymbolList = #()
			
			
			local myMax = (maxfilepath+maxfilename)
			if G_OBJ_UTIL.hasSpecificSymbol myMax symbolList:#("*\n*","*\r*") then (
				myMax=substituteString myMax "\r" "\\r"
				myMax=substituteString myMax "\n" "\\n"

				append ssymbolList ("Max File:"+myMax)
				
			)
			
			local objRender = STRender()
			local cameraStr = objRender.getAllCameras()
			format "cameraStr------------%-------------\n" cameraStr
			if G_OBJ_UTIL.hasSpecificSymbol cameraStr then (
				cameraStr=substituteString cameraStr "\r" "\\r"
				cameraStr=substituteString cameraStr "\n" "\\n"
				cameraStr=substituteString cameraStr "[,]" ", "
				cameraStr=substituteString cameraStr "\"" "\\\""
				format "validSpecificSymbol.cameraStr.wrong camera\n"
				append ssymbolList ("Camera:"+cameraStr)
				
			)
			
			if G_OBJ_UTIL.hasSpecificSymbol rendOutputFilename symbolList:#("*\n*","*\r*") then (
				local outputStr = rendOutputFilename
				outputStr=substituteString outputStr "\n" "\\n"
				outputStr=substituteString outputStr "\r" "\\r"
				append ssymbolList ("Output File:"+outputStr)
				
			)
			
			
			
			local errElemList=#()
			local renderElementsMgr = maxOps.GetRenderElementMgr #Production
			for n = 0 to (renderElementsMgr.numrenderelements()- 1) do(
				
				local el = renderElementsMgr.GetRenderElement n
				if ((classof el)==Missing_Render_Element_Plug_in) or (not hasProperty el "elementName")  then (
					
				)else(
					format "elementName.....%\n" el.elementName
					local elemName = el.elementName
					local elemPath = renderElementsMgr.getRenderElementFilename n 
					
					--if el.enabled == true  then (
					if elemName==undefined then (elemName="")
					
					--)
					if elemPath==undefined then (elemPath="")
					
					
					if (G_OBJ_UTIL.hasSpecificSymbol elemName) or (G_OBJ_UTIL.hasSpecificSymbol elemPath symbolList:#("*\n*","*\r*")) then (
						elemName=substituteString elemName "\n" "\\n"
						elemName=substituteString elemName "\r" "\\r"
						elemPath=substituteString elemPath "\n" "\\n"
						elemPath=substituteString elemPath "\r" "\\r"
						append errElemList ("Element:"+(elemName as string)+"="+(elemPath as string))

					)
				
				)
				
			)
			if errElemList.count>0 then (
				join ssymbolList errElemList
			)
			if ssymbolList.count>0 then (
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:ssymbolList code:G_TIPS_CODE.HAS_BAD_SYMPOL)
			)
			if G_OBJ_CON.infoList.count>0 then (
				writeTips()
				return false
			)
			true
			
		),
		
		fn hanFile=(

			
			local photonCount=1
			local vrmapCount=1
			local vrlmapCount=1
			--append G_OBJ_CON.fileList (STTexture reallyPath:sourceMaxFile inScenePath:sourceMaxFile)
			
			join G_OBJ_CON.fileList G_OBJ_CON.cacheList
			

			
				
			local prePath=G_OBJ_FILEUTIL.getPrePath()
			
			G_OBJ_UTIL.setIni  "max" ("max") (maxfilepath+maxfilename)
			local maxCount=2
				
			
			if G_OBJ_CON.mySkipUpload=="1" then (
				local inScenePathOK=G_OBJ_FILEUTIL.analysePath (maxfilepath+maxfilename)
				G_OBJ_UTIL.setIni  "texture" ("path1") ((maxfilepath+maxfilename)+">>"+inScenePathOK)
				
			)else(
				local inSceneSourceMaxFile=G_OBJ_FILEUTIL.analysePath (maxfilepath+maxfilename)+".7z"
				local max7z=pathconfig.appendPath G_OBJ_CON.myTaskProjectPath (maxfilename+".7z")
				G_OBJ_UTIL.setIni  "delete" "path1" max7z
				G_OBJ_UTIL.setIni  "texture" ("path1") ((max7z)+">>"+inSceneSourceMaxFile)
			)
			
			
			
			local ipArr=#()
			local textureList=#()
			for t in G_OBJ_CON.fileList do (
				if t!=undefined and t.reallyPath!=undefined and t.inScenePath!=undefined  then (
					
					local tReallyPath=t.reallyPath
					local tReallyFileName=getfilenamefile tReallyPath
					
					local tInScenePath=t.inScenePath
					local tInSceneFileName=getfilenamefile tInScenePath
					if (not (matchpattern tReallyFileName pattern:"{*}" )) and (matchpattern tInSceneFileName pattern:"{*}" ) then (
						tInScenePath=AssetManager.GetFileName tInSceneFileName
					)
					if tInScenePath==undefined or tInScenePath=="" then (
						append G_OBJ_CON.missingFileList t.inScenePath
					)else(
						local reallyFileType=getfilenametype t.reallyPath
						if reallyFileType!=undefined and reallyFileType!="" then (
							if reallyFileType==".max" then (
								G_OBJ_UTIL.setIni  "max" ("max"+(maxCount as string)) t.reallyPath
								maxCount=maxCount+1
							)
							if reallyFileType==".vrmap"  then (
								
								if G_OBJ_CON.mySkipUpload=="1" then (
									G_OBJ_UTIL.setIni  "customfile" ("path"+(photonCount as string)) ((t.reallyPath as string)+">>"+t.reallyPath)
									G_OBJ_UTIL.setIni  "vrmap" ("path"+(vrmapCount as string)) ((t.reallyPath as string)+">>"+t.reallyPath)
								)else(
									local inScenePathOK=G_OBJ_FILEUTIL.analysePath t.reallyPath
									G_OBJ_UTIL.setIni  "customfile" ("path"+(photonCount as string)) ((t.reallyPath as string)+">>"+inScenePathOK)
									G_OBJ_UTIL.setIni  "vrmap" ("path"+(vrmapCount as string)) ((t.reallyPath as string)+">>"+inScenePathOK)
								)
								vrmapCount=vrmapCount+1
								photonCount=photonCount+1
							)else if  reallyFileType==".vrlmap" then(
								if G_OBJ_CON.mySkipUpload=="1" then (
									G_OBJ_UTIL.setIni  "customfile" ("path"+(photonCount as string)) ((t.reallyPath as string)+">>"+t.reallyPath)
									G_OBJ_UTIL.setIni  "vrlmap" ("path"+(vrlmapCount as string)) ((t.reallyPath as string)+">>"+t.reallyPath)
								)else(
									local inScenePathOK=G_OBJ_FILEUTIL.analysePath t.reallyPath
									G_OBJ_UTIL.setIni  "customfile" ("path"+(photonCount as string)) ((t.reallyPath as string)+">>"+inScenePathOK)
									G_OBJ_UTIL.setIni  "vrlmap" ("path"+(vrlmapCount as string)) ((t.reallyPath as string)+">>"+inScenePathOK)
								)
								vrlmapCount=vrlmapCount+1
								photonCount=photonCount+1
							
							)else(
								if G_OBJ_CON.mySkipUpload=="1" then (
									--G_OBJ_UTIL.setIni  "texture" ("path"+(tt as string)) ((t.reallyPath as string)+">>"+tInScenePath)
									format "....%\n" ((t.reallyPath as string)+">>"+tInScenePath)
									appendIfUnique textureList ((t.reallyPath as string)+">>"+tInScenePath)
								)else(
									local inScenePathOK=G_OBJ_FILEUTIL.analysePath tInScenePath
									format "....%\n" ((t.reallyPath as string)+">>"+inScenePathOK)
									--G_OBJ_UTIL.setIni  "texture" ("path"+(tt as string)) ((t.reallyPath as string)+">>"+inScenePathOK)
									appendIfUnique textureList ((t.reallyPath as string)+">>"+inScenePathOK)
								)
								--tt=tt+1
							)
						)
						local ip = G_OBJ_UTIL.getIpFromPath tInScenePath
						if ip!=undefined and (findItem ipArr ip)==0 then (
							append ipArr ip
						)
					)
				)
				
			)
			
			----------------------------------------------------------------------------------------------check spec symbol------------------------------------------------------------
			for tex in textureList do(
				hasspe
			)
			
			
			local textureCount = 2
			for tex in textureList do(
				G_OBJ_UTIL.setIni  "texture" ("path"+(textureCount as string)) tex
				textureCount=textureCount+1
			)				
			
			
			
			---------------------IP---------------------

			local resultIpStr = ""
			format "iparr...%\n" ipArr
			for ip in ipArr do (
				resultIpStr=resultIpStr+ip+"|"
			)
			G_OBJ_UTIL.setIni  "common" "remoteip" resultIpStr

			
			---------------------mount---------------------
 			--mountFrom={'/100001/worker_ljw/max/':'A:','/100001/worker_ljw/max/D/':'D:','/100001/worker_ljw/max/E/':'E:'}
			local defaultMountDriver="A:"
			local defaultMountFrom="/"+G_OBJ_CON.myUserId+"/"+G_OBJ_CON.myProjectName+"/max"--/100001/worker_ljw/max/
			local mountFromStr="{'"+defaultMountFrom+"':'"+defaultMountDriver+"'"

			--if (matchPattern G_OBJ_CON.myProjectName pattern:"*_renderlocal") then (
			if (G_OBJ_CON.myPlatform=="1007" or G_OBJ_CON.myPlatform=="1008")  and not  (matchPattern G_OBJ_CON.myProjectName pattern:"*_rendernet") then (

			)else(

				for myMountDriver in G_OBJ_CON.driverArr do (
					local myMountFrom = defaultMountFrom+"/"+myMountDriver
					mountFromStr=mountFromStr+",'"+myMountFrom+"':'"+myMountDriver+":'"
					
				)
			)
			
			mountFromStr=mountFromStr+"}"
			G_OBJ_UTIL.setIni  "common" ("mountFrom") mountFromStr

			
			
			---------------------Missing file---------------------
			format "G_OBJ_CON.missingFileList...%\n" G_OBJ_CON.missingFileList
			if G_OBJ_CON.missingFileList.count>0 then (
				
				append G_OBJ_CON.infoList (STInfo level:"warn" msgList:G_OBJ_CON.missingFileList code:G_TIPS_CODE.MISSING_FILE)
				

				append  G_OBJ_CON.warnList "------------------------"
				append  G_OBJ_CON.warnList "Missing files:"
				join G_OBJ_CON.warnList G_OBJ_CON.missingFileList
				
				
			)
			
			return true
			
		),
		
		
		fn setResultIni result=(
			local count=1
			local tipsList=result.tipsList
			local cfgList=result.cfgList
			
			
			for cfg in cfgList do (
				if cfg.otype=="common" or cfg.otype=="vray" then (
					G_OBJ_UTIL.setIni  cfg.otype (cfg.okey) cfg.oval
				)else(
					G_OBJ_UTIL.setIni  cfg.otype (cfg.okey+(count as string)) cfg.oval
					count=count+1
				)
				
			)
			--------------------warn or error--------------------
			for tips in tipsList do (
				
				G_OBJ_UTIL.setIni  "tips" ("\""+tips.code+"\"" )  (G_OBJ_UTIL.convertPythonList tips.msgList)
					
			)
			
		),
		
		fn hanResult=(
			for result in G_OBJ_CON.resultList do (
				setResultIni result
			)
			return true
		),
		
		fn hanConfig=(

			
			G_OBJ_UTIL.setIni   "common" "kg"  G_OBJ_CON.kg
			if G_OBJ_CON.myGuyVersion!=undefined then (

				G_OBJ_UTIL.setIni   "common" "guyVersion"  G_OBJ_CON.myGuyVersion
			)
			
			G_OBJ_UTIL.setIni   "common" "maxLanguage"  (sysinfo.GetMaxLanguage() as string)
			G_OBJ_UTIL.setIni   "common" "windowsLanguage"  ((sysinfo.getLanguage  user:true) as string)
			G_OBJ_UTIL.setIni   "common" "ingoreWarn"  (G_OBJ_CON.myIngoreWarn as string)
			G_OBJ_UTIL.setIni   "common" "enableParam"  ((G_OBJ_CON.myEnableParam as string)+"(2:enable ; 1:disable)")
			G_OBJ_UTIL.setIni   "common" "skipUpload"  (G_OBJ_CON.mySkipUpload as string)
			G_OBJ_UTIL.setIni   "common" "from"  "client"
			
			
			
			if G_OBJ_CON.kg=="100" or G_OBJ_CON.kg=="101"  or G_OBJ_CON.kg=="102" then (

				G_OBJ_UTIL.setIni   "common" "onlyphoton"  "false"
			)
				
			if G_OBJ_CON.myPlatform=="1007" or G_OBJ_CON.myPlatform=="1008"  then (

				G_OBJ_UTIL.setIni   "client" "storage_texture"  "3444"
			)else(

				G_OBJ_UTIL.setIni   "client" "storage_texture"  "3443"
			)
			
			if G_OBJ_CON.myCustomClient=="yunwu" then(
				G_OBJ_UTIL.setIni   "client" "allOutputType"  "jpg,tga"
				G_OBJ_UTIL.setIni   "client" "allElemType"  "jpg,tga"
			)else(
				G_OBJ_UTIL.setIni   "client" "allOutputType"  G_OBJ_CON.allOutputType
				G_OBJ_UTIL.setIni   "client" "allElemType"  G_OBJ_CON.allElemType
			)
			
			

			for c in G_OBJ_CON.configList do (
				local keyy = c.key
				local val = c.val
				local type= c.type
				G_OBJ_UTIL.setIni   type keyy val	
			)
			
			
			
			G_OBJ_UTIL.setIni  "common" ("update") "20171228"
			G_OBJ_UTIL.setIni  "vray" ("update") "20171228"
			
			
			
			
			
			

			return true
		),

		fn getFormatRenderer thereder =(
			local rendStr = thereder as string
			rendStr	=substituteString rendStr "V_Ray_Adv_" "v-ray adv "
			rendStr	=substituteString rendStr "_" "."
		),
		
		fn run userId projectId projectName maxFile pluginCfg myRenderer myPlatform renderfarm tempPath guyVersion projectPath ingoreTexture enableParam skipUpload clientZone customClient fatherId seperateAccount= (
			

			
			
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP1_CREATETASK_START
			local initResult=init  userId projectId projectName maxFile pluginCfg myRenderer myPlatform renderfarm tempPath guyVersion projectPath ingoreTexture enableParam skipUpload clientZone customClient fatherId seperateAccount
			
			if not initResult then (
				return undefined
			)
			
			local theRenderer = for scrender in RendererClass.classes where matchPattern (scrender as string) pattern:"V_Ray_Adv*"collect scrender
			
			local mylocalrender = (getFormatRenderer theRenderer[1])
			
			if (matchPattern (myRenderer as string) pattern:"v-ray*") and  mylocalrender!= myRenderer then
			(
-- 				append G_OBJ_CON.errorList G_OBJ_LANG.ERR_PROXY_ENABLE
-- 				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#() code:G_TIPS_CODE.PROXY_ENABLE)
			
				append G_OBJ_CON.errorList G_OBJ_LANG.ERR_VRAY_MATCH
				append G_OBJ_CON.infoList (STInfo level:"error" msgList:#(("File vray version:"+myRenderer as string),("Max vray version:"+mylocalrender as string)) code:G_TIPS_CODE.VRAY_VERSION_ERR)
				writeTips()
				
				return undefined
			)
			
			local ll = loadMaxFile maxFile useFileUnits:true quiet:true 
				--local ll =true
			
			format "===========\n"
			if not validProperties() then (
				return undefined
			)
			format "===========------\n"
			if not validRenderer() then(
				return undefined
			)
			
			if not validSpecificSymbol() then (
				return undefined
			)
				
			
			
			local logarr1 = #()
			local logarr2 = #()
			
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP2_MAXFILE_LOAD_START
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP3_COMMON_START
			local objCommon = STCommon()
			objCommon.check()
			
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP4_RENDER_START
			local objRender = STRender()
			objRender.check()

			
			
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP5_RENDERER_START
			local rendFormat = G_OBJ_UTIL.getFormatRender()

			if rendFormat=="vray" then (

				objVray = STVray()
				objVray.check()				

			)else if rendFormat=="scanline" then (

			)else if rendFormat=="finalrender" then (

				objFR = STFinalrender()
				objFR.check()

			)else if rendFormat=="maxwell" then (

			)else if rendFormat=="mentalray" then (

			)
			
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP6_TEXTURE_START
			local objAsset= STAsset()
			objAsset.check()
			

			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP7_PLUGIN_START
			local objPlugin= STPlugin()
			objPlugin.check()
			

			local sourceMaxFile =(maxfilePath +maxFileName )
			G_OBJ_UTIL.oolog ( "sourceMaxFile.." +sourceMaxFile)
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP8_CONFIG_TASK_START
			
			
			
			
			if not hanConfig() then(
				G_OBJ_UTIL.oolog  "Analyse End with warn and Error"
				/*20170609[remove exit code]
                G_OBJ_UTIL.donetWrite "104" "Analyse End with warn and Error"
				G_OBJ_UTIL.dosWrite "104" "Analyse End with warn and Error"
				*/
                return undefined
			)
            
			
			if not hanFile() then(
				return undefined
			)
			
			hanResult()
			
			/*
			if G_OBJ_CON.infoList.count>0 then (
				for infoObj in G_OBJ_CON.infoList do (
					
					G_OBJ_UTIL.setIni  "tips" ("\""+infoObj.code+"\"" ) (G_OBJ_UTIL.convertPythonList infoObj.msgList )
				)
				
			)*/
			writeTips()-------------abort
			--format "warnlist........%\n" G_OBJ_CON.warnList
			G_OBJ_UTIL.donetWrite "200" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
			G_OBJ_UTIL.dosWrite "200" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
			
			G_OBJ_UTIL.donetWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
			G_OBJ_UTIL.dosWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
			
			sleep 1
            
            /*20170609[remove exit code]
			if G_OBJ_CON.warnList.count>0 then (

				G_OBJ_FILEUTIL.writeFileFN G_OBJ_CON.myWarnFile G_OBJ_CON.warnList
				G_OBJ_UTIL.setIniWithList "warn" G_OBJ_CON.warnList
				if G_OBJ_CON.errorList.count>0 then (

					G_OBJ_FILEUTIL.writeFileFN G_OBJ_CON.myErrorFile G_OBJ_CON.errorList
					G_OBJ_UTIL.oolog  "Analyse End with warn and Error"
					G_OBJ_UTIL.donetWrite "104" "Analyse End with warn and Error"
					G_OBJ_UTIL.dosWrite "104" "Analyse End with warn and Error"
				)else(
					if G_OBJ_CON.myIngoreWarn=="1" then (

						--local subResult=G_OBJ_UTIL.RBhideCmd G_OBJ_CON.myGuy (" -subtask "+G_OBJ_CON.myTaskId)
						G_OBJ_UTIL.oolog  "Analyse End with warn but ingore"
						G_OBJ_UTIL.donetWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
						G_OBJ_UTIL.dosWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
					)else(

						G_OBJ_UTIL.oolog  "Analyse End with warn "
						G_OBJ_UTIL.donetWrite "201" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
						G_OBJ_UTIL.dosWrite "201" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
					)
					
				)
			
			)else(
				
				if G_OBJ_CON.errorList.count>0 then (

					G_OBJ_FILEUTIL.writeFileFN G_OBJ_CON.myErrorFile G_OBJ_CON.errorList
					G_OBJ_UTIL.oolog  "Analyse End with  Error"
					G_OBJ_UTIL.donetWrite "104" "Analyse End with  Error"
					G_OBJ_UTIL.dosWrite "104" "Analyse End with  Error"
				)else(

					--local subResult=G_OBJ_UTIL.RBhideCmd G_OBJ_CON.myGuy (" -subtask "+G_OBJ_CON.myTaskId)
					G_OBJ_UTIL.oolog  "Analyse End with nothing"
					G_OBJ_UTIL.donetWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
					G_OBJ_UTIL.dosWrite "100" G_OBJ_LANG.STEP9_SUBMIT_TASK_END
				)
			)
            */

			
			sleep 5--wait for killing by python
			
				
			

			
		)

		
	)
	
	

	


fn rayvision userId projectId projectName maxFile pluginCfg myRenderer myPlatform renderfarm tempPath guyVersion projectPath ingoreTexture enableParam skipUpload clientZone customClient fatherId seperateAccount= (
	
	
	local objTask=STTask()
	objTask.run userId projectId projectName maxFile pluginCfg myRenderer myPlatform renderfarm tempPath guyVersion projectPath ingoreTexture enableParam skipUpload clientZone customClient fatherId seperateAccount
)




clearlistener()








