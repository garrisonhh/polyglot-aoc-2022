#!/usr/bin/env -S lua -W

-- solution --------------------------------------------------------------------

CPU = {
    x = 1,
    cycle = 1,
}

CPUCycles = {
    ["noop"] = 1,
    ["addx"] = 2,
}

function CPU:new()
    local t = {}
    setmetatable(t, self)
    self.__index = self
    return t
end

function CPU:doInst(inst)
    local op = inst[1]
    self.cycle = self.cycle + CPUCycles[op]

    if op == "addx" then
        self.x = self.x + tonumber(inst[2])
    end

    -- print(string.format("%s -> %d %d", op, self.cycle, self.x))
end

function Part1(program)
    local cpu = CPU:new()
    local sig_cycles = {20, 60, 100, 140, 180, 220}
    local sig_i = 1
    local sig_sum = 0

    for i = 1, #program do
        local inst = program[i]
        local last_x = cpu.x
        cpu:doInst(inst)

        if sig_i <= #sig_cycles then
            local found = false
            if cpu.cycle > sig_cycles[sig_i] then
                found = true
            elseif cpu.cycle == sig_cycles[sig_i] then
                last_x = cpu.x
                found = true
            end

            if found then
                -- print(string.format("cycle %d: x = %d", sig_cycles[sig_i], last_x))
                sig_sum = sig_sum + sig_cycles[sig_i] * last_x
                sig_i = sig_i + 1
            end
        end
    end

    print(string.format("part 1) sum of strengths: %d", sig_sum))
end

-- main ------------------------------------------------------------------------

---@param str string
function SplitWhitespace(str)
    local t = {}
    for match in string.gmatch(str, "[^%s]+") do
        table.insert(t, match)
    end

    return t
end

---returns `string list list` for each line
---@param filename string
function ReadProgram(filename)
    local f, msg = io.open(filename, "r")

    if f == nil then
        print("error: " .. msg)
        os.exit(1)
    end

    local ops = {}
    while true do
        local line = f:read("l")

        if line == nil then
            break
        elseif line ~= "" then
            table.insert(ops, SplitWhitespace(line))
        end
    end

    f:close()

    return ops
end

if #arg ~= 1 then
    print("usage: soln [input]")
    os.exit(1)
end

local program = ReadProgram(arg[1])

Part1(program)