lib = {}

lib.groups = {}

expect = require "cc.expect"

--[[
    Create a radiobutton group.
    `startingvalue` (any?) - The value that this group starts with. If any of the added radiobuttons has this as its value, it'll start highlighted.
    Returns the group to create radiobuttons in.
]]
function lib.group(startingvalue)
    if not lib.groups then
        lib.groups = {}
    end
    tab = {
        id = #lib.groups + 1,
        currentvalue = startingvalue,
        children = {},
        ['enabled']=true,
        ['rendered']=true,
        ['reactsToClicks']=true
    }

    --[[
        Create a new radiobutton in this group.
        `position` (libaccurate/common.vector2) - Position of this radiobutton.
        `label` (string) - Text to the right of the radiobutton.
        `value` (any?) - What value should the group's selection should be set to when this radiobutton is clicked. Make sure every radiobutton in the group has a unique value for this.
        `backgroundcolor` (string) - A single character describing the background color of the label and radiobutton. See CC color docs under blit() for options.
        `foregroundcolor` (string) - A single character describing the foreground color of the label and radiobutton. See CC color docs under blit() for options.
    ]]
    function tab:new(position, label, value, foregroundcolor, backgroundcolor)
        expect.expect(1, position, "table")
        expect.field(position, "x", "number")
        expect.field(position, "y", "number")
        expect.expect(2, label, "string")
        -- no expect for value as it can be anything
        expect.expect(4, foregroundcolor, "string")
        expect.expect(5, backgroundcolor, "string")

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

        radiobutton = {
            ['group']=self,
            ['baseposition']=position,
            ['label']=label,
            ['value']=value,
            ['enabled']=true,
            ['rendered']=true,
            ['bgcolor']=backgroundcolor,
            ['fgcolor']=foregroundcolor
        }
    
        function radiobutton:onclick()
            self.group.currentvalue = self.value
            self.group:_render(lib.monitor)
        end

        function radiobutton:_render(monitor)
            if not self.rendered then 
                return
            end
            if monitor then
                lib.monitor = monitor
            end
            monitor.setCursorPos(self.baseposition.x, self.baseposition.y)
            t = ((self.group.currentvalue == self.value) and "(*) " or "( ) ") .. self.label
            monitor.blit(t, string.rep(self.fgcolor, #t), string.rep(self.bgcolor, #t))
        end

        function radiobutton:contains(position)
            expect.expect(1, position, "table")
            expect.field(position, "x", "number")
            expect.field(position, "y", "number")
            
            return position.y == self.baseposition.y and position.x >= self.baseposition.x and position.x <= self.baseposition.x + 2
        end

        table.insert(self.children, radiobutton)
        return radiobutton
    end

    function tab:_render(monitor)
        if not self.rendered then
            return
        end
        for index, child in pairs(self.children) do
            if child.rendered then
                child:_render(monitor)
            end
        end
    end

    function tab:contains(position)
        expect.expect(1, position, "table")
        expect.field(position, "x", "number")
        expect.field(position, "y", "number")

        for index, child in pairs(self.children) do
            c = child:contains(position)
            if c then
                return c
            end
        end
    end

    function tab:onclick(position)
        expect.expect(1, position, "table")
        expect.field(position, "x", "number")
        expect.field(position, "y", "number")

        for index, child in pairs(self.children) do
            c = child:contains(position)
            if c then
                child:onclick()
            end
        end
    end

    table.insert(lib.groups, tab)
    return tab
end

return lib