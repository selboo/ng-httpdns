

local HTTPDNS = ngx.shared.HTTPDNS

local host = ngx.var.arg_host
local resolve = ngx.var.arg_resolve
local cjson = require "cjson"

local resolveserver = "127.0.0.1"
local resolver = require "resty.dns.resolver"

local result = {}
local ttl = 10

if resolve then
    resolveserver = resolve
end

if not host then
    host = "www.aikaiyuan.com"
end


function dns_query(host, resolveserver)

    local r, err = resolver:new{
        nameservers = { resolveserver },
        retrans = 2,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    }

    if not r then
        return "failed to instantiate the resolver", err, 1
    end

    local answers, err, tries = r:query(host, nil, { r.TYPE_A })
    if not answers then
        return "failed to query the DNS server", err, 1
    end

    result["error"] = ""
    result["status"] = 0

    if answers.errcode then
        result["status"] = answers.errcode
        result["error"]  = answers.errstr
    end

    result["ips"] = {}
    result["host"] = host

    for i, ans in ipairs(answers) do

        -- ngx.say(ans.name, " ", ans.address or ans.cname,
        --        " type:", ans.type, " class:", ans.class,
        --        " ttl:", ans.ttl)

        if ans.type == 1 then -- A
            table.insert(result["ips"], ans.address)
            if ans.ttl then
                ttl = ans.ttl
            end
        end

    end

    return result, nil, ttl

end


local answer, err = HTTPDNS:get(host)
if not answer then
    ngx.log(ngx.INFO, "host: ", host,  " MISS")
    local var, err, ttl = dns_query(host, resolveserver)
    if not err then
        answer = cjson.encode(var)

        local succ, err = HTTPDNS:set(host, answer, ttl)
        if err then
            ngx.log(ngx.ERR, "save httpdns error: ", err)
        else
            ngx.log(ngx.WARN, "save: ", host, "save httpdns ok: ", answer)
        end

    end
end

ngx.log(ngx.INFO, "host: ", host, " HIT")

-- return
ngx.say(answer)



