local utility = require("bili.utility")
require("bili.model")
local VSL_TAG = "vsl"
local letv = {}
local AVAILABLE_PERIOD_MILLI = 10800000
local LETV_SOURCE_DESCRIPTION = {["350"]="流畅",["1000"]="高清",["1300"]="超清",["720p"]="720P",["720P"]="720P",["1080p"]="1080P",["1080P"]="1080P",["unknown"]="未知"}
local LETV_SOURCE_DESCRIPTION_2 = {["9"]="350",["13"]="1000",["21"]="1300",["22"]="1300",["51"]="720p",["52"]="1080p"}
local LETV_META_MAP = {
	
	["350"] = {
 		["name"]            = "350",			 -- 源 TAG
 		["format"]			= VIDEO_FORMAT["MP4"], -- 视频封装格式
 		["video_codec"]		= "H264",			 -- 视频编码
 		["audio_codec"]		= "MP4A",			 -- 音频编码
	    ["type_tag"]        = "lua.letv.350", 	 -- 客户端 TAG
	    ["description"]     = "流畅",			 -- 描述
        ["kbps"]            = 350,				 -- 码率估算,大约是 bytes / seconds / 1000
        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
        ["order"]			= 1
	},
	["1000"] = {
 		["name"]            = "1000",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.letv.1000",
	    ["description"]     = "高清",
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 2
	},
	["1300"] = {
 		["name"]            = "1300",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.letv.1300",
	    ["description"]     = "超清",
        ["kbps"]            = 1300,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 3
	},
	["720p"] = {
 		["name"]            = "720p",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.letv.720P",
	    ["description"]     = "720P",
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},
	["720P"] = {
 		["name"]            = "720P",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.letv.720P",
	    ["description"]     = "720P",
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},
	["1080p"] = {
 		["name"]            = "1080p",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.letv.1080P",
	    ["description"]     = "1080P",
        ["kbps"]            = 2000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
		["order"]			= 5
	},
	["1080P"] = {
 		["name"]            = "1080P",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.letv.1080P",
	    ["description"]     = "1080P",
        ["kbps"]            = 2000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 5
	},
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.letv.unknown",
	    ["description"]     = "unknown",
        ["kbps"]            = -1,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= -1
	}

}

local function comps(a,b)
	local astr,bstr = string.gsub(a,"p","0"),string.gsub(b,"p","0")
	local anum = tonumber(astr)
	local bnum = tonumber(bstr)
	return anum<bnum
end

local function rotateRight(x,n)
	local bit = require("bit")
	local save
	for i = 1,n do
		save = bit.band(x,0x00000001)
		x = bit.rshift(x,1)
		save = bit.lshift(save,31)
		x = x + save
	end
	return x
end

local function getKey(value)
	local bit = require("bit")
	local key = 185025305
	local mod = key % 17
	local timeNow = value
	timeNow = rotateRight(timeNow,mod)
	local ret = bit.bxor(timeNow,key)
	return ret * 4
end

local function getTKey(t)
	local bit = require("bit")
	a = 0
	for i=1,8 do
		a = bit.band(1,t)   -- a = 1 & t
		t = bit.rshift(t,1) -- t >>= 1;
		a = bit.lshift(a,31)  --a <<= 31;
		t = t + a --t += $a;
	end
	return bit.bxor(t,185025305) --$tkey = $t^185025305;
end

-- function let_($value, $key)
-- {
-- $i = 0;
-- while ($i < $key) {
-- $value = 2147483647 & $value >> 1 | ($value & 1) << 31;
-- ++$i;
-- }
-- return $value;
-- }
-- function letu_($stime)
-- {
-- $key = 773625421;
-- $value = let_($stime, $key % 13);
-- $value = $value ^ $key;
-- $value = let_($value, $key % 17);
-- return $value;
-- }
local function getValue(value,key)
	local bit = require("bit")
	local i=0
	while i < key do
		local left_value = bit.band(2147483647, bit.rshift(value,1))
		local right_value = bit.lshift(bit.band(value,1),31)
		value = bit.bor(left_value,right_value)
		i = i + 1
	end
	return value
end

local function getTKey_new(t)
	local bit = require("bit")
	local key = 773625421
	local value = getValue(t, key%13)
	value = bit.bxor(value,key)
	value = getValue(value, key%17)
	return value
end

local function split_last(str, separator)
	local result = ""
	for i in string.gmatch(str, "[^"..separator.."]+") do
		result = i
	end
	if result == "" then
		result = str
	end
	return result
end

local function getkey_app(vid, timestamp)
	local input = vid..","..timestamp..",bh65OzqYYYmHRQ"
	local md5 = require("md5")
	return md5.sumhexa(input)
end

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

local function get_pi_by_quality(vl,quality)
	if quality >= 200 then
		q = 4
	else
		q = 1
	end
	return get_pi(vl,q)
end

local function get_result_old(body)
	local lxml
	if _VERSION == "Lua 5.2" then
		xml = require('LuaXml')
		lxml = xml
	else
		require('LuaXml')
		lxml = xml
	end

	local xfile = lxml.eval(body)
	local playurlnode = xfile:find("playurl")

	if playurlnode == nil or playurlnode[1] == nil then
		utility.log("failed")
		return nil
	end

	utility.log(playurlnode[1])
	local playurljson = json.decode(playurlnode[1])

	local dispatchjson = playurljson["dispatch"];
	if not dispatchjson then
		utility.log("failed")
		return nil
	end

	local duration = -1
	if playurljson["duration"] ~= nil then
		duration = playurljson["duration"] * 1000
	end


	local rateidtable = {}
	for k,v in pairs(dispatchjson) do
		table.insert(rateidtable,k)
	end

	table.sort(rateidtable,comps)
	for k,v in pairs(rateidtable) do
		utility.log(k,v)
	end

print("======",sstart,send)
	local result = {}
	for k,v in pairs(rateidtable) do
		local durl = {}
		local rateid= v --getrateid(rateidtable , quality)
		if rateid == nil then
			rateid = rateidtable[1]
		end
		local rurl= dispatchjson[rateid][1]
		rurl = string.gsub(rurl,"tss=ios","tss=no")
		local sstart , send = string.find(rurl,"&key=%x+")

		if sstart ~= nil then
			--rurl = string.sub(rurl,1,send)
			rurl = rurl.."&termid=1&format=0&hwtype=un&ostype=Windows7&tag=letv&sign=letv&expect=1&pay=0&rateid="..rateid
		else
			rurl = rurl.."&ctv=pc&m3v=1&termid=1&format=1&hwtype=un&ostype=Windows7&tag=letv&sign=letv&expect=3&tn="..math.random().."&pay=0&rateid="..rateid
			local r,c,h,s,body = http_utility.httpget(rurl,nil,ua) --http.request(rurl)
			local jsonstr = body

			local jsonobj = json.decode(jsonstr)
			if jsonobj == nil or jsonobj["location"] == nil then
				utility.log("failed: location not found")
				return nil
			end
			rurl = jsonobj["location"]
		end
--		utility.log(rateid,rurl)
		durl[rateid] = {["meta"]=LETV_META_MAP[rateid],["duration"]=duration,["rurl"]={rurl}}
		table.insert(result,durl)
	end


	return result
end

local function get_result_old_2(body)
	local result = {}
	local json = require("json")
	local root = json.decode(body)
	for i=1,#root.data[1].infos do
		local item = root.data[1].infos[i]
		local rateid = LETV_SOURCE_DESCRIPTION_2[tostring(item.vtype)]
		if rateid == nil then
			rateid = "unknown"
		end
		local duration = item.gdur * 1000
		local rurl = item.mainUrl.."tag=gug&format=0&expect=1"
		local durl = {}
		durl[rateid] = {["meta"]=LETV_META_MAP[rateid],["duration"]=duration,["rurl"]={rurl}}
		table.insert(result,durl)
	end
	return result
end

local function get_result_old_3(body)
	local result = {}
	local json = require("json")
	local root = json.decode(body)
	for i=1,#root.data[1].infos do
		local item = root.data[1].infos[i]
		local rateid = LETV_SOURCE_DESCRIPTION_2[tostring(item.vtype)]
		if rateid == nil then
			rateid = "unknown"
		end
		local duration = item.gdur * 1000
		local rurl = item.mainUrl.."&ctv=pc&m3v=1&termid=1&format=1&tag=letv&sign=letv&expect=3&tn="..math.random().."&pay=0&rateid="..rateid
		local r,c,h,s,body = utility.httpget(rurl,nil,ua) --http.request(rurl)
		local jsonstr = body

		local jsonobj = json.decode(jsonstr)
		if jsonobj == nil or jsonobj["location"] == nil then
			utility.log("failed: location not found")
			return nil
		end
		rurl = jsonobj["location"]
		local durl = {}
		durl[rateid] = {["meta"]=LETV_META_MAP[rateid],["duration"]=duration,["rurl"]={rurl}}
		table.insert(result,durl)
	end
	return result
end

local function get_result(body)
	local result = {}
	local json = require("json")
	local root = json.decode(body)
	local dur = tonumber(root.playurl.duration)
	local main_url = root.playurl.domain[1]
	for k,v in pairs(root.playurl.dispatch) do
		local rateid = k
		if rateid ~= "1080p" and rateid ~= "1080P" then
			local duration = dur * 1000
			local rurl = main_url..v[1].."&ctv=pc&m3v=1&termid=1&format=1&tag=letv&sign=letv&expect=3&tn="..math.random().."&pay=0&rateid="..rateid
			rurl = string.gsub(rurl,"tss=ios","tss=no")
			local r,c,h,s,body = utility.httpget(rurl,nil,ua) --http.request(rurl)
			local jsonstr = body

			local jsonobj = json.decode(jsonstr)
			if jsonobj == nil or jsonobj["location"] == nil then
				utility.log("failed: location not found")
				return nil
			end
			rurl = jsonobj["location"]
			local durl = {}
			durl[rateid] = {["meta"]=LETV_META_MAP[rateid],["duration"]=duration,["rurl"]={rurl}}
			table.insert(result,durl)		
		end
	end
	return result
end

local function get_result_app(body, ua)
	local result = {}
	local json = require("json")
	
	local root = json.decode(body)
	if root ~= nil and root.body ~= nil and root.body.videofile ~= nil then
		for k, v in pairs(root.body.videofile.infos) do
			local rateid = split_last(k, "_")
			if rateid ~= "180" and rateid ~= "1080p" and rateid ~= "1080P" then
				local rurl = v.mainUrl

				local r,c,h,s,body = utility.httpget(rurl, nil, ua)
				local jsonobj = json.decode(body)
				if jsonobj == nil or jsonobj["location"] == nil then
					utility.log("failed: location not found")
					return nil
				end
				rurl = jsonobj["location"]
				local durl = {}
				durl[rateid] = {["meta"] = LETV_META_MAP[rateid], ["rurl"] = {rurl}}
				table.insert(result, durl)
			end
		end
	end

	return result
end

local function getmid_app(vid, timestamp, ua)
	local mmsid = nil
	local json = require("json")

	local api_url = "http://api.mob.app.letv.com/play"
	api_url = api_url.."?vid="..vid
	api_url = api_url.."&tm="..timestamp
	api_url = api_url.."&playid=0&tss=no&pcode=010110216&version=5.8.3"
	
	local r,c,h,s,body = utility.httpget(api_url, nil, ua)

	local root = json.decode(body)
	if root ~= nil and root.body ~= nil then
		if root.body.videoInfo ~= nil then
			mmsid = root.body.videoInfo["mid"]
		elseif root.body.videofile ~= nil then
			mmsid = root.body.videofile["mmsid"]
		else
			mmsid = ""
		end
	end
	
	return mmsid
end

local function getplayurl_app(vid, quality)
	local json = require("json")

	local ua = "Mozilla/5.0 (iPad; CPU OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4"

	math.randomseed(os.time())
	local surl = "http://api.letv.com/time?tn="..math.random()
	local r,c,h,s,body = utility.httpget(surl, nil, ua)
	if c ~= 200 then
		utility.log("Get server time failed: "..surl)
		return nil
	end

	local stime = json.decode(body)["stime"]
	local mmsid = getmid_app(vid, stime, ua)
	local key = getkey_app(mmsid, stime)

	local api_url = "http://dynamic.app.m.letv.com/android/dynamic.php?mod=minfo&ctl=videofile&act=index"
	api_url = api_url.."&mmsid="..mmsid
	api_url = api_url.."&playid=2&tss=no&tm="..stime
	api_url = api_url.."&key="..key
	api_url = api_url.."&pcode=010110216&version=5.8.3&levelType=1"
	
	r,c,h,s,body = utility.httpget(api_url, nil, ua)
	return get_result_app(body, ua);
end

local function get_content(url)
	local r,c,h,s,body = utility.httpget(url,nil,USER_AGENT)

	if c ~= 200 then
		utility.log("failed:"..url,c,body,s,h.url)
		return nil
	end
	return body
end

local function getplayurl(vid,quality,device_info)

	--local http_utility = utility --require "bili.http_utility"
	local json = require("json")

	local ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.78.2 (KHTML, like Gecko) Version/7.0.6 Safari/537.78.2"
	if device_info ~= nil and device_info["ua"] ~= nil then
		ua = device_info["ua"]
	end

	math.randomseed( os.time() );
	local surl = "http://api.letv.com/time?tn="..math.random()
	utility.log("surl",surl)
	local r, c, h, s,body = utility.httpget(surl,nil,ua)

	if c ~= 200 then
		utility.log("failed:"..surl)
		return nil
	end

	local stime = json.decode(body)["stime"]
	utility.log(stime)

	local tkey = getTKey_new(stime)
	utility.log(tkey)

	--local apiurl = "http://api.letv.com/mms/out/video/play?id="..vid.."&platid=1&splatid=101&format=1&tkey="..tkey.."&domain=http%3A%2F%2Fwww.letv.com"
	--local apiurl = "http://api.letv.com/api/geturl?platid=3&splatid=301&playid=0&vtype=9,13,22,51&version=2.0&tss=no&vid="..vid.."&tkey="..tkey.."&retry=0"
	--local apiurl = "http://api.letv.com/mms/out/video/playJson?id="..vid.."&platid=1&splatid=101&format=1&tkey="..tkey.."&domain=http%3A%2F%2Fwww.letv.com"
	--local apiurl = "http://api.letv.com/mms/out/video/playJson?id="..vid.."&platid=1&splatid=101&format=1&tkey="..tkey.."&domain=www.letv.com"
	local apiurl = "http://api.letv.com/mms/out/video/playJson?id="..vid.."&platid=1&splatid=101&format=1&tkey="..tkey.."&domain=www.letv.com"

	utility.log("api_url",apiurl)
	local body = get_content(apiurl)

	return get_result(body)
end

function letv.resolve_segment(pi, seg, device_info)

end

function letv.resolve_media_resource(resolve_params,device_info,device_rank)
	if resolve_params == nil then
		return -1
	end

	--resolve vod index
	local durls = getplayurl_app(resolve_params["vid"],resolve_params["expected_quality"],device_info)
	local json = require("json")
	local djson = json.encode(durls)
	if djson == nil or #djson == 0 then
		return nil
	end
	--print(djson)
	local vi = vod_index:new()
	local selected_pi
	local expected_type_tag = resolve_params["expected_type_tag"]
	for k,v in pairs(durls) do
		local pi = play_index:new()
		for tag,vinfo in pairs(v) do
			local first_seg
			for i=1,#vinfo["rurl"] do
				local seg = segment:new()
				seg:set_property_kv(KEY_NAMES["duration"],vinfo["duration"])
				seg:set_property_kv(KEY_NAMES["url"],vinfo["rurl"][i])
				--table.insert(sl,seg)
				pi:add_segment(seg)
				if first_seg == nil then
					first_seg = seg
				end
			end
			pi:set_property_kv(KEY_NAMES["from"],resolve_params[KEY_NAMES["from"]])
			local type_tag = "lua."..resolve_params[KEY_NAMES["from"]].."."..tag
			local meta = vinfo["meta"]
			if meta ~= nil then
				type_tag = meta["type_tag"]
			end 
			pi["meta"]=meta
			pi:set_property_kv(KEY_NAMES["type_tag"],type_tag)
			local description = nil
			if meta ~= nil then
				description = meta["description"]
			end
			if description == nil then
				description = LETV_SOURCE_DESCRIPTION["unknown"]
			end
			pi:set_property_kv(KEY_NAMES["description"],description)
			pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
			pi:set_property_kv(KEY_NAMES["available_period_milli"], AVAILABLE_PERIOD_MILLI)
			pi:set_property_kv(KEY_NAMES["parsed_milli"], os.time() * 1000)
			if first_seg ~= nil then
				pi:set_index_mrl(VSL_TAG,first_seg["url"])
				pi:set_normal_mrl(first_seg["url"])
			end
		end
		if expected_type_tag ~= nil and  expected_type_tag == pi["type_tag"]  then
			selected_pi = pi
		end
		vi:add_play_index(pi)
	end

	if expected_type_tag ~= nil and selected_pi == nil then
		return nil
	end

	if vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)
	local curr_pi = selected_pi
	if curr_pi == nil then
		local vl = vi[KEY_NAMES["vod_list"]]
		utility.sort_vod_list(vl)
		curr_pi = get_pi_by_quality(vi[KEY_NAMES["vod_list"]],resolve_params["expected_quality"])
	end
	mr:set_play_index(curr_pi)
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

return letv
-- arg[1] video info json
--local videoinfojson = "{\"play\":\"194092\",\"review\":\"1267\",\"video_review\":\"44776\",\"favorites\":\"948\",\"title\":\"\\u3010\\u5b8c\\u7ed3\/1\\u6708\\u3011 \\u4e2d\\u4e8c\\u75c5\\u4e5f\\u8981\\u8c08\\u604b\\u7231\\uff01\\u604b 12\",\"description\":\" (\\uff40\\u30fb\\u03c9\\u30fb\\u00b4)(^\\u30fb\\u03c9\\u30fb^ )\",\"tag\":\"\\u4e2d\\u4e8c\\u75c5\\u4e5f\\u8981\\u8c08\\u604b\\u7231,\\u5b8c\\u7ed3\\u6492\\u82b1,NTR,\\u8bda\\u54e5\\u8981\\u5e78\\u798f,\\u5b8c\\u7ed3\\u6492\\u82b1\\u2606*:.\\uff61. \\\\(\\u00b0\\u2200\\u00b0)\/ .\\uff61.:*\\u2606,\\u5b8c\\u7ed3\\uff01,\\u68ee\\u51f8\",\"pic\":\"http:\/\/i0.hdslb.com\/u_f\/7037fc28de020747dd7c4c9af0cce27a.jpg\",\"author\":\"\\u642c\",\"mid\":\"928123\",\"pages\":\"2\",\"instant_server\":\"chat.bilibili.tv\",\"created_at\":\"2014-03-27 11:23\",\"credit\":\"3280\",\"coins\":\"923\",\"spid\":5691,\"src\":\"c\",\"season_id\":705,\"season_index\":\"12\",\"list\":{\"0\":{\"page\":1,\"type\":\"sohu\",\"vid\":\"6282932|1688350\",\"part\":\"1\",\"cid\":1492050,\"has_alias\":false},\"1\":{\"page\":2,\"type\":\"sina\",\"part\":\"2\",\"cid\":1490283}}}"
-- arg[2]
-- arg[3] device info json
--local deviceinfojson = "{\"user-agent\":\"abc\"}"
--letv.getplayurl("20055264",0)
