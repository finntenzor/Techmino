local function connect(url)
    print('Debug client open')
    return {
        messages={},
    }
end

local function copyTable(input)
    local copy = {}
    for k, v in pairs(input) do
        copy[k] = v
    end
    setmetatable(input, getmetatable(input))
    return copy
end

-- /**
--  * @brief data, err = client.read(conn)
--  *
--  * luatc_read is the function that serves the client.read on
--  * the lua side. Each call to this function will nonblockingly
--  * read some contents from connection and return to the caller.
--  *
--  * - When the data available for read in the connection is
--  *   <data>, this function will returns <data, nil>.
--  * - When there's currently no more data available in the
--  *   connection, <nil, nil> will be returned.
--  * - When the connection has been closed with some unrecoverable
--  *   error <err>, then <nil, err> will be returned. The error
--  *   must be a string.
--  * - This function might also returns <{}, nil> if this function
--  *   returns <{data1, data2, ...}, nil> as normal form of result.
--  *
--  * If the caller unref the connection with data available for
--  * read, those data will be discarded automatically.
--  */
local function read(conn)
    local copy = {}
    local n = #conn.messages
    for i = 1, n do
        copy[i] = conn.messages[i]
    end
    conn.messages={}
    return copy, nil
end

-- /**
--  * @brief err = client.write(conn, ...)
--  *
--  * luatc_write is the function that serves the client.write on
--  * the lua side. Each call to this function will nonblockingly
--  * write some content to the connection.
--  *
--  * - When the connection is not closed, calling this function
--  *   will pass all content followed by the connection userdata
--  *   to the stream function. And if the argument is invalid
--  *   then error will be returned to the caller (if any). And
--  *   nil will be returned if the write success.
--  * - When the connection is closed, the connection close causing
--  *   will be returned to the caller.
--  * - All errors returned must be a string.
--  *
--  * If the caller unref the stream with data pending to send,
--  * the default behaviour is that the stream closes after all
--  * data has sent. If there's any exception, they should explicit
--  * point out in the connection initialization function.
--  */
local function write(conn, data)
    for i = 2, 5 do
        local copy = copyTable(data)
        copy.clientID = i
        table.insert(conn.messages, copy)
    end
end

local exports = {
    connect = connect,
    read = read,
    write = write,
}
return exports
