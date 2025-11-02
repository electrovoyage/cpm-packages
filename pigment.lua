local lib = {}

expect = require "cc.expect"

function lib.create(position, size, backgroundcolor)
    expect.expect(1, position, "table")
    expect.field(position, "x", "number")
    expect.field(position, "y", "number")
    expect.expect(2, size, "table")
    expect.field(size, "x", "number")
    expect.field(size, "y", "number")
    expect.expect(3, backgroundcolor, "string")
    if #backgroundcolor ~= 1 then
        error('backgroundcolor must be exactly 1 character long')
    end

    if not common.contains(common.breakString('0123456789abcdef'), backgroundcolor) then
        error(backgroundcolor .. ' is not a valid color; see CC documentation for colors')
    end

    tab = {
        ['baseposition']=position,
        ['width']=size.x,
        ['height']=size.y,
        ['bgcolor']=backgroundcolor,
        ['enabled']=true,
        ['rendered']=true,
        ['reactsToClicks']=false
    }

    function tab:_render(monitor)
        if self.rendered then
            for y=self.baseposition.y,self.baseposition.y+self.height do
                monitor.setCursorPos(self.baseposition.x, y)
                monitor.blit(string.rep(' ', self.width), string.rep('0', self.width), string.rep(self.bgcolor, self.width))
            end
        end
    end

    function tab:contains(position)
        return position.x >= self.baseposition.x
            and position.y >= self.baseposition.y
            and position.x <= self.baseposition.x + self.width
            and position.y <= self.baseposition.y + self.height
    end

    return tab
end

return lib