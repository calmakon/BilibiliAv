xml = require('LuaXml')
require("bili.model")

local json = require("json")
local ByteBuffer = require("bili.byte_buffer")
local ByteBufferPtr = require("bili.byte_buffer_ptr")
local bit = require("bit")
local socket = require("socket")

local VER_NAME = "0.0.4"
local DEBUG = true;
local AVAILABLE_PERIOD_MILLI = 21600000
local AVAILABLE_CKEY_MILLI = 1080000
local LOG_TAG = "[QQ]:"
local resolver = {}
local utility = require("bili.utility")
local socket_url = require("socket.url")
local VSL_TAG = "vsl"

local EXTRA_BASE_URL   = "base_url"
local EXTRA_USER_AGENT = "user_agent"
local EXTRA_VT = "vt"
local EXTRA_VID = "vid"
local EXTRA_IDX = "idx"
local EXTRA_FMT = "fmt"
local EXTRA_FORMAT = "format"

local FAKE_MR_RESULT = "{\"resolve_params\":{\"cid\":\"$s0\",\"vid\":\"$s1\",\"from\":\"qq\",\"has_alias\":\"false\",\"link\":\"\",\"resolve_bili_cdn_play\":\"false\",\"expected_quality\":200,\"weblink\":\"\",\"request_from_downloader\":\"false\",\"page\":0,\"raw_vid\":\"$s1\",\"name\":\"\",\"avid\":\"2872018\"},\"vod_index\":{\"vod_list\":[{\"available_period_milli\":21600000,\"parsed_milli\":1454053545000,\"extra_info\":{\"fmt\":\"mp4\",\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"vid\":\"$s1\",\"vt\":\"100\",\"format\":\"2\"},\"from\":\"qq\",\"player_codec_config_list\":[\"TX_PLAYER\",\"AV_PLAYER\",\"IJK_HWPLAYER\",\"IJK_PLAYER\"],\"type_tag\":\"lua.qq.mp4\",\"segment_list\":[{\"bytes\":0,\"duration\":0}],\"local_proxy_type\":3,\"need_ringbuf\":true,\"description\":\"mp4\"},{\"available_period_milli\":21600000,\"parsed_milli\":1454053545000,\"extra_info\":{\"fmt\":\"hd\",\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"vid\":\"$s1\",\"vt\":\"100\",\"format\":\"10412\"},\"from\":\"qq\",\"type_tag\":\"lua.qq.hd\",\"player_codec_config_list\":[\"TX_PLAYER\",\"AV_PLAYER\",\"IJK_HWPLAYER\",\"IJK_PLAYER\"],\"segment_list\":[{\"extra_info\":{\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"idx\":1},\"bytes\":0,\"meta_url\":\"http://vv.video.qq.com/getvclip?otype=xml&platform=11&encryptVer=5.1&appver=3.9.6.6991&fmt=hd&format=10412&vid=$s1&vt=100&idx=1&cKey=Zx6CuWnEIKx6P8HoAP2UvuOh5L4CyDagAX-YH5dLYvXcdiFFhWNMu4NM0YUhrCl73HNsf6Zf8iYEnvihtAzkjpJ3SPYYQIEkowqqFRlK_PAedsK-nwzTVZ_kitfKgVRzMynDi0pHz1hnNiZagOtH8OsAiDnmrEsS1Wz_SjOQW8kT0KyCM8sv8A\",\"duration\":223040}],\"index_mrl\":\"http/vsl://index_mrl\",\"need_ringbuf\":true,\"description\":\"高清\"},{\"available_period_milli\":21600000,\"parsed_milli\":1454053545000,\"extra_info\":{\"fmt\":\"shd\",\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"vid\":\"$s1\",\"vt\":\"100\",\"format\":\"10401\"},\"from\":\"qq\",\"type_tag\":\"lua.qq.shd\",\"player_codec_config_list\":[\"TX_PLAYER\",\"AV_PLAYER\",\"IJK_HWPLAYER\",\"IJK_PLAYER\"],\"segment_list\":[{\"extra_info\":{\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"idx\":1},\"bytes\":0,\"meta_url\":\"http://vv.video.qq.com/getvclip?otype=xml&platform=11&encryptVer=5.1&appver=3.9.6.6991&fmt=shd&format=10401&vid=$s1&vt=100&idx=1&cKey=Zx6CuWnEIKx6P8HoAP2UvuOh5L4CyDagAX-YH5dLYvXcdiFFhWNMu4NM0YUhrCl73HNsf6Zf8iYEnvihtAzkjpJ3SPYYQIEkowqqFRlK_PAedsK-nwzTVZ_kitfKgVRzMynDi0pHz1hnNiZagOtH8OsAiDnmrEsS1Wz_SjOQW8kT0KyCM8sv8A\",\"duration\":223040}],\"index_mrl\":\"http/vsl://index_mrl\",\"need_ringbuf\":true,\"description\":\"超清\"}]},\"play_index\":{\"available_period_milli\":21600000,\"parsed_milli\":1454053545000,\"extra_info\":{\"fmt\":\"shd\",\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"vid\":\"$s1\",\"vt\":\"100\",\"format\":\"10401\"},\"from\":\"qq\",\"type_tag\":\"lua.qq.shd\",\"player_codec_config_list\":[\"TX_PLAYER\",\"AV_PLAYER\",\"IJK_HWPLAYER\",\"IJK_PLAYER\"],\"segment_list\":[{\"extra_info\":{\"base_url\":\"http://vhotwsh.video.qq.com/flv/167/41/\",\"idx\":1},\"bytes\":0,\"meta_url\":\"http://vv.video.qq.com/getvclip?otype=xml&platform=11&encryptVer=5.1&appver=3.9.6.6991&fmt=shd&format=10401&vid=$s1&vt=100&idx=1&cKey=Zx6CuWnEIKx6P8HoAP2UvuOh5L4CyDagAX-YH5dLYvXcdiFFhWNMu4NM0YUhrCl73HNsf6Zf8iYEnvihtAzkjpJ3SPYYQIEkowqqFRlK_PAedsK-nwzTVZ_kitfKgVRzMynDi0pHz1hnNiZagOtH8OsAiDnmrEsS1Wz_SjOQW8kT0KyCM8sv8A\",\"duration\":223040}],\"index_mrl\":\"http/vsl://index_mrl\",\"need_ringbuf\":true,\"description\":\"超清\"}}"

local GetToken, GetCKey, CalculateCKey

local QQ_META_MAP = {
    -- 高清首选
    ["fhd"]     = {
        ["name"]            = "fhd",        -- QQ源 TAG
        ["type_tag"]        = "lua.qq.fhd", -- 客户端 TAG
        ["description"]     = "原画",        -- 描述
        ["kbps"]            = 1200,         -- 码率
        ["hq_score"]        = 0,            -- 高清优先级, -1 表示不支持
        ["lq_score"]        = 0,            -- 低清优先级, -1 表示不支持
        ["need_geturl_api"] = false,
        ["order"]           = 6
    },
    -- 低清首选
    ["shd"]     = {
        ["name"]            = "shd",
        ["type_tag"]        = "lua.qq.shd",
        ["description"]     = "超清",
        ["kbps"]            = 650,
        ["hq_score"]        = 100,
        ["lq_score"]        = 1,
        ["need_geturl_api"] = false,
        ["order"]           = 5
    },
    ["hd"]      = {
        ["name"]            = "hd",
        ["type_tag"]        = "lua.qq.hd",
        ["description"]     = "高清",
        ["kbps"]            = 235,
        ["hq_score"]        = 90,
        ["lq_score"]        = 90,
        ["need_geturl_api"] = false,
        ["order"]           = 4
    },
    ["sd"]      = {
        ["name"]            = "sd",
        ["type_tag"]        = "lua.qq.sd",
        ["description"]     = "标清",
        ["kbps"]            = 64,
        ["hq_score"]        = 80,
        ["lq_score"]        = 100,
        ["need_geturl_api"] = false,
        ["order"]           = 2
    },
    ["mp4"]     = {
        ["name"]            = "mp4",
        ["type_tag"]        = "lua.qq.mp4",
        ["description"]     = "mp4",
        ["kbps"]            = 64,
        ["hq_score"]        = 20,
        ["lq_score"]        = 20,
        ["need_geturl_api"] = true,
        ["order"]           = 1
    },
    ["flv"]     = {
        ["name"]            = "flv",
        ["type_tag"]        = "lua.qq.flv",
        ["description"]     = "flv",
        ["kbps"]            = 64,
        ["hq_score"]        = 10,
        ["lq_score"]        = 10,
        ["need_geturl_api"] = true,
        ["order"]           = 3
    },
    ["unknown"] = {
        ["name"]            = "unknown",
        ["type_tag"]        = "lua.qq.unknown",
        ["description"]     = "其他",
        ["kbps"]            = 0,
        ["hq_score"]        = -1,
        ["lq_score"]        = -1,
        ["need_geturl_api"] = false,
        ["order"]           = -1
    }
}

local function lprint(use_logcat, text)
    if use_logcat ~= nil and use_logcat then
        --require("biliapi").log(1, text)
    end
    if DEBUG then
        print(text)
    end
end

local QQ_META_REVERSE_MAP = {}
for k, v in pairs(QQ_META_MAP) do
    QQ_META_REVERSE_MAP[v["type_tag"]] = v;
end

local function get_meta_by_qq_stream_tag(id)
    local meta = QQ_META_MAP[tostring(id)]
    if meta == nil then
        meta = QQ_META_MAP["unknown"]
    meta["description"] = "其他("..id..")";
    end
    return meta;
end

local function qq_vod_meta_url_builder(media_info, stream_info, seg_info)
    return meta_url
end

function resolver.resolve_media_resource(resolve_params, device_info,device_rank)
    if (resolve_params["request_from_downloader"] == "false" or  resolve_params["request_from_downloader"] == false) and (device_info["os"] == "ios" or device_info["os"] == "IOS") then
        local result,_ = string.gsub(FAKE_MR_RESULT, "$s0", resolve_params["cid"])
        result = string.gsub(result, "$s1", resolve_params["vid"])
        return result
    end
    local expected_quality  = resolve_params["expected_quality"];
    local expected_type_tag = resolve_params["expected_type_tag"];
    local user_agent        = resolve_params["user_agent"];
    local qq_from    = resolve_params["from"]
    local qq_vid     = resolve_params["vid"]
    local qq_ckey = ""

    ::resolve_begin::
    qq_ckey = CalculateCKey(11, "5.1", "3.9.6.6991", qq_vid)

    if qq_ckey == nil or string.len(qq_ckey) == 0 then
        return nil
    end

    local use_logcat   = device_info["logcat"];
    if use_logcat == nil then use_logcat = false end

    lprint(use_logcat, "QQLuaResolver:"..VER_NAME);

    local url = "http://vv.video.qq.com/getvinfo"
    url = url.."?otype=xml"
    url = url.."&platform=11&encryptVer=5.1&appver=3.9.6.6991"
    url = url.."&defn=shd&defaultfmt=shd"
    url = url.."&speed=8064"
    url = url.."&vid="..qq_vid.."&vids="..qq_vid
    url = url.."&cKey="..qq_ckey

    lprint(use_logcat, url);
    local host = socket_url.parse(url).authority
    local r,c,h,s,body = utility.httpget(url, {["Host"] = host}, user_agent);

    if c ~= 200 then
        lprint(use_logcat, "failed["..c.."]["..user_agent.."]:"..url)
        lprint(use_logcat, body);
        return nil
    end

    -- utility.log(body)
    local xdom = xml.eval(body)
    local vi = vod_index:new()

    --------------------
    -- retrieve base urls
    local xnode_vi    = xdom:find("vl"):find("vi");
    local media_info  = {}
    media_info["vid"] = xnode_vi:find("vid")[1];
    media_info["fn"]  = xnode_vi:find("fn")[1];

    local lnk = nil
    local xnode_lnk = xnode_vi:find("lnk")
    if xnode_lnk ~= nil then  -- lnk node exists ?
        lnk = xnode_lnk[1]
    end
    if lnk ~= nil and lnk ~= "" and lnk ~= media_info["vid"] then  -- handle double vid, whose inner vid is shd
        qq_vid = lnk
        goto resolve_begin
    end

    for _, xnode_ui in pairs(xnode_vi:find("ul")) do
        if xnode_ui.TAG ~= nil and xnode_ui[xnode_ui.TAG] == "ui" then
            local v_url = xnode_ui:find("url")[1];
            local v_vt = xnode_ui:find("vt")[1];
            local i, j = string.find(v_url, "vhotwsh")

            if media_info["url"] == nil or media_info["url"] == "" then   -- first url
                media_info["url"] = v_url
                media_info["vt"] = v_vt
            elseif i ~= nil then    -- wangsu cdn, prefer it
                media_info["url"] = v_url
                media_info["vt"] = v_vt
            end

            if DEBUG or use_logcat then
                lprint(use_logcat, LOG_TAG.."ui")
                lprint(use_logcat, LOG_TAG.."  vid = "..media_info["vid"])
                lprint(use_logcat, LOG_TAG.."  fn  = "..media_info["fn"])
                lprint(use_logcat, LOG_TAG.."  vt  = "..media_info["vt"])
                lprint(use_logcat, LOG_TAG.."  url = "..media_info["url"])
            end
        end
    end

    --------------------
    -- retrieve stream list
    if DEBUG or use_logcat then
        lprint(use_logcat, LOG_TAG.."streams")
    end

    local type_tag_pi_map = {}
    local pi_list = {}


    local isAddFlv = true;
    local pi_tmp = nil;
    local isNewSeg = false;

    local xnode_fl = xdom:find("fl")

    for _, xnode_fi in pairs(xnode_fl) do
        if xnode_fi.TAG ~= nil and xnode_fi[xnode_fi.TAG] == "fi" then
            local url_from_geturl_api = nil;
            local pi = play_index:new()
            local stream_info = {}
            stream_info["br"]   = xnode_fi:find("br")[1];
            stream_info["id"]   = xnode_fi:find("id")[1];
            stream_info["name"] = xnode_fi:find("name")[1];
            local stream_meta = get_meta_by_qq_stream_tag(stream_info["name"])
            stream_info["meta"] = stream_meta

            pi:set_property_kv(KEY_NAMES["from"],     qq_from)
            pi:set_property_kv(KEY_NAMES["type_tag"], stream_meta["type_tag"])
            pi:set_property_kv(KEY_NAMES["description"], stream_meta["description"])

            -- pi:set_property_kv(KEY_NAMES["user_agent"],USER_AGENT)
            pi:set_property_kv(KEY_NAMES["need_ringbuf"], true)
            pi:set_property_kv(KEY_NAMES["parsed_milli"], os.time() * 1000)
            pi:set_property_kv(KEY_NAMES["available_period_milli"], AVAILABLE_PERIOD_MILLI)
            pi:set_property_kv(KEY_NAMES["extra_info"], {
                [EXTRA_VT] = media_info["vt"],
                [EXTRA_VID] = media_info["vid"],
                [EXTRA_FMT] = stream_info["name"],
                [EXTRA_FORMAT] = stream_info["id"],
                [EXTRA_BASE_URL]   = media_info["url"],
                [EXTRA_USER_AGENT] = user_agent
            });

            if DEBUG or use_logcat then
                lprint(use_logcat, LOG_TAG.."  stream:"..stream_info["name"]..":"..stream_info["br"].."kbps "..stream_meta["type_tag"].." "..stream_meta["description"])
            end

            if stream_meta["hq_score"] >= 0 and stream_meta["lq_score"] >= 0 then
                --------------------
                -- retrieve segment list
                local seg_info_list = {};
                local xnode_fclip = xnode_vi:find("fclip")
                local use_get_url = (xnode_fclip ~= nil and xnode_fclip[1] == "0")
                if stream_meta["need_geturl_api"] or use_get_url then  -- for old video which cannot use getvclip
                    if (url_from_geturl_api == nil) then
                        local url = "http://vv.video.qq.com/geturl?otype=xml"
                        url = url.."&platform=11"
                        url = url.."&format="..stream_info["id"]
                        url = url.."&vid="..qq_vid

                        lprint(use_logcat, url);
                        local host = socket_url.parse(url).authority
                        local r,c,h,s,body = utility.httpget(url, {["Host"] = host}, user_agent);
                        lprint(use_logcat, body);
                        if c ~= 200 then
                            lprint(use_logcat, "failed["..c.."]["..user_agent.."]:"..url)
                            lprint(use_logcat, body);
                            return nil
                        end

                        local xdom = xml.eval(body)
                        
                        local xnode_vd = xdom:find("vd")
                        if xnode_vd ~= nil then
                            local xnode_vi = xnode_vd:find("vi")
                            if xnode_vi ~= nil then
                                local xnode_url = xnode_vi:find("url")
                                if xnode_url ~= nil then
                                    url_from_geturl_api = xnode_url[1]
                                end
                            end
                        end
                    end

                    if url_from_geturl_api ~= nil and url_from_geturl_api ~= "" then
                        lprint(use_logcat, "url_from_geturl_api = "..url_from_geturl_api)
                    else
                        url = "http://vv.video.qq.com/getvkey"
                        url = url.."?otype=xml"
                        url = url.."&platform=11&encryptVer=5.1&appver=3.9.6.6991"
                        url = url.."&format="..stream_info["id"]
                        url = url.."&charge=0"
                        url = url.."&vid="..qq_vid
                        url = url.."&filename="..media_info["fn"]
                        url = url.."&ran="..math.random()
                        url = url.."&cKey="..qq_ckey

                        lprint(use_logcat, url);
                        host = socket_url.parse(url).authority
                        r,c,h,s,body = utility.httpget(url, {["Host"] = host}, user_agent);
                        lprint(use_logcat, body);
                        if c ~= 200 then
                            lprint(use_logcat, "failed["..c.."]["..user_agent.."]:"..url)
                            lprint(use_logcat, body);
                            return nil
                        end

                        local xdom = xml.eval(body)
                        
                        local xnode_key = xdom:find("key")
                        if xnode_key ~= nil then
                            local qq_key = xnode_key[1]
                            url_from_geturl_api = media_info["url"]..media_info["fn"]
                            url_from_geturl_api = url_from_geturl_api.."?vkey="..qq_key
                            lprint(use_logcat, "url_from_getkey_api = "..url_from_geturl_api)
                        else
                            lprint(use_logcat, "getvkey failed! key not found.")
                        end
                    end

                    local seg = segment:new()
                    seg:set_property_kv(KEY_NAMES["duration"], 0)
                    seg:set_property_kv(KEY_NAMES["bytes"],    0)
                    seg:set_property_kv(KEY_NAMES["url"],      url_from_geturl_api)

                    pi:add_segment(seg)
                    pi:set_normal_mrl(url_from_geturl_api)
                    pi:set_property_kv(KEY_NAMES["local_proxy_type"], PI_LOCAL_PROXY_TYPE_QQ_FLV)
                else
                    local xnode_cl = xnode_vi:find("cl")
                    local xnode_ci = nil
                    if xnode_cl ~= ni then
                        xnode_ci = xnode_cl:find("ci")
                    end
                    if xnode_ci ~= nil then
                        for _, xnode_ci in pairs(xnode_vi:find("cl")) do
                            if xnode_ci.TAG ~= nil and xnode_ci[xnode_ci.TAG] == "ci" then
                                local seg_info = {}
                                seg_info["cd"] = xnode_ci:find("cd")[1];
                                seg_info["index"] = #seg_info_list;
                                table.insert(seg_info_list, seg_info);

                                local meta_url = "http://vv.video.qq.com/getvclip"
                                meta_url = meta_url.."?otype=xml"
                                meta_url = meta_url.."&platform=11&encryptVer=5.1&appver=3.9.6.6991"
                                meta_url = meta_url.."&fmt="..stream_info["name"]
                                meta_url = meta_url.."&format="..stream_info["id"]
                                meta_url = meta_url.."&vid="..media_info["vid"]
                                meta_url = meta_url.."&vt="..media_info["vt"];
                                meta_url = meta_url.."&idx="..(seg_info["index"] + 1)
                                meta_url = meta_url.."&cKey="..qq_ckey

                                local seg = segment:new()
                                seg:set_property_kv(KEY_NAMES["duration"], seg_info["cd"] * 1000)
                                seg:set_property_kv(KEY_NAMES["bytes"],    0)
                                seg:set_property_kv(KEY_NAMES["meta_url"], meta_url)
                                seg:set_property_kv(KEY_NAMES["extra_info"], {
                                    [EXTRA_IDX] = seg_info["index"] + 1,
                                    [EXTRA_BASE_URL]   = media_info["url"],
                                    [EXTRA_USER_AGENT] = user_agent
                                });
                                -- seg[KEY_NAMES["extra_info"]][EXTRA_BASE_URL] = media_info["url"];
                                pi:add_segment(seg)

                                if DEBUG or use_logcat then
                                    lprint(use_logcat, LOG_TAG.."    segment:"..seg_info["cd"])
                                end
                            end
                        end
                    else
                        local seg_duration = 299
                        local td = xnode_vi:find("td")[1]

                        local cnt = math.floor(tonumber(td)/seg_duration)
                        if cnt == 0 then
                            cnt = 1
                        end
                        for i=1,cnt do
                            local seg_info = {}
                            seg_info["cd"] = td
                            seg_info["index"] = i;
                            table.insert(seg_info_list, seg_info);

                            local meta_url = "http://vv.video.qq.com/getvclip"
                            meta_url = meta_url.."?otype=xml"
                            meta_url = meta_url.."&platform=11&encryptVer=5.1&appver=3.9.6.6991"
                            meta_url = meta_url.."&fmt="..stream_info["name"]
                            meta_url = meta_url.."&format="..stream_info["id"]
                            meta_url = meta_url.."&vid="..media_info["vid"]
                            meta_url = meta_url.."&vt="..media_info["vt"];
                            meta_url = meta_url.."&idx="..(seg_info["index"])
                            meta_url = meta_url.."&cKey="..qq_ckey

                            local seg = segment:new()
                            if tonumber(i)==tonumber(cnt) then
                                seg:set_property_kv(KEY_NAMES["duration"], (seg_info["cd"] - seg_duration * (i - 1)) * 1000)
                            else
                                seg:set_property_kv(KEY_NAMES["duration"], seg_duration * 1000)
                            end

                            seg:set_property_kv(KEY_NAMES["bytes"],    0)
                            seg:set_property_kv(KEY_NAMES["meta_url"], meta_url)
                            seg:set_property_kv(KEY_NAMES["extra_info"], {
                                [EXTRA_IDX] = seg_info["index"],
                                [EXTRA_BASE_URL]   = media_info["url"],
                                [EXTRA_USER_AGENT] = user_agent
                            });
                            -- seg[KEY_NAMES["extra_info"]][EXTRA_BASE_URL] = media_info["url"];
                            pi:add_segment(seg)
                        end
                    end
                    pi:set_index_mrl(VSL_TAG, qq_vid)
                end

                local meta = QQ_META_MAP[stream_info["name"]]
                if meta == nil then
                    meta = QQ_META_MAP["unknown"]
                end
                pi["meta"] = meta

                if meta["name"] == "mp4" then
                    isAddFlv = false
                end

                if meta["name"] == "flv" then
                    pi_tmp = pi
                else
                    vi:add_play_index(pi);
                end

                if meta["name"] ~= "flv" and meta["name"] ~= "mp4" and meta["name"] ~= "unknown" then
                    isNewSeg = true;
                end

                type_tag_pi_map[stream_meta["type_tag"]] = pi;
                local pi_item = {
                    ["pi"] = pi,
                    ["stream_info"] = stream_info}
                table.insert(pi_list, pi_item);
            end -- end if
        end -- end if
    end -- end for

    if isAddFlv == true then
        vi:add_play_index(pi_tmp);
    end

    local app_version_code = tonumber(device_info["app_version_code"]);
    local os = device_info["os"];
    local isAllowRemoveMp4 = false;

    if os == "android" then
        isAllowRemoveMp4 = true;
    end

    if os == "ios" and device_info["app_version_name"] == "tv.danmaku.bilianime" and app_version_code > 890 then
        isAllowRemoveMp4 = true;
    end

    if isNewSeg == true and isAllowRemoveMp4 == true then
        --delete flv & mp4 in vi & pi_list
        local vod_list = vi[KEY_NAMES["vod_list"]];
        for k,v in pairs(vod_list) do
            if v ~= nil and v ~= nil then
                if v["meta"]["name"] == "sd" or v["meta"]["name"] == "flv" then
                    table.remove(vod_list, k);
                end
            end
        end

        for k,v in pairs(pi_list) do
            if  v ~= nil and v["pi"] ~= nil and v["pi"]["meta"] ~= nil then
                if v["pi"]["meta"]["name"] == "sd" or v["pi"]["meta"]["name"] == "flv" then
                    table.remove(pi_list, k);
                end
            end
        end
    end


    local mr = media_resource:new()
    mr:set_vod_index(vi)
    mr:set_resolve_params(resolve_params)

    local selected_pi = nil;
    local selected_type_tag = nil;
    if (expected_type_tag ~= nil and expected_type_tag ~= "") then
        if DEBUG or use_logcat then
            lprint(use_logcat, LOG_TAG.."select expected_type_tag: ".. expected_type_tag)
        end
        selected_pi = type_tag_pi_map[expected_type_tag];
        selected_type_tag = expected_type_tag;
    end
    if selected_pi == nil then
        table.sort(pi_list, function(left, right)
            if expected_quality >= 200 then
                -- high quality
                return left["stream_info"]["meta"]["hq_score"] >= right["stream_info"]["meta"]["hq_score"]
            else
                -- low quality
                return left["stream_info"]["meta"]["lq_score"] >= right["stream_info"]["meta"]["lq_score"]
            end
        end)
        
        selected_pi = pi_list[1]["pi"];
        if DEBUG or use_logcat then
            for _, pi_item in pairs(pi_list) do
                lprint(use_logcat, LOG_TAG.."after sort["..expected_quality.."]: "..selected_pi["type_tag"]);
            end
        end
    end

    mr:set_play_index(selected_pi);

    vi:init_player_codec_config_list(device_info,device_rank)

    selected_type_tag = pi_list[1]["stream_info"]["meta"]["type_tag"];

    if DEBUG or use_logcat then
        lprint(use_logcat, LOG_TAG.."select play index("..selected_type_tag.."): "..selected_pi["type_tag"]);
    end

    local vl = mr[KEY_NAMES["vod_index"]][KEY_NAMES["vod_list"]]
    utility.sort_vod_list(vl)
    local find_pi = utility.resolve_play_index(vl,resolve_params,device_info,device_rank)
    if find_pi ~= nil then
        mr:set_play_index(find_pi)
    end

    return mr;
end



function resolver.resolve_segment(pi, seg, device_info)
    local parsed_milli = pi["parsed_milli"]
    local seg_meta_url = seg[KEY_NAMES["meta_url"]]
    local extra_info   = seg[KEY_NAMES["extra_info"]]
    local base_url     = extra_info[EXTRA_BASE_URL]
    local user_agent   = extra_info[EXTRA_USER_AGENT]

    local use_logcat   = device_info["logcat"]
    if use_logcat == nil then use_logcat = false end

    if os.time() * 1000 - parsed_milli >= AVAILABLE_CKEY_MILLI then
        lprint(use_logcat, LOG_TAG.."meta_url #"..extra_info["idx"].." has been timeout, regenerate meta_url!")

        local pi_extra = pi["extra_info"]
        local vid = pi_extra["vid"]

        local qq_ckey = CalculateCKey(11, "5.1", "3.9.6.6991", vid)

        if qq_ckey ~= nil and string.len(qq_ckey) > 0 then
            local vclip_url = "http://vv.video.qq.com/getvclip"
            vclip_url = vclip_url.."?otype=xml"
            vclip_url = vclip_url.."&platform=11&encryptVer=5.1&appver=3.9.6.6991"
            vclip_url = vclip_url.."&fmt="..pi_extra["fmt"]
            vclip_url = vclip_url.."&format="..pi_extra["format"]
            vclip_url = vclip_url.."&vid="..vid
            vclip_url = vclip_url.."&vt="..pi_extra["vt"]
            vclip_url = vclip_url.."&idx="..extra_info["idx"]
            vclip_url = vclip_url.."&cKey="..qq_ckey

            seg_meta_url = vclip_url
        end
    end

    if DEBUG or use_logcat then
        lprint(use_logcat, LOG_TAG.."resolve meta "..seg_meta_url);
        lprint(use_logcat, LOG_TAG.."resolve base_url "..base_url);
    end

    math.randomseed(os.time());

    lprint(use_logcat, seg_meta_url);
    local host = socket_url.parse(seg_meta_url).authority
    local r,c,h,s,body = utility.httpget(seg_meta_url, {["Host"] = host}, user_agent);

    if c ~= 200 then
        if DEBUG then
            utility.log("failed["..c.."]:"..seg_meta_url)
        end
        return nil
    end

    -- utility.log(body)
    local xdom = xml.eval(body)
    local xnode_vi = xdom:find("vi");

    local key      = xnode_vi:find("key")[1];
    local fmt      = xnode_vi:find("fmt")[1];
    local fn       = xnode_vi:find("fn")[1];
    local fs       = xnode_vi:find("fs")[1];    -- size
    local fn_split = utility.split(fn, ".");
    local ftype    = fn_split[#fn_split];
    local fpath    = fn
    fpath = fpath.."?vkey="..key
    fpath = fpath.."&fmt="..fmt
    fpath = fpath.."&type="..ftype;

    seg[KEY_NAMES["url"]] = base_url..fpath;

    return seg;
end

local _gKeyToken = {
    0x32, 0x93, 0x82, 0x4D, 0x60, 0x84, 0x5F, 0x51, 0x20, 0x72, 0xF2, 0xF4, 0x8B, 0x67, 0x4E, 0x01
}

local gKeyToken = ByteBuffer.new()
for k,v in pairs(_gKeyToken) do
    gKeyToken:push_byte(v)
end

local gMaskToken = {
    0x60, 0x47, 0x93, 0x56
}

local _gKeyCKey = {
    0xCA, 0x08, 0x15, 0xB5, 0xB3, 0xC9, 0x53, 0xA0, 0x69, 0x13, 0xAD, 0x4D, 0x57, 0xCA, 0x15, 0x7C
}

local gKeyCKey = ByteBuffer.new()
for k,v in pairs(_gKeyCKey) do
    gKeyCKey:push_byte(v)
end

local UInt32_MaxValue = 4294967295

local function OverflowPlus(a, b)
    local value = a + b
    if value > UInt32_MaxValue then
        value = value - UInt32_MaxValue - 1
    elseif value < 0 then
        value = UInt32_MaxValue + value + 1
    end
    return value
end

local function OverflowMinus(a, b)
    local value = a - b
    if value > UInt32_MaxValue then
        value = value - UInt32_MaxValue - 1
    elseif value < 0 then
        value = UInt32_MaxValue + value + 1
    end
    return value
end

local function UInt32_Clip(input)
    local result = input
    if input > UInt32_MaxValue then
        result = input - UInt32_MaxValue - 1
    elseif input < 0 then
        result = UInt32_MaxValue + input + 1
    end
    return result
end

local function HenKan(a, b, c)
    local x, y, z
    local s = ByteBuffer.new()
    local i = 0

    s:push_int64(0)
    s:push_int64(0)

    x = UInt32_Clip(bit.bswap(a:get_int32_at(1)))
    y = UInt32_Clip(bit.bswap(a:get_int32_at(5)))
    z = 0

    for i = 0, 3 do
        s:set_int32_at(i * 4 + 1, bit.bswap(b:get_int32_at(i * 4 + 1)))
    end

    for i = 1, 16 do
        z = OverflowMinus(z, 0x61c88647)
        x = OverflowPlus(x, bit.bxor(bit.bxor(OverflowPlus(bit.rshift(y, 5), s:get_int32_at(5)), OverflowPlus(bit.lshift(y, 4), s:get_int32_at(1))), OverflowPlus(y, z)))
        y = OverflowPlus(y, bit.bxor(bit.bxor(OverflowPlus(bit.rshift(x, 5), s:get_int32_at(13)), OverflowPlus(bit.lshift(x, 4), s:get_int32_at(9))), OverflowPlus(x, z)))
    end

    c:set_int32_at(1, bit.bswap(x))
    c:set_int32_at(5, bit.bswap(y))
end

local function Transform(data, key)
    assert(ByteBuffer.is_instance(data))

    local mod = 0; local pad = 0; local off = 0
    local r = ByteBuffer.new()
    local s = ByteBuffer.new()
    local t = ByteBufferPtr.new()

    local result = ByteBuffer.new()
    local out_data = ByteBufferPtr.new(result)

    for i = 1, 2 do
        r:push_int32(0)
        s:push_int32(0)
    end

    for i = 1, 16 do
        result:push_int32(0)
    end

    mod = (data:length() + 10) % 8
    pad = 0
    if mod ~= 0 then
        pad = 8 - mod
    end
    r[1] = bit.bor(pad, bit.band(math.random(255), 0xF8))
    off = 1
    
    for i = 1, pad do
        r[off + 1] = math.random(255)
        off = off + 1
    end
    
    t:bind(s)
    for i = 1, 2 do
        if off < 8 then
            r[off + 1] = math.random(255)
            off = off + 1
        end
        if off == 8 then
            for j = 1, 8 do
                r[j] = bit.bxor(r[j], t[j])
            end
            HenKan(r, key, out_data)
            for j = 1, 8 do
                out_data[j] = bit.bxor(out_data[j], s[j])
            end
            for j = 1, 8 do
                s[j] = r[j]
            end
            off = 0
            t:bind(out_data:get_buffer())
            t:sync_offset(out_data)
            out_data:add_offset(8)
        end
    end
    
    local data_ptr = 1
    for i = 1, data:length() do
        if off < 8 then
            r[off + 1] = data[data_ptr]
            data_ptr = data_ptr + 1
            off = off + 1
        end
        if off == 8 then
            for j = 1, 8 do
                r[j] = bit.bxor(r[j], t[j])
            end
            HenKan(r, key, out_data)
            for j = 1, 8 do
                out_data[j] = bit.bxor(out_data[j], s[j])
            end
            for j = 1, 8 do
                s[j] = r[j]
            end
            off = 0
            t:bind(out_data:get_buffer())
            t:sync_offset(out_data)
            out_data:add_offset(8)
        end
    end

    for i = 1, 8 do
        if off < 8 then
            r[off + 1] = 0
            off = off + 1
        end
        if off == 8 then
            for j = 1, 8 do
                r[j] = bit.bxor(r[j], t[j])
            end
            HenKan(r, key, out_data)
            for j = 1, 8 do
                out_data[j] = bit.bxor(out_data[j], s[j])
            end
            for j = 1, 8 do
                s[j] = r[j]
            end
            off = 0
            t:bind(out_data:get_buffer())
            t:sync_offset(out_data)
            out_data:add_offset(8)
        end
    end

    return result
end

local gMap = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
local function Encode(si)
    local i, l
    local li = si:length()
    local ptr = si
    l = li % 3
    if l ~= 0 then
        l = 1
    end
    l = l + math.floor(li / 3)
    l = l * 4
    local lo = 512
    local so = {}
    local ch = 0
    local index = 1
    local lasti = 0
    for i = 0, math.floor(li/3) - 1 do
        ch = bit.band(bit.rshift(ptr[i * 3 + 1], 2), 0x3f)
        so[i * 4 + 1] = gMap:sub(ch + 1, ch + 1)
        ch = bit.bor(bit.lshift(bit.band(ptr[i * 3 + 1], 3), 4), bit.rshift(ptr[i * 3 + 2], 4))
        so[i * 4 + 2] = gMap:sub(ch + 1, ch +1)
        ch = bit.bor(bit.lshift(bit.band(ptr[i * 3 + 2], 0xf),2), bit.rshift(ptr[i * 3 + 3], 6))
        so[i * 4 + 3] = gMap:sub(ch + 1, ch +1)
        ch = bit.band(ptr[i * 3 + 3], 0x3f)
        so[i * 4 + 4] = gMap:sub(ch + 1, ch +1)
        index = index + 1
        lasti = i
    end
    local i = lasti + 1
    if (li % 3) > 0 then
        ch = bit.band(bit.rshift(ptr[i * 3 + 1], 2), 0x3f)
        so[4 * i + 1] = gMap:sub(ch + 1, ch +1)
        l = l - 1
        if (li % 3) == 2 then
            ch = bit.bor(bit.lshift(bit.band(ptr[i * 3 + 1], 3), 4), bit.rshift(ptr[i * 3 + 2], 4))
            so[4 * i + 2] = gMap:sub(ch + 1, ch +1)
            ch = bit.lshift(bit.band(ptr[i * 3 + 2], 0xf), 2)
            so[4 * i + 3] = gMap:sub(ch + 1, ch +1)
        else
            ch = bit.lshift(bit.band(ptr[i * 3 + 1], 3), 4)
            so[4 * i + 2] = gMap:sub(ch + 1, ch +1)
            l = l - 1
        end
    end
    lo = l
    local ckey = ByteBuffer.new()
    for k, v in pairs(so) do
        ckey:push_char(v)
    end
    return ckey
end

GetToken = function(hash, platform, appver)
    local str = ByteBuffer.new()

    str:push_short(0)
    str:push_short(1)
    str:push_int32(platform)

    str:push_short(string.len(appver))
    str:push_string(appver)

    str:push_short(string.len(hash))
    str:push_string(hash)

    str:set_short_at(1, str:length() - 2)

    local transformed = Transform(str, gKeyToken)

    local tmp_buf = ByteBuffer.new()
    tmp_buf:copy_from(transformed)

    transformed:copy_from(tmp_buf, tmp_buf:length(), 1, 7)
    transformed:set_short_at(3, 1)
    transformed:set_short_at(5, 0x9c78)
    transformed:set_short_at(1, tmp_buf:length() + 4)


    local sock = assert(socket.connect("rlog.video.qq.com", 8080))
    sock:send(transformed:to_string())

    local tmp = ByteBuffer.new()

    local timeout = 1
    local retry_count = 0
    local status = ""

    ::begin::
    sock:settimeout(timeout, "b")
    repeat
        local chunk, _status, partial = sock:receive(1)
        status = _status
        if chunk ~= nil then
            tmp:push_string(chunk)
        end
    until chunk == nil

    if status == "timeout" and tmp:length() == 0 then
        if retry_count < 3 then
            timeout = timeout + 1
            retry_count = retry_count + 1
            goto begin
        else
            tmp:clear()
            return tmp
        end
    end

    sock:close()

    local response_length = tmp:length()
    for i = 0, response_length - 3 do
        tmp[i + 2 + 1] = bit.bxor(tmp[i + 2 + 1], gMaskToken[i % #gMaskToken + 1])
    end

    return tmp
end

GetCKey = function(token, platform, encrypt_version, appver, vid, time)
    local str = ByteBuffer.new()

    str:push_short(0)
    str:push_string("n:x")
    str:push_byte(0)

    str:push_int32(platform)
    str:push_int32(time)

    str:push_short(string.len(encrypt_version))
    str:push_string(encrypt_version)

    str:push_short(string.len(appver))
    str:push_string(appver)

    str:push_short(string.len(vid))
    str:push_string(vid)

    str:push_short(token:length())
    str:push_string(token:to_string())

    str:set_short_at(1, str:length() - 2)

    local out = Transform(str, gKeyCKey)

    return Encode(out)
end

CalculateCKey = function(platform, encrypt_version, appver, vid)
    local token = GetToken("01012323454567678989010123234545", platform, appver)

    if token == nil or token:length() == 0 then
        return nil
    end

    local param_token = ByteBuffer.new()
    param_token:copy_from(token, token:length() - 2, 3, 1)

    return GetCKey(param_token, platform, encrypt_version, appver, vid, os.time() - 30):to_string()
end

return resolver