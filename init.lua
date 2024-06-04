local utf8, varargs, tern

utf8  = require("utf8")
varargs = require("lib.varargs")
tern  = require("lib.tern")

---The value of *τ*.
math.tau = math.pi * 2

---Generates a v4 uuid. **NOT** cryptographically sound, and
---should not be used in secure scenarios.
---@return string
math.uuid = function()
    local result = ("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", function(x)
        return ("%x"):format(x == "x" and math.random(0, 0xf) or math.random(8, 0xb))
    end)

    return result
end

---Take number, and assuming it's placement in a range from `from_min` to `from_max`, map that
---number if it instead were in the range `to_min` to `to_max`. For example, a number that is
---half way between `from_min` and `from_max` should be half way between `to_min` and `to_max`.
---
---The ranges are not exclusive, which is to say, if your first range went from 1 - 4, and your
---second range went from 50 - 100, but your number is outside of the first range (8), then your
---result will be out of range of the second range in to the same respect (200).
---@param value number The number you'd like to map from the first range to the second range.
---@param from_min number The lower bound of the first range.
---@param from_max number The upper bound of the first range.
---@param to_min number The lower bound of the second range.
---@param to_max number The upper bound of the second range.
---@return number
---@nodiscard
math.map = function(value, from_min, from_max, to_min, to_max)
    return (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min
end

---Returns a number clamped between a range of `min` and `max`.
---@param value number The value you'd like to clamp.
---@param min number The lower bound of the range.
---@param max number The upper bound of the range.
---@return number
---@nodiscard
math.clamp = function(value, min, max)
    if value <= min then return min end
    if value >= max then return max end
    return value
end

---Returns whether a number is between the `min` and `max`, equivalent to `min <= value and value <= max`.
---@param value number The number you'd like to check.
---@param min number The lower bound of the range.
---@param max number The upper bound of the range.
---@return boolean
---@nodiscard
math.between = function(value, min, max)
    return min <= value and value <= max
end

---Linearly interpolate a number towards another number by some percentage.
---This functions similiarly to lerping a vector, but in 1D space rather than
---2D or higher. A `percent` value above 1 or below 0 will extrapolate beyond
---the original range.
---@param value number The number you'd like to interpolate.
---@param to number The number you'd like to interpolate towards.
---@param percent number The percent value you'd like to interpolate.
---@return number
---@nodiscard
math.lerp = function(value, to, percent)
    return value + (to - value) * percent
end

---round a number to so-many decimal of places, which can be negative, 
---e.g. -1 places rounds to 10's, -2 to the 100's, etc.
---        
---```lua
-----examples:
---    print(math.round(173.2562))     --173
---    print(math.round(173.2562, 2))  --173.26
---    print(math.round(173.2562, -1)) --170
---```
---@param value number The number you'd like to round (0 by default).
---@param sigfig? number The amount of significant figures you'd like to round to. A whole number is usually used, but is not required.
---@return number
---@nodiscard
math.round = function(value, sigfig)
    local mult = 10 ^ (sigfig or 0)

    return math.floor(value * mult + 0.5) / mult
end

---Taking a value, cycle between the provided range. For example, if `from` is 6
---and `to` is 10, then as you pass numbers in, your output will be 6, 7, 8, 9, 10,
---6, 7, 8, 9, 10.
---
---Note that floating point values will have seemingly quirky behaviour. For example,
---if our range was from 6 to 10, and we passed into 5.8, we'd recieve 5.8 instead of 9.8.
---However, if we passed 10.2, we'd recieve 5.2. In this sense, the lower bound of the
---provided range actually includes `from - 0.9(repeating)`. Also, due to floating point
---precision, `to + <incredibly_small_number>` can then cause the output to be `from - 1`.
---
---Overall, if this sort of precision is an issue is for you, you may wish to write your own
---implementation to handle these floating point edge cases.
---@param value number The number to cycle between the range `from` to `to`.
---@param from number The lower bound of the range.
---@param to number The upper bound of the range.
---@return number
---@nodiscard
math.cycle = function(value, from, to)
    if math.clamp(value, from, to) == value then return value end

    local dt, res

    dt  = from - 1
    res = (value - dt) % (to - dt)

    return (res == 0 and to or res) + dt
end

---Returns the local timezone offset of the provided timestamp in hours. If a timestamp is
---not provided, then uses the current timestamp.
---@param timestamp? number A timestamp in seconds, representing a time in the past or future.
---@return number
---@nodiscard
os.tz_offset = function(timestamp)
    local utc, here

    timestamp = timestamp or os.time()

    utc  = os.date("!*t", timestamp)
    here = os.date("*t", timestamp)

	here.isdst = false --http://lua-users.org/wiki/TimeZone

    ---@diagnostic disable-next-line: param-type-mismatch
	return os.difftime(os.time(here), os.time(utc)) / 3600
end

---@version 5.1
---
---Returns the elements from the given `list`. This function is equivalent to
---```lua
---    return list[i], list[i+1], ···, list[j]
---```
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-unpack"])
---
---@param self table
---@param i?   integer
---@param j?   integer
---@nodiscard
---@diagnostic disable-next-line: duplicate-set-field
table.unpack = function(self, i, j)
    return unpack(self, i, j)
end

---Reverse the entries of a table **in place**.
---@param self table The table to be reversed.
---@return table #A reference to the *new*, reversed table.
table.reverse = function(self)
    local n = #self

    for i = 1, n * 0.5 do
        self[i], self[n] = self[n], self[i]
        n = n - 1
    end

    return self
end

---Counts the values that exist in a table using `pairs`.
---@param self table The table to count.
---@return number
---@nodiscard
table.count = function(self)
    local count = 0

    for _, _ in pairs(self) do count = count + 1 end

    return count
end

---Return the key/value pairs of a table as a 2d table, where
---each item in the table is the table `{key, value}`. Iterates
---over the table using `__pairs`, so tables without a `__pairs`
---implementation will not return entries as expected.
---@param self table The table to iterate over.
---@return table
---@nodiscard
table.entries = function(self)
    local result = {}

    for k, v in pairs(self) do
        result[#result + 1] = { k, v }
    end

    return result
end

---Create a table that only contains values that exist in *all* tables. Comparision is
---done with a simple `==`, so values that are passed by reference will only be in the
---result if they are the same item in memory. It is assumed that the table is a non-
---sparse, numerically indexed table, and may result in unexpected output if the input
---is otherwise.
---@param ... table Any of amount of tables with any amount of items.
---@return table
---@nodiscard
table.set = function(...)
    local tmp, output

    output = {}
    tmp    = {}

    for _, tbl in ipairs{ ... } do
        for _, val in ipairs(tbl) do
            if not tmp[val] then tmp[val] = 0 end

            tmp[val] = tmp[val] + 1
        end
    end

    for k, v in pairs(tmp) do
        if v > 1 then output[#output + 1] = k end 
    end

    return output
end

---Return the values of a non numerically indexed table as a numerically indexed table.
---Due to the values in the original table no having an order, this will also not provide
---a consistant ordering of said values. Iterates over the table using `__pairs`, so
---tables without a `__pairs` implementation will not return entries as expected.
---@param self table The table to iterate over.
---@return table
---@nodiscard
table.values = function(self)
    local result = {}

    for _, v in pairs(self) do
        result[#result + 1] = v
    end

    return result
end

---Return the keys of a non numerically indexed table as a numerically indexed table.
---Due to the keys in the original table no having an order, this will also not provide
---a consistant ordering of said keys. Iterates over the table using `__pairs`, so
---tables without a `__pairs` implementation will not return entries as expected.
---@param self table The table to iterate over.
---@return table
---@nodiscard
table.keys = function(self)
    local result = {}

    for k, _ in pairs(self) do
        result[#result + 1] = k
    end

    return result
end

---Takes the elements of a table that implements either `__ipairs` or `__pairs`,
---and returns the string where each item is seperated by the provided seperator. If the
---table implements both `__ipairs` and `__pairs`, then `__ipairs` takes precendence.
---
---Each value in the table is `tostring`'d, and if no seperator is provided, then a space
---is used.
---
---The optional `last` is a secondary seperator that is used only to seperate the last two
---items. So, for example;
---```lua
---local my_table = { "apples", "grapes", "oranges" }
---
---print(table.join(my_table, ", ", " and ")) --Returns "apples, grapes and oranges"
---```
---If no `last` seperator is provided, then the last seperator will simply be the same as
---the defined seperator.
---@param self table The table to join into a string.
---@param sep? string The string to seperate each value by.
---@param last? string A secondary string, that seperates only the last two values, if provided.
---@return string
---@nodiscard
table.join = function(self, sep, last)
    local str = ""

    sep  = sep or " "
    last = last or sep

    if select(2, ipairs(self)) then
        local amount = #self

        for i, v in ipairs(self) do
            str = str .. tostring(v)

            if i - 1 == amount then
                str = str .. last
            elseif i ~= amount then
                str = str .. sep
            end
        end

        return str
    elseif select(2, pairs(self)) then
        local amount, i
        
        amount = table.count(self)
        i      = 1

        for _, v in pairs(self) do
            str = str .. tostring(v)

            if i - 1 == amount then
                str = str .. last
            elseif i ~= amount then
                str = str .. sep
            end

            i = i + 1
        end

        return str
    end

    error("Table value does not implement '__ipairs' or '__pairs'.")
end

---Takes each table or value passed in, and merges them all into a single table. Merges table
---based on key/value pairs, and merges from left to right.
---```
---a = { fruit = "apple" }
---b = { fruit = "bannana", veggie = "carrot" }
---c = { name = "jumpsplat120" }
---
---d = table.merge(c, b, a)
---
-----tables b and a have been merged into c, so d == c
-----c => { name = "jumpsplat120", fruit = "apple", veggie = "carrot" }
---```
---@param ... any The table or values to be joined together.
---@return table
table.merge = function(...)
    local args, main
    
    args = { ... }
    main = table.remove(args, 1)

    for _, v in ipairs(args) do
        for k, vv in pairs(v) do
            main[k] = vv
        end
    end

    return main
end

---Takes each table or value passed in, and merges them all into a single table. Assumes table
---is sequentially ordered, and merges table such that all of param1 will exist, then all of param2,
---then all of param3, and so on. Only shallowly copies tables, and uses `ipairs` internally.
---@param ... any The table or values to be joined together.
---@return table
---@nodiscard
table.imerge =  function(...)
    local result = {}

    for _, i in ipairs({...}) do
        if i ~= nil then
            if type(i) == "table" then
                for _, j in ipairs(i) do
                    result[#result + 1] = j
                end
            else
                result[#result + 1] = i
            end
        end
    end

    return result
end

---Takes a table, then iterates through each item in the table, passing it through the
---provided function. If the function returns `true`, then the value is kept in the new
---table.
---@param self table The table to iterate through.
---@param func fun(i:number, value:any):boolean The function used to filter the table.
---@return table
---@nodiscard
table.filter = function(self, func)
    local result = {}

    for i, v in ipairs(self) do
        if func(i, v) then
            result[#result + 1] = v
        end
    end
    
    return result
end

---Takes a table, and returns a copy of the table with only unique values. Assumes
---the table is a sequentially ordered table, and uses ipairs internally.
---@param self table The table to deduplicate.
---@return table
---@nodiscard
table.deduplicate = function(self)
    local tmp, result

    tmp    = {}
    result = {}

    for _, v in ipairs(self) do
        tmp[v] = true
    end
    
    for k, _ in pairs(tmp) do
        result[#result + 1] = k 
    end

    return result
end

---Return the index of the searched for value, if found. It's assumed that the table
---is numerically indexed, and will iterate over the table using ipairs. Sparse tables
---or other non traditional tables may not return expected results.
---@param self table The table that is being searched through.
---@param search any Any value that can be contained in a table.
---@return number?
---@nodiscard
table.find = function(self, search)
    for i, v in ipairs(self) do if v == search then return i end end
end

---Iterate over each value inside a table, and applies the function to
---each one. Internally uses `pairs` to interate, and both changes the table
---in place, and also returns a reference to itself for chaining purposes.
---@param self table The table that is being iterated on.
---@param func fun(key: any, value: any): any, any The function that is applied to each value in the table.
---@return table #A reference to the original table.
table.map = function(self, func)
    local clone = {}

    for k, v in pairs(self) do clone[k] = v end

    for k, v in pairs(clone) do
        local a, b = func(k, v)

        if a == nil and b == nil then self[k] = nil end
        if a        and b == nil then self[a] = v   end
        if a == nil and b        then self[k] = b   end
        if a and b               then self[a] = b   end
    end

    return self
end

---Iterate over each value inside a table, and applies the function to
---each one. Internally uses `ipairs` to interate, and both changes the table
---in place, and also returns a reference to itself for chaining purposes.
---@param self table The table that is being iterated on.
---@param func fun(index: number, value: any): index, any The function that is applied to each value in the table.
---@return table #A reference to the original table.
---@diagnostic disable-next-line: duplicate-set-field
table.foreach = function(self, func)
    local clone = {}

    for i, v in ipairs(self) do clone[i] = v end

    for i, v in ipairs(clone) do
        local a, b = func(i, v)

        self[i] = nil

        if a and b == nil then self[a] = v end
        if a == nil and b then self[i] = b end
        if a and b        then self[a] = b end
    end
    
    return self
end

local op = {}
---Recursively iterate through a multidimensional table of arbitrary depth. It's assumed that the
---only values in the table are also tables until you've reached the bottom of the depth. It's also
---assumed that the tables are numerically indexed tables, or otherwise implement the `__pairs` metatmethod.
---
---`mdarray` is a recursive function, and can cause issues of tables with excessive depth.
---
---Does **NOT** change the table in place, but doesn return a reference to itself for chaining purposes.
---@param self table The multi dimensional table that is being iterated on.
---@param func fun(...) The function that is applied to each value in the table.
---@param depth number? The depth that you want to iterate down to (2 by default).
---@return table #A reference to the initial table
table.mdarray = function(self, func, depth)
    local p

    op[self] = op[self] or {
        final = true,
        index = 1
    }

    p     = op[self]
    depth = depth or 2

    for i, v in ipairs(self) do
        if depth > 1 then
            table.mdarray(v, function(...)
                if p.final then
                    func(p.index, i, ...)

                    p.index = p.index + 1
                else
                    func(i, ...)
                end
            end, depth - 1)
        end
        
        if depth == 1 then
            func(i, v)
        end
    end

    op[self] = nil

    return self
end

--Takes a arbitrarily nested, sequential, numerically indexed table
--and flattens it into a single table.
--
---```lua
---local a = { "a", "b", { "c", { "foo", "bar", { "fizz", "buzz" } }, "d" } }
---
---table.flatten(a)  -- { "a", "b", "c", "foo", "bar", "fizz", "buzz", "d" }
---```
---@param self table The table to flatten.
---@return table #A new table containing the flattened results. The original tables are left unmodified.
table.flatten = function(self, result)
    result = result or {}
    
    for _, v in ipairs(self) do
        if type(v) == "table" then
            result = table.flatten(v, result)
        else
            result[#result + 1] = v 
        end
    end

    return result
end

---Shuffles the items in a sequential, numerically indexed table. Shuffles
---in place.
---@param self table The table that to shuffle.
---@return table #A reference to the original table.
table.shuffle = function(self)
    local result = {}

    for _ = 1, table.maxn(self), 1 do
        result[#result + 1] = table.remove(self, math.random(table.maxn(self)))
    end

    for i, v in ipairs(result) do self[i] = v end

    return self
end

---Iterate over each value inside a table, and applies the function to
---each one, eventually returning a single value. Each time the function runs,
---it passes in the current index/value pair, as well as the previously returned value.
---@param self table The table that is being iterated on.
---@param func fun(index: number, value: any, prev: any): any The function that is applied to each value in the table.
---@param init any? An optional starting value to be passed in to the function. This value is used as `prev` on the first run of the function. If no init is provided, then the first iteration is skipped and the second interation starts with the first and second value.
---@return any #The single value that is returned.
---@nodiscard
table.reduce = function(self, func, init)
    for i, v in ipairs(self) do
        if init == nil then
            init = v
        else
            init = func(i, v, init)
        end
    end

    return init
end

---Iteratively set the keys of the table as tables, until setting
---the key as the final value. For example, instead of;
---```lua
---local a = {}
---
---if not a.b   then a.b   = {} end
---if not a.b.c then a.b.c = {} end
---
---a.b.c.d = "Hello!"
---```
---You can simply do;
---```lua
---local a = {}
---
---table.deepset(a, "b", "c", "d", "Hello!")
---```
---If reaching a value when iterating through the table that isn't a table
---(excluding the final value), then the function will error.
---@param self table The table that is being iterated on.
---@param ... any? Any value that could be a key in a table.
---@return table #A reference to the original passed table.
table.deepset = function(self, ...)
    local args, result, value, last_key
    
    result   = self
    args     = { ... }
    value    = table.remove(args)
    last_key = table.remove(args)
    
    for _, v in ipairs(args) do
        assert(result[v] == nil or type(result[v]) == "table", "Reached non-table or non-nil value.")

        if result[v] == nil then result[v] = {} end

        result = result[v]
    end

    result[last_key] = value

    return self
end

---Iteratively retrieve each key that was passed in the table, until either
---the final value is reached, or `nil` is reached. For example, instead of
---```lua
---local a = {}
---
---if not a or not a.b or not a.b.c or not a.b.c.d then
--- print("Nothing!")
---else
--- print(a.b.c.d)
---end
---```
---You can simply do;
---```lua
---local a = {}
---
---print(table.deepget(a, "b", "c", "d") or "Nothing!")
---```
---If one of the interm values of the table are not also a table,
---(excluding the final value), then the function will error.
---@param self table The table that is being iterated on.
---@param ... any? Any value that could be a key in a table.
---@return any? #The value in the table at the keys indicated, or `nil`.
table.deepget = function(self, ...)
    local result, output, args
    
    result = self
    args   = { ... }
    len    = #args

    for i, v in ipairs(args) do
        output = result[v]
        
        if i == len then return output end
        if not output then return end

        result = output
    end
end

---Returns a random value from a numerically indexed table. Does not
---modify the table. If the table has no items in it, then it returns `nil`.
---@param self table The table to get a random value from.
---@return any?
table.random = function(self)
    return self[math.random(#self)]
end

---Randomly removes and returns a value from a numerically indexed table.
---If the table has no items in it, then it returns `nil`.
---@param self table The table to remove a random value from.
---@return any?
table.randpop = function(self)
    if #self == 0 then return end

    return table.remove(self, math.random(#self))
end

---Compares any amount of tables, by comparing the values of each index against
---each other. Internally uses `__ipairs` to interate, so tables with non numeric keys
---will not return an accurate result.
---@param ... table Any amount of tables to compare against each other.
---@return boolean
table.equals = function(...)
    local first, args, len

    args  = { ... }
    len   = #args
    first = table.remove(args, 1)

    for _, v in ipairs(args) do
        if len ~= #v then return false end

        for ii, vv in ipairs(first) do
            if v[ii] ~= vv then return false end
        end
    end

    return true
end

---Get a subset of a table, from `i` to `j`, inclusive. Non-numerically indexed tables will
---not function as expected. You can also use a negative index for `j`, to index backwards
---from the end. For example;
---
---```lua
---local a = { "a", "b", "c", "d" }
---
---table.subset(a, 1, 3)  -- { "a", "b", "c" }
---table.subset(a, 2)     -- { "b", "c", "d" }
---table.subset(a, 1, -2) -- { "a", "b" }
---```
---@param self table The table that is being split.
---@param i number The starting index of the original table.
---@param j number? The ending index of the original table. By default, is equal to `#tbl`.
---@return table #A new table that is a subset of the original table.
table.subset = function(self, i, j)
    local result = {}
    
    j = j or 0

    for a = i, j <= 0 and #self + j or j, 1 do
        result[#result + 1] = self[a]
    end

    return result
end

---Split a string into a it's constituent parts, based on the provided seperator.
---@param self string The string to split. Can either be passed in manually using `string.split` or using the colon operator.
---@param separator string? Provide the seperator to split by. If no seperator is provided, splits per character.
---@param keep boolean? Whether you want to keep the seperator. If `true`, then the seperator is kept to the first of the pair split. So `"Hey there"` becomes `{ "Hey ", "there" }`
---@param plain? boolean Whether to do a plain split; that is to say, treating the split string as though it were a plain string, and ignoring magic characters. By default, this is `true`.
---@return string[] #Will return all the split pieces in a table. If the string did not split, returns the whole string in the table.
---@nodiscard
string.split = function(self, separator, plain, keep)
    local result, index

    result = {}
    index  = 1
    plain  = plain == nil or plain
    keep   = not not tern(keep == nil, false, keep) and 0 or 1
    
    if separator == nil then
        for i, chr in self do result[i] = chr end

        return result
    end

    while true do
        local start, fin = self:find(separator, index, plain)
        
        if not start then
            if index <= #self then
                result[#result + 1] = self:sub(index)
            end

            break
        end
        
        result[#result + 1] = self:sub(index, start - keep)

        index = fin + 1
    end

    return result
end

---Returns a string that contains anything found after the seperator specified. If the seperator isn't found
---in the string, then it returns the original string.
---@param self string The string to be split.
---@param separator string The seperator to search for.
---@param plain? boolean Whether to do a plain search; that is to say, treating the search string as though it were a plain string, and ignoring magic characters. By default, this is `true`.
---@return string
---@nodiscard
string.after = function(self, separator, plain)
    if plain == nil then plain = true end

    local start, fin = self:find(separator, 1, plain)

    if not start then return self end

    return self:sub(fin + 1)
end

---Returns a string that contains anything found before the seperator specified. If the seperator isn't found
---in the string, then it returns the original string.
---@param self string The string to be split.
---@param separator string The seperator to search for.
---@param plain? boolean Whether to do a plain search; that is to say, treating the search string as though it were a plain string, and ignoring magic characters. By default, this is `true`.
---@return string
---@nodiscard
string.before = function(self, separator, plain)
    if plain == nil then plain = true end

    local start, fin = self:find(separator, 1, plain)
    
    if fin - separator:len() == 0 then return ""   end
    if not start                  then return self end

    return self:sub(1, fin - separator:len())
end

---Return a string in Titlecase Format. That means the first letter of anything after a space is uppercased.
---@param self string The string to be titlecased
---@return string
---@nodiscard
string.title = function(self) 
    local result = ""

    for _, v in ipairs(self:split(" ")) do
        result = v:sub(1, 1):upper() .. v:sub(2, -1) .. " " 
    end

    return result:sub(1, -2)
end

---Returns whether a string ends with another string.
---@param self string The string you are checking against
---@param str string The string you are looking for
---@return boolean
---@nodiscard
string.endswith = function(self, str)
    return self:sub(-str:len()) == str
end

---Returns whether a string starts with another string.
---@param self string The string you are checking against
---@param str string The string you are looking for
---@return boolean
---@nodiscard
string.startswith = function(self, str)
    return self:sub(1, str:len()) == str
end

---Takes a string, and pads the front of it with the provided string. Will pad up to the length required,
---which means a multicharacter pad can cause it to go over the number provided. For example, if you wanted
---to pad a string with `abc`, and you had the string `def`, and you wanted to make sure it was padded up to
---four characters, you'd get `abcdef`, not just `cdef`. 
---@param self string The string you want to pad.
---@param num number The minimum amount of characters you need in the outputted string.
---@param str string The string you want to pad with.
---@return string
---@nodiscard
string.padleft = function(self, num, str)
    while #self < num do
        self = str .. self
    end

    return self
end

---Takes a string, and pads the back of it with the provided string. Will pad up to the length required,
---which means a multicharacter pad can cause it to go over the number provided. For example, if you wanted
---to pad a string with `abc`, and you had the string `def`, and you wanted to make sure it was padded up to
---four characters, you'd get `defabc`, not just `defa`. 
---@param self string The string you want to pad.
---@param num number The minimum amount of characters you need in the outputted string.
---@param str string The string you want to pad with.
---@return string
---@nodiscard
string.padright = function(self, num, str)
    while #self < num do
        self = self .. str
    end

    return self
end

---Removes trailing and leading spaces from a string.
---@param self string The string you want to remove the spaces from.
---@return string
---@nodiscard
string.trim = function(self)
    local result = self:gsub("^%s*", ""):gsub("%s*$", "")
    
    return result
end

local function char_iterator(self, index)
    index = index + 1

    if index > utf8.len(self) then return end

    return index, utf8.char(utf8.codepoint(self, utf8.offset(self, index)))
end

debug.setmetatable("", {
    __call = function(self, ...)
        local value = select(2, ...)

        if type(value) ~= "number" then
            return char_iterator(self, 0)
        end

        return char_iterator(self, value)
    end,
    __index = string
})

debug.setmetatable(0, {
    __index = math
})