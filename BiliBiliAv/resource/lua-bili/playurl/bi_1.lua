local iqiyi = {}
local utility = require("bili.utility")
require("bili.model")
local AVAILABLE_PERIOD_MILLI = 300000
local IQIYI_META_MAP = {
	["5"] = {
 		["name"]            = "5",			     -- 源 TAG
 		["format"]			= VIDEO_FORMAT["FLV"], -- 视频封装格式
 		["video_codec"]		= "H264",			 -- 视频编码
 		["audio_codec"]		= "MP4A",			 -- 音频编码
	    ["type_tag"]        = "lua.iqiyi.5.fhd", -- 客户端 TAG
	    ["description"]     = "原画",			 -- 描述
        ["kbps"]            = 3800,				 -- 码率估算,大约是 bytes / seconds / 1000
        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
        ["order"]			= 5
	},
	["4"] = {
 		["name"]            = "4",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.iqiyi.4.shd",
	    ["description"]     = "超清",
        ["kbps"]            = 2000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},
	["2"] = {
 		["name"]            = "2",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.iqiyi.2.hd",
	    ["description"]     = "高清",
        ["kbps"]            = 770,
        ["hq_score"]        = 100,
        ["lq_score"]        = 1,
        ["order"]			= 3
	},
	["1"] = {
 		["name"]            = "1",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.iqiyi.1.sd",
	    ["description"]     = "流畅",
        ["kbps"]        = 560,
        ["hq_score"]        = 90,
        ["lq_score"]        = 90,
        ["order"]			= 2
	},
	["96"] = {
 		["name"]            = "96",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.iqiyi.96.ld",
	    ["description"]     = "极速",
        ["kbps"]            = 270,
        ["hq_score"]        = 80,
        ["lq_score"]        = 80,
        ["order"]			= 1
	},
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.iqiyi.unknown",
	    ["description"]     = "未知",
        ["kbps"]            = 0,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= -1
	}
}

local IQIYI_META_REVERSE_MAP = {}
for k, v in pairs(IQIYI_META_MAP) do
    IQIYI_META_REVERSE_MAP[v["type_tag"]] = v;
end

local VSL_TAG = "vsl"
local IQIYI_DATA_URL = "http://data.video.qiyi.com/"
local IQIYI_DATA_URL_HD = "http://netcncallcnc.inter.iqiyi.com/"
init_iqiyi_server_time = nil
init_local_time = nil


local function get_pi(t,q)
	if q <= 1 then
		return t[1]
	end
	for i = 1,#t do
		if q == i then
			return t[i]
		end
	end
	if q >= 3 then
		return t[#t]
	end
	return t[1]
end

local function get_pi_by_quality(vl,resolve_params)
	local q = 1
	local quality = resolve_params["expected_quality"]
	local request_from_downloader = resolve_params["request_from_downloader"]
	if request_from_downloader == nil then
		request_from_downloader = false
	end
	if quality >= 200 then
		q = #vl
		if vl[q]["meta"] ~= nil and vl[q]["meta"]["name"] == "5" and q > 2 and request_from_downloader == false then
			q = #vl - 1
		end
	else
		q = 1
	end
	return get_pi(vl,q)
end


local function get_meta_by_stream_tag(id)
    local meta = IQIYI_META_MAP[tostring(id)]
    if meta == nil then
        meta = IQIYI_META_MAP["unknown"]
    meta["description"] = "其他("..id..")";
    end
    return meta;
end

local function comps(a,b)
	local astr,bstr = string.gsub(a.bid,"96","0"),string.gsub(b.bid,"96","0")
	local anum = tonumber(astr)
	local bnum = tonumber(bstr)
	return anum<bnum
end

local function resolve_resource(vid,tvid)
	local http_utility = utility --require "bili.http_utility"
	local json = require("json")

	local deviceinfo = nil
	if deviceinfojson ~= nil then
		deviceinfo = json.decode(deviceinfojson)
	end
	local ua = USER_AGENT
	if deviceinfo ~= nil and deviceinfo["ua"] ~= nil then
		ua = deviceinfo["ua"]
	end

	-- local base_url = "http://cache.video.qiyi.com/vp/0/"
	-- local api_url = base_url..vid.."/"

	math.randomseed(os.time())
	local tm = math.random(1000,2000)
	local uuid = require("uuid")
	uuid.randomseed(os.time())
	local uid = uuid.new()
		--md5
	local lmd5
	if _VERSION == "Lua 5.2" then
		lmd5 = require("md5")
	else
		require('md5')
		lmd5 = md5
	end
	local enc = lmd5.sumhexa("ts56gh"..tm..tvid)
	local api_url = "http://cache.video.qiyi.com/vms?key=fvip&src=p&tvId="..tvid.."&vid="..vid.."&vinfo=1&tm="..tm.."&enc="..enc.."&qyid="..uid.."&tn="..math.random()

	utility.log("api_url",api_url)

	local r, c, h, s,body = http_utility.httpget(api_url,nil,ua)

	if c ~= 200 then
		utility.log("failed:"..api_url)
		return nil
	end

	--utility.log("api_url body:",body)

	local resource = {["stream_list"]={}}

	local jobject = json.decode(body)
	local jstream_array = jobject["data"]["vp"]["tkl"][1]["vs"]
	table.sort(jstream_array,comps)
	for i=1,#jstream_array do
		local jstream = jstream_array[i]
		local jsegment_array = jstream["fs"]

		local stream = {["total_bytes"]=0,["total_duration"]=0,["segment_list"]={},["bid"]="0"}
		for j=1,#jsegment_array do
			local jsegment = jsegment_array[j]
			local segment = {}
			segment["path"] = jsegment["l"]
			segment["bytes"] = jsegment["b"]
			segment["duration"] = jsegment["d"]
			stream["total_bytes"] = stream["total_bytes"] + segment["bytes"]
			stream["total_duration"] = stream["total_duration"] + segment["duration"]
			table.insert(stream["segment_list"],segment)
		end
		if jstream["bid"] ~= nil then
			stream["bid"] = jstream["bid"]
		end
		stream["subtitle_path"] = jstream["mu"]
		table.insert(resource["stream_list"],stream)

		utility.log("iqiyi", "iqiyi found:", stream.bid);
	end
	return resource
end


local function resolve_server_time()
	if iqiyi_server_time ~= nil and init_local_time ~= nil then
		return init_iqiyi_server_time + (os.time() - init_local_time)
	end

	math.randomseed( os.time() );
	local surl = "http://data.video.qiyi.com/t?tn="..math.random()
--	utility.log("surl",surl)
	local r, c, h, s,body = utility.httpget(surl,nil,USER_AGENT)

	if c ~= 200 then
		utility.log("failed:"..surl)
		return -1
	end

	local jobject = json.decode(body)
	if jobject == nil or jobject["t"] == nil then
		return -1
	end
	init_iqiyi_server_time = jobject["t"]
	init_local_time = os.time()
	return init_iqiyi_server_time
end


local function resolve_key(stime,segment_url)
--	utility.log("segment_url",segment_url)
	local spos,epos = string.find(segment_url, "/")
--	utility.log("spos",spos)
	if spos == nil then
		return ""
	end

	local path = utility.split(segment_url,"/")
	local file_name_with_ext = path[#path]
	local file_name_array = utility.split(file_name_with_ext,".")
	local file_name = file_name_array[1]
--	utility.log("file_name",file_name_with_ext,file_name)

	local sb = (math.floor(math.floor(stime/10)/60))..")(*&^flash@#$%a"..file_name

	--md5
	local lmd5
	if _VERSION == "Lua 5.2" then
		lmd5 = require("md5")
	else
		require('md5')
		lmd5 = md5
	end
	local md5str = lmd5.sumhexa(sb)
--	utility.log("md5",sb,md5str)
	return md5str
end

local function getVRSXORCode(a, b)
	local bit = require("bit")
    local n = b % 3;
    if n == 1 then
        return bit.bxor(a,121)
	end
    if n == 2 then
        return  bit.bxor(a,72)
	end
    return bit.bxor(a,103)
end

local function getVrsEncodeCode(str)
	local tmp = utility.split(str,"-")
	local bin = {}
	for k,t in pairs(tmp) do
		--print("k",string.char(tonumber(t,16)))
		local tt = t
		if #tt == 1 then
			tt = "0"..tt
		end
		 table.insert(bin,string.char(tonumber(tt,16)))
	end
	local len = #bin
	local ret = ""
	for i=1,len do
		local num = getVRSXORCode(string.byte(bin[i]),len - i)
		--print(num,string.char(tonumber(num)))
		ret = string.char(num)..ret
	end
	return ret
end


local function resolve_vod_index(from,vid,tvid,server_time,device_info)
	local resource = resolve_resource(vid,tvid)
	if resource == nil then
		return nil
	end

	local server_time = resolve_server_time()
	
	local vi = vod_index:new()
	local pi_list = {}
	local sys_os =  device_info["os"]
	for i=1,#resource["stream_list"] do
		local stream      = resource["stream_list"][i]
		local tag         = tostring(stream["bid"])
		local stream_meta = get_meta_by_stream_tag(tag)

			if tag ~= "5" or sys_os ~= "ios" then
			local type_tag    = stream_meta["type_tag"]
			local pi          = play_index:new()
			pi:set_property_kv(KEY_NAMES["from"],        from)
			pi:set_property_kv(KEY_NAMES["type_tag"],    type_tag)
			pi:set_property_kv(KEY_NAMES["description"], stream_meta["description"])
			utility.log(type_tag)

			for _,_segment in pairs(stream["segment_list"]) do
				local segment_path = utility.trim(_segment["path"])
				local spos,epos = string.find(segment_path,"/")
				if spos == 1 then
					segment_path = string.sub(segment_path,2)
				else
					segment_path = getVrsEncodeCode(segment_path)
					segment_path = string.sub(segment_path,2)
				end
				local key = resolve_key(server_time, segment_path)
				if utility.is_empty_string(key) == false and string.find(key,"/") ~= #key  then
					key = key.."/"
				end
				local fs,_ = string.find(segment_path,"-")
				local prefix_url = IQIYI_DATA_URL
				if fs ~= nil then
					prefix_url = IQIYI_DATA_URL_HD
				end
				if string.find(segment_path,"/") ~= 1 then
					segment_path = "/"..segment_path
				end
				local segment_meta_url = string.format(prefix_url.."%s%s%s",key,"videos",segment_path)
				local seg = segment:new()
				seg:set_property_kv(KEY_NAMES["duration"],_segment["duration"])
				seg:set_property_kv(KEY_NAMES["bytes"], _segment["bytes"])
				if prefix_url == IQIYI_DATA_URL_HD then
					seg:set_property_kv(KEY_NAMES["url"], segment_meta_url)
					pi:set_index_mrl(VSL_TAG,segment_meta_url)
				else
					seg:set_property_kv(KEY_NAMES["meta_url"], segment_meta_url)
					pi:set_index_mrl(VSL_TAG,vid)
				end
				pi:add_segment(seg)

				
				--pi:set_normal_mrl(segment_meta_url)
				pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
				pi:set_property_kv(KEY_NAMES["need_ringbuf"],true)
				pi:set_property_kv(KEY_NAMES["parsed_milli"],os.time() * 1000)
				pi:set_property_kv(KEY_NAMES["available_period_milli"],AVAILABLE_PERIOD_MILLI)
			end

			local meta = IQIYI_META_MAP[tostring(tag)]
			if meta == nil then
				meta = IQIYI_META_MAP["unknown"]
			end
			pi["meta"] = meta
			vi:add_play_index(pi)

			local pi_item = {
				["pi"] = pi,
				["stream_meta"] = stream_meta}
			table.insert(pi_list, pi_item)

		end
	end

	return vi, pi_list
end

function iqiyi.resolve_media_resource(resolve_params,device_info,device_rank)
	if resolve_params == nil then
		return -1
	end

	utility["logcat"] = device_info["logcat"] ~= false;

	local expected_quality  = resolve_params["expected_quality"]
	local expected_type_tag = resolve_params["expected_type_tag"]
	local from = resolve_params["from"]
	local vid = resolve_params["vid"]
	local tvid = nil
	local viurl = "http://cache.video.qiyi.com/vi/0/"..vid.."/"
	local r, c, h, s,body = utility.httpget(viurl,nil,USER_AGENT)
	if c == 200 then
		local json = require("json")
		local jobj = json.decode(body)
		if jobj ~= nil then
			tvid = jobj.tvid
		end
	end
	
	if tvid == nil then
		local weblink = resolve_params["weblink"]
		if weblink ~= nil then
			local r, c, h, s,body = utility.httpget(weblink,nil,USER_AGENT)
			if c ~= 200 then
				utility.log("failed:"..weblink)
				return nil
			end
			local _,_,_tvid = string.find(body,'data%-player%-tvid="([^"]+)"')
			tvid = _tvid
		end 
	end
	if tvid == nil then
		utility.log("====error:tvid is nil")
		return nil
	end
	local server_time = resolve_server_time()
	utility.log(server_time)
	local vi, pi_list = resolve_vod_index(from, vid, tvid, server_time,device_info)
	if vi == nil or vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)

	local selected_pi = nil
	local vl = vi[KEY_NAMES["vod_list"]]
	for i = 1,#vl do
		if expected_type_tag == vl[i][KEY_NAMES["type_tag"]] then
			selected_pi = vl[i]
			break
		end
	end

	table.sort(pi_list, function(left, right)
        if expected_quality >= 200 then
            -- high quality
            return left["stream_meta"]["order"] < right["stream_meta"]["order"]
		else
			-- low quality
			return left["stream_meta"]["order"] < right["stream_meta"]["order"]
		end
	end)

    for _, pi_item in pairs(pi_list) do
        utility.log("after sort["..expected_quality.."]: "..pi_item["stream_meta"]["name"]);
    end

	if selected_pi == nil then
		selected_pi = get_pi_by_quality(vi[KEY_NAMES["vod_list"]],resolve_params)
	end
	if selected_pi == nil then
        selected_pi = pi_list[1]["pi"];
	end
	mr:set_play_index(selected_pi)
	mr:set_resolve_params(resolve_params)

	vi:init_player_codec_config_list(device_info,device_rank) 
	local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
	utility.sort_vod_list(vl)
	local find_pi = utility.resolve_play_index(vl,resolve_params,device_info,device_rank)
	if find_pi ~= nil then
		mr:set_play_index(find_pi)
	end

	utility.log(mr:to_json())
	return mr

end

function iqiyi.resolve_segment(pi,seg,device_info)
	local seg_meta_url = seg[KEY_NAMES["meta_url"]]
	utility.log("seg_meta_url",seg_meta_url)

	if string.find(seg_meta_url,IQIYI_DATA_URL_HD) == 1 then
		seg[KEY_NAMES["url"]] = seg_meta_url
		return seg
	end

	if string.find(seg_meta_url,IQIYI_DATA_URL) ~= 1 then
		local key = resolve_key(resolve_server_time(),seg_meta_url)
		local segs = utility.split(string.gsub(seg_meta_url,IQIYI_DATA_URL,""),"/")
		local segment_path = ""
		for i=2,#segs do
			segment_path = segment_path.."/"..segs[i]
		end
		utility.log("key",key,segment_path)
		seg_meta_url = string.format(IQIYI_DATA_URL.."%s/%s",key,segment_path)
	end
	local r, c, h, s,body = utility.httpget(seg_meta_url,nil,USER_AGENT)

	if c ~= 200 then
		utility.log("failed:"..seg_meta_url)
		return -1
	end
	print(body)
	local json = require("json")
	local jobj = json.decode(body)
	seg[KEY_NAMES["url"]] = jobj["l"]

	print(jobj["l"])
	return seg
end

return iqiyi
