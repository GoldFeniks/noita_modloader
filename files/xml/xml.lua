dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/xml/state_table.lua")

string_buffer = {}
string_buffer.__name = "string_buffer"
string_buffer.__index = string_buffer

string_buffer.new = make_smart_function(function (self, data)
    local buffer = {}
    setmetatable(buffer, self)

    buffer.data = data
    buffer.left  = 1
    buffer.right = 0

    return buffer
end, { "self", "data" })

string_buffer.next = function (self)
    self.right = self.right + 1
    if self.right > #self.data then
        return "\0"
    end

    return self.data:sub(self.right, self.right)
end

string_buffer.value = function (self)
    return self.data:sub(self.left, self.right - 1)
end

string_buffer.cut = make_smart_function(function (self, offset)
    self.left = self.right + (offset or 0)
end, { "self", "offset" })

string_buffer.rollback = function (self)
    self.right = self.left
end


xml_tag = {}

xml_tag.__index = function (self, key)
    local value = xml_tag[key]
    if value ~= nil then
        return value
    end

    return self.__parameters[key]
end

xml_tag.__newindex = function (self, key, value)
    self.__parameters[key] = value
end

xml_tag.__name = "xml_tag"

xml_tag.new = make_smart_function(function (self, name, parameters, children)
    local tag = {
        __name=name,
        __parameters={},
        __n_parameters=0,
        __children=children or {}
    }

    setmetatable(tag, self)

    for key, value in pairs(parameters) do
        tag:set_parameter(key, value)
    end

    return tag
end, { "self", "name", "parameters", "children" }, { parameters={} })

xml_tag.set_parameter = make_smart_function(function (self, name, value)
    if self.__parameters[name] == nil then
        rawset(self, "__n_parameters",  self.__n_parameters + 1)
    end

    self.__parameters[name] = value
end, { "self", "name", "value" })

xml_tag.get_parameter = make_smart_function(function (self, name)
    return self.__parameters[name]
end, { "self", "name" })

xml_tag.update_parameters = make_smart_function(function (self, parameters)
    for key, value in pairs(parameters) do
        self:set_value(key, value)
    end
end, { "self", "parameters" })

xml_tag.add_child = make_smart_function(function (self, child)    
    table.insert(self.__children, child)
end, { "self", "child" })

xml_tag.get_child = make_smart_function(function (self, idx)
    return self.__children[idx]
end, { "self", "idx" })

xml_tag.__check = function (self, tag_name, filters)
    if self.__name ~= tag_name then
        return false
    end

    for key, checker in pairs(filters) do
        local value = self.__parameters[key]
        if value == nil then
            return false
        end

        if type(checker) == "string" and checker ~= value then
            return false
        end

        if type(checker) == "function" and not checker(value) then
            return false
        end
    end

    return true
end

xml_tag.find = make_smart_function(function (self, tag_name, filters, levels, allow_recursive, result, level)
    result = result or {}

    if self:__check(tag_name, filters) then
        table.insert(result, self)

        if not allow_recursive then
            return result
        end
    end

    if level >= levels then
        return result
    end

    for i, tag in ipairs(self.__children) do
        tag:find(tag_name, filters, levels, allow_recursive, result, level + 1)
    end

    return result
end, { "self", "tag_name", "filters", "levels", "allow_recursive", "result", "level" }, { filters={}, levels=1, allow_recursive=false, level=0 })

xml_tag.to_string = make_smart_function(function (self, indent, offset, newline)
    if newline == "" then
        newline = " "
    end

    local result = string.format("%s<%s", offset, self.__name)

    local new_offset = offset .. string.rep(" ", indent)

    if self.__n_parameters == 1 then
        for key, value in pairs(self.__parameters) do
            result = string.format("%s %s=\"%s\"", result, key, value)
        end
    else
        for key, value in pairs(self.__parameters) do
            result = string.format("%s%s%s%s=\"%s\"", result, newline, new_offset, key, value)
        end
    end

    if #self.__children > 0 then
        result = result .. ">"

        for i, value in ipairs(self.__children) do
            result = result .. newline .. newline .. value:to_string(indent, new_offset, newline)
        end

        result = string.format("%s%s%s</%s>", result, newline, offset, self.__name)
    else
        result = string.format("%s%s%s></%s>", result, newline, offset, self.__name)
    end

    return result
end, { "self", "indent", "offset", "newline" }, { indent=4, offset="", newline="\n" })

xml_tag.__tostring = xml_tag.to_string


xml_parser = {}
xml_parser.__index = xml_parser
xml_parser.__name = "xml_parser"

xml_parser.new = make_smart_function(function (self, buffer)
    local parser = {}
    setmetatable(parser, self)

    parser.buffer = string_buffer:new(buffer)
    parser.state  = state_table.states.DEFAULT
    parser.line   = 1
    parser.column = 1
    
    return parser
end, { "self", "buffer" })

xml_parser.__error = function (self, reason)
    if reason ~= nil then
        reason = " : " .. reason
    else
        reason = ""
    end

    error(string.format("Error parsing XML at line %i, column %i%s", self.line, self.column, reason))
end

xml_parser.__next = function (self)
    local value = self.buffer:next()
    if value == "\0" then
        self:__error("End of file reached")
    end
    
    self.state = state_table:next_state(self.state, value)

    if self.state == state_table.states.ERROR then
        self:__error()
    end

    if value == '\n' then
        self.line = self.line + 1
        self.column = 0
    end

    self.column = self.column + 1

    return self.state
end

xml_parser.__skip_all = function (self, state)
    while self:__next() == state do
    end
end

xml_parser.__find_next = function (self, state)
    while self:__next() ~= state do
    end
end

xml_parser.__parse_sequence = function (self, state)
    self.buffer:cut()

    self:__skip_all(state)

    return self.buffer:value()
end

xml_parser.__require_next = function (self, state)
    if self:__next() ~= state then
        self:__error()
    end
end

xml_parser.__parse_parameter = function (self)
    local name = self:__parse_sequence(state_table.states.PARAMETER_NAME)

    self:__find_next(state_table.states.PARAMETER_VALUE_START)

    local value = ""
    if self:__next() == state_table.states.PARAMETER_VALUE then
        value = self:__parse_sequence(state_table.states.PARAMETER_VALUE)
    end

    return name, value
end

xml_parser.parse = function (self)
    self:__require_next(state_table.states.TAG_START)
    self:__require_next(state_table.states.TAG_NAME)

    local name = self:__parse_sequence(state_table.states.TAG_NAME)
    local tag = xml_tag:new(name)

    while self.state ~= state_table.states.TAG_NEXT_CLOSE and self.state ~= state_table.states.TAG_END do
        local state = self:__next()

        if state == state_table.states.PARAMETER_NAME then
            local name, value = self:__parse_parameter()
            tag:set_parameter(name, value)
        end
    end

    if self.state == state_table.states.TAG_NEXT_CLOSE then
        self:__require_next(state_table.states.TAG_CLOSE)
        return tag
    end

    while true do
        local state = self.state
        self.buffer:cut()        

        while true do
            self:__find_next(state_table.states.TAG_START)

            self.buffer:cut((-1))

            if self:__next() ~= state_table.states.COMMENT_START then
                break
            end
        end

        if self.state == state_table.states.CLOSE_TAG_START then
            self:__skip_all(state_table.states.CLOSE_TAG_START)

            local closing_name = self:__parse_sequence(state_table.states.CLOSE_TAG_NAME)
            if closing_name ~= name then
                self:__error(string.format("Incorrect closing tag name: %s != %s", name, closing_name))
            end

            if self.state == state_table.states.CLOSE_TAG_NEXT_CLOSE then
                self:__skip_all(state_table.states.CLOSE_TAG_NEXT_CLOSE)
            end

            break
        end        

        self.state = state
        self.buffer:rollback()
        tag:add_child(self:parse())
    end

    return tag
end
