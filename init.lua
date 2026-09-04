-- 1. Лидер-клавиша (Пробел)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. Автозагрузка lazy.nvim
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

-- 3. Подключение плагинов
require("lazy").setup({
  spec = {
    -- Тема Catppuccin с прозрачностью под Ghostty
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
	
	-- Повышенная яркость номеров строк
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

    -- Подсветка синтаксиса Treesitter (Nvim 0.12+)
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

    -- Автодополнение кода (nvim-cmp)
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

-- 4. Настройки интерфейса и навигации
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false

-- 5. Поддержка русской раскладки в режимах Normal и Visual
vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

-- 6. Функция форматирования с сохранением позиции курсора
local function format_sql_buffer()
  local view = vim.fn.winsaveview()
  vim.cmd("silent! normal! gggqG")
  vim.fn.winrestview(view)
end

-- 7. Настройки буферов SQL (форматирование, выполнение и автодополнение)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql", "pgsql" },
  callback = function(event)
    vim.bo[event.buf].formatprg = "pg_format -"
    vim.bo[event.buf].omnifunc = "vim_dadbod_completion#omni"

    -- Выполнить запрос под курсором по <leader>r (Пробел + r)
    vim.keymap.set("n", "<leader>r", "vip<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      remap = true,
      desc = "Выполнить текущий запрос",
    })

    -- Выполнить запрос под курсором по Ctrl + Enter
    vim.keymap.set("n", "<C-CR>", "vip<Plug>(DBUI_ExecuteQuery)", {
      buffer = event.buf,
      remap = true,
      desc = "Выполнить текущий запрос",
    })
  end,
})

-- Шорткаты ручного форматирования (<leader>f)
vim.keymap.set("n", "<leader>f", format_sql_buffer, { desc = "Форматировать весь файл" })
vim.keymap.set("v", "<leader>f", "gq", { desc = "Форматировать выделенный фрагмент" })

-- Автоформатирование перед сохранением (:w)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.sql", "*.pgsql" },
  callback = format_sql_buffer,
})

-- Выполнение SQL-запроса в Dadbod (в нормальном и визуальном режимах)
-- Вариант 1: Space + r
vim.keymap.set({ "n", "v" }, "<leader>r", "<Plug>(DBUI_ExecuteQuery)", { desc = "DB: Execute Query" })

-- Вариант 2: Ctrl + Enter (работает одновременно с первым)
vim.keymap.set({ "n", "v" }, "<C-CR>", "<Plug>(DBUI_ExecuteQuery)", { desc = "DB: Execute Query" })

-- Пример вызова команды или formatprg:
vim.bo.formatprg = "pg_format -u 0 -f 0 -t 0 -"
