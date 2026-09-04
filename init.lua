-- ============================================================================
-- 1. Лидер-клавиши
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- 2. Автозагрузка менеджера lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 3. Плагины
-- ============================================================================
require("lazy").setup({
  spec = {
    -- Тема Catppuccin Mocha с прозрачностью под Ghostty
    {
      "catppuccin/nvim",
      name = "catppuccin",
      lazy = false,
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          flavour = "mocha",
          transparent_background = true,
          integrations = {
            treesitter = true,
            cmp = true,
            dadbod_ui = true,
          },
        })
        vim.cmd.colorscheme("catppuccin-mocha")

        -- Повышенная контрастность неактивных номеров строк
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#a6adc8" })
      end,
    },

    -- Статус-лайн Lualine
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        options = {
          theme = "auto",
        },
      },
    },

    -- Подсветка синтаксиса Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        vim.treesitter.language.register("markdown", "markdown")
      end,
    },

    -- Живой предпросмотр Markdown в браузере
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = "cd app && npm install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      keys = {
        { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
      },
    },

    -- Работа с базами данных (Dadbod UI + Completion)
    {
      "kristijanhusak/vim-dadbod-ui",
      dependencies = {
        { "tpope/vim-dadbod", lazy = true },
        { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
      },
      cmd = {
        "DBUI",
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUIFindBuffer",
      },
      init = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
        vim.g.db_ui_winwidth = 35
        vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
        vim.g.db_ui_execute_on_save = 0
        vim.g.db_ui_disable_query_bind_parameters = 1
      end,
      keys = {
        { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Открыть / закрыть панель БД" },
        { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Найти буфер запроса БД" },
      },
    },

    -- Движок автодополнения (nvim-cmp)
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "kristijanhusak/vim-dadbod-completion",
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          snippet = {
            expand = function(args)
              vim.snippet.expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
            { name = "path" },
          }),
        })

        cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
          sources = cmp.config.sources({
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
          }),
        })
      end,
    },
  },
  rocks = {
    enabled = false,
  },
})

-- ============================================================================
-- 4. Настройки редактора и навигации
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false

-- Поддержка русской раскладки в режимах Normal и Visual
vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

-- ============================================================================
-- 5. Буферы баз данных (Dadbod)
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql", "pgsql" },
  callback = function(event)
    -- Автодополнение контекста схемы БД
    vim.bo[event.buf].omnifunc = "vim_dadbod_completion#omni"

    -- Выполнение текущего запроса под курсором по Space + r или Ctrl + Enter
    vim.keymap.set("n", "<leader>r", "vip<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      remap = true,
      desc = "DB: Выполнить текущий блок",
    })
    vim.keymap.set("n", "<C-CR>", "vip<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      remap = true,
      desc = "DB: Выполнить текущий блок",
    })

    -- Выполнение только выделенного фрагмента в визуальном режиме
    vim.keymap.set("v", "<leader>r", "<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      desc = "DB: Выполнить выделенный SQL",
    })
    vim.keymap.set("v", "<C-CR>", "<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      desc = "DB: Выполнить выделенный SQL",
    })
  end,
})
