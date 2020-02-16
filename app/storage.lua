local log = require('log')

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
        log.info('DB started')
    end,

    find = function(self, key)
        local value = self.space:select({key})
        return (value ~= nil and next(value) ~= nil)
    end,

    get = function(self, key)
        local obj = self.space:select({key})
        log.info('Key "%s" selected', key)
        return obj[1][2]
    end,

    post = function(self, key, value)
        self.space:insert({key, value})
        log.info('Key "%s" inserted', key)
    end,

    put = function(self, key, value)
        self.space:replace({key, value})
        log.info('Value with key "%s" updated', key)
    end,

    delete = function(self, key, value)
        self.space:delete({key})
        log.info('Key "%s" deleted', key)
    end,
}

return storage
