# Neovim Configuration

Минималистичный, быстрый конфиг на Lua для macOS, оптимизированный для работы с PostgreSQL, базами данных и Markdown. Управление плагинами осуществляется через `lazy.nvim`.

---

## Стек и возможности

* **Менеджер плагинов:** [lazy.nvim](https://github.com/folke/lazy.nvim) (с версионированием через `lazy-lock.json`).
* **Тема оформления:** [Catppuccin Mocha](https://github.com/catppuccin/nvim) с поддержкой прозрачности фона.
* **Строка статуса:** [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim).
* **Синтаксис:** [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).
* **Работа с БД:** [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) + автодополнение через `vim-dadbod-completion`.
* **Автодополнение:** [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (буфер, пути, SQL).
* **Форматирование:** `pg_format` с сохранением позиции курсора и автоформатированием при `:w`.
* **Markdown:** [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) с живым предпросмотром в браузере.

---

## Быстрое развертывание на новом устройстве

### 1. Системные зависимости (macOS)
```bash
brew install neovim git pgformatter node
brew install --cask font-jetbrains-mono-nerd-font
```

### 2. Клонирование репозитория
```bash
git clone git@github.com:CaesarFTPR/nvim-config.git ~/.config/nvim
```

### 3. Первый запуск
```bash
nvim
```
> `lazy.nvim` автоматически склонирует себя и скачает все зафиксированные в `lazy-lock.json` плагины.

---

## Основные горячие клавиши

Лидер-клавиша: `Space` (Пробел).

| Сочетание | Режим | Описание |
| :--- | :--- | :--- |
| `<leader>db` | Normal | Открыть / закрыть боковую панель баз данных (DBUI) |
| `<leader>df` | Normal | Найти активный буфер запроса БД |
| `<leader>r` / `<C-CR>` | Normal | Выполнить SQL-запрос / блок под курсором |
| `<leader>f` | Normal / Visual | Форматировать весь SQL-файл / выделенный блок |
| `<leader>mp` | Normal | Включить / выключить интерактивный предпросмотр Markdown |
| `:w` | Normal | Сохранить файл (автоматически форматирует `.sql`) |
