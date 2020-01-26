local log = require("log")

local storage = {
    init = function(self, conf)
        box.cfg{
            listen = conf.listen,
        }
        box.once('init', function()
            space = box.schema.space.create('storage')
            space:format({
                {name = 'key', type = 'string'},
                {name = 'value'},
            })
            space:create_index('primary', {
                type = 'hash',
                parts = {'key'}
            })
            end
        )
        self.space = box.space.storage
    end,

    find = function(self, key)
        local value = self.space:select({key})
        return (value ~= nil and next(value) ~= nil)
    end,

    get = function(self, key)
        local obj = self.space:select({key})
        return obj[1][2]
    end,

    post = function(self, key, value)
        self.space:insert({key, value})
    end,

    put = function(self, key, value)
        self.space:replace({key, value})
    end,

    delete = function(self, key, value)
        self.space:delete({key})
    end,
}

return storage
