if defined 'T' then return end
module 'T'

local next, getn, tremove, setmetatable = next, getn, tremove, setmetatable

local wipe, acquire, release
local pool, pool_size, overflow_pool, auto_release = {}, 0, setmetatable({}, {__mode='k'}), {}

function wipe(t)
	setmetatable(t, nil)
	for k, v in pairs(t) do
		t[k] = nil
	end
	t.reset, t.reset = nil, 1
end
M.wipe = wipe

CreateFrame'Frame':SetScript('OnUpdate', function()
	for t in pairs(auto_release) do release(t) end
	wipe(auto_release)
end)

function acquire()
	if pool_size > 0 then
		pool_size = pool_size - 1
		return pool[pool_size + 1]
	end
	local t = next(overflow_pool)
	if t then
		overflow_pool[t] = nil
		return t
	end
	return {}
end
M.acquire = acquire

function release(t)
	wipe(t)
	auto_release[t] = nil
	if pool_size < 50 then
		pool_size = pool_size + 1
		pool[pool_size] = t
	else
		overflow_pool[t] = true
	end
end
M.release = release

do
	local function f(_, v) if v then auto_release[v] = true; return v end end
	M.temp = setmetatable({}, {__metatable=false, __newindex=nop, __call=f, __sub=f})
end
do
	local function f(_, v) if v then auto_release[v] = nil; return v end end
	M.static = setmetatable({}, {__metatable=false, __newindex=nop, __call=f, __sub=f})
end

M.get_T = acquire

do
	local function ret(t)
		if getn(t) > 0 then
			return tremove(t, 1), ret(t)
		else
			release(t)
		end
	end
	M.ret = ret
end

M.empty = setmetatable({}, {__metatable=false, __newindex=nop})

local vararg
do
	local MAXPARAMS = 100

	local code = [[
		local f, acquire, auto_release = f, acquire, auto_release
		return function(
	]]
	for i = 1, MAXPARAMS - 1 do
		code = code .. format('a%d,', i)
	end
	code = code .. [[
		overflow)
		if overflow ~= nil then error("T-vararg overflow.", 2) end
		local n = 0
		repeat
	]]
	for i = MAXPARAMS - 1, 1, -1 do
		code = code .. format('if a%1$d ~= nil then n = %1$d; break end;', i)
	end
	code = code .. [[
		until true
		local t = acquire()
		auto_release[t] = true
		t.n = n
		repeat
	]]
	for i = 1, MAXPARAMS - 1 do
		code = code .. format('if %1$d > n then break end; t[%1$d] = a%1$d;', i)
	end
	code = code .. [[
		until true
		return f(t)
		end
	]]

	function vararg(f)
		local chunk = loadstring(code)
		setfenv(chunk, {f=f, acquire=acquire, auto_release=auto_release})
		return chunk()
	end
	M.vararg = setmetatable({}, {
		__metatable = false,
		__sub = function(_, v) return vararg(v) end,
	})
end

M.A = vararg(function(arg)
	local t = acquire()
	for i = 1, arg.n do
		t[i] = arg[i]
	end
	return t
end)
M.S = vararg(function(arg)
	local t = acquire()
	for i = 1, arg.n do
		t[arg[i]] = true
	end
	return t
end)
M.O = vararg(function(arg)
	local t = acquire()
	for i = 1, arg.n, 2 do
		t[arg[i]] = arg[i + 1]
	end
	return t
end)