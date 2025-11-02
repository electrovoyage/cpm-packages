local lib = {}
common = require("/gui/common")
expect = require "cc.expect"
strutils = require "cc.strings"

function pad(text, padding)
    return string.rep(" ", padding) .. text .. string.rep(" ", padding)
end

function padout(text, width)
    return pad(text, (width - #text) / 2)
end

function lib.create(label, position, xpadding, ypadding, backgroundcolor, onclick)
    expect.expect(1, label, "string")
    expect.expect(2, position, "table")
    expect.field(position, "x", "number")
    expect.field(position, "y", "number")
    expect.expect(3, xpadding, "number")
    expect.expect(4, ypadding, "number")
    expect.expect(5, backgroundcolor, "string")
    expect.expect(6, onclick, "function")

    if xpadding % 1 ~= 0 or ypadding % 1 ~= 0 then
        error('xpadding and ypadding must be whole numbers')
    end

    if xpadding < 0 or ypadding < 0 then
        error('xpadding and ypadding must be positive or zero')
    end

    if #backgroundcolor ~= 1 then
        error('backgroundcolor must be exactly 1 character long')
    end

    if not common.contains(common.breakString('0123456789abcdef'), backgroundcolor) then
        error(backgroundcolor .. ' is not a valid color; see CC documentation for colors')
    end

    tab = {
        ['label']=label,
        ['xpadding']=xpadding,
        ['ypadding']=ypadding,
        ['baseposition']=position,
        ['bgcolor']=backgroundcolor,
        ['enabled']=true,
        ['rendered']=true,
        ['_clickfunc']=onclick,
        ['reactsToClicks']=true
    }

    --[[
        Internal function. Recalculate width from label text and xpadding.
    ]]
    function tab:_recalcWidth()
        self.width = #self.label + (2 * self.xpadding)
    end

    --[[
        Internal function. Recalculate height from ypadding.
    ]]
    function tab:_recalcHeight()
        self.height = 1 + (2 * self.ypadding)
    end
    tab:_recalcWidth()
    tab:_recalcHeight()

    --[[
        Set the button's text.
    ]]
    function tab:setlabel(text)
        expect.expect(1, text, "string", "number")
        self.label = tostring(label)
        self:_recalcWidth()
    end

    --[[
        Set the button's X padding - the amount of empty space
        to the left and right of the text.
    ]]
    function tab:setxpadding(padding)
        expect.expect(1, padding, "number")
        self.xpadding = padding
        self:_recalcWidth()
    end

    --[[
        Set the button's Y padding - the amount of empty space
        above and below the text.
    ]]
    function tab:setypadding(padding)
        expect.expect(1, padding, "number")
        self.ypadding = padding
        self._recalcHeight()
    end

    --[[
        Set the button's background color. Must be one of the
        letters used by ComputerCraft's blit() function.
    ]]
    function tab:setBackgroundColor(backgroundcolor)
        if #backgroundcolor ~= 1 then
            error('backgroundcolor must be exactly 1 character long')
        end

        if not common.contains(common.breakString('0123456789abcdef'), backgroundcolor) then
            error(backgroundcolor .. ' is not a valid color; see CC documentation for colors')
        end

        self.bgcolor = backgroundcolor
    end

    --[[
        Set the button's position.
    ]]
    function tab:setPosition(x, y)
        self.baseposition = common.vector2(x, y)
    end

    function tab:onclick()
        self._clickfunc()
    end

    --[[
        Internal function. Check if a position is inside the button.
    ]]
    function tab:contains(position)
        expect.expect(1, position, "table")
        expect.field(position, "x", "number")
        expect.field(position, "y", "number")
        return (position.x >= self.baseposition.x
            and position.y >= self.baseposition.y
            and position.x <= self.baseposition.x + self.width
            and position.y <= self.baseposition.y + self.height)
    end

    --[[
        Internal function. Render button on provided monitor.
    ]]
    function tab:_render(monitor)
        if not self.rendered then
            return
        end
        backgroundcolor = string.rep(self.enabled and self.bgcolor or '7', self.width)
        foregroundcolor = string.rep(self.bgcolor == '0' and '8' or '0', self.width)
        ypadding = self.ypadding
        
        --monitor.setCursorPos(self.baseposition.x, self.baseposition.y)
        for i=self.baseposition.y, self.baseposition.y + self.height - 1 do
            monitor.setCursorPos(self.baseposition.x, i)
            fromtop = i - self.baseposition.y
            s = fromtop == ypadding and pad(self.label, self.xpadding) or string.rep(' ', self.width)

            monitor.blit(s, foregroundcolor, backgroundcolor)
        end
    end

    return tab
end

return lib