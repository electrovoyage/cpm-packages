local lib = {}
lib.isuppercase = false
lib.currenttext = ""
lib.done = false

lib.reactsToClicks = true
lib.enabled = true
lib.rendered = true

function lib:cback(chars)
    local char, alternative = unpack(common.breakString(chars))
    return function()
        self.currenttext = self.currenttext .. (self.isuppercase and alternative or char)
        print(self.currenttext)
    end
end

function lib:init()
    local width, height = monitor.getSize()
    local topy = height - 9

    local xoffset1 = 1
    local xoffset2 = 2
    local yoffset = 0

    self.widgets = {
        pigment.create({x=1,y=topy - 1}, {x=width, y=height}, 'f'),
        button.create("1!", {x=xoffset1 + 1, y=yoffset + topy}, 0, 0, 'b', self:cback("1!")),
        button.create("2@", {x=xoffset1 + 4, y=yoffset + topy}, 0, 0, 'b', self:cback("2@")),
        button.create("3#", {x=xoffset1 + 7, y=yoffset + topy}, 0, 0, 'b', self:cback("3#")),
        button.create("4$", {x=xoffset1 + 10,y=yoffset + topy}, 0, 0, 'b', self:cback("4$")),
        button.create("5%", {x=xoffset1 + 13,y=yoffset + topy}, 0, 0, 'b', self:cback("5%")),
        button.create("6^", {x=xoffset1 + 16,y=yoffset + topy}, 0, 0, 'b', self:cback("6^")),
        button.create("7&", {x=xoffset1 + 19,y=yoffset + topy}, 0, 0, 'b', self:cback("7&")),
        button.create("8*", {x=xoffset1 + 22,y=yoffset + topy}, 0, 0, 'b', self:cback("8*")),
        button.create("9(", {x=xoffset1 + 25,y=yoffset + topy}, 0, 0, 'b', self:cback("9(")),
        button.create("0)", {x=xoffset1 + 28,y=yoffset + topy}, 0, 0, 'b', self:cback("0)")),
        button.create("<-", {x=xoffset1 + 31,y=yoffset + topy}, 1, 0, 'b', function()
            self.currenttext = string.sub(self.currenttext, 1, #self.currenttext - 1)
        end),

        button.create(" A", {x=xoffset2 + 1,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("aA")),
        button.create(" S", {x=xoffset2 + 4,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("sS")),
        button.create(" D", {x=xoffset2 + 7,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("dD")),
        button.create(" F", {x=xoffset2 + 10,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("fF")),
        button.create(" G", {x=xoffset2 + 13,y=yoffset + topy + 2}, 0, 0, 'b', self:cback('gG')),
        button.create(" H", {x=xoffset2 + 16,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("hH")),
        button.create(" J", {x=xoffset2 + 19,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("jJ")),
        button.create(" K", {x=xoffset2 + 22,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("kK")),
        button.create(" L", {x=xoffset2 + 25,y=yoffset + topy + 2}, 0, 0, 'b', self:cback("lL")),
        button.create("Done", {x=xoffset2 + 28,y=yoffset + topy + 2}, 1, 0, 'b', function() 
            self.done = true 
        end)

    }
end

function lib:bring_up_keyboard()
    self.currenttext = ""
    self.done = false
    self.rendered = true
end

function lib:get_keyboard()
    return self.done, self.currenttext
end

function lib:_render(monitor)
    if not self.rendered then
        return
    end
    for index, widget in pairs(self.widgets) do
        widget:_render(monitor)
    end
end

function lib:contains(position)
    return self.widgets[1]:contains(position)
end

function lib:onclick(position)
    for index, widget in pairs(common.slice(self.widgets, 2)) do
        local b = widget:contains(position)
        if b then
            widget:onclick()
        end
    end
    return false
end

return lib