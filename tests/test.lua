local http_client = require('http.client')
local json = require('json')
local tap = require('tap')
local taptest = tap.test("test_api")

local host = os.getenv('APP_HOST')
if host == nil then 
    host = "http://localhost:8080/"
end
local url = host .. '/kv'

local test_key = '1'
local insert_val = {val = 'test_insert'}
local update_val = {val = 'test_update'}
local insert_data = json.encode({key = test_key, value = insert_val})
local update_data = json.encode({value = update_val})

local test_cases = {
    {
        name = 'test insert',
        method = 'POST',
        key = '',
        body = insert_data,
        expected_status = 201,
        expected_body = 'OK'
    },
    {
        name = 'test insert duplicate key',
        method = 'POST',
        key = '',
        body = insert_data,
        expected_status = 409,
        expected_body = json.encode({error = 'Key '..test_key..' exists.'})
    },
    {
        name = 'test insert invalid body',
        method = 'POST',
        key = '',
        body = 'invalid_body',
        expected_status = 400,
        expected_body = json.encode({error = 'Invalid body'})
    },
    {
        name = 'test get existing key',
        method = 'GET',
        key = test_key,
        expected_status = 200,
        expected_body = json.encode(insert_val)
    },
    {
        name = 'test get nonexisting key',
        method = 'GET',
        key = 'nonexisting_key',
        expected_status = 404,
        expected_body = json.encode({error = 'Key nonexisting_key not exists.'})
    },
    {
        name = 'test update',
        method = 'PUT',
        key = test_key,
        body = update_data,
        expected_status = 200,
        expected_body = 'OK'
    },
    {
        name = 'test get after update',
        method = 'GET',
        key = test_key,
        expected_status = 200,
        expected_body = json.encode(update_val)
    },
    {
        name = 'test update nonexisting key',
        method = 'PUT',
        key = 'nonexisting_key',
        body = update_data,
        expected_status = 404,
        expected_body = json.encode({error = 'Key nonexisting_key not exists.'})
    },
    {
        name = 'test update invalid body',
        method = 'PUT',
        key = test_key,
        body = 'invalid_body',
        expected_status = 400,
        expected_body = json.encode({error = 'Invalid body'})
    },
    {
        name = 'test delete existing key',
        method = 'DELETE',
        key = test_key,
        expected_status = 200,
        expected_body = 'OK'
    },
    {
        name = 'test delete nonexisting key',
        method = 'DELETE',
        key = 'nonexisting_key',
        expected_status = 404,
        expected_body = json.encode({error = 'Key nonexisting_key not exists.'})
    },
    {
        name = 'test get after delete',
        method = 'GET',
        key = test_key,
        expected_status = 404,
        expected_body = json.encode({error = 'Key '..test_key..' not exists.'})
    }
}

local function test_func(data)
    return function(taptest)
        local key = data.key
        local req_url = url
        if key ~= '' then
            req_url = req_url .. '/' .. key
        end

        local resp = http_client.request(data.method, req_url, data.body)
        taptest:plan(2)
        taptest:is(resp.status, data.expected_status)
        taptest:is(resp.body, data.expected_body)
    end
end

local cnt_tests = table.getn(test_cases)
taptest:plan(cnt_tests)
for i = 1, cnt_tests do
    taptest:test(test_cases[i].name, test_func(test_cases[i]))
end

taptest:check()