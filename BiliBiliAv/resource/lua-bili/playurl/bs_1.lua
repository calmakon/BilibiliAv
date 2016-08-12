local sohu = {}
local AVAILABLE_PERIOD_MILLI = 43200000
local SOHU_SOURCE_DESCRIPTION = {["high"]="高清",["super"]="超清"}
local SOHU_META_MAP = {
		["high"] = {
 		["name"]            = "high",			     -- 源 TAG
	    ["type_tag"]        = "lua.sohu.high", -- 客户端 TAG
	    ["description"]     = "高清",			 -- 描述
        ["kbps"]            = 500,				 -- 码率估算,大约是 bytes / seconds / 1000
        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
        ["order"]			= 1
	},		
	["super"] = {
 		["name"]            = "super",
	    ["type_tag"]        = "lua.sohu.super",
	    ["description"]     = "超清",
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 2
	},		
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.sohu.unknown",
	    ["description"]     = "超清",
        ["kbps"]            = -1,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 3
	}
}
local utility = require("bili.utility")
local VSL_TAG = "vsl"
local API_KEY = "9854b2afa779e1a6bff1962447a09dbd"
local PLATFORM = "6"
local SVER = "4.0.2"
local PARTNER = "2"
local PREFIX_URL = "url_"
local PREFIX_CLIPS_BYTES = "clips_bytes_"
local PREFIX_CLIPS_DURATION = "clips_duration_"
local USER_AGENT = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)"

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
	local q = 1
	if quality >= 200 then
		q = 2
	end
	return get_pi(vl,q)
end


function sohu.resolve_media_resource(resolve_params,device_info,device_rank)
	if resolve_params == nil then
		return -1
	end
	local ua = USER_AGENT
	local raw_vid = resolve_params["raw_vid"]
	local ids = utility.split(raw_vid,"|")
	local vid = ids[2]
	local aid = ids[1]
	-- 1 480P 2 352P 21 720P
	local json = require("json")
	require("bili.model")
	local vi = vod_index:new()
	local expected_quality = resolve_params[KEY_NAMES["expected_quality"]]
	local expected_type_tag = resolve_params[KEY_NAMES["expected_type_tag"]]
	local expected_pi
	for k,v in pairs(SOHU_SOURCE_DESCRIPTION) do
		local ver = 1
		if k == "super" then
			ver = 21
		end
		local api_url = string.format("http://hot.vrs.sohu.com/vrs_flash.action?vid=%s&ver=%s&ref=0001", vid, ver)
		-- http://my.tv.sohu.com/play/videonew.do?vid=81006360_1&plid=9044043&uid=14051627022704132424&authorId=264365297&out=0&g=8&referer=http%3A//my.tv.sohu.com/pl/9044043/81006360.shtml&t=0.7323659029789269
		if #ids >= 3 and ids[3] == "ugc" then
			api_url = string.format("http://my.tv.sohu.com/play/videonew.do?vid=%s_%s&plid=%s", vid, ver, aid)
		end
		utility.log(api_url)
		local r, c, h, s,body = utility.httpget(api_url,nil, ua)
		if c ~= 200 then
			return nil
		end

		local jobject = json.decode(body)
		if jobject == nil then
			return nil
		end

		-- no 'data'!
		local data = jobject["data"]

		if data == json.util.null then
			return nil
		end
		local pi = play_index:new()
		pi:set_property_kv(KEY_NAMES["from"],resolve_params[KEY_NAMES["from"]])
		local meta = SOHU_META_MAP[k]
		if meta == nil then
			meta = SOHU_META_MAP["unknown"]
		end
		pi["meta"] = meta
		local type_tag = meta["type_tag"]--"lua."..resolve_params[KEY_NAMES["from"]].."."..k
		pi:set_property_kv(KEY_NAMES["type_tag"],type_tag)
		local description = meta["description"]--SOHU_SOURCE_DESCRIPTION[tostring(definition)]
		pi:set_property_kv(KEY_NAMES["description"],description)
		if ua ~= nil then
			pi:set_property_kv(KEY_NAMES["user_agent"],ua)
		end
		pi:set_property_kv(KEY_NAMES["need_ringbuf"],true)
		pi:set_property_kv(KEY_NAMES["available_period_milli"], AVAILABLE_PERIOD_MILLI)
		pi:set_property_kv(KEY_NAMES["parsed_milli"], os.time() * 1000)
		local su = data["su"]
		local ck = data["ck"]
		local clips_bytes = data["clipsBytes"]
		local clips_durations = data["clipsDuration"]
		if su == nil or #su == 0 then
			return nil
		end
		local first_seg
		for i = 1,#su do
			-- http://101.227.173.62/cdnList?new=/74/180/SefxfR8Io9itQks2kdz17B.mp4&vid=81006360_1&uid=14051627022704132424&tvid=81006360&ch=pgc&sz=1265_446&md=CJbYRqj4wabZqNrzFTS+piCvPu5s3937VqzLlg==156&prod=flash&pt=1&uuid=261addb4-baa1-faed-13a6-fce76407360d&ugu=264365297&ugcode=MT2tMCrLfo9tT-6s2c9sTmDaqWykewvmMN3tc-fmQz16Zbi9oqFKfM_U9eqpYt7dv-TUi_vxu24oqCnI3Vt7Y0JPU9aZyw9BUlN4
			local p2purl = string.format("http://%s/p2p?new=%s&num=%s&key=%s", jobject["allot"], su[i], i, ck[i])
			-- if #ids >= 3 then
			-- 	p2purl = string.format("http://%s/cdnList?new=%s&vid=%s_%s&tvid=%s&ch=pgc", jobject["allot"], su[i], vid, ver, vid)
			-- end
			local duration = clips_durations[i] * 1000
			local seg = segment:new()
			-- print(p2purl)
			seg:set_property_kv(KEY_NAMES["meta_url"],p2purl)
			seg:set_property_kv(KEY_NAMES["bytes"],clips_bytes[i])
			seg:set_property_kv(KEY_NAMES["duration"],duration)
			if first_seg == nil then
				first_seg = seg
				pi:set_index_mrl(VSL_TAG,p2purl)
			end
			pi:add_segment(seg)
		end
		if expected_type_tag == type_tag then
			expected_pi = pi
		end
		first_seg = nil
		vi:add_play_index(pi)
	end

	if vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)
	vi:init_player_codec_config_list(device_info,device_rank)

	local curr_pi = expected_pi
	if curr_pi == nil then
		local vl = vi[KEY_NAMES["vod_list"]]
		utility.sort_vod_list(vl)
		curr_pi = get_pi_by_quality(vl,expected_quality)
	end
	mr:set_play_index(curr_pi)
	mr:set_resolve_params(resolve_params)

	local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
	utility.sort_vod_list(vl)
	local find_pi = utility.resolve_play_index(vl,resolve_params,device_info,device_rank)
	if find_pi ~= nil then
		mr:set_play_index(find_pi)
	end

	return mr

end


function sohu.resolve_segment(pi, seg, device_info)
	require("bili.model")
	local seg_meta_url = seg[KEY_NAMES["meta_url"]]
	utility.log("seg_meta_url",seg_meta_url)

	local r, c, h, s,body = utility.httpget(seg_meta_url, nil, USER_AGENT)

	if c ~= 200 then
		utility.log("failed:"..seg_meta_url)
		return -1
	end

	local lxml
	if _VERSION == "Lua 5.2" then
		xml = require('LuaXml')
		lxml = xml
	else
		require('LuaXml')
		lxml = xml
	end
	local xfile = lxml.eval(body)
	local ip = xfile:find("ip")
	if ip ~= nil and #ip > 0 then
		local hd = xfile:find("hd")
		local path = xfile:find("path")
		local key = xfile:find("key")
		local idc = xfile:find("idc")
		local url = string.format("http://%s%s/%s?key=%s&idc=%s&n=1",ip[1], hd[1], path[1], key[1], idc[1])
		seg[KEY_NAMES["url"]] = url
	end
	-- local files = xfile:find("file")
	-- local json = require("json")
	-- local jobj = json.decode(body)
	-- seg[KEY_NAMES["url"]] = jobj["l"]

	-- print(jobj["l"])
	return seg
end

return sohu
