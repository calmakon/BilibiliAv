local youku = {}
local utility = require("bili.utility")
-- require("api")
local mime = require("mime")
local biliapi = require("biliapi")
require("bili.model")
local lmd5;
lmd5 = require("md5")




local AVAILABLE_PERIOD_MILLI = 10800000
local YOUKU_META_MAP = {
	-- ["hd3"] = {
 -- 		["name"]            = "hd3",			     -- 源 TAG
 -- 		["format"]			= VIDEO_FORMAT["FLV"], -- 视频封装格式
 -- 		["video_codec"]		= "H264",			 -- 视频编码
 -- 		["audio_codec"]		= "MP4A",			 -- 音频编码
	--     ["type_tag"]        = "lua.youku.5.hdflv3", -- 客户端 TAG
 --        ["videotype"]       = "hd3",
 --        ["sidtype"]         = "flv/",
 --        ["hdtype"]          = 0,
	--     ["description"]     = "原画",			 -- 描述
 --        ["kbps"]            = 3800,				 -- 码率估算,大约是 bytes / seconds / 1000
 --        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
 --        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
 --        ["order"]			= 5
	-- },
	["hd2"] = {
 		["name"]            = "hd2",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.youku.4.hdflv2",
        ["videotype"]       = "hd2",
        ["sidtype"]         = "flv/",
        ["hdtype"]          = 2,
	    ["description"]     = "高清",
        ["kbps"]            = 2000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},
    ["mp4"] = {
        ["name"]            = "mp4",
        ["format"]          = VIDEO_FORMAT["MP4"],
        ["video_codec"]     = "H264",
        ["audio_codec"]     = "MP4A",
        ["type_tag"]        = "lua.youku.2.mp4",
        ["description"]     = "标清",
        ["video_type"]      = "mp4",
        ["sidtype"]         = "mp4/",
        ["hdtype"]          = 1,
        ["kbps"]            = 560,
        ["hq_score"]        = 90,
        ["lq_score"]        = 90,
        ["order"]           = 3
    },
	["flv"] = {
 		["name"]            = "flv",
 		["format"]			= VIDEO_FORMAT["FLV"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.youku.3.flv",
	    ["description"]     = "流畅",
        ["video_type"]      = "flv",
        ["sidtype"]         = "flv/",
        ["hdtype"]          = 0,
        ["kbps"]            = 770,
        ["hq_score"]        = 100,
        ["lq_score"]        = 1,
        ["order"]			= 2
	},
	
	-- ["sdflv"] = {
 -- 		["name"]            = "sdflv",
 -- 		["format"]			= VIDEO_FORMAT["FLV"],
 -- 		["video_codec"]		= "H264",
 -- 		["audio_codec"]		= "MP4A",
	--     ["type_tag"]        = "lua.youku.1.sdflv",
	--     ["description"]     = "sdflv",
 --        ["video_type"]      = "sdflv",
 --        ["sidtype"]         = "flv/",
 --        ["hdtype"]          = 0,
 --        ["kbps"]            = 270,
 --        ["hq_score"]        = 80,
 --        ["lq_score"]        = 80,
 --        ["order"]			= 1
	-- },
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.youku.unknown",
	    ["description"]     = "未知",
        ["description"]     = "nil",
        ["video_type"]      = "nil",
        ["sidtype"]         = "nil",
        ["kbps"]            = 0,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= -1
	}
}

local YOUKU_META_REVERSE_MAP = {}
for k, v in pairs(YOUKU_META_MAP) do
    YOUKU_META_REVERSE_MAP[v["type_tag"]] = v;
end

local VSL_TAG = "vsl"

local url_prefix_youku = "http://v.youku.com/player/getPlayList/VideoIDS/";
local url_surfix_youku = "/timezone/+08/version/5/source/out?ctype=10&n=3&ev=1&password=&ran=";
local url_surfix_tudou = "/timezone/+08/version/5/source/out/Sc/2?ctype=10&n=3&ev=1&password=&ran=";




function removeChar(source,character)
    if character == '.' then
        character = "%.";
    end
    local index = string.find(source,character);
    local before = string.sub(source,1,index-1);
    local after = string.sub(source,index+1);
    local result = before..after;
    return result;
end

function getMixString(seedstr)
    local seed = tonumber(seedstr);
    local mixed = "";
    local source = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890";
    local len = #source;
    for i=1,len do
        seed = (seed * 211 + 30031) % 65536;
        local index = math.floor(seed / 65536 * #source);
        index = index + 1;
        local c = string.sub(source,index,index);
        mixed = mixed..c;
        source = removeChar(source,c);
    end
    return mixed;
end

function getFileId(fileId,seed)
    local mixed = getMixString(seed);
    local ids = utility.split(fileId,'*');
    local realId = '';
    local length = #ids;
    length = length ;
    for  i = 1,length do
        local id = tonumber(ids[i]);
        id = id + 1;
        realId = realId..string.sub(mixed,id,id);
    end
    return realId;
end





function descryptDes(content,key)

    local length = #content;
    local i = 0;
    local result = "";

    while i*8 < length do
        local end_index = 8*(i+1);
        if end_index > length then
            end_index = length;
        end

        local res1 = biliapi.des_ecb_dec_blk(string.sub(content,1+i*8,end_index),key);
        i = i + 1;
        result = result..res1;
    end

    return result;
end


function encryptDes(content,key)

    local length = #content;
    local i = 0;
    local result = "";

    while i*8 < length do
        local end_index = 8*(i+1);
        if end_index > length then
            end_index = length;
        end


        local res1 = biliapi.des_ecb_enc_blk(string.sub(content,1+i*8,end_index),key);
        i = i + 1;
        result = result..res1;
    end

    return result;
end







function setSize(s)
        if #s%8~= 0 then
            for i = #s%8 , 7 do
                s = s.."\x00";
            end
        end
     

        
        local res = encryptDes(s,'21dd8110');
        local res_base64 = mime.b64(res);
        return res_base64;
end
function changeSize(s)
        local md5str = lmd5.sumhexa(s.."_kservice");
        return string.sub(md5str,1,4);
end
function getSize(s)
    
        local dataBase64 = mime.unb64(s);
        res = descryptDes(dataBase64,'00149ad5');
        return res;
end




local spilt = function(str,pattern)
    local ret= {}
    string.gsub(str, "[^".. pattern .."]+", function(item) table.insert(ret, item) end )
    return  ret;
end

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


function decodeYouku(youkuid,from)

    utility.log("youkuid"..youkuid)
	local url = url_prefix_youku..youkuid..url_surfix_youku;
    if from == "td" then
        url = url_prefix_youku..youkuid..url_surfix_tudou;
    end
    math.randomseed(os.time())
    url = url..math.random(1000,9999)
    utility.log("api_url"..url)
    local r, c, h, s,body;
    
    r, c, h, s,body = utility.httpget(url,nil,USER_AGENT);
    if (c ~= 200) then
        return;
    end

    local resource = {["stream_list"]={}}

    local json = require("json")
    local youkuJson = json.decode(body)
    local data = youkuJson["data"][1];
    local  result = {};
    local  timelength = data.seconds*1000;
    result.timelength = timelength;
    result.framecount = math.floor(timelength/41.67);
    result.src = 0;
    result.from = "youku";
    result.durl = {};
 
    for key, value in pairs(YOUKU_META_MAP) do     
            if data.segs[key] ~= nil and data.streamfileids[key] ~= nil then

                    local stream = {
                                    ["total_bytes"]=0,
                                    ["total_duration"]=0,
                                    ["segment_list"]={},
                                    ["video_type"]="nil",
                                    ["format"]="nil",
                                    ["hd_type"]="nil",
                                    ["sid"]="nil"
                                };

                    local seed = 0;
                    seed = data.seed;
                    local _hd_type = YOUKU_META_MAP[key]["hdtype"];
                    local _sid_type = YOUKU_META_MAP[key]["sidtype"];
                    local fileId = getFileId(data.streamfileids[key], seed);
                    if #fileId > 8 then
                     
                            for   i = 1,#data.segs[key] do
                                local vp_data = data.segs[key][i];
                                local n = tonumber(vp_data.no);

                                local hex = string.format("%X",vp_data.no);

                                if #hex == 1 then
                                    hex = '0'..hex;
                                end


                                local ep_x_total = getSize(data.ep);

                                local ep_x = spilt(ep_x_total,"_");
                                local sid = ep_x[1];
                                local token = string.sub(ep_x[2],1,4);
                                local bctime = '0'; 
                                local e = sid .. '_' .. string.sub(fileId,1,8) .. hex .. string.sub(fileId,11) .. '_' .. token .. '_' .. bctime;
                    
                                local f = changeSize(e);
                         
                                local ep = setSize(e .. '_' .. string.sub(f,1,4));
                 
                                local url = "http://k.youku.com/player/getFlvPath/sid/" .. sid..'_'..hex..'/st/'.._sid_type..'fileid/' .. string.sub(fileId,1,8) .. hex .. string.sub(fileId,11) .. '?K=' .. vp_data.k..
                                                                '&hd='.. _hd_type..'&myp=0&ts='..vp_data.seconds..'&ypp=0&ctype=10&ev=1&token='..token..'&oip='..data.ip..'&ep='..encodeURI(ep);
                                
                              
                                local segment = {};


                                segment["order"] = n+1;
                                segment["duration"] = tonumber(vp_data.seconds)*1000;
                                segment["bytes"] = tonumber(vp_data.size);
                                segment["url"] = url;

                                stream["segment_list"][segment["order"]] = segment;

                            

                            end
                    end

            result.durl[key] = stream;
            end


    end  




return result;


 
   
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

local function get_pi_by_quality(vl,resolve_params)
	local q = 1
	local quality = resolve_params["expected_quality"]
	local request_from_downloader = resolve_params["request_from_downloader"]
	if request_from_downloader == nil then
		request_from_downloader = false
	end
	if quality >= 200 then
		q = #vl
	else
		q = 1
	end
	return get_pi(vl,q)
end


local function get_meta_by_stream_tag(id)
    local meta = YOUKU_META_MAP[tostring(id)]
    if meta == nil then
        meta = YOUKU_META_MAP["unknown"]
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
 
 



local function resolve_vod_index(from,vid)
	local resource = decodeYouku(vid,from)
	if resource == nil then
		return nil
	end

	local vi = vod_index:new()
	local pi_list = {}
	for key, value in pairs(resource["durl"])  do
		local stream      = value;
		local tag         = tostring(key)
		local stream_meta = get_meta_by_stream_tag(tag)


			local type_tag    = stream_meta["type_tag"]
			local pi          = play_index:new()
			pi:set_property_kv(KEY_NAMES["from"],        from)
			pi:set_property_kv(KEY_NAMES["type_tag"],    type_tag)
			pi:set_property_kv(KEY_NAMES["description"], stream_meta["description"])

			for _,_segment in pairs(stream["segment_list"]) do
				
				local segment_meta_url = _segment["url"];
				local seg = segment:new()
				seg:set_property_kv(KEY_NAMES["duration"],_segment["duration"])
				seg:set_property_kv(KEY_NAMES["bytes"], _segment["bytes"])
                seg:set_property_kv(KEY_NAMES["url"], _segment["url"])
				pi:add_segment(seg);				
			end


            pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
            pi:set_property_kv(KEY_NAMES["need_ringbuf"],true)
            pi:set_property_kv(KEY_NAMES["parsed_milli"],os.time() * 1000)
            pi:set_property_kv(KEY_NAMES["available_period_milli"],AVAILABLE_PERIOD_MILLI)


			local meta = YOUKU_META_MAP[tostring(tag)]
			if meta == nil then
				meta = YOUKU_META_MAP["unknown"]
			end
            pi:set_index_mrl(VSL_TAG, vid)
			pi["meta"] = meta
			vi:add_play_index(pi)

	end
	return vi
end

function youku.resolve_media_resource(resolve_params,device_info,device_rank)
	if resolve_params == nil then
		return -1
	end

	utility["logcat"] = device_info["logcat"] ~= false;

	local expected_quality  = resolve_params["expected_quality"]
	local expected_type_tag = resolve_params["expected_type_tag"]
	local from = resolve_params["from"]
	local vid = resolve_params["vid"]
    utility.log("vid"..vid)
	local vi, pi_list = resolve_vod_index(from, vid)
	if vi == nil or vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)

	vi:init_player_codec_config_list(device_info,device_rank) 
	local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
	utility.sort_vod_list(vl)


    local selected_pi = nil
    local vl = vi[KEY_NAMES["vod_list"]]
    for i = 1,#vl do
        if expected_type_tag == vl[i][KEY_NAMES["type_tag"]] then
            selected_pi = vl[i]
            break
        end
    end


    if selected_pi == nil then
        selected_pi = get_pi_by_quality(vi[KEY_NAMES["vod_list"]],resolve_params)
    end
    if selected_pi == nil then
        selected_pi = vl[1];
    end
    mr:set_play_index(selected_pi)
    mr:set_resolve_params(resolve_params)

	local find_pi = utility.resolve_play_index(vl,resolve_params,device_info,device_rank)
	if find_pi ~= nil then
		mr:set_play_index(find_pi)
	end

	utility.log(mr:to_json())
	return mr

end

function youku.resolve_segment(pi,seg,device_info)
	return nil;
end

return youku;
