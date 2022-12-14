#!/usr/bin/env -S lua -W

-- solution --------------------------------------------------------------------

CPU = {
    x = 1,
    history = {}, -- list of x states
}

CPUCycles = {
    ["noop"] = 1,
    ["addx"] = 2,
}

function CPU:new()
    local t = {}
    setmetatable(t, self)
    t.history = {1}
    self.__index = self
    return t
end

function CPU:doInst(inst)
    local op = inst[1]
    for _ = 1, CPUCycles[op] - 1 do
        table.insert(self.history, self.x)
    end

    if op == "addx" then
        self.x = self.x + tonumber(inst[2])
    end

    table.insert(self.history, self.x)
end

function CPU:runProgram(program)
    for i = 1, #program do
        self:doInst(program[i])
    end
end

function CPU:printCRT()
    local WIDTH = 40
    local HEIGHT = 6

    for y = 1, HEIGHT do
        for x = 1, WIDTH do
            local reg = self.history[x + (y - 1) * WIDTH]

            if math.abs((x - 1) - reg) <= 1 then
                io.write("#")
            else
                io.write(".")
            end
        end
        print()
    end
end

function CPU:showHistory()
    print("[cpu history]")
    for i = 1, #self.history do
        print(string.format("during %d - %d", i, self.history[i]))
    end
end

function Part1(program)
    local cpu = CPU:new()
    cpu:runProgram(program)

    local sig_cycles = {20, 60, 100, 140, 180, 220}
    local sig_sum = 0

    for _, cycle in pairs(sig_cycles) do
        sig_sum = sig_sum + cycle * cpu.history[cycle]
    end

    print(string.format("part 1) sum of strengths: %d", sig_sum))
end

function Part2(program)
    local cpu = CPU:new()
    cpu:runProgram(program)
    print("part 2)")
    cpu:printCRT()
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
Part2(program)