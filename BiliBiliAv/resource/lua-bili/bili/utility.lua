local utility = {}
local debug = false
local ltn12 = require("ltn12")
local http1 = require("socket.http")
USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"

local TV_MODELS = {
"MiBOX_iCNTV","MiBOX1S","MiBOX2","MiBOX_mini","MagicBox1s_Plus",
"MagicBox","MagicBox1s_Pro","MagicBox2", --天猫魔盒
"M310", -- 华为秘盒
"LeTVX60","Letv S40 Air","Letv S50 Air", "Letv X50 Air",
"AMLOGIC8726MX",
"MiTV2","MiTV","MiTV2-49","MiTV2-40","MiTV2-55",
"Android TV on Haier 6A600",
"ideatv K82",
"TCL-CN-AM6C-A71C-M",
"Quad Core TV BOX",
"10MOONS_D6Q", -- 天敏
"H7", -- 海美迪
"R-8XX-iCNTV",
"Yunhe-BT-4001", -- 百度云盒
"KIUI", -- 开博尔
"KIUI6-M",
"KIUI-3188",
"SoftwinerEvb",
"INPHIC_I6H", -- 英菲克
"INPHIC_I9E",
"INPHIC_I9",
"INPHIC_I6X",
"长虹智能电视"
}

function string.fh(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

local function wrapheaders(headers,ua)
	if not headers then
		headers = {}
	end
	if ua ~= nil then
		headers["User-Agent"] = ua
	else
		headers["User-Agent"] = USER_AGENT
	end
	if headers["Accept"] == nil then
		headers["Accept"] = "*/*"
	end
	--if headers["Accept-Encoding"] == nil then
	--	headers["Accept-Encoding"] = "gzip,deflate,sdch"
	--end
	if headers["Accept-Language"] == nil then
		headers["Accept-Language"] = "zh-CN,zh;q=0.8"
	end
	if headers["Connection"] == nil then
		headers["Connection"] = "keep-alive"
	end
	return headers
end

function utility.httpget(url,headers,ua,follow_redirect)
	local result = {}
	local h = wrapheaders(headers,ua)
	if follow_redirect == nil then
		follow_redirect = true
	end
	local reqt = {sink = ltn12.sink.table(result),url=url,headers = h,redirect=follow_redirect}
	local r, c, h, s = http1.request(reqt)
	return r,c,h,s, table.concat(result)
end

function utility.log(...)
	if debug == false then
		return
	end
    --print(...)
    --require("biliapi").log(1, ...)
    require("biliapi").log(1, ...)
end

function utility.get_tv_box_m()
-- 	f3bb208b3d081dc8   0-3
-- 4fa4601d1caa8b48    4-7
-- 452d3958f048c02a    8-11
-- 86385cdc024c0f6c     12-15
-- 5256c25b71989747   16-19
-- e97210393ad42219   20-23
-- return {1="f3bb208b3d081dc8",
return {"66336262323038623364303831646338", "34666134363031643163616138623438","34353264333935386630343863303261","38363338356364633032346330663663","35323536633235623731393839373437","65393732313033393361643432323139"}
end

function utility.typeof(var)
    local _type = type(var);
    if(_type ~= "table" and _type ~= "userdata") then
        return _type;
    end
    local _meta = getmetatable(var);
    if(_meta ~= nil and _meta._NAME ~= nil) then
        return _meta._NAME;
    else
        return _type;
    end
end

function utility.split(str, separator)
	local result = {}
	for i in string.gmatch(str, "[^"..separator.."]+") do
		table.insert(result,i)
	end
	if #result == 0 then
		table.insert(result,str)
	end
	return result
end

function utility.concat(str)
	return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function utility.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function comps_order(a,b)
	local ameta = a["meta"]
	local bmeta = b["meta"]
	if ameta == nil or bmeta == nil or ameta["order"] == nil or bmeta["order"] == nil then
		return false
	end
	local anum = ameta["order"]
	local bnum = bmeta["order"]
	return anum < bnum
end

function utility.sort_vod_list(t)
	table.sort(t,comps_order)
	for i=1,#t do
		t[i]["meta"] = nil
	end
end

local function x(a, b)
	local bit = require("bit")
	return bit.bor(a, b) - bit.band(a, b)
end

local function sort_nums()
	return ("6337393836663535306539363566613865616264646435653033363665356466"):fh()
end

function utility.resolve_play_index(vl,resolve_params,device_info,device_rank)
	local expected_type_tag = resolve_params["expected_type_tag"]
	local expected_quality =  resolve_params["expected_quality"]
	--脚本版本1010 支持离线选择清晰度优先
	if expected_type_tag == nil and device_info ~= nil and device_info["user_si"] ~= nil and device_info["user_si"]["vercode"] ~= nil and device_info["user_si"]["vercode"] >= 1010 and expected_quality >0 and resolve_params["request_from_downloader"] then
		if expected_quality <=100 then
			return vl[1]
		end
		local index = 1
		local count = #vl
		if expected_quality <= 200 then
			if count >= 2 then
				index = 2
			end
		elseif expected_quality <= 300 then
			if count <= 2 then
				index = count
			elseif count >= 5 then
				index = 4
			else
				index = 3
			end
		elseif expected_quality <= 400 then
			index = count
		end
		return vl[index]
	end
	if expected_type_tag ~= nil or  expected_quality ~= 0 then
		if expected_type_tag == nil and expected_quality >= 200 and resolve_params["from"] == "iqiyi" and #vl > 2 then
			return vl[#vl-1]
		end
		return nil
	end

	--找出分数最高的解码模式
	--syshw/v2hwplusplus/v2hwplus/v2hw 越清晰越好
	--sw 低清
	--其他 低清
	if device_rank == nil then
		return nil
	end
	local index = 1
	local sh = math.min(device_info["sw"],device_info["sh"])
	if sh >= 720  then
		if #vl <= 2 or resolve_params["from"] ~= "iqiyi" then
			index = #vl
		elseif #vl > 2 then
			index = #vl -1
		else
			index = #vl
		end
	end
	return vl[index]
end

function utility.d_tv_box(str, key, skey)
	local binary_str = ""
	for i=1,#str/4 do
		local index = (i - 1) * 4 + 1
		if(i == 1) then 
			index = 1
		end
		local seg = string.sub(str, index, index+3)
		local decrypted = x(tonumber(skey..seg, 16), key)
		binary_str = binary_str..string.format("%04x",decrypted)
	end
	return binary_str
end

function utility.is_empty_string(str)
	return str == nil or str == "" or #str ==0
end

function utility.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function utility.remove(tab, element)
	local pos = {}
	for i=1,#tab do
		if tab[i] == element then
			table.insert(pos, i)
		end
	end
	for k,v in pairs(pos) do
		table.remove(tab, v)
	end
end

function utility.is_tv_box(model)
	return utility.contains(TV_MODELS,model)
end

function utility.check_tv_box(model, s)
	local snum = sort_nums()
	return utility.d_tv_box(snum, model, s) 
end


return utility