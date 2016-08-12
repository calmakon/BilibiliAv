local utility = require("bili.utility")
require("bili.model")
local VSL_TAG = "vsl"
local PI_BILI_API_FROM_FMT_1 = "lua.%s.bapi.1"
local PI_BILI_API_FROM_FMT_2 = "lua.%s.bapi.2"
local PI_BILI_API_FROM_FMT_9 = "lua.%s.bapi.9"
local PI_BILI_API_DESCRIPTION_1 = "流畅"
local PI_BILI_API_DESCRIPTION_2 = "高清"
local PI_BILI_API_DESCRIPTION_9 = "超清"

local PI_BILI_API_FROM_FMT_LIVE_1 = "lua.live.bapi.live1"
local PI_BILI_API_FROM_FMT_LIVE_2 = "lua.live.bapi.live2"
local PI_BILI_API_FROM_FMT_LIVE_4 = "lua.live.bapi.live4"
local PI_BILI_API_FROM_FMT_LIVE_5 = "lua.live.bapi.live5"
local PI_BILI_API_DESCRIPTION_LIVE_1 = "高清"
local PI_BILI_API_DESCRIPTION_LIVE_2 = "高清"
local PI_BILI_API_DESCRIPTION_LIVE_3 = "超清"
local PI_BILI_API_DESCRIPTION_LIVE_4 = "超清"

local biliapi = {}
local AVAILABLE_PERIOD_MILLI = 3600000
local BILIAPI_SOURCE_DESCRIPTION = {["1"]="流畅",["2"]="高清",["3"]="高清",["unknown"]="未知"}
local BILIAPI_META_MAP = {

	["1"] = {
 		["name"]            = "1",			     -- 源 TAG
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.1", -- 客户端 TAG
	    ["description"]     = "流畅",			 -- 描述
        ["kbps"]            = 350,				 -- 码率估算,大约是 bytes / seconds / 1000
        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
        ["order"]			= 1				 	 -- 排序
	},
	["2"] = {
 		["name"]            = "2",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.2",
	    ["description"]     = "高清",
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 2
	},
	["3"] = {
 		["name"]            = "3",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.2",
	    ["description"]     = "高清",
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 3
	},
	["live1"] = {
 		["name"]            = "live1",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.live1",
	    ["description"]     = PI_BILI_API_DESCRIPTION_LIVE_1,
        ["kbps"]            = 650,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},
	["live2"] = {
 		["name"]            = "live2",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.live2",
	    ["description"]     = PI_BILI_API_DESCRIPTION_LIVE_2,
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 5
	},
	["live3"] = {
 		["name"]            = "live3",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.live3",
	    ["description"]     = PI_BILI_API_DESCRIPTION_LIVE_3,
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 6
	},
	["live4"] = {
 		["name"]            = "live4",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.live4",
	    ["description"]     = PI_BILI_API_DESCRIPTION_LIVE_4,
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 7
	},
	["9"] = {
 		["name"]            = "9",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.%s.bapi.9",
	    ["description"]     = PI_BILI_API_DESCRIPTION_9,
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 9
	},
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.%s.bapi.unknown",
	    ["description"]     = "unknown",
        ["kbps"]            = -1,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	}

}

local LOW_QUAILTIY_FLV_ROOM_IDS = {}
--1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,5151,5152,5153,5154,5155,5156,5157,5158,5159,5160,5161,5162,5163,5164,5165,5166,5167,5168,5169,5170,5171,5172,5173,5174,5175,5176,5177,5178,5179,5180,5220,5221,5222,5223,5224,5225,5226,5227,5228,5229,5230,5231,5232,5233,5234,5235,5236,5237,5238,5239,5240,5241,5242,5243,5244,5245,5246,5247,5248,5249,5250,5251,5252,5253,5254,5255,5256,5257,5258,5259


local function append_bili_api_pi_live(vod_list,description,from_fmt,quality)
	local pi = vod_list[1]
	local new_pi = play_index:new()
	new_pi:set_property(pi)
	local from = pi[KEY_NAMES["from"]]
	local tag = string.format(from_fmt,from)
	
	new_pi:set_property_kv(KEY_NAMES["from"],     tag)
    new_pi:set_property_kv(KEY_NAMES["type_tag"], tag)
	new_pi:set_property_kv(KEY_NAMES["description"], description)
	new_pi:set_property_kv(KEY_NAMES["is_resolved"], false)
    -- newpi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
    new_pi:remove_property(KEY_NAMES["need_ringbuf"])
    new_pi:remove_property(KEY_NAMES["parsed_milli"])
    new_pi:remove_property(KEY_NAMES["available_period_milli"])

    local meta = BILIAPI_META_MAP[tostring(quality)]
	if meta == nil then
		meta = BILIAPI_META_MAP["unknown"]
	end
	new_pi["meta"] = meta
	table.insert(vod_list,new_pi)
end


local function append_bili_api_pi(vod_list,description,from_fmt,quality)
	local pi = vod_list[1]
	local new_pi = play_index:new()
	new_pi:set_property(pi)
	local from = pi[KEY_NAMES["from"]]
	local vtype = "flv"
	if from ~= "youku" and quality ~= 2 then
		vtype = "mp4"
	elseif from == "vupload" then
		vtype = "mp4"
	end
	local tag = string.format(from_fmt,vtype)
	new_pi:set_property_kv(KEY_NAMES["from"],     tag)
    new_pi:set_property_kv(KEY_NAMES["type_tag"], tag)
	new_pi:set_property_kv(KEY_NAMES["description"], description)
	new_pi:set_property_kv(KEY_NAMES["is_resolved"], false)
    -- newpi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
    new_pi:remove_property(KEY_NAMES["need_ringbuf"])
    new_pi:remove_property(KEY_NAMES["parsed_milli"])
    new_pi:remove_property(KEY_NAMES["available_period_milli"])

    local meta = BILIAPI_META_MAP[tostring(quality)]
	if meta == nil then
		meta = BILIAPI_META_MAP["unknown"]
	end
	new_pi["meta"] = meta

	table.insert(vod_list,new_pi)
end

function key_sort(a,b)	
	--print(a,b)
	return b > a
end

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


function biliapi.resolve_segment(pi, seg, device_info)

end

local function gets(params, key)
	local keyset = {}
	local i = 0
	for k,v in pairs(params) do
		i = i + 1
		keyset[i] = k
	end
	table.sort(keyset, key_sort)
	local data = ""
	for k,v in pairs(keyset) do
		if data == "" then
			data = data..v.."="..encodeURI(params[v])
		else
			data = data.."&"..v.."="..encodeURI(params[v])
		end
	end

	--md5
	local lmd5
	if _VERSION == "Lua 5.2" then
		lmd5 = require("md5")
	else
		require('md5')
		lmd5 = md5
	end
	local md5str = lmd5.sumhexa(data..key)
	return md5str
end

function biliapi.getplayurl(resolve_params,cid,from,qtag,device_info,resolve_bili_cdn_play,device_rank,accept_format,ts,access_token)
	local json = require("json")
	local platform = ""
	local quality = qtag
-- 	f3bb208b3d081dc8   0-3
-- 4fa4601d1caa8b48    4-7
-- 452d3958f048c02a    8-11
-- 86385cdc024c0f6c     12-15
-- 5256c25b71989747   16-19
-- e97210393ad42219   20-23
	-- local ts = utility.ch_relat()
	

	
	local h = math.ceil(tonumber(os.date('%H', ts))/4);
	local ak = utility.get_tv_box_m()[h]
	if ak == nil then
		ak = utility.get_tv_box_m()[1]
	end
	ak = utility.concat(ak)
	if qtag == "9" or qtag == 9 then
		quality = 3
		accept_format = "flv"
	elseif qtag == "live2" then
		quality = 2
	elseif from == "sina" or from == "youku" then
		if quality == 3 then
			quality = 2
		end
	elseif qtag == "live1" or qtag == "live3" or qtag == "live4" or qtag == "live5" then
		quality = 4
	end

	local params = {["cid"]=cid,["quality"]=quality,["appkey"]=ak}
	if device_info ~= nil then
		local djson = device_info
		if djson["os"] ~= nil then
			params["platform"] = "android"
			platform = "platform=android&"

				params["platform"] = djson["os"]
				platform = "platform="..djson["os"].."&"

				if djson["app_version_code"] ~= nil then
					params["_appver"] = device_info["app_version_code"]
					platform = platform.."_appver="..device_info["app_version_code"].."&"
				end
				if djson["buvid"] ~= nil and #djson["buvid"] < 64 then
					params["_buvid"] = device_info["buvid"]
					platform = platform.."_buvid="..device_info["buvid"].."&"
				end

			if djson["device_type"] ~= nil then
				params["_device"] = device_info["device_type"];
				platform = platform.."_device="..device_info["device_type"].."&"
			end
			if djson["device_id_16"] ~= nil then
				params["_hwid"] = device_info["device_id_16"];
				platform = platform.."_hwid="..device_info["device_id_16"].."&"
			end
			if djson["device_rank"] ~= nil then
				params["_ulv"] = device_info["device_rank"];
				platform = platform.."_ulv="..device_info["device_rank"].."&"
			end
		end
	end
	-- local r = ""
	-- local s = {60037,50330,194259,46576,"255610",275958,"142772","63840"}
	-- for i=1,#s do r = r..string.format("%x", tonumber(s[i])/i);end
	local r = utility.check_tv_box(149098444, "8e3")
	local lmd5
	if _VERSION == "Lua 5.2" then
		lmd5 = require("md5")
	else
		require('md5')
		lmd5 = md5
	end
	local md5str = lmd5.sumhexa(r).."BlUa"
	r = lmd5.sumhexa(md5str)

	if resolve_params ~= nil then
		if resolve_params["avid"] ~= nil then
			params["_aid"] = resolve_params["avid"]
			platform = platform.."_aid="..resolve_params["avid"].."&"
		end
		if resolve_params["tid"] ~= nil then
			params["_tid"] = resolve_params["tid"]
			platform = platform.."_tid="..resolve_params["tid"].."&"
		end
		if resolve_params["page"] ~= nil then
			params["_p"] = resolve_params["page"]
			platform = platform.."_p="..resolve_params["page"].."&"
		end
		if resolve_params["request_from_downloader"] ~= nil then
			if (device_info["request_from_downloader"] == true or device_info["request_from_downloader"] == "true") then
				params["_down"] = "1"
				platform = platform.."_down=1&"
			else
				params["_down"] = "0"
				platform = platform.."_down=0&"
			end
		end
	end
	local api_url = ""
	if from == "live" then
		api_url = "http://live.bilibili.com/api/playurl?"
	else
		api_url = "http://interface.bilibili.com/playurl?"
	end
	if access_token ~= nil and access_token["access_key"] ~= nil and #access_token["access_key"] >0 and access_token["mid"] ~= nil then
		params["access_key"] = access_token["access_key"]
		platform = platform.."access_key="..params["access_key"].."&"
		params["mid"] = access_token["mid"]
		platform = platform.."mid="..params["mid"].."&"
	end
	params["otype"] = "json"
	api_url = api_url..platform.."cid="..cid.."&quality="..quality.."&otype=json&appkey="..params["appkey"]
-- print(api_url)
	local live_codec_mode = nil
	if device_rank ~= nil and device_rank["live_codec_mode"] ~= nil then
		live_codec_mode = device_rank["live_codec_mode"]
	end
	if from == "live" and qtag ~= "live4" and qtag ~= "live1" then
		params["type"] = "rtmp"
		api_url = api_url.."&type=rtmp"
	elseif accept_format == "flv" then

	elseif from == "sina" and quality == 2 then
		params["type"] = "flv"
		api_url = api_url.."&type=flv"
	elseif from ~= "youku" and quality ~= 3 then
		params["type"] = "mp4"
		api_url = api_url.."&type=mp4"
	elseif from == "vupload" then
		params["type"] = "mp4"
		api_url = api_url.."&type=mp4"
	end
	if resolve_bili_cdn_play == true then
		params["accel"] = 1
		api_url = api_url.."&accel=1"
	end
	sign = gets(params,r)
	api_url = api_url.."&sign="..sign
	local r, c, h, s,body = utility.httpget(api_url,nil,USER_AGENT)
-- print(api_url,c, body, "========\n")
	if c ~= 200 or body == nil or string.find(body,"<result>error</result>") then
		utility.log("failed:"..api_url)
		return nil
	end

	-- utility.log("api",api_url,body)

	local jobj = json.decode(body)
	if (jobj ~= nil or jobj["durl"] == nil or jobj["durl"] == "" or #jobj["durl"] == 0) and accept_format == nil and from == "vupload" and quality == 3 and jobj["format"] ~= "hdmp4" then
		return biliapi.getplayurl(resolve_params,cid,from,quality,device_info,resolve_bili_cdn_play,device_rank,"flv",ts,access_token)
	end

	if jobj == nil or jobj["durl"] == nil then
		return nil
	end
	local other_quality = jobj["accept_quality"]
	if other_quality == nil then
		other_quality = {4}
	end
	if utility.contains(other_quality, quality) == false then
		quality = 4
	end
	utility.remove(other_quality, quality)
	-- print(json.encode(other_quality), quality, "----==")

	local hdtag = "hd.mp4?expires"
	local durl = jobj["durl"]
	for j=1,#durl do
		local returl = durl[j]["url"]
		if quality ~= 2 and (returl== nil or string.find(returl,hdtag)) then
			local backup_urls = durl[j]["backup_url"]
			if backup_urls ~= nil and #backup_urls>0 then
				for i=1,#backup_urls do
					if not string.find(backup_urls[i],hdtag) then
						durl[j]["url"] = backup_urls[i]
						break
					end
				end
			end
		end
	end

	return durl,quality,other_quality
end

local function get_qtag_by_quality(resolve_params,device_info,device_rank)

	local expected_type_tag = resolve_params["expected_type_tag"]
	local expected_quality =  resolve_params["expected_quality"]

	local quality = expected_quality
	if expected_type_tag ~= nil then
		local arr = utility.split(expected_type_tag,".")
		if arr[1] == "lua" then
			local q1 = tonumber(arr[#arr])
			if q1 == 2 then
				quality = 200
			elseif q1 == 9 then
				return 9
			else
				quality = 100
			end
		end
	end

	if expected_type_tag ~= nil then
		if quality == 0 then
			if device_info["sh"] > 540 then
				return 3
			else
				return 1
			end
		else
			if quality >= 200 then
				return 3
			else
				return 1
			end
		end
	else
		if expected_quality == 0 then
			if device_rank ~= nil then
				local sh = 720
				if device_info["sw"] ~= nil and device_info["sh"] ~= nil then
					sh = math.min(device_info["sw"],device_info["sh"])
				end
				if sh >= 720  then
					return 3
				else
					return 1
				end
			else
				return 1
			end
		else
			if expected_quality >= 400 then
				return 9
			elseif expected_quality >= 200 then
				return 3
			else
				return 1
			end
		end
	end

	return 1
end

local function get_live_qtag_by_quality(resolve_params,device_info,device_rank)
	local expected_type_tag = resolve_params["expected_type_tag"]
	local expected_quality =  resolve_params["expected_quality"]

	if expected_type_tag ~= nil then
		local arr = utility.split(expected_type_tag,".")
		if arr[1] == "lua" then
			local qtag = arr[#arr]
			if string.find(qtag, "live") ~= nil and string.find(qtag, "live") > 0 then
				return qtag
			end
		end
	end

	if expected_type_tag == nil and expected_quality ~= nil and expected_quality > 0 then
		if expected_quality <= 100 then
			return "live2"
		else
			return "live4"
		end
	end

	local sh = 720
	if device_info["sw"] ~= nil and device_info["sh"] ~= nil then
		sh = math.min(device_info["sw"],device_info["sh"])
	end
	if sh < 720  then
		return "live2"
	end

	return "live4"
end

function biliapi.resolve_media_resource(resolve_params,device_info,device_rank,access_token)
	if resolve_params == nil then
		return -1
	end

	--resolve vod index
	local expected_type_tag = resolve_params["expected_type_tag"]
	local expected_quality = resolve_params["expected_quality"]

	-- print("expected_quality1",expected_quality, "expected_type_tag", expected_type_tag)
	local from = resolve_params[KEY_NAMES["from"]]
	local qtag = nil
	if from == "live" then
		qtag = get_live_qtag_by_quality(resolve_params,device_info,device_rank)
	else
		qtag = get_qtag_by_quality(resolve_params,device_info,device_rank)
	end
	print("qtag",qtag)
	local ts = os.time()
	local r, c, h, s,body = utility.httpget(utility.concat("687474703A2F2F696E746572666163652E62696C6962696C692E636E2F736572766572646174652E6A733F74733D31"),nil,USER_AGENT)
	if c == 200 and body ~= nil then
		ts = tonumber(body)
	end
	local durls,quality,other_quality = biliapi.getplayurl(resolve_params,resolve_params["cid"],resolve_params["from"], qtag, device_info,resolve_params["resolve_bili_cdn_play"],device_rank,"mp4",ts,access_token)
	if durls == nil then
		return nil
	end
	local json = require("json")
	local djson = json.encode(durls)
	if djson == nil or #djson == 0 then
		return nil
	end
	local vi = vod_index:new()
	local pi = play_index:new()
	local selected_pi = pi
	if durls["order"] ~= nil then
		durls = {[1]=durls}
	end
	for i=1,#durls do
		local durl = durls[i]
		local seg = segment:new()
		local url = durl["url"]
		if url == nil and durl["application"] ~= nil and durl["name"] ~= nil then
			url = durl["application"].."/"..durl["name"]
		end
		seg:set_property_kv(KEY_NAMES["url"],url)
		seg:set_property_kv(KEY_NAMES["bytes"],durl["size"])
		seg:set_property_kv(KEY_NAMES["duration"],durl["length"])
		seg:set_property_kv(KEY_NAMES["backup_urls"],durl["backup_url"])
		pi:add_segment(seg)
	end

	
	pi:set_property_kv(KEY_NAMES["from"],from)
	local from = resolve_params[KEY_NAMES["from"]]
	local vtype = "flv"
	if from ~= "youku" and qtag ~= 2 then
		vtype = "mp4"
	elseif from == "vupload" then
		vtype = "mp4"
	end
	local ttag = qtag
	local meta = BILIAPI_META_MAP[tostring(ttag)]
	if meta == nil then
		meta = BILIAPI_META_MAP["unknown"]
	end
	local type_tag = string.format(meta["type_tag"],vtype) --"lua."..vtype..".bapi."..qtag
	pi:set_property_kv(KEY_NAMES["type_tag"],type_tag)
	pi["meta"] = meta
	local description = meta["description"] --BILIAPI_SOURCE_DESCRIPTION[tostring(qtag)]
	if description == nil then
		description = BILIAPI_SOURCE_DESCRIPTION["unknown"]
	end
	
	pi:set_property_kv(KEY_NAMES["description"],description)
	pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
	pi:set_property_kv(KEY_NAMES["need_ringbuf"],true)
	pi:set_property_kv(KEY_NAMES["parsed_milli"], os.time() * 1000)
	pi:set_property_kv(KEY_NAMES["available_period_milli"], AVAILABLE_PERIOD_MILLI)
	local first_seg = pi["segment_list"][1]
	if first_seg ~= nil then
		pi:set_index_mrl(VSL_TAG,first_seg["url"])
		if #pi["segment_list"] == 1 then
			pi:set_normal_mrl(first_seg["url"])
		end
	end

	if expected_type_tag ~= nil and selected_pi == nil then
		return nil
	end

	vi:add_play_index(pi)

	if vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)
	local curr_pi = selected_pi
	mr:set_play_index(curr_pi)
	mr:set_resolve_params(resolve_params)

	if from == "live" then
		vi:init_live_player_codec_config_list(device_info,device_rank,first_seg["url"])
	else
		vi:init_player_codec_config_list(device_info,device_rank)
	end
	if from ~= "live" then
		if qtag == 1 then
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_2,PI_BILI_API_FROM_FMT_2,2)
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_9,PI_BILI_API_FROM_FMT_9,9)
		elseif qtag == 9 then
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_1,PI_BILI_API_FROM_FMT_1,1)
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_2,PI_BILI_API_FROM_FMT_2,2)
		else
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_1,PI_BILI_API_FROM_FMT_1,1)
			append_bili_api_pi(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_9,PI_BILI_API_FROM_FMT_9,9)
		end
	else
		-- if expected_type_tag ~= nil and (qtag == "live1" or qtag == "live4") then
		-- 	curr_pi:set_property_kv(KEY_NAMES["description"],BILIAPI_META_MAP[qtag][KEY_NAMES["description"]])
		-- 	if room_id ~= nil then
		-- 		append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_5,PI_BILI_API_FROM_FMT_LIVE_5,"live5")
		-- 	end
		-- elseif qtag == "live1" and is_low_quaility == false then
		-- 	-- 修改curr_pi
		-- 	curr_pi:set_property_kv(KEY_NAMES["description"],PI_BILI_API_DESCRIPTION_LIVE_5)
		-- 	qtag = "live5"
		-- 	curr_pi["meta"] = BILIAPI_META_MAP[tostring(qtag)]
		-- 	if room_id ~= nil then
		-- 		append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_4,PI_BILI_API_FROM_FMT_LIVE_4,"live4")
		-- 	end
		-- elseif is_low_quaility == true or qtag == "live4" then
		-- 	append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_5,PI_BILI_API_FROM_FMT_LIVE_5,"live5")
		-- else
		-- 	if room_id ~= nil then
		-- 		append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_1,PI_BILI_API_FROM_FMT_LIVE_1,"live1")
		-- 	end
		-- end
		if quality == 2 then
			curr_pi:set_property_kv(KEY_NAMES["description"],PI_BILI_API_DESCRIPTION_LIVE_2)
			qtag = "live2"
			curr_pi["meta"] = BILIAPI_META_MAP[tostring(qtag)]
		else
			curr_pi:set_property_kv(KEY_NAMES["description"],PI_BILI_API_DESCRIPTION_LIVE_4)
			qtag = "live4"
			curr_pi["meta"] = BILIAPI_META_MAP[tostring(qtag)]
		end
		curr_pi:set_property_kv(KEY_NAMES["type_tag"], string.format(curr_pi["meta"]["type_tag"], "flv"))
		if #other_quality > 0 then
			for i=1,#other_quality do
				local qa = other_quality[i]
				if qa == 2 then
					append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_2,PI_BILI_API_FROM_FMT_LIVE_2,"live2")
				else
					append_bili_api_pi_live(vi[KEY_NAMES["vod_list"]],PI_BILI_API_DESCRIPTION_LIVE_4,PI_BILI_API_FROM_FMT_LIVE_4,"live4")	
				end
			end
		end
	end
	
	local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
	utility.sort_vod_list(vl)

	--print("mr=========",#mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]])
	
	utility.log(mr:to_json())
	return mr
end

return biliapi
