local log = require('log')
local http_server = require('http.server')
local handlers = require('handlers')

local server = {
    init = function(self, storage, conf)
        local routers = handlers.register(storage)
        self.server = http_server.new(conf.host, conf.port, {
            log_requests = true,
            log_errors = true
        })
        self.server:set_router(routers)
    end,

    start = function(self)
        self.server:start()
        log.info("HTTP server started")
    end,
}

return server