local tudou = {}


local function decode_youku_vid(base64_url)
    local mime = require("mime")
    local utility = require("bili.utility")
    local base64_url2 = string.gsub(base64_url,"XN","")
    local url = mime.unb64(base64_url2)
    local r, c, h, s,body = utility.httpget(url,nil,USER_AGENT)
    if h.location == nil then
        return nil
    end
    local s,e,r = string.find(h.location,"youkuId=([^&]+)&")
    return r
end

function tudou.resolve_media_resource(resolve_params,device_info,device_rank)
	local youku_vid = decode_youku_vid(resolve_params["vid"])
    print("youku_vid"..youku_vid)
    if youku_vid == nil then
        return nil
    end
    resolve_params["raw_vid"] = resolve_params["vid"]
    resolve_params["vid"] = youku_vid
    local youku = require("playurl.by_1")
    local mr = youku.resolve_media_resource(resolve_params,device_info,device_rank)
    resolve_params["vid"] = resolve_params["raw_vid"]
    return mr
end

function tudou.resolve_segment(pi,seg,device_info)
	
end


--decode_youku_vid("http://www.tudou.com/a/lHvXdgRhkLc/&iid=132326906&rpid=116568909&resourceId=116568909_04_05_99/v.swf")
--decode_youku_vid("XNaHR0cDovL3d3dy50dWRvdS5jb20vYS9sSHZYZGdSaGtMYy8maWlkPTEzMjMyNjkwNiZycGlkPTExNjU2ODkwOSZyZXNvdXJjZUlkPTExNjU2ODkwOV8wNF8wNV85OS92LnN3Zg==")

return tudou
