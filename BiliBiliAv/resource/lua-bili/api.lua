-- version 2.4 - 141218
-- 增加优酷源本地解析
-- version 2.3
-- misc_api增加resolve_player_params和get_vlcmedia_options方法
-- 删除暂时无用的文件
-- version 2.2
-- hdmp4地址返回错误(空)后重试hd flv解析
-- version 2.1
-- 改进直播画质选择和播放器选择
-- version 1.9
-- deviceinfo增加cpu_info sys_decoder_type
-- version 1.8
-- api.lua: 增加怪盗Joker/寄生兽的屏蔽离线avid
-- version 1.7
-- bp_1.lua: 修复网页找不到vid导致解析失败
-- version 1.6 
-- api.lua:增加fix_video_page_data(video_pages_json, device_info_json)接口

local SCRIPT_VERSION_NAME = "3.1.0"
local SCRIPT_VERSION_CODE = 3001;
local ERROR_FAILED = -1
local ERROR_WRONG_PARAMATER = -2
local ERROR_NIL_PARAMETER_VALUE = -3

local json = require("json")

local function create_resolver(from,vid,expected_type_tag,resolve_bili_cdn_play,platform,device_info)
	local resolver = nil
	local name = nil
	if resolve_bili_cdn_play == true then
		resolver = require("playurl.biliapi")
		name = "playurl.biliapi"
		return resolver,name
	end
	local s = -1
	if expected_type_tag ~= nil then
		s = string.find(expected_type_tag,"lua(%.?%w*)%.bapi.(%d)")
	end
	local support_des = false
	if device_info ~= nil and device_info["app_version_code"] ~= nil then
		if device_info["os"] == "android" then
			if device_info["app_version_code"] >= 209072 then
				support_des = true
			end
		elseif device_info["os"] == "ios" then
			local app_version_code = tonumber(device_info["app_version_code"]);
			if device_info["app_version_name"] == "tv.danmaku.bilianime" and app_version_code >= 881 then
				support_des = true
			elseif device_info["app_version_name"] == "ibili.app.ibiliplayer" and app_version_code >= 100800 then
				support_des = true
			end
		end
	end
	-- print("support_des",from, support_des,device_info["app_version_name"] ,device_info["app_version_code"])

	if from == "td" and support_des == true then
		resolver = require("playurl.bt_1")
		name = "playurl.bt_1"
	elseif from == "letv" or from == "sina" or vid == nil or vid == "" or s == 1 then
		resolver = require("playurl.biliapi")
		name = "playurl.biliapi"
	elseif from == "mletv" then
		resolver = require("playurl.bl_1")
		name = "playurl.bl_1"
	elseif from == "iqiyi" or from == "qiyi" then
		resolver = require("playurl.bi_1")
		name = "playurl.bi_1"
	elseif from == "qq" then
		resolver = require("playurl.bq_1")
		name = "playurl.bq_1"
	elseif from == "sohu" then
		resolver = require("playurl.bs_1")
		name = "playurl.bs_1"
	elseif from  == "pptv" then
		resolver = require("playurl.bp_1")
		name = "playurl.bp_1"
	else
		--print("unknwon from "..from)
		resolver = require("playurl.biliapi")
		name = "playurl.biliapi"
	end
	return resolver,name
end

function get_version_name()
	return SCRIPT_VERSION_NAME
end

function get_version_code()
	return SCRIPT_VERSION_CODE
end

function get_corever_name()
	return _VERSION
end

local function append_bili_api_pi(vod_list,description,from_fmt,quality)
	require("bili.model")
	local pi = vod_list[1]
	local new_pi = play_index:new()
	new_pi:set_property(pi)
	local from = pi[KEY_NAMES["from"]]
	local vtype = "flv"
	if quality == 1 and from ~= "youku" then
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

	table.insert(vod_list,new_pi)
end

local block_avids = {}
local block_spids = {}
local block_season_ids = {1597}
local block_date_tids = {145,146,147,83}

local function block_this_avid(resolve_params) 
	if resolve_params["request_from_downloader"] == true then
		local avid = resolve_params["avid"]
		local utility = require("bili.utility")	
		if utility.contains(block_avids,avid) then
			return true
		end
	end
	return false
end

function resolve_media_resource(resolve_params_json,device_info_json,device_rank_json,access_token_json)
	if resolve_params_json == nil then
		return nil
	end
	local resolve_params
	if resolve_params_json ~=nil then
		resolve_params = json.decode(resolve_params_json)
	end

	if block_this_avid(resolve_params) then
		local url = "http://download.hdslb.net/download_deny_10s.m4v"
		local json_format = "{\"vod_index\":{\"vod_list\":[{\"is_resolved\":false,\"user_agent\":\"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"from\":\"lua.mp4.bapi.1\",\"description\":\"流畅\",\"segment_list\":[{\"url\":\"%s\",\"bytes\":148107,\"duration\":210000}],\"player_codec_config_list\":[{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"ANDROID_PLAYER\",\"use_open_max_il\":false},{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"VLC_PLAYER\",\"use_open_max_il\":false}],\"type_tag\":\"lua.mp4.bapi.1\",\"normal_mrl\":\"%s\",\"index_mrl\":\"http/vsl://index_mrl\"},{\"need_ringbuf\":true,\"from\":\"letv\",\"user_agent\":\"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"player_codec_config_list\":[{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"ANDROID_PLAYER\",\"use_open_max_il\":false},{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"VLC_PLAYER\",\"use_open_max_il\":false}],\"type_tag\":\"lua.flv.bapi.2\",\"normal_mrl\":\"%s\",\"description\":\"高清\",\"index_mrl\":\"http/vsl://index_mrl\",\"segment_list\":[{\"url\":\"%s\",\"bytes\":148107,\"duration\":210000}]}]},\"play_index\":{\"need_ringbuf\":true,\"from\":\"letv\",\"user_agent\":\"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36\",\"player_codec_config_list\":[{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"ANDROID_PLAYER\",\"use_open_max_il\":false},{\"use_list_player\":false,\"use_mdeia_codec\":true,\"player\":\"VLC_PLAYER\",\"use_open_max_il\":false}],\"type_tag\":\"lua.flv.bapi.2\",\"normal_mrl\":\"%s\",\"description\":\"高清\",\"index_mrl\":\"http/vsl://index_mrl\",\"segment_list\":[{\"url\":\"%s\",\"bytes\":148107,\"duration\":210000}]},\"resolve_params\":{\"resolve_bili_cdn_play\":false,\"avid\":1669036,\"expected_quality\":400,\"request_from_downloader\":true,\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"cid\":\"2543276\",\"has_alias\":false,\"vid\":\"4f89c5f094\",\"raw_vid\":\"4f89c5f094\",\"from\":\"letv\",\"link\":\"\",\"page\":1}}"
		return string.format(json_format,url,url,url,url,url,url,url)
	end

	local utility = require("bili.utility")	
	local device_info
	if device_info_json ~= nil then
		device_info = json.decode(device_info_json)
	end
	local device_rank
	if device_rank_json ~= nil then
		device_rank = json.decode(device_rank_json)
	end
	if resolve_params == nil or device_info == nil or device_rank == nil then
		return nil
	end
	print("device_rank",device_rank,device_rank_json)
	require("bili.model")
	local expected_type_tag = resolve_params["expected_type_tag"]
	local resolver,name = create_resolver(resolve_params[KEY_NAMES["from"]],resolve_params[KEY_NAMES["vid"]],expected_type_tag,resolve_params[KEY_NAMES["resolve_bili_cdn_play"]],device_info["os"],device_info)
	if resolver == nil then
		return nil
	end
	utility.log("resolver"..name)
	local access_token
	if access_token_json ~= nil then
		access_token = json.decode(access_token_json)
	end
	local mr = resolver.resolve_media_resource(resolve_params,device_info,device_rank,access_token)
	if resolve_params[KEY_NAMES["from"]] == "qq" and utility.typeof(mr) == "string" then
		return mr
	end

	if resolve_params[KEY_NAMES["from"]] == "youku" then
		if mr == nil or utility.typeof(mr) ~= "table" or mr[KEY_NAMES["vod_index"]] == nil or mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == nil or #mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == 0 then
			if mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]][1] == nil or mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]][1] == "" then
				resolver = require("playurl.by_1")
				mr = resolver.resolve_media_resource(resolve_params,device_info,device_rank,access_token)
			end
		end
	else
		if mr == nil or utility.typeof(mr) ~= "table" or mr[KEY_NAMES["vod_index"]] == nil or mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == nil or #mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == 0 then
			if name == "playurl.biliapi" then
				if resolve_params[KEY_NAMES["resolve_bili_cdn_play"]] == true then
					resolve_params[KEY_NAMES["resolve_bili_cdn_play"]] = false
				else
					resolve_params[KEY_NAMES["resolve_bili_cdn_play"]] = true
				end
			end
			resolver = require("playurl.biliapi")
			mr = resolver.resolve_media_resource(resolve_params,device_info,device_rank,access_token)
		end
	end

	if mr == nil or utility.typeof(mr) ~= "table" or mr[KEY_NAMES["vod_index"]] == nil or mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == nil or #mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]] == 0 then
		return nil
	end

	local s = -1
	if expected_type_tag ~= nil then
		s = string.find(resolve_params["expected_type_tag"],"lua(%.?%w*)%.bapi.(%d)")
	end
	if from ~= "letv" and from ~= "sina" and from ~= "youku" and s ~= 1 and resolve_params[KEY_NAMES["has_alias"]] == true then
		local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
		if vl ~= nil then
			append_bili_api_pi(vl,PI_BILI_API_DESCRIPTION_1,PI_BILI_API_FROM_FMT_1,1)
			append_bili_api_pi(vl,PI_BILI_API_DESCRIPTION_2,PI_BILI_API_FROM_FMT_2,2)
		end
	end
	return mr:to_json()
end

function handle_resolver(from, device_info_json)
	if from == "mletv" or from == "letv" then
		return true
	elseif from == "iqiyi" or from == "qiyi" then
		return true
	elseif from == "qq" then
		return true
	elseif from == "youku" or from == "sina" then
		return true
	elseif from == "sohu" then
		return true
	elseif from == "pptv" then
		return true
	end
	return false
end

local function handle_resolve_segment(from)
	if from ~= "iqiyi" and from ~= "qiyi" and from ~= 'qq' and from ~= 'sohu' then
		print("unknwon from "..from)
		return false
	end
	return true
end

function resolve_segment(pi_segment_json,device_info_json,device_rank_json,access_token_json)
	if pi_segment_json == nil then
		return nil
	end

	local pi_segment = json.decode(pi_segment_json)
	local pi = pi_segment["play_index"]
	local seg = pi_segment["segment"]
	local from = pi["from"]
	if handle_resolve_segment(from) == false then
		if seg ~= nil then
			return json.encode(seg)
		else
			return nil
		end
	end
	if seg == nil then
		seg = pi["segment_list"][1]
	end

	local utility = require("bili.utility")

	local device_info
	if device_info_json ~= nil then
		device_info = json.decode(device_info_json)
	end
	local resolver = create_resolver(from,"vid_blank",nil,false,device_info["os"],device_info)
	if resolver == nil then
		return nil
	end

	local device_rank
	if device_rank_json ~= nil then
		device_rank = json.decode(device_rank_json)
	end
	local result_seg = resolver.resolve_segment(pi,seg,device_info,device_rank)
	if result_seg == nil then
		return nil
	end

	return json.encode(result_seg)
end

function fix_video_page_data(video_pages_json, device_info_json)
	local utility = require("bili.utility")

	if video_pages_json == nil then
		return nil
	end

	local video_pages = json.decode(video_pages_json)
	if video_pages == nil then
		return nil
	end

	local tid = video_pages["tid"]
	local created = video_pages["created"]
	local created_at = video_pages["created_at"]

	local need_block_date = false
	if tid ~= nil and tid ~= 0 then
		if utility.contains(block_date_tids, tid) and created_at ~= nil then
			need_block_date = true
		end
	end

	local page_list = video_pages["page_list"]
	if page_list == nil then
		return nil
	end
	local spid = video_pages["spid"]
	local season_id = video_pages["season_id"]

	local need_block_by_spid = utility.contains(block_spids,spid)
	local need_block_by_season_id = utility.contains(block_season_ids,season_id)

	if need_block_date == false and need_block_by_spid == false and need_block_by_season_id == false then
		return nil
	end

	if need_block_date then
		video_pages["created"] = 0
		video_pages["created_at"] = "1970-01-01 08:00"
	end

	if need_block_by_spid or need_block_by_season_id then
		for i = 1, #page_list do
			local video_page = page_list[i]
			video_page["downloadable"] = false
			video_page["downloadable_detail"] = "由于版权原因，此视频暂不提供离线功能"
		end
	end
	return json.encode(video_pages)
end


function is_tv_box(device_info_json,device_rank_json)
	local utility = require("bili.utility")
	local device_info
	if device_info_json ~= nil then
		device_info = json.decode(device_info_json)
	end
	if device_info == nil then
		return false
	end
	return utility.is_tv_box(device_info["model"])
end

--print("time",os.time())
-- sample code:
-- resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":true,\"raw_vid\":\"6570807|1801226\",\"expected_quality\":200,\"page\":1,\"avid\":1165106,\"link\":\"\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"request_from_downloader\":false,\"from\":\"sohu\",\"vid\":\"6570807\",\"cid\":\"1708617\"}"
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"http:\/\/player.pptv.com\/v\/PMcyseeUjcsurBQ.swf?vid=0a2lmamVoKmgj9iioJbPpqeL1K2doKmZp6mcmZzPraE=\",\"expected_quality\":200,\"page\":1,\"avid\":1154888,\"link\":\"\",\"user_agent\":\"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko\/20100101 Firefox\/16.0\",\"request_from_downloader\":false,\"from\":\"pptv\",\"vid\":\"http:\/\/player.pptv.com\/v\/PMcyseeUjcsurBQ.swf?vid=0a2lmamVoKmgj9iioJbPpqeL1K2doKmZp6mcmZzPraE=\",\"cid\":\"1686973\"}"
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"\",\"expected_quality\":200,\"page\":1,\"avid\":1155322,\"link\":\"\",\"user_agent\":\"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko\/20100101 Firefox\/16.0\",\"request_from_downloader\":false,\"from\":\"sina\",\"expected_type_tag\":\"lua.sina.bapi.2\",\"vid\":\"\",\"cid\":\"1686044\"}"
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"http://player.pptv.com/v/QM6qKJD2ZqQHhe0.swf\",\"expected_quality\":100,\"page\":1,\"avid\":1138938,\"link\":\"\",\"from\":\"pptv\",\"vid\":\"http://player.pptv.com/v/QM6qKJD2ZqQHhe0.swf\",\"cid\":\"1654331\"}"
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"\",\"expected_quality\":200,\"page\":1,\"avid\":905045,\"link\":\"\",\"from\":\"sina\",\"vid\":\"\",\"cid\":\"1315027\"}"
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"6570807|1775218\",\"expected_quality\":100,\"page\":1,\"avid\":1102964,\"link\":\"\",\"from\":\"sohu\",\"vid\":\"\",\"cid\":\"1625903\"}"
--resolve_params_json = "{\"from\":\"mletv\",\"vid\":\"20031605\",\"os\":\"android\",\"model\":\"Nexus 5\",\"core_si\":{\"vercode\":5001,\"vername\":\"lua\"},\"expected_quality\":200,\"avid\":\"1018132\",\"link\":\"\",\"user_si\":{\"vercode\":1000,\"vername\":\"1.0\"},\"device_id\":\"KOT49H\",\"sh\":1080,\"cid\":\"1635702\",\"osvername\":\"4.4.2\",\"has_alias\":false,\"resolve_bili_cdn_play\":false,\"raw_vid\":\"20031605\",\"osvercode\":19,\"page\":\"1\",\"name\":\"av1018132-p1\",\"ua\":\"Dalvik2.0.0 (Linux; U; Android 4.4.2; Nexus 5 BuildKOT49H)\",\"sdpi\":\"xxhdpi\",\"sw\":1794}"

--resolve_params_json = "{\"cid\":\"1534107\",\"from\":\"mletv\",\"link\":\"\",\"raw_vid\":\"20057078\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"20057078\",\"weblink\":\"http://www.letv.com/ptv/vplay/20057078.html\",\"avid\":1060155,\"expected_quality\":0,\"has_alias\":false,\"page\":1,\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false}"
--resolve_params_json = "{\"cid\":\"1875006\",\"from\":\"letv\",\"link\":\"\",\"raw_vid\":\"485cd5fef8\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"485cd5fef8\",\"weblink\":\"\",\"avid\":1238098,\"expected_quality\":0,\"has_alias\":false,\"page\":1,\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false}"
--resolve_params_json = "{\"cid\":\"1908455\",\"expected_type_tag\":\"lua.mp4.bapi.1\",\"from\":\"sohu\",\"link\":\"\",\"raw_vid\":\"6922830|1859385\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"6922830\",\"weblink\":\"\",\"avid\":1253386,\"expected_quality\":200,\"has_alias\":true,\"page\":2,\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false}"
--resolve_params_json = "{\"has_alias\":false,\"resolve_bili_cdn_play\":false,\"raw_vid\":\"20262893\",\"expected_quality\":200,\"avid\":1282362,\"page\":1,\"weblink\":\"http://www.letv.com/ptv/vplay/20262893.html\",\"link\":\"\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"request_from_downloader\":false,\"from\":\"mletv\",\"vid\":\"20262893\",\"cid\":\"1957645\"}"
--resolve_params_json = "{\"has_alias\":false,\"resolve_bili_cdn_play\":true,\"raw_vid\":\"1913a0fe19\",\"expected_quality\":0,\"avid\":1305406,\"page\":1,\"weblink\":\"\",\"link\":\"\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"request_from_downloader\":false,\"from\":\"letv\",\"vid\":\"1913a0fe19\",\"cid\":\"1983374\"}"
-- resolve_params_json = "{\"avid\":3025715,\"cid\":4745689,\"ep_id\":70900,\"expected_quality\":0,\"expected_type_tag\":\"lua.mp4.bapi.9\",\"from\":\"vupload\",\"has_alias\":false,\"page\":0,\"page_title\":\"1\",\"raw_vid\":\"vupload_4745689\",\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false,\"season_id\":\"2742\",\"spid\":0,\"tid\":0,\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"vupload_4745689\"}"
--resolve_params_json = "{\"from\":\"iqiyi\",\"vid\":\"1792416a88bb6fdf245ad0202a5e37b4\",\"os\":\"android\",\"model\":\"Nexus 5\",\"core_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-base\",\"vercode\":5001,\"vername\":\"lua\"},\"expected_quality\":400,\"avid\":\"1018132\",\"link\":\"\",\"user_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-bili\",\"vercode\":1000,\"vername\":\"1.0\"},\"device_id\":\"KOT49H\",\"sh\":1080,\"cid\":\"2233027\",\"osvername\":\"4.4.2\",\"has_alias\":false,\"resolve_bili_cdn_play\":false,\"raw_vid\":\"1792416a88bb6fdf245ad0202a5e37b4\",\"osvercode\":19,\"page\":\"1\",\"name\":\"av1018132-p1\",\"ua\":\"Dalvik/2.0.0 (Linux; U; Android 4.4.2; Nexus 5 Build/KOT49H)\",\"sdpi\":\"xxhdpi\",\"sw\":1794,\"request_from_downloader\":true}"
--iOS sample code
--resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"raw_vid\":\"\",\"weblink\":\"\",\"link\":\"\",\"from\":\"vupload\",\"vid\":\"vupload_7959087\",\"cid\":\"7959087\",\"avid\":\"4901078\",\"page\":0,\"request_from_downloader\":false,\"expected_quality\":200,\"name\":\"\",\"tid\":\"75\"}"
--device_info_json = "{\"logcat\":false,\"os\":\"ios\",\"app_version_name\":\"tv.danmaku.bilianime\",\"user_rank\":\"0\",\"app_version_code\":\"3380\",\"model\":\"100\",\"osvername\":\"9.300000\",\"device_type\":\"iphone\",\"buvid\":\"39791709f75aa00d6e89f8445bd2a858\",\"device_id_16\":\"39791709f75aa00d\"}"
--device_rank_info = "{\"syshw\":200,\"codec_mode\":\"auto\"}"

--device_info_json = "{\"osvername\":\"4.3\",\"os\":\"android\",\"model\":\"Lenovo A788t\",\"osvercode\":18,\"core_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-base\",\"vercode\":5001,\"vername\":\"lua\"},\"logcat\":false,\"ua\":\"Dalvik/1.6.0 (Linux; U; Android 4.3; Lenovo A788t Build/S104)\",\"user_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-bili\",\"vercode\":1000,\"vername\":\"1.0\"},\"device_id\":\"S104\",\"sh\":480,\"sdpi\":\"hdpi\",\"sw\":854}"
--device_info_json = "{\"osvername\":\"4.4.4\",\"os\":\"android\",\"model\":\"Nexus 5\",\"osvercode\":19,\"core_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-base\",\"vercode\":5001,\"vername\":\"lua\"},\"logcat\":true,\"ua\":\"Dalvik/2.0.0 (Linux; U; Android 4.4.4; Nexus 5 Build/KTU84P)\",\"user_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-bili\",\"vercode\":1010,\"vername\":\"1.1\"},\"device_id\":\"KTU84P\",\"sh\":1776,\"sdpi\":\"xxhdpi\",\"sw\":1080}"
--device_rank_info = "{\"syshw\":75,\"device_quirks\":{\"score\":100,\"sw_hq\":false,\"hw_mc\":true,\"hw_lavf\":false,\"hw_omxil\":false},\"v2hwplusplus\":70,\"v2hwplus\":60,\"sw\":175,\"codec_mode\":\"auto\",\"v2hw\":50}"

-- resolve_params_json = "{\"resolve_bili_cdn_play\":false,\"has_alias\":false,\"expected_quality\":0,\"spid\":0,\"page\":0,\"avid\":1705480,\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"request_from_downloader\":false,\"from\":\"live\",\"expected_type_tag\":\"lua.live.bapi.live1\",\"cid\":\"2603541\"}"
-- resolve_params_json = "{\"cid\":\"2746209\",\"from\":\"youku\",\"link\":\"\",\"raw_vid\":\"XODQ2MDY0NzM2\",\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"XODQ2MDY0NzM2\",\"weblink\":\"\",\"avid\":1791170,\"expected_quality\":0,\"has_alias\":false,\"page\":1,\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false,\"spid\":0}"

-- //////   test sohu resolve segment
-- resolve_params_json = "{\"avid\":2368176,\"cid\":\"3702167\",\"expected_quality\":0,\"from\":\"sohu\",\"has_alias\":false,\"link\":\"\",\"page\":1,\"raw_vid\":\"5359902|2391784\",\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false,\"spid\":0,\"tid\":0,\"user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\",\"vid\":\"5359902\",\"weblink\":\"\"}"
-- device_info_json = "{\"core_si\":{\"vername\":\"lua\",\"vercode\":5001,\"path\":\"/data/data/tv.danmaku.bili/files/lua-base\"},\"user_si\":{\"vername\":\"1.1\",\"vercode\":1010,\"path\":\"/data/data/tv.danmaku.bili/files/lua-bili\"},\"os\":\"android\",\"osvername\":\"5.0.1\",\"osvercode\":21,\"device_id\":\"LRX22C\",\"model\":\"Nexus 5\",\"ua\":\"Dalvik/2.1.0 (Linux; U; Android 5.0.1; Nexus 5 Build/LRX22C)\",\"sw\":1080,\"sh\":1776,\"sdpi\":\"xxhdpi\",\"logcat\":true,\"cpu_info\":{\"abi\":\"armeabi-v7a\",\"abi2\":\"armeabi\",\"cpu_id\":\"Qualcomm Krait\",\"manufacturer\":\"LG\",\"vendor\":\"Qualcomm\",\"core_count\":4},\"sys_decoder_type\":\"ALL\",\"app_version_name\":\"tv.danmaku.bili@2.9.7.2-git\",\"app_version_code\":209072}"
-- device_rank_info = "{\"live_codec_mode\":\"sysHW\",\"device_quirks\":{\"score\":200,\"sw_hq\":true,\"hw_mc\":true,\"hw_lavf\":false,\"hw_omxil\":false},\"v2hwplus\":240,\"codec_mode\":\"auto\",\"syshw\":350,\"v2hwplusplus\":280,\"sw\":175,\"v2hw\":125}"


-- resolve_params_json = "{\"avid\":3628284,\"cid\":5800010,\"ep_id\":0,\"expected_quality\":0,\"expected_type_tag\":\"lua.mp4.bapi.9\",\"from\":\"vupload\",\"has_alias\":false,\"page\":1,\"raw_vid\":\"vupload_5800010\",\"request_from_downloader\":false,\"resolve_bili_cdn_play\":false,\"spid\":0,\"tid\":0,\"user_agent\":\"\",\"vid\":\"vupload_5800010\"}"
--device_info_json = "{\"osvername\":\"4.4.4\",\"os\":\"android\",\"model\":\"Nexus 5\",\"osvercode\":19,\"core_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-base\",\"vercode\":5001,\"vername\":\"lua\"},\"logcat\":false,\"ua\":\"Dalvik/1.6.0 (Linux; U; Android 4.4.4; Nexus 5 Build/KTU84P)\",\"user_si\":{\"path\":\"/data/data/tv.danmaku.bili/files/lua-bili\",\"vercode\":1000,\"vername\":\"1.0\"},\"device_id\":\"KTU84P\",\"sh\":1080,\"sdpi\":\"xxhdpi\",\"sw\":1794}"
--device_rank_info = "{\"syshw\":200,\"v2hwplusplus\":0,\"v2hwplus\":0,\"sw\":75,\"codec_mode\":\"auto\",\"v2hw\":0}"
--access_token_json = "{\"access_key\":\"be36b72b0a36128df3d2c328685f681b\",\"expires\":1455768547,\"mid\":3027215}"
--local mrjson = resolve_media_resource(resolve_params_json,device_info_json,device_rank_info,access_token_json)
--print(mrjson)
-- local mr = json.decode(mrjson)
-- local pi = mr["vod_index"]["vod_list"][2]
-- local seg = pi["segment_list"][2]
-- local piseg = {["play_index"]=pi, ["segment"]=seg}
-- local pistr = json.encode(piseg)
-- print(pistr)
-- resolve_segment(pistr,device_info_json,device_rank_info)
-- /////   test sohu resolve segment



-- print(mrjson)
--local mr = json.decode(mrjson)
--local pi = mr["play_index"]
--local pi_seg = {
--				["play_index"] = pi,
--				["segment"] = seg
--				}
--local pi_seg_json = "{\"segment\":{\"duration\":364827,\"bytes\":24593589,\"meta_url\":\"http:\/\/data.video.qiyi.com\/866856f106d5f9c1c6b9306ebad812d5\/videos\/v0\/20140526\/1a\/68\/3e\/06717b979805b2e29b0560a9342425f8.f4v\"},\"play_index\":{\"type_tag\":\"lua.iqiyi.2.hd\",\"available_period_milli\":300000,\"from\":\"iqiyi\",\"parsed_milli\":1401337213000,\"need_faad\":false,\"local_proxy_type\":0,\"index_mrl\":\"http\/vsl:\/\/index_mrl\",\"prefer_vlc\":false,\"is_resolved\":true,\"need_membuf\":false,\"is_downloaded\":false,\"description\":\"¸ßÇå\",\"segment_list\":[{\"duration\":364827,\"bytes\":24593589,\"meta_url\":\"http:\/\/data.video.qiyi.com\/866856f106d5f9c1c6b9306ebad812d5\/videos\/v0\/20140526\/1a\/68\/3e\/06717b979805b2e29b0560a9342425f8.f4v\"},{\"duration\":362227,\"bytes\":19061405,\"meta_url\":\"http:\/\/data.video.qiyi.com\/2e5ddbbcd17bce74cb90f3d3064bfc0b\/videos\/v0\/20140526\/1a\/68\/3e\/f83334c40bc07165e7e3251e75270e45.f4v\"},{\"duration\":360601,\"bytes\":21223898,\"meta_url\":\"http:\/\/data.video.qiyi.com\/621b6c50faabf1ca999bdd14ee2847ca\/videos\/v0\/20140526\/1a\/68\/3e\/70398ad85c296aed83dea92e4dcfd5df.f4v\"},{\"duration\":352614,\"bytes\":24986449,\"meta_url\":\"http:\/\/data.video.qiyi.com\/ba2db55e2960f106590fea7131a64229\/videos\/v0\/20140526\/1a\/68\/3e\/95a66e01c83cac6e27b1a0d1fe1617ad.f4v\"}],\"need_ringbuf\":true,\"user_agent\":\"Mozilla\/5.0 (Windows NT 6.1; WOW64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/34.0.1847.116 Safari\/537.36\",\"psedo_bitrate\":0,\"is_stub\":false}}"
--resolve_segment(pi_seg_json)
