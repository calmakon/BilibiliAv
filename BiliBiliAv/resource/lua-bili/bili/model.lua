--Constant fields
KEY_NAMES = {url="url",duration="duration", bytes="bytes", meta_url="meta_url",backup_urls="backup_urls",
			type_tag="type_tag",description="description",available_period_milli="available_period_milli",from="from",parsed_milli="parsed_milli",need_faad="need_faad",is_resolved="is_resolved",local_proxy_type="local_proxy_type",normal_mrl="normal_mrl",index_mrl="index_mrl",prefer_vlc="prefer_vlc",need_membuf="need_membuf",is_downloaded="is_downloaded",segment_list="segment_list",player_codec_config_list="player_codec_config_list",need_ringbuf="need_ringbuf",user_agent="user_agent",request_from_downloader="request_from_downloader",extra_info="extra_info",psedo_bitrate="psedo_bitrate",is_stub="is_stub",
			vod_list="vod_list",
			name="name",from="from",cid="cid",vid="vid",link="link",raw_vid="raw_vid",has_alias="has_alias",resolve_bili_cdn_play="resolve_bili_cdn_play",expected_quality="expected_quality" ,
			vod_index="vod_index",play_index="play_index",resolve_params="resolve_params",
			player="player",use_list_player="use_list_player",media_codec_direct="media_codec_direct",use_mdeia_codec="use_mdeia_codec",use_open_max_il="use_open_max_il"}

KEY_NAME_ARRAY_SEGMENT = {KEY_NAMES["url"],KEY_NAMES["duration"],KEY_NAMES["bytes"],KEY_NAMES["backup_urls"],KEY_NAMES["meta_url"],KEY_NAMES["extra_info"]}
KEY_NAME_ARRAY_PLAY_INDEX = {KEY_NAMES["type_tag"],KEY_NAMES["description"],KEY_NAMES["available_period_milli"],KEY_NAMES["from"],KEY_NAMES["parsed_milli"],KEY_NAMES["need_faad"],KEY_NAMES["is_resolved"],KEY_NAMES["local_proxy_type"],KEY_NAMES["normal_mrl"],KEY_NAMES["index_mrl"],KEY_NAMES["prefer_vlc"],KEY_NAMES["need_membuf"],KEY_NAMES["is_downloaded"],KEY_NAMES["segment_list"],KEY_NAMES["player_codec_config_list"],KEY_NAMES["need_ringbuf"],KEY_NAMES["user_agent"],KEY_NAMES["extra_info"],KEY_NAMES["psedo_bitrate"],KEY_NAMES["is_stub"]}
KEY_NAME_ARRAY_VOD_INDEX = {KEY_NAMES["vod_list"]}
KEY_NAME_ARRAY_RESOLVE_PARAMS = {KEY_NAMES["name"],KEY_NAMES["from"],KEY_NAMES["cid"],KEY_NAMES["vid"],KEY_NAMES["link"],KEY_NAMES["raw_vid"],KEY_NAMES["has_alias"],KEY_NAMES["resolve_bili_cdn_play"],KEY_NAMES["expected_quality"],KEY_NAMES["request_from_downloader"]}
KEY_NAME_ARRAY_MEDIA_RESOURCE = {KEY_NAMES["vod_index"],KEY_NAMES["play_index"],KEY_NAMES["resolve_params"]}
KEY_NAME_ARRAY_PLAYER_CODEC_CONFIG = {KEY_NAMES["player"],KEY_NAMES["use_list_player"],KEY_NAMES["media_codec_direct"],KEY_NAMES["use_mdeia_codec"],KEY_NAMES["use_open_max_il"]}
PLAYER_NAMES = {NONE="NONE", ANDROID_PLAYER="ANDROID_PLAYER", VLC_PLAYER="VLC_PLAYER", IJK_PLAYER="IJK_PLAYER", MP_PLAYER="MP_PLAYER", AV_PLAYER="AV_PLAYER",IJK_HWPLAYER="IJK_HWPLAYER",TX_PLAYER="TX_PLAYER"}
VIDEO_FORMAT = {MP4="MPEG-4",FLV="FLV",M3U="M3U",M3U8="M3U8"}

PI_LOCAL_PROXY_TYPE_NONE     = 0
PI_LOCAL_PROXY_TYPE_SINA_MP4 = 1
PI_LOCAL_PROXY_TYPE_QQ_FLV   = 3

PI_BILI_API_FROM_FMT_1 = "lua.%s.bapi.1"
PI_BILI_API_FROM_FMT_2 = "lua.%s.bapi.2"
PI_BILI_API_DESCRIPTION_1 = "备用-流畅"
PI_BILI_API_DESCRIPTION_2 = "备用-高清"


local function remove_private_fields(obj)
	local utils = require("bili.utility")
	for k,v in pairs(obj) do
		if tostring(k):sub(1,1)=="_" then
			obj[k] = nil
		elseif utils.typeof(v) == "table" then
			remove_private_fields(v)
		end
	end
end

--BaseType class
base_type = {}
function base_type:new(key_name_array)
	local obj = {_kna = key_name_array}
    self.__index = self
    return setmetatable(obj, self)
end

function base_type:set_array(key_name_array)
	self._kna = key_name_array
end

function base_type:set_property_kv(k,v)
	local kna = self._kna
	if kna == nil then
		return
	end

	for i=1,#kna do
		if kna[i] == k then
			self[k] = v
			break
		end
	end
end

function base_type:set_property(kvtable)
	local kna = self._kna
	if kna == nil then
		return
	end
	for k,v in pairs(kvtable) do
		for i=1,#kna do
			if kna[i] == k then
				self[k] = v
				break
			end
		end
	end
end

function base_type:remove_property(t)
	local util = require("bili.utility")
	local _type = util.typeof(t)
	if _type == "string" then
		self[t] = nil
	elseif _type == "table" then
		for k,v in pairs(t) do
			self[v] = nil
		end
	end
end

function base_type:to_json()
	local json = require("json")
	local obj = self
	remove_private_fields(obj)
	return json.encode(obj)
end

--PlayerCodecConfig class
player_codec_config = base_type:new(KEY_NAME_ARRAY_PLAYER_CODEC_CONFIG)

--Segment class
segment = base_type:new(KEY_NAME_ARRAY_SEGMENT)


--PlayIndex class
play_index = base_type:new(KEY_NAME_ARRAY_PLAY_INDEX)

function play_index:new()
	local obj = base_type:new(KEY_NAME_ARRAY_PLAY_INDEX)
	self.__index = self
    return setmetatable(obj, self)
end

function play_index:add_segment(seg)
	local segment_list = self[KEY_NAMES["segment_list"]]
	if segment_list == nil then
		self[KEY_NAMES["segment_list"]] = {}
		segment_list = self[KEY_NAMES["segment_list"]]
	end
	table.insert(segment_list,seg)
end

function play_index:set_index_mrl(vsl_tag,location)
	self[KEY_NAMES["index_mrl"]] = string.format("http/%s://%s",vsl_tag,"index_mrl")
end

function play_index:set_normal_mrl(location)
	self[KEY_NAMES["normal_mrl"]] = location
end

function play_index:get_player_codec_config_list(player_names,device_quirks)
	local list = {}
	for i=1,#player_names do
		local pcc = player_codec_config:new()
		pcc:set_property_kv(KEY_NAMES["player"],player_names[i])
		pcc:set_property_kv(KEY_NAMES["use_list_player"],#self[KEY_NAMES["segment_list"]] > 1)
		if device_quirks ~= nil then
			pcc:set_property_kv(KEY_NAMES["use_mdeia_codec"],device_quirks["hw_mc"])
			pcc:set_property_kv(KEY_NAMES["use_open_max_il"],device_quirks["hw_omxil"])
		else
			pcc:set_property_kv(KEY_NAMES["use_mdeia_codec"],false)
			pcc:set_property_kv(KEY_NAMES["use_open_max_il"],false)
		end
		table.insert(list,pcc)
	end
	return list
end

local MODEL_NAMES = {"Nexus 5", "MI 4LTE", "HM NOTE 1LTE","HUAWEI GRA-UL00",  -- 开发想测的的
					"MI 4C", "Redmi Note 2", "MI 3", "OPPO R7", "MI NOTE LTE", "GT-N7100", "HM 2A","Mi-4c","MX4","MI PAD" -- 排名前10
				}

local function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function play_index:init_player_codec_config_list(device_info,device_rank)
	local meta = self["meta"]
	local os =  device_info["os"]
	if meta == nil or device_info == nil or device_rank == nil then
		return
	end

	local format = meta["format"]  
	local video_codec = meta["video_codec"]
	local audio_codec = meta["audio_codec"]
	local device_quirks = device_rank["device_quirks"]
	local app_version_code = device_info["app_version_code"]


	local player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
	if os == "ios" then
		local osvername =  device_info["osvername"]
		player_names = {"IJK_PLAYER","AV_PLAYER","MP_PLAYER"}
		if tonumber(osvername) >= 8.0 then
			if  self["from"] == "live" then
				if tonumber(app_version_code) == 100810 then
					player_names = {PLAYER_NAMES["IJK_PLAYER"]}
				elseif (tonumber(app_version_code) > 1100 and tonumber(app_version_code) < 1200) or (tonumber(app_version_code) > 100800 and tonumber(app_version_code) <100900)  then 
					player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
				else
					player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
				end
			elseif self["from"] == "qq" then
				player_names = {PLAYER_NAMES["TX_PLAYER"],PLAYER_NAMES["AV_PLAYER"],PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
			else
				if tonumber(app_version_code) == 100810 then
					player_names = {PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["AV_PLAYER"]}
				elseif (tonumber(app_version_code) > 1100 and tonumber(app_version_code) < 1200) or (tonumber(app_version_code) > 100800 and tonumber(app_version_code) <100900) then
					player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["AV_PLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
				else
					player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["AV_PLAYER"]}
				end
			end
			
		else
			if  self["from"] == "live" then
				player_names = {PLAYER_NAMES["IJK_PLAYER"]}
			elseif  self["from"] == "qq" then
				player_names = {PLAYER_NAMES["TX_PLAYER"],PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["AV_PLAYER"]}
			else
				player_names = {PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["AV_PLAYER"]}
			end
		end
		self[KEY_NAMES["player_codec_config_list"]] = player_names
	else
		if format == VIDEO_FORMAT["MP4"] then
			player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
		elseif format == VIDEO_FORMAT["FLV"] then
			if device_quirks == nil or device_quirks["hw_lavf"] then
				player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
			else
				player_names = {PLAYER_NAMES["VLC_PLAYER"],PLAYER_NAMES["ANDROID_PLAYER"]}
			end	
		else
			player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
		end
		if app_version_code ~= nil and tonumber(app_version_code) >= 301070 then
			if device_info["osvercode"] ~= nil and tonumber(device_info["osvercode"]) >= 16 then
				player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
				if tonumber(device_info["osvercode"]) >= 18 then
					player_names = {PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}			
				elseif device_info["model"] ~=nil then
					if contains(MODEL_NAMES, device_info["model"]) then
						player_names = {PLAYER_NAMES["IJK_PLAYER"],PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
					end
				end
				if tonumber(app_version_code) <= 302000 then
					if device_info ~= nil and device_info["cpu_info"] ~= nil then
						if device_info["cpu_info"]["abi"] == "x86" or device_info["cpu_info"]["abi2"] == "x86" or device_info["cpu_info"]["abi"] == "X86" or device_info["cpu_info"]["abi2"] == "X86" then
							player_names = {PLAYER_NAMES["ANDROID_PLAYER"],PLAYER_NAMES["VLC_PLAYER"]}
						end
					end
				end
			end
		end

		local list = self:get_player_codec_config_list(player_names,device_quirks)
		self[KEY_NAMES["player_codec_config_list"]] = list
	end

end

function play_index:init_live_player_codec_config_list(device_info,device_rank,url)
	local meta = self["meta"]
	if meta == nil or device_info == nil or device_rank == nil then
		return
	end
	
	local utils = require("bili.utility")
	local device_quirks = device_rank["device_quirks"]

	local osvername = device_info["osvername"]
	local app_version_code = device_info["app_version_code"];
	local os = device_info["os"]

	if os == "ios" then
		player_names = {"IJK_PLAYER","AV_PLAYER","MP_PLAYER"}
		if tonumber(osvername) >= 8.0 then
			if tonumber(app_version_code) == 100810 then
				player_names = {PLAYER_NAMES["IJK_PLAYER"]}
			elseif (tonumber(app_version_code) > 1100 and tonumber(app_version_code) < 1200) or (tonumber(app_version_code) > 100800 and tonumber(app_version_code) <100900) then
				player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
			else
				player_names = {PLAYER_NAMES["IJK_HWPLAYER"],PLAYER_NAMES["IJK_PLAYER"]}
			end
		else
			player_names = {PLAYER_NAMES["IJK_PLAYER"]}
		end
		self[KEY_NAMES["player_codec_config_list"]] = player_names
	else
		local player_names = {PLAYER_NAMES["IJK_PLAYER"]}
		local utils = require("bili.utility")
		if utils.is_tv_box(device_info["model"]) then
			player_names = {PLAYER_NAMES["ANDROID_PLAYER"], PLAYER_NAMES["IJK_PLAYER"], PLAYER_NAMES["IJK_PLAYER"]}
		end
		local list = self:get_player_codec_config_list(player_names,device_quirks)
		self[KEY_NAMES["player_codec_config_list"]] = list
	end
end


--VodIndex class
vod_index = base_type:new(KEY_NAME_ARRAY_VOD_INDEX)

function vod_index:new()
	local obj = base_type:new(KEY_NAME_ARRAY_VOD_INDEX)
	self.__index = self
    return setmetatable(obj, self)
end

function vod_index:add_play_index(pi)
	local vod_list = self[KEY_NAMES["vod_list"]]
	if vod_list == nil then
		self[KEY_NAMES["vod_list"]] = {}
		vod_list = self[KEY_NAMES["vod_list"]]
	end
	table.insert(vod_list,pi)
end

function vod_index:init_player_codec_config_list(device_info,device_rank)
	local vod_list = self[KEY_NAMES["vod_list"]]
	if vod_list == nil then
		return
	end
	for i=1,#vod_list do
		local pi = vod_list[i]
		pi:init_player_codec_config_list(device_info,device_rank)
	end		
end

function vod_index:init_live_player_codec_config_list(device_info,device_rank,url)
	local vod_list = self[KEY_NAMES["vod_list"]]
	if vod_list == nil then
		return
	end
	for i=1,#vod_list do
		local pi = vod_list[i]
		pi:init_live_player_codec_config_list(device_info,device_rank,url)
	end		
end

--ResolveParams class
resolve_params = base_type:new(KEY_NAME_ARRAY_RESOLVE_PARAMS)

function resolve_params:new(tobj)
	local obj = base_type:new(KEY_NAME_ARRAY_RESOLVE_PARAMS)
	if tobj ~= nil then
		obj = tobj
		obj._kna = KEY_NAME_ARRAY_RESOLVE_PARAMS
	end
	self.__index = self
    return setmetatable(obj, self)
end


--MediaResource
media_resource = base_type:new(KEY_NAME_ARRAY_MEDIA_RESOURCE)

function media_resource:set_vod_index(vi)
	self[KEY_NAMES["vod_index"]] = vi
end

function media_resource:set_play_index(pi)
	self[KEY_NAMES["play_index"]] = pi
end

function media_resource:set_resolve_params(rp)
	self[KEY_NAMES["resolve_params"]] = rp
end

-- testing code
--~ pi = play_index:new()
--~ pi:set_property({[KEY_NAMES["type_tag"]]="lua.iqiyi.hd",[KEY_NAMES["from"]]="sohu"})
--~ rp = resolve_params:new()
--~ rp:set_property_kv("from","iqiyi")
--~ mr = media_resource:new()
--~ mr:set_resolve_params(rp)
--~ mr:set_play_index(pi)
--~ local json_str = mr:to_json()
--~ print(json_str)
--~ return json_str
