-------------------------------------------------------------------------------
-- orriginal code from:
-- https://github.com/raulchen/dotfiles/tree/master/hammerspoon
-- 
-------------------------------------------------------------------------------
local module = {}
local timeout = 3
local modal = hs.hotkey.modal.new('alt', 'space')
-------------------------------------------------------------------------------
function modal:entered()
    modal.alert = hs.alert.show("🔨", 600)
    modal.timer = hs.timer.doAfter(timeout, function() modal:exit() end)
end
-------------------------------------------------------------------------------
function modal:exited()
    if modal.alert then
        hs.alert.closeSpecific(modal.alert)
    end
    module.cancelTimeout()
end
-------------------------------------------------------------------------------
function module.exit()
    modal:exit()
end
-------------------------------------------------------------------------------
function module.cancelTimeout()
    if modal.timer then
        modal.timer:stop()
    end
end
-------------------------------------------------------------------------------
function module.restart()
    if modal.timer then
        modal.timer:stop()
    end
    modal.timer = hs.timer.doAfter(timeout, function() modal:exit() end)
end
-------------------------------------------------------------------------------
function module.bind(mod, key, fn)
    modal:bind(mod, key, function() fn(); module.exit() end)
end
-------------------------------------------------------------------------------
function module.bindMultiple(mod, key, pressedFn, releasedFn, repeatFn)
    modal:bind(
        mod,
        key,
        function() pressedFn(); end,
        function() end,
        function() module.restart(); repeatFn(); end)
end
-------------------------------------------------------------------------------
module.bind('', 'escape', module.exit)
module.bind('alt', 'space', module.exit)
-------------------------------------------------------------------------------
return module
-------------------------------------------------------------------------------
