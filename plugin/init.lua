local rime = require "rime_toggle"
rime.setup()

vim.api.nvim_create_user_command("RimeToggle", function()
  rime.toggle()
end, { desc = "Toggle Rime auto ASCII mode" })

vim.api.nvim_create_user_command("RimeEnable", function()
  rime.enable()
end, { desc = "Enable Rime auto ASCII mode" })

vim.api.nvim_create_user_command("RimeDisalbe", function()
  rime.disable()
end, { desc = "Disalbe Rime auto ASCII mode" })
