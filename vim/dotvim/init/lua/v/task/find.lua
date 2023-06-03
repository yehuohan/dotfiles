-- Fuzzy finder tasks
local fzer = {
    rg = 'rg --vimgrep -F {opt} -e "{pat}" {loc}',
    fzf = {
        file = ':FzfFiles {pat}',
        live = ':FzfRg {pat}',
        tags = ':FzfTags {pat}',
    },
    leaderf = {
        file = ':Leaderf file --input "{pat}"',
        live = ':Leaderf rg --nowrap --input "{pat}"',
        tags = ':Leaderf tag --nowrap --input "{pat}"',
    },
    telescope = {
        file = ':lua require("telescope.builtin").find_files({search_file="{pat}"})',
        live = ':lua require("telescope.builtin").live_grep({placeholder="{pat}"})',
        tags = ':lua require("telescope.builtin").tags({placeholder="{pat}"})',
    },
}

local function setup() end

return {
    setup = setup,
}
