-- Навигация между вью
local nav = {}

function nav.switchView(state, id)
    if not state.ui or state.ui.activeView == id then return end
    state.ui.previousView = state.ui.activeView
    state.ui.activeView = id
    state.ui.viewChanged = true
end

function nav.back(state)
    nav.switchView(state, (state.ui and state.ui.previousView) or "overview")
end

return nav
