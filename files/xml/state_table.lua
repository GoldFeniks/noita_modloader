local states = {
    DEFAULT=0,

    TAG_START=1,
    TAG_NEXT_CLOSE=2,
    TAG_END=3,
    TAG_CLOSE=4,
    TAG_NAME=5,
    TAG_PARAMETERS=6,

    PARAMETER_NAME=7,
    PARAMETER_EQUALS=8,
    PARAMETER_NEXT_VALUE_START=9,
    PARAMETER_VALUE_START=10,
    PARAMETER_VALUE=11,
    PARAMETER_VALUE_END=12,

    CLOSE_TAG_START=13,
    CLOSE_TAG_NAME=14,
    CLOSE_TAG_NEXT_CLOSE=15,

    COMMENT_START=16,
    COMMENT_START_FIRST_DASH=17,
    COMMENT_START_SECOND_DASH=18,
    COMMENT=19,
    COMMENT_END_FIRST_DASH=20,
    COMMENT_END_SECOND_DASH=21,
    COMMENT_END=22,

    ERROR=100
}


function in_range(value, low, high)
    return low <= value and high > value
end


function state_change(changes)
    changes.default    = changes.default    or states.ERROR
    changes.letters    = changes.letters    or changes.default
    changes.numbers    = changes.numbers    or changes.default
    changes.symbols    = changes.symbols    or changes.default
    changes.whitespace = changes.whitespace or changes.default

    changes.unknown    = changes.unknown or states.ERROR

    setmetatable(changes, {
        __index=function (table, key)
            if #key ~= 1 then
                return states.ERROR
            end

            local code = string.byte(key)
            if code == nil then
                return states.ERROR
            end

            if code ~= 9 and code ~= 10 and code ~= 13 and (
                in_range(code, 0, 32) or code >= 127
            ) then
                return changes.unknown
            end

            if in_range(code, 65, 91) or in_range(code, 97, 123) then
                return changes.letters
            end

            if in_range(code, 48, 58) then
                return changes.numbers
            end

            if code ~= 60 and code ~= 62 and (
                in_range(code,  33,  48) or
                in_range(code,  58,  65) or
                in_range(code,  91,  97) or
                in_range(code, 123, 127)
            ) then
                return changes.symbols
            end

            if code == 10 or code == 13 or code == 9 or code == 32 then
                return changes.whitespace
            end

            return changes.default
        end
    })

    return changes
end


state_table = {}
state_table.state_changes = {
    [states.DEFAULT]=state_change{
        ["<"]=states.TAG_START,
        whitespace=states.DEFAULT,
    },
    [states.TAG_START]=state_change{
        ["/"]=states.CLOSE_TAG_START,
        ["!"]=states.COMMENT_START,
        letters=states.TAG_NAME,
    },
    [states.TAG_NEXT_CLOSE]=state_change{
        [">"]=states.TAG_CLOSE,
    },
    [states.TAG_END]=state_change{
        ["<"]=states.TAG_START,
        whitespace=states.DEFAULT,
    },
    [states.TAG_CLOSE]=state_change{
        ["<"]=states.TAG_START,
        whitespace=states.DEFAULT,
    },
    [states.TAG_NAME]=state_change{
        ["_"]=states.TAG_NAME,
        ["."]=states.TAG_NAME,
        ["/"]=states.TAG_NEXT_CLOSE,
        [">"]=states.TAG_END,
        letters=states.TAG_NAME,
        numbers=states.TAG_NAME,
        whitespace=states.TAG_PARAMETERS,
    },
    [states.TAG_PARAMETERS]=state_change{
        ["/"]=states.TAG_NEXT_CLOSE,
        [">"]=states.TAG_END,
        ["_"]=states.PARAMETER_NAME,
        letters=states.PARAMETER_NAME,
        whitespace=states.TAG_PARAMETERS,
    },
    [states.PARAMETER_NAME]=state_change{
        ["="]=states.PARAMETER_NEXT_VALUE_START,
        ["."]=states.PARAMETER_NAME,
        ["_"]=states.PARAMETER_NAME,
        letters=states.PARAMETER_NAME,
        numbers=states.PARAMETER_NAME,
        whitespace=states.PARAMETER_EQUALS,
    },
    [states.PARAMETER_EQUALS]=state_change{
        ["="]=states.PARAMETER_NEXT_VALUE_START,
        whitespace=states.PARAMETER_EQUALS,
    },
    [states.PARAMETER_NEXT_VALUE_START]=state_change{
        ["\""]=states.PARAMETER_VALUE_START,
        whitespace=states.PARAMETER_NEXT_VALUE_START,
    },
    [states.PARAMETER_VALUE_START]=state_change{
        ["<"]=states.ERROR,
        ["\n"]=states.ERROR,
        ["\r"]=states.ERROR,
        ["\""]=states.PARAMETER_VALUE_END,
        default=states.PARAMETER_VALUE,
    },
    [states.PARAMETER_VALUE]=state_change{
        ["<"]=states.ERROR,
        ["\n"]=states.ERROR,
        ["\r"]=states.ERROR,
        ["\""]=states.PARAMETER_VALUE_END,
        default=states.PARAMETER_VALUE,
    },
    [states.PARAMETER_VALUE_END]=state_change{
        ["/"]=states.TAG_NEXT_CLOSE,
        [">"]=states.TAG_END,
        letters=states.PARAMETER_NAME,
        whitespace=states.TAG_PARAMETERS,
    },
    [states.CLOSE_TAG_START]=state_change{
        letters=states.CLOSE_TAG_NAME,
        whitespace=states.CLOSE_TAG_START
    },
    [states.CLOSE_TAG_NAME]=state_change{
        ["_"]=states.CLOSE_TAG_NAME,
        ["."]=states.CLOSE_TAG_NAME,
        [">"]=states.TAG_CLOSE,
        letters=states.CLOSE_TAG_NAME,
        numbers=states.CLOSE_TAG_NAME,
        whitespace=states.CLOSE_TAG_NEXT_CLOSE,
    },
    [states.CLOSE_TAG_NEXT_CLOSE]=state_change{
        [">"]=states.TAG_CLOSE,
        whitespace=states.CLOSE_TAG_NEXT_CLOSE
    },
    [states.COMMENT_START]=state_change{
        ["-"]=states.COMMENT_START_FIRST_DASH,
    },
    [states.COMMENT_START_FIRST_DASH]=state_change{
        ["-"]=states.COMMENT_START_SECOND_DASH,
    },
    [states.COMMENT_START_SECOND_DASH]=state_change{
        ["-"]=states.COMMENT_END_FIRST_DASH,
        default=states.COMMENT,
    },
    [states.COMMENT]=state_change{
        ["-"]=states.COMMENT_END_FIRST_DASH,
        default=states.COMMENT,
    },
    [states.COMMENT_END_FIRST_DASH]=state_change{
        ["-"]=states.COMMENT_END_SECOND_DASH,
        default=states.COMMENT,
    },
    [states.COMMENT_END_SECOND_DASH]=state_change{
        [">"]=states.COMMENT_END,
    },
    [states.COMMENT_END]=state_change{
        ["<"]=states.TAG_START,
        whitespace=states.DEFAULT,
    }
}

state_table.states = states

function state_table:next_state(state, value)
    return self.state_changes[state][value]
end
