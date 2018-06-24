

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
global g_tips_code=STCode()
	
	
struct MsDict(  
    private  
    table = #(),  
  
    fn binSort a b =  
    (  
        if a[1] > b[1] then 1  
        else if a[1] < b[1] then -1  
        else 0  
    ),  
    fn formatDic dic level:0 spaces:4 =  
    (  
        strm = "\n" as stringStream  
        padding = "    "  
        if level != 0 then  
        (  
            for a=1 to level do for b=1 to spaces do padding += " "  
        )  
        for k in (dic.keys()) do  
        (  
            val = dic.get_kv k  
            case (classof val) of  
            (  
                (MsDict):format "%%:\n%" padding k (formatDic val level:(level+1) spaces:spaces) to:strm  
                
				default:format "%%:%\n" padding k val to:strm  
            )  
        )  
        (strm as string)  
    ), 
	
	fn format_to_json dic level:0 spaces:4 =  
    (  
        strm = "\n" as stringStream  
        padding = "    "  
        if level != 0 then  
        (  
            for a=1 to level do for b=1 to spaces do padding += " "  
        )  
		if (classof dic) ==Array then (
			for i=1 to dic.count do  
			(   
				val=dic[i]
				
				local comma_flag =","
				if i == dic.count then (
					comma_flag=""
				)
				
				case (classof val) of  
				(  
					(MsDict):(
						format "%{\n%%%}%\n" padding  (format_to_json val level:(level+1) spaces:spaces) padding padding comma_flag to:strm
					)				
					(Array): (
						format "\n%[\n%%]%\n" padding  (format_to_json val level:(level+1) spaces:spaces) padding comma_flag to:strm 
					)
					default:(
						format "%\"%\"%\n" padding val comma_flag comma_flag to:strm 
						
					)
				)  
			)  
		)else if  (classof dic) ==MsDict then (
			local dict_key = dic.keys()
			local dict_val = dic.vals()
			local dict_count = (dic.keys()).count
				
			for i=1 to dict_count do
			(  
				local val = dict_val[i]
				local k =dict_key[i]
				
				local comma_flag =","
				if i ==dict_count then (
					comma_flag=""
				)
				case (classof val) of  
				(  
					(MsDict):format "%\"%\":{\n%%}%\n" padding k (format_to_json val level:(level+1) spaces:spaces) padding comma_flag to:strm  
					(Array): (
						format "%\"%\":\n%[\n%%]%\n" padding k padding (format_to_json val level:(level+1) spaces:spaces) padding comma_flag to:strm 
					)
					default:(
						format "%\"%\":\"%\"%\n" padding k val  comma_flag to:strm 
					)
				)  
			)  
			
			
		)else(
			
			
		)
		
        (strm as string)  
    ), 

	

	
    public  
    fn count = keys.count,  
    fn get_kv k =   
    (  
        val = bsearch #(k) table binSort  
        if val == undefined then return val  
        val[2]  
  
    ),  
    fn set_kv k v =  
    (  
        val = bsearch #(k) table binSort  
        if val == undefined then  
        (  
            append table #(k,v)  
            qsort table binSort  
            return this  
        )  
        val[2] = v  
        this  
    ),  
    fn hasK k =  
    (  
        t = case (bsearch #(k) table binSort) of  
        (  
            (undefined):false  
            default:true  
        )  
        t  
    ),  
    fn delK k =  
    (  
        for i=1 to table.count where table[i][1] == k do  
        (  
            indx = i  
            exit  
        )  
        if indx == 0 then throw ("there is no key "+k+" in dictionary")  
        deleteItem table indx  
        this  
    ),  
    fn keys =  
    (  
        out = for k in table collect k[1] 
        out  
    ),
	fn vals = (
		out = for k in table collect k[2] 
        out 
		
	),
	
	
	
    fn pprint =  
    (  
        print (formatDic this)  
        ok  
    ) ,
    fn print_to_json =  
    (  
		
		format "{\n%}\n" (format_to_json this)		
        ok  
    ),
	
	fn write_json_file json_file=(
		
		
		local json_str = format_to_json this
		format "{\n%}\n" json_str 
		
		if doesfileexist json_file then (
			deleteFile json_file
		)
		local maxv_int = ((maxversion())[1])/1000
		if  maxv_int>= 15 then(
			json_file_obj = createFile json_file encoding:#utf8
		)else(
			json_file_obj = createFile json_file
		)
		format "{\n%}" json_str to:json_file_obj
		close json_file_obj
	)

	
	
	
)



struct STConstanst(
	cg_file,
	task_json_file,
	asset_json_file,
	tips_json_file,
	ignore_analyse_array,
	
	log_file,
	log_count=1,
	
	my_tdout = createAssembly dotnetcode "StdOutPrinter",
	dot_common = createAssembly dotnetcode2 "Common",
	
	max_version_int,
	max_version,
	scene_frames_array,
	scene_frames_str,
	
	renderer_class,
	renderer_name,
	renderer_format,
	
	scene_info_dict = MsDict(),
	tips_json_dict=MsDict(),
	
	fn get_max_version max_version_int= (
		local max_version = "3ds Max "
		if max_version_int<=9 then (
			return max_version_int
		)else(
			return (2008+max_version_int-10)
		)
		
		
	),
	
	fn get_frames_array = (
		
		local frameStart = rendStart.frame as integer
		local frameEnd = rendEnd.frame as integer
		local frames_array = #()
		local nth = (rendNThFrame as integer)
		
		if rendtimetype==1 then (--single
			
			frameStart=currenttime.frame as integer
			frameEnd=currenttime.frame as integer
			append frames_array frameStart
		)else if rendtimetype==2 then (--Active Time segment
			frameStart = animationRange.start.frame as integer
			frameEnd = animationRange.end.frame as integer
			if frameStart == frameEnd then (
				append frames_array frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append frames_array i
				)
			)		
			
		)else if rendtimetype==3 then (--Ranage
			if frameStart == frameEnd then (
				append frames_array frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append frames_array i
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
							append frames_array k
						)
					)
				)else(
					append frames_array (f as integer)
				)
			)
		)
		
		local result = #()
		for b in frames_array do (
			if findItem result b ==0 then (
				append result b			
			)
			
		)
		result
	),
		
	fn get_frames_str=(
		local frame_str = "0"
		if rendtimetype==1 then (--single
			frame_str= (currentTime.Frame as integer) as string --sliderTime.Frame
		)else if rendtimetype==2 then (--Active Time segment
			local anStart = (animationRange.start.frame as integer) as string
			local anEnd =  (animationRange.end.frame as integer) as string 
			local nth = (rendNThFrame as integer) as string
			frame_str=anStart+"-"+anEnd +"["+nth+"]"
		)else if rendtimetype==3 then (--Ranage
			
			local nth =(rendNThFrame as integer) as string
			local start = (rendStart.frame as integer) as string
			local end = (rendEnd.frame as integer) as string
			frame_str=start+"-"+end +"["+nth+"]"				
			
		)else if rendtimetype==4 then(--Frames
			
			local frames = rendPickupFrames 
			if frames!=undefined and frames!="" then (			
				frame_str=frames
			)			
		)
		frame_str
	),
	
	fn get_renderer_name  = (
		
		local render_str = ( classof renderers.production ) as string
		local rend = undefined 
		if (render_str == (vray as string)) then (
			rend="vray"
		) else if (render_str == (default_scanline_renderer as string)) then (
			rend = "scanline"
		) else if render_str == (finalRender_stage_1 as string) then (
			rend = "finalrender"
		) else if (render_str == (MaxwellRenderer as string)) then (
			rend = "maxwell"
		) else if (render_str == (mental_ray_renderer as string)) then (
			rend = "mentalray"
		) else if (render_str == (mental_ray_iray_Renderer as string)) then (
			rend = "mentalray_iray"
		) else if (render_str == (Quicksilver_Hardware_Renderer as string)) then (
			rend = "hardware"
		) else if (render_str == (CoronaRenderer as string)) then (
			rend = "coronarender"
		) else if (render_str == (Krakatoa as string)) then (
			rend = "krakatoa"
		) else (
			rend = (toLower render_str)
		)
		rend	
		
	),
	fn format_renderer thereder =(
		local rendStr = thereder as string
		rendStr	= substituteString rendStr "V_Ray_Adv_" "v-ray adv "
		rendStr	= substituteString rendStr "_" "."
		rendStr	= substituteString rendStr "SP" "sp"
		
	),
	
	fn init cg_file_temp task_json asset_json tips_json ignore_array= (
		cg_file=cg_file_temp
		task_json_file=task_json
		asset_json_file = asset_json
		tips_json_file = tips_json
		ignore_analyse_array=ignore_array
		
		max_version_int=((maxversion())[1])/1000
		max_version=get_max_version max_version_int
		scene_frames_array=get_frames_array()
		scene_frames_str=get_frames_str()
		
		renderer_class= (classof renderers.production) as string
		renderer_name=get_renderer_name()
		renderer_format=format_renderer renderer_name
		
		
		log_file = (getFilenamePath task_json_file) +"log.txt"
	)
	
		
)
global g_obj_con=STConstanst()


struct STUtil(
	
	fn print_log myval = (
		
		local logPath = g_obj_con.log_file
		local max_version_int=((maxversion())[1])/1000
		if max_version_int >= 15 then(
			SetINISetting  g_obj_con.log_file "log" (g_obj_con.log_count as string) ("["+(localTime as string)+"]"+myval) forceUTF16:true
		)else(
			SetINISetting  g_obj_con.log_file "log" (g_obj_con.log_count as string) ("["+(localTime as string)+"]"+myval)
		)
		format "%\n" ("["+(localTime as string)+"]"+myval)
		g_obj_con.log_count=g_obj_con.log_count+1
	),
	fn convert_to_str str=(
		if str==undefined then (
			str=""
		)
		(str as string)
	),
	

	fn to_lower str =(
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



	fn is_standard_name myName= (
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

	fn is_Standard_path myPath= (
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
	
	fn has_specific_symbol myStr symbolList:#("*\n*","*\r*","*\\*")= (
		
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


	fn replace_str sourceStr oldStr newStr  = (
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


	fn getframes_array = (
		debugLog "STUtil.getframes_array.001"	
		local frameStart = rendStart.frame as integer
		local frameEnd = rendEnd.frame as integer
		local frames_array = #()
		local nth = (rendNThFrame as integer)
		debugLog "STUtil.getframes_array.002"
		if rendtimetype==1 then (--single
			
			frameStart=currenttime.frame as integer
			frameEnd=currenttime.frame as integer
			append frames_array frameStart
		)else if rendtimetype==2 then (--Active Time segment
			frameStart = animationRange.start.frame as integer
			frameEnd = animationRange.end.frame as integer
			if frameStart == frameEnd then (
				append frames_array frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append frames_array i
				)
			)		
			
		)else if rendtimetype==3 then (--Ranage
			if frameStart == frameEnd then (
				append frames_array frameStart 
			)else(
				for i=frameStart to frameEnd by nth do (
					append frames_array i
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
							append frames_array k
						)
					)
				)else(
					append frames_array (f as integer)
				)
			)
		)
		debugLog "STUtil.getframes_array.003"
		local result = #()
		for b in frames_array do (
			if findItem result b ==0 then (
				append result b			
			)
			
		)
		debugLog "STUtil.getframes_array.004"
		result
	)
)
global g_obj_util = STUtil()


struct STFileUtil(
	
	fn get_file_name file= (
		local ext = getFilenameType file
		local bname = getFileNameFile file
		local result = bname + ext
		result
	),

	fn analyse_path myPath=(
		
		local mName = getFilenameFile myPath
		local mType = getFilenameType myPath
	
		local prePath=getPrePath()
		local driverArr=#()
	
		if myPath==undefined or myPath=="" then (
			return ""
		)
		myPath=g_obj_util.replace_str myPath "\\" "/"
		
		
	
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
		
		lowerMyPath = g_obj_util.to_lower myPath
			
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
)
global g_file_util = STFileUtil()


struct STCommon(
	
	scene_common_dict = MsDict(),
	
	
	fn check_output_file =(
		
		
		local file_name = g_file_util.get_file_name rendOutputFilename
		
		if file_name==undefined then (
			file_name=""
		)
		local base_name=getfilenamefile file_name
		local base_type=getfilenametype file_name
		scene_common_dict.set_kv "output_file_basename" base_name
		scene_common_dict.set_kv "output_file_type" base_type
		scene_common_dict.set_kv "rend_save_file" (rendSaveFile as string)
		scene_common_dict.set_kv "output_file" file_name		
	),
	
	fn get_renderable_camera=(
		local my_camera = getActiveCamera()
		local render_view
		
		try(
			if (rendUseActiveView) then ( 
				render_view = viewport.activeViewport 
			)else ( 
				render_view = rendViewIndex 
			)
			my_camera =  (viewport.getCamera index:render_view)
			
		)catch()
		local camera_str = undefined 
		if my_camera!=undefined then (
			camera_str=my_camera.name
			
		)
		if camera_str == undefined then (
			camera_str=""
		)
		camera_str
	),
	fn get_camera_array = (
		
		local camera_array = #()
		for i=1 to cameras.count do(
			
			local c=cameras[i]
			if ((classof c) as string )!="Targetobject" then (
				append camera_array c.name
			)
		)
		
		camera_array
	),

	fn check_camera=(
		local camera_array=get_camera_array()
		if camera_array.count==0 then (
			g_obj_con.tips_json_dict.set_kv g_tips_code.CAMERA_NULL #()
		)
		scene_common_dict.set_kv "all_camera" camera_array
		scene_common_dict.set_kv "renderable_camera" (get_renderable_camera())
			
		if getrendertype() != #view and getrendertype() != #normal then(
			g_obj_con.tips_json_dict.set_kv g_tips_code.RENDER_TYPE #("Area to Render :"+(getrendertype() as string ))
		)  
	),
	
	fn check_element  = (
		
		local rend = renderers.production
		local renderElementsMgr = maxOps.GetRenderElementMgr #Production
		local elementActive=renderElementsMgr.GetElementsActive()
		if elementActive==true then (
			scene_common_dict.set_kv "element_active" "1"
		)else(
			scene_common_dict.set_kv "element_active" "0"
		)
		elementStr=""
		if renderElementsMgr.numrenderelements()>0 then (
			local elemPath = renderElementsMgr.getRenderElementFilename 0 
			
			local element_type=undefined
			if elemPath!=undefined then (
				element_type=getfilenametype elemPath
			)
			if element_type==undefined or element_type=="" then (
				if  rendOutputFilename!=undefined then (
					local outputType = getfilenametype rendOutputFilename
					element_type=outputType
				)
				
			)
			if element_type==undefined or element_type=="" then (
				element_type="tga"
			)
			element_type=g_obj_util.replace_str elemType "." ""
			scene_common_dict.set_kv "element_type" element_type
		)
		
		local element_array = #()
		for n = 0 to (renderElementsMgr.numrenderelements()- 1) do(
			local el =classof( renderElementsMgr.GetRenderElement n)
			local elemPath = renderElementsMgr.getRenderElementFilename n
			append element_array el
		)
		scene_common_dict.set_kv "element_list" element_array
		
	),
	fn check_gamma=(
		
		if IDisplayGamma.colorCorrectionMode == #gamma then(
			scene_common_dict.set_kv "gamma" "1"
		)else(
			scene_common_dict.set_kv "gamma" "0"
		)
		scene_common_dict.set_kv "gamma_val" (IDisplayGamma.gamma as string)
		scene_common_dict.set_kv "in_gamma" (fileInGamma as string)
		scene_common_dict.set_kv "out_gamma" (fileOutGamma as string)
		
	),
	
	fn check_frames=(
		scene_common_dict.set_kv "rend_timeType" (rendTimeType as string)
		
		scene_common_dict.set_kv "frames" g_obj_con.scene_frames_str
			
		local animation_range_start=((animationRange.Start as string)as integer) as string
		local animation_range_end=((animationRange.End as string)as integer) as string
		scene_common_dict.set_kv "animation_range" (animation_range_start+"-"+animation_range_end)
	),
	
	fn check_others=(
		if BitmapProxyMgr.globalProxyEnable==true then (
			g_obj_con.tips_json_dict.set_kv g_tips_code.PROXY_ENABLE #()
		)
		
		local xrefcount = xrefs.getXRefFileCount()
		if xrefcount > 0 then(			
			g_obj_con.tips_json_dict.set_kv g_tips_code.XREFFILES #()
		)
		local xrefobjcount = objXRefs.getNumfiles()
		if xrefobjcount > 0 then	(
			g_obj_con.tips_json_dict.set_kv g_tips_code.XREFOBJ #()
		)
	),
		
	fn check = (
		g_obj_util.print_log "STCommon...check...Start "
		
		scene_common_dict.set_kv "cg_version" max_version
		scene_common_dict.set_kv "width" (renderWidth as string)
		scene_common_dict.set_kv "height" (renderHeight as string)
		
		check_frames()
		check_output_file()
		check_camera()
		check_gamma()
		check_element()
		check_others()
		
		scene_common_dict
	)
	
	
)


struct STRenderer(
	
	scene_renderer_dict=MsDict(),
	
	fn check_vfb =(
		local my_renderer = renderers.production
		
		local vfb=my_renderer.output_on 
		if vfb then (
			scene_renderer_dict.set_kv "vfb" "1"
		)else(
			scene_renderer_dict.set_kv "vfb" "0"
		)
			
		local rend_raw_img_name = my_renderer.output_saveRawFile as string
		scene_renderer_dict.set_kv "rend_raw_img_name" rend_raw_img_name
		
		local raw_img_name = my_renderer.output_rawFileName
		raw_img_name=g_obj_util.convert_to_str raw_img_name
		raw_img_name=g_obj_util.replace_str raw_img_name "\\" "/"
		scene_renderer_dict.set_kv "raw_img_name" raw_img_name
		
		local save_sep_channel = my_renderer.output_splitgbuffer as string
		scene_renderer_dict.set_kv "save_sep_channel" save_sep_channel
		
		local channel_file = g_obj_util.convert_to_str my_renderer.output_splitfilename
		channel_file=g_obj_util.replace_str channel_file "\\" "/"
		scene_renderer_dict.set_kv "channel_file" channel_file
		
		local displacement=my_renderer.options_displacement as string
		scene_renderer_dict.set_kv "displacement" displacement
		
		local reflection_refraction=my_renderer.options_reflectionRefraction as string
		scene_renderer_dict.set_kv "reflection_refraction" reflection_refraction
			
		local filter_on=my_renderer.filter_on as string
		scene_renderer_dict.set_kv "filter_on" filter_on
		
		local image_sampler_type=my_renderer.imageSampler_type as string
		scene_renderer_dict.set_kv "image_sampler_type" image_sampler_type
		
		local filter_kernel=(classof my_renderer.filter_kernel as string)
		local filter_kernel2=""
		if filter_kernel ==	"Area"	then(	
			filter_kernel2 =	"Area"
		)else if filter_kernel ==	"Sharp_Quadratic" 	then(	
			filter_kernel2 =	"Sharp Quadratic" 
		)else if filter_kernel ==	"Catmull_Rom"	then(	
			filter_kernel2 =	"Catmull-Rom"
		)else if filter_kernel ==	"Plate_Match_MAX_R2"	then(	
			filter_kernel2 =	"Plate Match/MAX R2"
		)else if filter_kernel ==	"Quadratic"	then(	
			filter_kernel2 =	"Quadratic"
		)else if filter_kernel ==	"cubic"	then(	
			filter_kernel2 =	"cubic"
		)else if filter_kernel ==	"Video"	then(	
			filter_kernel2 =	"Video"
		)else if filter_kernel ==	"Soften"	then(	
			filter_kernel2 =	"Soften"
		)else if filter_kernel ==	"Cook_Variable"	then(	
			filter_kernel2 =	"Cook Variable"
		)else if filter_kernel ==	"Blendfilter"	then(	
			filter_kernel2 =	"Blend"
		)else if filter_kernel ==	"Blackman"	then(	
			filter_kernel2 =	"Blackman"
		)else if filter_kernel ==	"Mitchell_Netravali"	then(	
			filter_kernel2 =	"Mitchell-Netravali"
		)else if filter_kernel ==	"VRayLanczosFilter"	then(	
			filter_kernel2 =	"VRayLanczosFilter"
		)else if filter_kernel ==	"VRaySincFilter"	then(	
			filter_kernel2 =	"VRaySincFilter"
		)else if filter_kernel ==	"VRayBoxFilter"	then(	
			filter_kernel2 =	"VRayBoxFilter"
		)else if filter_kernel ==	"VRayTriangleFilter"	then(	
			filter_kernel2 =	"VRayTriangleFilter"
		)
		scene_renderer_dict.set_kv "filter_kernel" filter_kernel2
		
		
	),
	
	fn check_gi = (
		
		local my_renderer = renderers.production
			
		if my_renderer.gi_on==true then(
			scene_renderer_dict.set_kv "gi" "1"
		)else(
			scene_renderer_dict.set_kv "gi" "0"
		)
		
		local subdivs =""
		local secbounce=""
		if hasProperty my_renderer "dmcgi_subdivs" then (
			subdivs=my_renderer.dmcgi_subdivs as string
		)
		if hasProperty my_renderer "qmcgi_subdivs" then (
			subdivs=my_renderer.qmcgi_subdivs as string
		)
		local secbounce=""
		if hasProperty my_renderer "dmcgi_depth" then (
			secbounce=my_renderer.dmcgi_depth as string
		)
		if hasProperty my_renderer "qmcgi_depth" then (
			secbounce=my_renderer.qmcgi_depth as string
		)
		
		local irrmap_file=(g_obj_util.convert_to_str my_renderer.adv_irradmap_loadFileName )
		irrmap_file=g_obj_util.replace_str  irrmap_file "\\" "/"
		
		local light_cache_file=g_obj_util.convert_to_str my_renderer.lightcache_loadFileName
		light_cache_file=g_obj_util.replace_str  light_cache_file "\\" "/"
		
		scene_renderer_dict.set_kv "primary_gi_engine" (my_renderer.gi_primary_type as string)
		scene_renderer_dict.set_kv "irradiance_map_mode"  (my_renderer.adv_irradmap_mode as string)
		scene_renderer_dict.set_kv "irrmap_file"  irrmap_file
		scene_renderer_dict.set_kv "secondary_gi_engine"  (my_renderer.gi_secondary_type as string)
		scene_renderer_dict.set_kv "light_cache_mode"  (my_renderer.lightcache_mode as string)
		scene_renderer_dict.set_kv "light_cache_file"  light_cache_file
		scene_renderer_dict.set_kv "mem_limit"  (my_renderer.system_raycaster_memLimit as string )
		scene_renderer_dict.set_kv "default_geometry"  (my_renderer.system_instancedObjects as string)
		scene_renderer_dict.set_kv "subdivs"  subdivs
		scene_renderer_dict.set_kv "secbounce"  secbounce
		scene_renderer_dict.set_kv "displacement"  (my_renderer.options_displacement as string) 
		scene_renderer_dict.set_kv "reflection_refraction"  (my_renderer.options_reflectionRefraction as string)
		
		scene_renderer_dict.set_kv "gi_width" (renderWidth as string)
		scene_renderer_dict.set_kv "gi_height" (renderHeight as string)
		scene_renderer_dict.set_kv "gi_frames"  g_obj_con.scene_frames_str
		
	
		
	),
	
	fn check_vray = (
		check_vfb()
		check_gi()
	),
	fn check=(
		scene_renderer_dict.set_kv "renderer_orign" g_obj_con.renderer_class
		scene_renderer_dict.set_kv "renderer_name" g_obj_con.renderer_name
		scene_renderer_dict.set_kv "renderer" g_obj_con.renderer_format
		
		local mi = findstring g_obj_con.renderer_class "miss"
		local rt = findstring g_obj_con.renderer_class "rt"
		
		if mi!=undefined then (
			g_obj_con.tips_json_dict.set_kv g_tips_code.RENDERER_MISSING #()
			
		)
		if rt!=undefined then (
			g_obj_con.tips_json_dict.set_kv g_tips_code.RENDERER_NOTSUPPORT #()
		)
		
		if g_obj_con.renderer_class== mental_ray_iray_Renderer or g_obj_con.renderer_class == Quicksilver_Hardware_Renderer or g_obj_con.renderer_class == Brazil_r_s_Rio_Learning_Edition_v2_0__build_1618 then(
			g_obj_con.tips_json_dict.set_kv g_tips_code.RENDERER_NOTSUPPORT #()			
		)
		
		if (g_obj_con.renderer_class == (vray as string)) then (
			check_vray()
		)
		
		
		scene_renderer_dict
	)
	
	
)


struct STAsset(
    
    asset_dict=MsDict(),
	
	fn check_texture = (
		local tex_list= #()
		Atsops.Refresh()
		Atsops.getFiles &tex_list
	
		local result_tex_array=#()
		for tex in tex_list do(
			if  (matchPattern tex pattern:"*.fxd") then(
			)else if (matchPattern tex pattern:"*.xmesh") then(
			)else if (matchPattern tex pattern:"*.vrmesh") then(
			)else if (matchPattern tex pattern:"*.bin") then(
			)else if (matchPattern tex pattern:"*.aur") then(
			)else if tex==(maxfilepath+maxfilename) then(
			)else if  (ATSOps.IsInputFile tex)  then(
				append result_tex_array tex
			)
		)
		if result_tex_array.count>0 then (
			asset_dict.set_kv "texture"  result_tex_array
		)
	),
	
	fn check_krakatoa = (
        
	),
	
	fn check_xmesh = (
		
	),
	
	fn check_xrefs = (
	),
	
	fn check_realflow = (
	),
	
	fn check_alembic = (
		
		local alembic_array = #()
		try(
			abc_file = getclassinstances Alembic_Mesh_Geometry 
			for i = 1 to abc_file.count do (
				local alembic_path = abc_file[i].path
				append alembic_array alembic_path
			)
		)catch()
		
		try (
			abc_file = getclassinstances AlembicObject
			for i = 1 to abc_file.count do (
				local alembic_path =  abc_file[i].source
				append alembic_array alembic_path
			)
		)catch()
		
		
		if alembic_array.count>0 then (
			asset_dict.set_kv "alembic"  alembic_array
		)
		
	),
	
	fn check_point_cache=(
		local point_cache_array=#()
		
		local pcArr = #()
		try(
			pcArr = getClassInstances  Point_Cache
			local pcwsmArr =  getClassInstances Point_CacheSpacewarpModifier
			join pcArr pcwsmArr
		)catch()
		try(			
			for pc in pcArr do (
				append point_cache_array (fpc.fileName  as string)
			)
		)catch()
		
		if point_cache_array.count>0 then (
			asset_dict.set_kv "point_cache"  point_cache_array
		)
	),	
	
	fn check_fumefx = (
	),
	
	fn check_phoenix = (
	),
	
	fn check_vray_volume = (
	),
	
	
	fn check_vrmesh = (	
	),
		
	fn check_ies = (
		local ies_array=#()
		try(
			local Targetlight=getclassinstances Target_Light 
			local Freelight= getclassinstances Free_Light
			local all_ies = Targetlight+Freelight
			for my_ies in   all_ies do (
				append ies_array (my_ies.webfile)
				
			)
		)catch()
		
		if ies_array.count>0 then (
			asset_dict.set_kv "ies" ies_array
		)
	),
		
	fn check=(
		check_texture()
		check_krakatoa()
		check_xmesh()
		check_xrefs()
		check_realflow()
		check_alembic()
		check_point_cache()
		check_fumefx()
		check_phoenix()
		check_vray_volume()
		check_vrmesh()
		check_ies()
		asset_dict
	)
	
		
)

fn analyse file:cg_file task:task_json asset:asset_json tips:tips_json ignore:#()=(
	g_obj_con.init file task asset tips ignore
	local loadResult = loadMaxFile g_obj_con.cg_file useFileUnits:true quiet:true 
	
	local scene_common_dict = (STCommon()).check()
	local scene_renderer_dict=(STRenderer()).check()
	
	local scene_info_dict=MsDict()
	scene_info_dict.set_kv "common" scene_common_dict
	scene_info_dict.set_kv "renderer" scene_renderer_dict
	
	format "\n\n\n------------------task-------------------\n"
	task_json=MsDict()
	task_json.set_kv "scene_info" scene_info_dict
	task_json.write_json_file g_obj_con.task_json_file
		
	format "\n\n\n------------------asset-------------------\n"
	local asset_json = (STAsset()).check()
	asset_json.write_json_file g_obj_con.asset_json_file
		
	format "\n\n\n------------------tips-------------------\n"
	g_obj_con.tips_json_dict.write_json_file g_obj_con.tips_json_file
)

clearlistener()

/*
main  file:"D:/Renderbus/max2012-2014复杂贴图打包/要命要命不是人.max" task:"c:/renderfarm/project/666/task.json" asset:"c:/renderfarm/project/666/asset.json" tips:"c:/renderfarm/project/666/tips.json"
*/

