local lib = {}
expect = require "cc.expect"

--[[
    More compact way of providing coordinates.
]]
function lib.vector2(x, y)
    expect.expect(1, x, "number")
    expect.expect(2, y, "number")
    return {["x"]=x, ["y"]=y}
end

function lib.breakString(s)
    local f = s:gmatch(".")
    local t = {}
    local l = f()
    repeat
        table.insert(t, l)
        l = f()
    until l == nil
    return t
end

function lib.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function lib.slice(t, start, finish)
	if not finish then
		finish = #t
	end
	local newt = {}
	for i=start,finish do
		table.insert(newt, t[i])
	end
	return newt
end

function lib.reverse(t)
	local newt = {}
	for i=#t, 1, -1 do
		table.insert(newt, t[i])
	end
	return newt
end

return lib