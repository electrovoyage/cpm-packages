local lib = {}

lib.version = "0.1"

-- aCCurate, like computercraft = CC
print('libaccurate v'..lib.version)

expect = require("cc.expect")
button = require("/gui/buttons")
common = require("/gui/common")
label = require("/gui/label")
radiobutton = require("/gui/radiobutton")
pigment = require('/gui/pigment')
keyboard = require("/gui/keyboard")

lib.widgets = {}
lib.isterminal = false

--[[
    Set up library to work on provided monitor.
    Returns the libaccurate/common module.
]]
function lib.init(monitor)
    expect.expect(1, monitor, "table")
    lib.monitor = monitor
    return common
end

--[[
    Create a new button.
    `label` (string) - The text on the button.
    `position` (libaccurate/common.vector2) - Position of the top-left corner of the button. The top-left corner of the screen is (1,1).
    `xpadding` (number) - How much empty space is to the left and right of the text.
    `ypadding` (number) - How much empty space is above and below the text.
    `backgroundcolor` (string) - A single character describing the background color of this button. See CC color docs under blit() for options.
    `onclick` (function () -> any?) - Function that gets executed when this button is clicked.

    Return the button.
]]
function lib.create_button(label, position, xpadding, ypadding, backgroundcolor, onclick)
    table.insert(lib.widgets, button.create(label, position, xpadding, ypadding, backgroundcolor, onclick))
    return lib.widgets[#lib.widgets]
end

--[[
    Create a new label.
    `text` (string) - The text of the label.
    `position` (libaccurate/common.vector2) - Position of the top-left corner of the button. The top-left corner of the screen is (1,1).
    `maxwidth` (number?) - How many characters should fit on a line before an automatic line break. If set to nil, automatic line breaks will be disabled (`\n` and `\r` can still be used)
    `backgroundcolor` (string) - A single character describing the background color of the text area. See CC color docs under blit() for options.
    `foregroundcolor` (string) - A single character describing the foreground color of the text area. See CC color docs under blit() for options.

    Return the label.
]]
function lib.create_label(text, position, maxwidth, backgroundcolor, foregroundcolor)
    table.insert(lib.widgets, label.create(text, position, maxwidth, backgroundcolor, foregroundcolor))
    return lib.widgets[#lib.widgets]
end

--[[
    Create a new pigment.
    `position` (libaccurate/common.vector2) - Position of the top-left corner of the pigment. The top-left corner of the screen is (1,1).
    `size` (libaccurate/common.vector2) - Size of the pigment.
    `backgroundcolor` (string) - A single character describing the background color of the text area. See CC color docs under blit() for options.

    Return the pigment.
]]
function lib.create_pigment(position, size, backgroundcolor)
    local w = pigment.create(position, size, backgroundcolor)
    table.insert(lib.widgets, w)
    return w
end

--[[
    Create a new radiobutton group.
    A single group can have any number of radiobuttons. Radiobuttons of a single group share the same value (i.e. only one of a group can be selected).

    Return the group for adding radiobuttons.
]]
function lib.create_radiobutton_group(startingvalue)
    w = radiobutton.group(startingvalue)
    table.insert(lib.widgets, w)
    return w
end

--[[
    Internal function. Add a widget to the list of widgets to render and process.
]]
function lib.add(widget)
    table.insert(lib.widgets, widget)
end

--[[
    Internal function. Error if init() hasn't been run yet.
]]
function lib._monitorCheck()
    if not lib.monitor then
        error('No monitor specified! Run .init() first.')
    end
end

--[[
    Clear screen and redraw all widgets.
    Necessary after creating widgets or reconfiguring existing ones.
]]
function lib.redrawAll()
    lib._monitorCheck()
    lib.monitor.clear()
    for index, widget in pairs(lib.widgets) do
        widget:_render(lib.monitor)
    end
    keyboard:_render(lib.monitor)
end

--[[
    Internal loop for reading and processing touch events.
]]
function lib.touchScreenThread()
    while true do
        if lib.isterminal then
            event, button, x, y = os.pullEvent("mouse_click")
        else
            event, side, x, y = os.pullEvent("monitor_touch")
            button = 1
        end
        if button == 1 then
            if keyboard:contains(common.vector2(x, y)) and keyboard.rendered then
                keyboard:onclick(common.vector2(x, y))
            else
                for index, widget in pairs(lib.widgets) do
                    if widget.reactsToClicks then
                        if widget:contains(common.vector2(x, y)) and widget.enabled then
                            widget:onclick(common.vector2(x, y))
                            break
                        end
                    end
                end
            end
        end
    end
end

--[[
    Start main loop.
    `mainloop` (function () -> any?) - The main loop of your program. This should not return until the program is fully done (or crashes).
    `terminal` (boolean?) - If provided and true, will use mouse_click events instead of monitor_touch. Enable this if running on an Advanced Computer and you want the UI to show up on the computer itself, not a monitor. In this case init() should also be called with the argument `term`.
    Only call this at the end of your program as this function will not return until something errors or your mainloop returns.
]]
function lib.run(mainloop, terminal)
    expect.expect(1, mainloop, "function")
    expect.expect(2, terminal, "boolean", "nil")
    lib.isterminal = terminal or false
    keyboard:init()
    --lib.add(keyboard)
    lib.redrawAll()
    parallel.waitForAny(lib.touchScreenThread, mainloop)
end

print('by electrovoyage.')
return lib