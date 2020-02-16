#!/usr/bin/env tarantool

local json = require('json')
local log = require('log')
local http_router = require('http.router')

local function bad_request(req, code, msg)
    local resp = req:render({json = {error = msg}})
    resp.status = code
    log.info('Request failed: %s', msg)
    return resp
end

local routers = {
    init = function(self, storage)
        self.storage = storage
        return self
    end,

    get = function(self, req)
        return function(req)
            local key = req:stash('id')

            if (self.storage:find(key) == false) then
                return bad_request(req, 404, 'Key '..key..' not exists.')
            end

            local rec = self.storage:get(key)
            return { status = 200, body = json.encode(rec) }
        end
    end,

    post = function(self, req)
        return function(req)
            local status, obj = pcall(function() return req:json() end)
            local key, value = obj['key'], obj['value']

            if not status or (type(key) ~= 'string') or (value == nil) then
                return bad_request(req, 400, 'Invalid body')
            end

            if (self.storage:find(key)) then
                return bad_request(req, 409, 'Key '..key..' exists.')
            end

            self.storage:post(key, value)
            return { status = 201, body = 'OK' }
        end
    end,

    put = function(self, req)
        return function(req)
            local key = req:stash('id')
            local status, obj = pcall(function() return req:json() end)

            if not status then
                return bad_request(req, 400, 'Invalid body')
            end

            local value = obj['value']
            if (self.storage:find(key) == false) then
                return bad_request(req, 404, 'Key '..key..' not exists.')
            end

            self.storage:put(key, value)
            return { status = 200, body = 'OK' }
        end
    end,

    delete = function(self, req)
        return function(req)
            local key = req:stash('id')

            if (self.storage:find(key) == false) then
                return bad_request(req, 404, 'Key '..key..' not exists.')
            end

            self.storage:delete(key)
            return { status = 200, body = 'OK' }
        end
    end,

    get_handler = function(self) return self:get() end,
    post_handler = function(self) return self:post() end,
    put_handler = function(self) return self:put() end,
    delete_handler = function(self) return self:delete() end,
}

local register = function(storage)
    local r = routers:init(storage)
    return http_router.new()
            :route({
                    method = 'GET',
                    path = '/kv/:id',
                },
                r:get_handler()
            )
            :route({
                    method = 'POST',
                    path = '/kv',
                },
                r:post_handler()
            )
            :route({
                    method = 'PUT',
                    path = '/kv/:id',
                },
                r:put_handler()
            )
            :route({
                    method = 'DELETE',
                    path = '/kv/:id',
                },
                r:delete_handler()
            )
end

return {
    register = register
}