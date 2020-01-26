#!/usr/bin/env tarantool

local conf = require('conf')
local server = require('server')
local storage = require('storage')

storage:init(conf.storage)
server:init(storage, conf.server)
server:start()
