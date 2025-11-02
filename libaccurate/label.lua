lib = {}

strutils = require "cc.strings"

function lib.create(text, position, maxwidth, backgroundcolor, foregroundcolor)
    expect.expect(1, text, "string")
    expect.expect(2, position, "table")
    expect.field(position, "x", "number")
    expect.field(position, "y", "number")
    expect.expect(3, maxwidth, "number", "nil")
    expect.expect(4, backgroundcolor, "string")
    expect.expect(5, foregroundcolor, "string")

    if type(maxwidth) == "number" and maxwidth % 1 ~= 0 then
        error("maxwidth must be whole or nil")
    end

    if #backgroundcolor ~= 1 then
        error('backgroundcolor must be exactly 1 character long')
    end

    if not common.contains(common.breakString('0123456789abcdef'), backgroundcolor) then
        error(backgroundcolor .. ' is not a valid color; see CC documentation for colors')
    end

    if #foregroundcolor ~= 1 then
        error('foregroundcolor must be exactly 1 character long')
    end

    if not common.contains(common.breakString('0123456789abcdef'), foregroundcolor) then
        error(foregroundcolor .. ' is not a valid color; see CC documentation for colors')
    end

    tab = {
        ['text']=text,
        ['baseposition']=position,
        ['maxwidth']=maxwidth,
        ['bgcolor']=backgroundcolor,
        ['fgcolor']=foregroundcolor,
        ['reactsToClicks']=false,
        ['enabled']=true,
        ['rendered']=true
    }

    --[[
        Set label text.
    ]]
    function tab:setText(text)
        expect.expect(1, text, "string")
        self.text = text
    end

    --[[
        Set maximum line width.
        If set to nil then will only go to a new line on \n.
    ]]
    function tab:setMaxWidth(width)
        expect.expect(1, width, "string", "nil")
        self.maxwidth = width
    end

    --[[
        Set the label's background color. Must be one of the
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
        Internal function. Create lines for rendering.
    ]]
    function tab:_splitlines()
        t = {}
        maxwidth = self.maxwidth
        currentline = ""
        for index, char_ in pairs(common.breakString(self.text)) do
            if char_ == "\n" or char_ == "\r" then
                table.insert(t, currentline)
                currentline = ""
            else
                if not( currentline == "" and char_ == " ") then
                    currentline = currentline .. char_
                end

                if #currentline == maxwidth then
                    table.insert(t, currentline)
                    currentline = ""
                end
            end
        end
        if t[#t] ~= currentline then
            table.insert(t, currentline)
        end
        return t
    end

    --[[
        Set the label's foreground color. Must be one of the
        letters used by ComputerCraft's blit() function.
    ]]
    function tab:setForegroundColor(foregroundcolor)
        if #foregroundcolor ~= 1 then
            error('foregroundcolor must be exactly 1 character long')
        end

        if not common.contains(common.breakString('0123456789abcdef'), foregroundcolor) then
            error(foregroundcolor .. ' is not a valid color; see CC documentation for colors')
        end

        self.fgcolor = foregroundcolor
    end

    --[[
        Internal function. Render label on provided monitor.
    ]]
    function tab:_render(monitor)
        if not self.rendered then
            return
        end
        lines = self:_splitlines()
        for ind, line in pairs(lines) do
            monitor.setCursorPos(self.baseposition.x, self.baseposition.y + ind - 1)
            monitor.blit(strutils.ensure_width(line, self.maxwidth), string.rep(self.fgcolor, self.maxwidth), string.rep(self.bgcolor, self.maxwidth))
        end
    end

    return tab
end

return lib