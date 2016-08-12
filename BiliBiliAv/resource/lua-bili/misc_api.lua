local AVIDS = {}

local DisableDownloadAVIDS = {-123}
local DisableDownloadSPIDS = {34566,30156,24227,34557,34575,34563,34810,16459,1867,30789,2635,47492,35005,24270,42511,53081,50384,50437,50453}
local DisableDownloadSeasonIDS = {1597}

function get_inject_js_str(url)
	local b,e = string.find(url,"letv.")
	if b ~=nil and b >= 1 then
		return "javascript:var objs = document.getElementsByClassName('j-download'); for(i=0;i<objs.length;i++){var obj=objs[i].cloneNode(true);objs[i].parentNode.replaceChild(obj,objs[i]);obj.addEventListener('click',function(){android.openPlayer();return true;})};if(android.isUserLogin && android.isUserLogin()){var obj=document.getElementsByClassName('hv_ico_pasued')[0];var newobj=obj.cloneNode(true);obj.parentNode.replaceChild(newobj,obj);newobj.addEventListener('click',function(){android.openPlayer();return true;});}"		
	end
end

function get_http_headers(resolve_params_json, device_info_json)
	local headers = {}
	headers["Content-Type"] = ""
	headers["Accept"] = "*/*"
	headers["Accept-Encoding"] = "identity;q=1, *;q=0"
	headers["Accept-Language"] = "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4"
	headers["Connection"] = "keep-alive"
	local json = require("json")
	return json.encode(headers)
end

function get_inject_js_str_ios(url, platform)
	local pagex_js = "function pageX(elem){return elem.offsetParent ?elem.offsetLeft + pageX( elem.offsetParent ) : elem.offsetLeft};"
	local pagey_js = "function pageY(elem){return elem.offsetParent?elem.offsetTop + pageY(elem.offsetParent):elem.offsetTop};"
	local remove_js = "var children=document.getElementsByTagName('video');if(children){for(var c=0;c<children.length;c++){child = children[c];child.remove();}};"

	if string.find(url, "tudou.com") ~= nil and string.find(url, "tudou.com") > 1 then
		return ""
	end

	local id_array_define = ""
	if string.find(url, "iqiyi.com") ~= nil and string.find(url, "iqiyi.com") > 1 then
		id_array_define = "var ids = ['player-container','widget-videoArea','j-player','fla_box'];"
		if platform == "ipad" then
			id_array_define = "var ids = ['widget-videoArea','player-container','fla_box','j-player'];"
		end
	elseif string.find(url, "letv.com") ~= nil and string.find(url, "letv.com") > 1 then
		id_array_define = "var ids = ['j-player','fla_box','player-container','widget-videoArea'];"
		if platform == "ipad" then
			id_array_define = "var ids = ['fla_box','j-player','widget-videoArea','player-container'];"
		end
	elseif string.find(url, "pps.tv") ~= nil and string.find(url, "pps.tv") > 1 then
		id_array_define = "var ids = ['player-panel','player-wrap','j-player','fla_box','player-container','widget-videoArea'];"
		if platform == "ipad" then
			id_array_define = "var ids = ['player-wrap','player-panel','fla_box','j-player','widget-videoArea','player-container'];"
		end
	elseif string.find(url, "tudou.com") ~= nil and string.find(url, "tudou.com") > 1 then
		id_array_define = "var ids = ['playPanelView'];"
	elseif string.find(url, "youku.com") ~= nil and string.find(url, "youku.com") > 1 then
		id_array_define = "var ids = ['playPanelView'];"
	else
		id_array_define = "var ids = ['player-container','widget-videoArea','fla_box','j-player'];"
		if platform == "ipad" then
			id_array_define = "var ids = ['widget-videoArea','player-container','fla_box','j-player'];"
		end
	end
	return id_array_define..pagex_js..pagey_js.."function getRectData(idarr){"..remove_js.."for(var i=0;i<idarr.length;i++){var elem=document.getElementById(idarr[i]);if(!elem){var elems=document.getElementsByClassName(idarr[i]);if(elems)elem=elems[0];}if(elem){var rect={};rect.left=pageX(elem);rect.top=pageY(elem);rect.width=elem.clientWidth;rect.height=elem.clientHeight;return JSON.stringify(rect);}}};getRectData(ids);"
end

function get_redirect_weblink_url(url)
	return nil
end

function reset_player_params(player_params_json)
	if player_params_json == nil then
		return nil
	end
	local json = require("json")
	local player_params = json.decode(player_params_json)
	if player_params ~= nil then
		local resolve_params = player_params["resolve_params"]
		if(resolve_params ~= nil) then
			local weblink = resolve_params["weblink"]
			if weblink == nil or #weblink == 0 then
				return nil
			end
			local from = resolve_params["from"]
			if from == "mletv" then
				return nil
			end
			if from == "iqiyi" then
    			return nil
			end
			local avid = resolve_params["avid"]
			if weblink ~= nil and avid ~= nil then
				for _,v in pairs(AVIDS) do
  					if v == avid or "av"..v == avid then
    					resolve_params["weblink"] = ""
    					return json.encode(player_params)
  					end
				end
			end
		end
	end
end

function get_webview_user_agent(origin_ua, app_version_name, resolve_params_json, device_info_json)
	if origin_ua ~= nil and app_version_name ~= nil and resolve_params_json ~= nil and device_info_json ~= nil then
		local json = require("json")
		local resolve_params = json.decode(resolve_params_json)
		if resolve_params ~= nil then
			local weblink = resolve_params["weblink"]
			if weblink ~= nil and string.find(weblink, "tudou.com") ~= nil and string.find(weblink, "tudou.com") > 1 then
				return origin_ua.." "..app_version_name
			end
		end
	end
	return origin_ua
end

function isAllowDownload(avid,spid,season_id)
	if avid == nil then
		return "YES"
	end
	
	for _,v in pairs(DisableDownloadAVIDS) do
		if tostring(v) == tostring(avid) then
			return "NO"
		end
	end

	if spid == nil then
		return "YES"
	end

	for _,s in pairs(DisableDownloadSPIDS) do
		if tostring(s) == tostring(spid) then
			return "NO"
		end
	end

	if season_id == nil then
		return "YES"
	end

	for _,s in pairs(DisableDownloadSeasonIDS) do
		if tostring(s) == tostring(season_id) then
			return "NO"
		end
	end

	return "YES"

end

function getWebplayerBody_ios(url, platform)

	print("========",url)
	print("url.length",#url)

	local useragent = "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53"

	if platform == "ipad" then
		useragent = "Mozilla/5.0 (iPad; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53"
	end

	local utility = require("bili.utility")	
	local r, c, h, s,body = utility.httpget(url,nil,useragent)

	print("c=",c)

	if tonumber(c) == 302 or tonumber(c) == 301 then
		print("========",h["location"])
		r, c, h, s,body = utility.httpget(h["location"],nil,useragent)
	end
	
	

	if string.find(url, "tudou.com") ~= nil and string.find(url, "tudou.com") > 1 then
		return body
	elseif string.find(url, "sohu.com") ~= nil and string.find(url, "sohu.com") > 1 then
		return " <script language=\"javascript\" type=\"text/javascript\"> window.location.href=\""..url.."\";  </script>"
	elseif string.find(url, "youku.com") ~= nil and string.find(url, "youku.com") > 1 then
		return body
	elseif string.find(url, "bilibili.com") ~= nil and string.find(url, "bilibili.com") > 1 then
		return body
	else
		body = string.gsub(body, "<script", "<iframe height='0' width='0' frameborder=0 style='display:none'")
		body = string.gsub(body, "</script>", "</iframe>")
		body = string.gsub(body, "class=\"video\"", "class=\"video\" style=\"height:180px\"")

	end

	return body
	
end


function getIsShowWebMediaPlayer_ios(url, platform)

	if string.find(url, "tudou.com") ~= nil and string.find(url, "tudou.com") > 1 then
		return "NO"
	elseif string.find(url, "youku.com") ~= nil and string.find(url, "youku.com") > 1 then
		return "NO"
	else
		return "YES"
	end
end

function getIsShowWebMediaPlayerOnClickButton_ios(url, platform)

	if string.find(url, "bilibili.com") ~= nil and string.find(url, "bilibili.com") > 1 then
		return "NO"
	else
		return "YES"
	end
end

function resolve_player_params(player_params_json, device_info_json, device_rank_json)
	-- if player_params_json == nil then
	-- 	return nil
	-- end	
	-- return nil
end

function find(str, f)
	return string.find(str,f) ~= nil and string.find(str,f) >= 1
end

function get_vlcmedia_options(options_array_json, device_info_json, device_rank_json)
	local json = require("json")
	local device_info = json.decode(device_info_json)
	if device_info == nil or device_info["cpu_info"] == nil or device_info["osvercode"] == nil then
		return nil
	end
	local vendor = device_info["cpu_info"]["vendor"]
	if vendor == nil then
		return nil
	end
	if device_info["osvercode"] > 17 or vendor ~= "MediaTek" then
		return nil
	end

	if options_array_json ~= nil then
		local options_array = json.decode(options_array_json)
		local options_result = {}
		local codec_value = nil
		for k,v in pairs(options_array) do
			local find_codec = find(v, ":codec") 
			if find_codec == true then
				codec_value = v
			end
			if v ~= ":mediacodec-force-dr" and find_codec == false then
				table.insert(options_result, v)
			end
		end
		--:codec=mediacodec,avcodec,all
		if codec_value ~= nil then
			local r,s = string.gsub(codec_value,"mediacodec,","")
			table.insert(options_result,r)
		end 
		table.insert(options_result,":no-mediacodec-dr")
		return json.encode(options_result)
	end
	return nil
end

function disableBackgroundCache()
	return "NO"
end

function allowDecoder_iOS(resolve_params_json,device_info_json,device_rank_json)
	local json = require("json")

	local device_info
	if device_info_json ~= nil then
		device_info = json.decode(device_info_json)
	end

	local device_rank
	if device_rank_json ~= nil then
		device_rank = json.decode(device_rank_json)
	end

	
	return "IJK_HWPLAYER,IJK_PLAYER,AV_PLAYER"
end

--local js = get_inject_js_str_ios('http://www.iqiyi.com/v_19rrmlz7ic.html','ipad')
--print(js)