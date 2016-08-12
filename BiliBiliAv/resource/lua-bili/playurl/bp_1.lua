local utility = require("bili.utility")
local bit = require("bit")
require("bili.int64_utility")
require("bili.model")
local pptv = {}
local AVAILABLE_PERIOD_MILLI = 14400000
local PPTV_SOURCE_DESCRIPTION = {["0"]="流畅",["1"]="高清",["2"]="超清",["5"]="标清",["unknown"]="未知"}
local PPTV_META_MAP = {
	["0"] = {
 		["name"]            = "0",			     -- 源 TAG
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A",
	    ["type_tag"]        = "lua.pptv.0", -- 客户端 TAG
	    ["description"]     = "流畅",			 -- 描述
        ["kbps"]            = 350,				 -- 码率估算,大约是 bytes / seconds / 1000
        ["hq_score"]        = -1,				 -- 高清优先级, -1 表示不支持
        ["lq_score"]        = -1,				 -- 低清优先级, -1 表示不支持
        ["order"]			= 1
	},		
	["5"] = {
 		["name"]            = "5",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.pptv.5",
	    ["description"]     = "标清",
        ["kbps"]            = 500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 2
	},
	["1"] = {
 		["name"]            = "1",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.pptv.1",
	    ["description"]     = "高清",
        ["kbps"]            = 1000,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 3
	},	
	["2"] = {
 		["name"]            = "2",
 		["format"]			= VIDEO_FORMAT["MP4"],
 		["video_codec"]		= "H264",
 		["audio_codec"]		= "MP4A", 		
	    ["type_tag"]        = "lua.pptv.2",
	    ["description"]     = "超清",
        ["kbps"]            = 1500,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 4
	},	
	["unknown"] = {
 		["name"]            = "unknown",
	    ["type_tag"]        = "lua.pptv.unknown",
	    ["description"]     = "未知",
        ["kbps"]            = -1,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["order"]			= 5
	}
}
local VSL_TAG = "vsl"
local SERVER_KEY = "qqqqqww"
local AUTH = "d410fafad87e7bbf6c6dd62434345818"
local PLATFORM = "android3";
local PARAM = "userType%3D0";
local K_VER = "1.1.0.7932";
local SVER = "3.6.1";
local PLAT_TYPE = "phone.android";
local URL_FORMAT = "http://%s/%d/%s?%s"

local function to_java_byte(num)
	if num >= -128 and num <=127  then
		return num
	end
	local mod_num
	if num > 127 then
		mod_num = num%128
	elseif num < -128 then
		mod_num = num%128
	end

	return -128 + mod_num

end

local function comps(a,b)
	local astr,bstr = string.gsub(a,"p","0"),string.gsub(b,"p","0")
	local anum = tonumber(astr)
	local bnum = tonumber(bstr)
	return anum<bnum
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
		q = 3
	else
		q = 1
	end
	return get_pi(vl,q)
end

local function time2StringBuf(i,buf,j)
		for k=1,8 do
			if k > j then
				break
			end
			buf[k] = to_java_byte(bit.band(0xf,bit.rshift(i,28 - 4 * (k-1%8))))   --(0xf & i >> 28 - 4 * (k % 8));
			local byte0 = buf[k]
			local byte1
			if buf[k]>9 then
				byte1 = 87
			else
				byte1 = 48
			end
			buf[k] = to_java_byte(byte0 + byte1)
		end
end

local function a(abyte0, i)
	local k = 0
	for j=1,i do
		k = bit.bxor(k,bit.lshift(abyte0[j],8 * (((j - 1)%4))) )  --k ^= abyte0[j] << 8 * (j % 4);
	end
	return k
end

local function a4(abyte0, i, abyte1, j)
	if j<1+i*2 then
		return 0
	end
	local m = 1
	for k=0,i-1 do
		abyte1[k*2 + 1] = to_java_byte(bit.band(0xf,abyte0[k+1])) --(byte) (0xf & abyte0[k]);
		abyte1[1 + k*2 + 1] = to_java_byte(bit.band(0xf,bit.rshift(abyte0[k+1],4)))  --(byte) (0xf & abyte0[k] >> 4);
		m = m + 2
	end
	for l=1,i*2 do
		local byte0 = abyte1[l]
		local byte1
		if byte0 > 9  then
			byte1 = 87
		else
			byte1 = 48
		end
		abyte1[l] = to_java_byte(byte0+byte1)
	end
	abyte1[i * 2 + 1] = 0
	return 1
end

local function b1(num)
	if utility.typeof(num) == "number" then
		return bit.band(0xffffffff,num)
	else
		return i64_toInt(i64_and(i64(0xffffffff),num))
	end
end


local function b4(abyte0, i, abyte1, j)
	local l = a(abyte1,j)
	print("b4 l",l)
	local bit = require("bit")
	local l64 = i64(l)
	local r64 = i64_lshift(l64,8)
	print(i64_toInt(r64))

	--local l1 = bit.bor(bit.lshift(l,8),bit.rshift(l,24))
	--local l2 = bit.bor(bit.lshift(l,16),bit.rshift(l,16))
	--local l3 = bit.bor(bit.lshift(l,24),bit.rshift(l,8))
	local l1 = i64_or(i64_lshift(l64,8),i64_rshift(l64,24))
	local l2 = i64_or(i64_lshift(l64,16),i64_rshift(l64,16))
	local l3 = i64_or(i64_lshift(l64,24),i64_rshift(l64,8))
	--print(l1,l2,l3,i)

	for k=1,i do
		print("k",k)
		if k + 15 > i then
			break
		end
		local l4 = 0
		local l5 = 0
		local l6 = 0
		for i1=0,3 do
			l4 = bit.bor(l4, bit.lshift(bit.band(0xff,abyte0[k+i1]),i1*8))			-- l4 |= (long) (0xff & abyte0[k + i1]) << i1 * 8;
			l5 = bit.bor(l5, bit.lshift(bit.band(0xff,abyte0[4+k+i1]),i1*8))		-- l5 |= (long) (0xff & abyte0[4 + (k + i1)]) << i1 * 8;
		end
		print("l4l5",l4,l5,l6)
		for j1=1,32 do
			l6 = i64_toInt(i64_and(i64(0xffffffff),i64(l6 - 0x61c88647)))	-- l6 = b(l6 - 0x61c88647L);
			--l4 = l4 + bit.bxor(bit.bxor(bit.lshift(l5,4),l5+l6),l1 + bit.rshift(l5,5))  -- l4 = b(l4 + (b(b(l + b(l5 << 4)) ^ b(l5 + l6)) ^ b(l1 + b(l5 >> 5))));
			local l4tmp1 = b1(i64_add(i64(l),i64(b1(i64_lshift(i64(l5),4)))))
			local l4tmp2 = b1(i64_add(i64(l5),i64(l6)))
			local l4tmp3 = b1(i64_add(l1,i64(b1(i64_rshift(i64(l5),5)))))
			local l4tmp = i64_add(i64(l4) , i64(bit.bxor(b1(bit.bxor(l4tmp1,l4tmp2)), l4tmp3)))
			l4 = b1(l4tmp)

            --l5 = l5 + bit.bxor(bit.bxor(bit.lshift(14,4),l4+l6),l3 + bit.rshift(l4,5))  -- l5 = b(l5 + (b(b(l2 + b(l4 << 4)) ^ b(l4 + l6)) ^ b(l3 + b(l4 >> 5))));
			--l5 = bit.band(0xffffffff,l5)
			local l5tmp1 = b1(i64_add(l2,i64(b1(i64_lshift(i64(l4),4)))))
			local l5tmp2 = b1(i64_add(i64(l4),i64(l6)))
			local l5tmp3 = b1(i64_add(l3,i64(b1(i64_rshift(i64(l4),5)))))
			local l5tmp = i64_add(i64(l5) , i64(bit.bxor(b1(bit.bxor(l5tmp1,l5tmp2)), l5tmp3)))
			l5 = b1(l5tmp)
			local l5tmp4 = bit.bxor(l5tmp1,l5tmp2)
		end
		print("l4l5l6",l4,l5,l6)
		for k1=1,4 do
			local index = k - 1 + k1 - 1 + 1
			abyte0[index] = b1(i64_and(i64(255),i64_rshift(i64(l4),(k1-1)*8))) --(byte) (int) (255L & l4 >> k1 * 8);
			abyte0[index] = to_java_byte(abyte0[index])
			abyte0[4 + index] = b1(i64_and(i64(255),i64_rshift(i64(l5),(k1-1)*8))) --bit.rshift(bit.band(255,l5),(k1-1)*8)   --abyte0[4 + (k + k1)] = (byte) (int) (255L & l5 >> k1 * 8);
			abyte0[4 + index] = to_java_byte(abyte0[4 + index])
		end


		k = k+16
	end

end

local function getKey(ttime)
--~ 		byte abyte0[] = new byte[16];
--~         byte abyte1[] = new byte[16];
--~         byte abyte2[] = new byte[33];
--~         int i = 0;
--~         while (i < 16) {
--~             byte byte0;
--~             if (i < SERVER_KEY.length())
--~                 byte0 = (byte) SERVER_KEY.charAt(i);
--~             else
--~                 byte0 = 0;
--~             abyte1[i] = byte0;
--~             i++;
--~         }
--~         time2StringBuf((int) (ttime / 1000L - 100L), abyte0, 16);
--~         Random random = new Random();
--~         for (int j = 0; j < 16; j++)
--~             if (abyte0[j] == 0) abyte0[j] = (byte) random.nextInt(256);
--~         b(abyte0, 16, abyte1, 16);
--~         a(abyte0, 16, abyte2, 33);
--~         return new String(abyte2, 0, 32);

		local abyte0={}
		local abyte1={}
		local abyte2={}
		for a=1,16 do
			abyte0[a] = 0
			abyte1[a] = 0
		end
		for a=1,32 do
			abyte2[a] = 0
		end

		for i=1,16 do
			local byte0
			if i <= #SERVER_KEY then
				byte0 = string.byte(SERVER_KEY,i)
			else
				byte0 = 0
			end
			abyte1[i] = byte0
		end
		local json = require("json")
--		print("abye0",json.encode(abyte0),math.floor(ttime / 1000) - 100)
		time2StringBuf(math.floor(ttime / 1000) - 100, abyte0, 16);
		for j=1,16 do
			if abyte0[j] == 0 then
				abyte0[j] = math.floor(math.random(-128,127))
			end
		end
		--abyte0 = {53, 51, 56, 49, 52, 100, 98, 54, 4, -83, -41, -65, -111, 109, 125, 99}


		b4(abyte0,16,abyte1,16)
--		print("abyte0",json.encode(abyte0))
		a4(abyte0,16,abyte2,33)
		print("abyte2",json.encode(abyte2))

		local result = ""
		for j=1,#abyte2 do
			result = result..string.char(abyte2[j])
			if j >= 32 then
				break
			end
		end
		return result
end

local function getStreamUrlParameters(expireKey)
return "platform="..PLATFORM.."&type="..PLAT_TYPE.."&sv="..SVER
                .."&sdk=1&content=need_drag&auth="..AUTH.."&k="..expireKey
                .."&key="..getKey(os.time() * 1000).."&agent=ppap"
end


function pptv.resolve_segment(pi, seg, device_info)

end

function pptv.resolve_media_resource(resolve_params,device_info,device_rank)
	if resolve_params == nil then
		return -1
	end
	local vid = resolve_params["vid"]
	local from = resolve_params["from"]
	local expected_type_tag = resolve_params["expected_type_tag"]
	local expected_quality = resolve_params["expected_quality"]

	vid = string.gsub(vid,".swf%??.*","")
	vid = string.gsub(vid,"http://player.pptv.com/v/","")
	local play_url = "http://v.pptv.com/show/"..vid..".html"
	-- get vid
	local r, c, h, s,body = utility.httpget(play_url,nil,USER_AGENT)
	if c ~= 200 then
		utility.log("failed:"..play_url)
		return nil
	end

	local vid_str = string.sub(body,string.find(body,"\"video_%d+"))
	vid = utility.split(vid_str,"_")[2]


	local uuid = require("uuid")
	uuid.randomseed(os.time())
	local api_url = string.format("http://play.api.pptv.com/boxplay.api?auth=%s&userLevel=1&content=need_drag&id=%s&platform=%s&param=%s&vvid=%s&k_ver=%s&sv=%s&ver=1&type=%s&gslbversion=2",
									AUTH,vid,PLATFORM,PARAM,tostring(uuid.new()),K_VER,SVER,PLAT_TYPE)
	utility.log(api_url)

	local r, c, h, s,body = utility.httpget(api_url,nil,USER_AGENT)
	if c ~= 200 then
		utility.log("failed:"..api_url)
		return nil
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

	local files = xfile:find("file")
	local expire_time

	local selected_pi
	local vi = vod_index:new()
	for i=1,#files do
		local file = files[i]

		local dt = xfile:find("dt","ft",file.ft)

		if dt ~= nil then
			file["serverHost"] = dt:find("sh")[1]
			file["serverTime"] = dt:find("st")[1]
			file["expireKey"] = dt:find("key")[1]
			expire_time = dt:find("key")["expire"]
		end
		local drag = xfile:find("drag","ft",file.ft)
		if drag ~= nil then
			local tag = tostring(file["ft"])
			local type_tag = "lua."..resolve_params[KEY_NAMES["from"]].."."..tag
			local pi = play_index:new()
			pi:set_property_kv(KEY_NAMES["from"],from)
			pi:set_property_kv(KEY_NAMES["type_tag"],type_tag)
			local description = PPTV_SOURCE_DESCRIPTION[tag]
			if description == nil then
				description = PPTV_SOURCE_DESCRIPTION["unknown"]
			end
			pi:set_property_kv(KEY_NAMES["description"],description)
			pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
			pi:set_property_kv(KEY_NAMES["need_ringbuf"],true)
			pi:set_property_kv(KEY_NAMES["available_period_milli"], AVAILABLE_PERIOD_MILLI)
			pi:set_property_kv(KEY_NAMES["parsed_milli"], os.time() * 1000)

			file["segment_list"] = drag
			for j=1,#file["segment_list"] do
				local seg_url = string.format(URL_FORMAT,file["serverHost"],file["segment_list"][j]["no"],file["rid"],getStreamUrlParameters(file["expireKey"]))
				--print(file["segment_list"][1]["no"],seg_url)
				local filesize = file["segment_list"][j]["fs"]
				local duration = file["segment_list"][j]["dur"] * 1000
				local seg = segment:new()
				seg:set_property_kv(KEY_NAMES["url"],seg_url)
				seg:set_property_kv(KEY_NAMES["bytes"],filesize)
				seg:set_property_kv(KEY_NAMES["duration"],duration)
				pi:add_segment(seg)
			end
			local first_seg = pi["segment_list"][1]
			if first_seg ~= nil then
				pi:set_index_mrl(VSL_TAG,first_seg["url"])
				if #pi["segment_list"] == 1 then
					pi:set_normal_mrl(first_seg["url"])
				end
			end

			if expected_type_tag == type_tag  then
				selected_pi = pi
			end

			local meta = PPTV_META_MAP[tostring(tag)]
			if meta == nil then
				meta = PPTV_META_MAP["unknown"]
			end
			pi["meta"] = meta

			vi:add_play_index(pi)
		end

	end


	if vi[KEY_NAMES["vod_list"]] == nil then
		return nil
	end

	local mr = media_resource:new()
	mr:set_vod_index(vi)
	local curr_pi = selected_pi
	if curr_pi == nil then
		curr_pi = get_pi_by_quality(vi[KEY_NAMES["vod_list"]],resolve_params["expected_quality"])
	end
	mr:set_play_index(curr_pi)

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

--local expireKey = "ca0f989659ebb437f6ecf834dc092e62-27d7-1400945734"
--print("getStreamUrlParameters",getStreamUrlParameters(expireKey))
--local ostime = 1400983066654
--print("getkey",getKey(ostime))

return pptv
-- arg[1] video info json
--local videoinfojson = "{\"play\":\"194092\",\"review\":\"1267\",\"video_review\":\"44776\",\"favorites\":\"948\",\"title\":\"\\u3010\\u5b8c\\u7ed3\/1\\u6708\\u3011 \\u4e2d\\u4e8c\\u75c5\\u4e5f\\u8981\\u8c08\\u604b\\u7231\\uff01\\u604b 12\",\"description\":\" (\\uff40\\u30fb\\u03c9\\u30fb\\u00b4)(^\\u30fb\\u03c9\\u30fb^ )\",\"tag\":\"\\u4e2d\\u4e8c\\u75c5\\u4e5f\\u8981\\u8c08\\u604b\\u7231,\\u5b8c\\u7ed3\\u6492\\u82b1,NTR,\\u8bda\\u54e5\\u8981\\u5e78\\u798f,\\u5b8c\\u7ed3\\u6492\\u82b1\\u2606*:.\\uff61. \\\\(\\u00b0\\u2200\\u00b0)\/ .\\uff61.:*\\u2606,\\u5b8c\\u7ed3\\uff01,\\u68ee\\u51f8\",\"pic\":\"http:\/\/i0.hdslb.com\/u_f\/7037fc28de020747dd7c4c9af0cce27a.jpg\",\"author\":\"\\u642c\",\"mid\":\"928123\",\"pages\":\"2\",\"instant_server\":\"chat.bilibili.tv\",\"created_at\":\"2014-03-27 11:23\",\"credit\":\"3280\",\"coins\":\"923\",\"spid\":5691,\"src\":\"c\",\"season_id\":705,\"season_index\":\"12\",\"list\":{\"0\":{\"page\":1,\"type\":\"sohu\",\"vid\":\"6282932|1688350\",\"part\":\"1\",\"cid\":1492050,\"has_alias\":false},\"1\":{\"page\":2,\"type\":\"sina\",\"part\":\"2\",\"cid\":1490283}}}"
-- arg[2]
-- arg[3] device info json
--local deviceinfojson = "{\"user-agent\":\"abc\"}"
--letv.getplayurl("20055264",0)
