local colors = require('Esteban.waifus')
local M = {}

-- Función para establecer el colorscheme
function M.set_colorscheme(name)
	local scheme = colors[name] or colors.Rem

	vim.cmd("highlight clear")
	vim.cmd("hi Normal guifg=" .. scheme.foreground .. " guibg=" .. scheme.background)
	vim.cmd("hi Comment guifg=" .. scheme.comment)
	vim.cmd("hi Keyword guifg=" .. scheme.keyword)
	vim.cmd("hi Function guifg=" .. scheme.function_name)
	vim.cmd("hi String guifg=" .. scheme.string)
	vim.cmd("hi Identifier guifg=" .. scheme.variable)
	vim.cmd("hi Type guifg=" .. scheme.type)
	vim.cmd("hi Constant guifg=" .. scheme.constant)
	vim.cmd("hi Operator guifg=" .. scheme.operator)

	-- Guardar el esquema de colores en un archivo
	local colorscheme_file = vim.fn.expand("~/.config/nvim/colorscheme.txt")
	local file, err = io.open(colorscheme_file, "w")
	if file then
		file:write(name .. "\n") -- Asegúrate de agregar un salto de línea
		file:close()
	else
	end
end

-- Función para cargar el esquema de colores guardado
function M.load_colorscheme()
	local colorscheme_file = vim.fn.expand("~/.config/nvim/colorscheme.txt")
	local file, err = io.open(colorscheme_file, "r")
	if file then
		local scheme_name = file:read("*l")
		file:close()
		if scheme_name then
			M.set_colorscheme(scheme_name)
		else
		end
	else
	end
end

-- Función de vista previa que muestra el ASCII de la waifu
function M.preview_colorscheme(name)
	local scheme = colors[name] or colors.Rem

	-- Usar el arte ASCII de la waifu y dividir en líneas
	local ascii_art = scheme.ascii_art or ""
	local lines = {}
	for line in ascii_art:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local content = {}
	-- Añadir las líneas del arte ASCII
	for _, line in ipairs(lines) do
		table.insert(content, line)
	end

	return content
end

-- Función para mostrar el picker de selección de esquema de color
function M.select_colorscheme()
	local options = {}
	for name, _ in pairs(colors) do
		table.insert(options, name)
	end

	local previewer = require('telescope.previewers').new_buffer_previewer {
		define_preview = function(self, entry, status)
			local content = M.preview_colorscheme(entry.value)

			-- Limpiar el buffer de vista previa
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)

			-- Resaltar el texto en el buffer de vista previa
			for i, line in ipairs(content) do
				vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "Normal", i - 1, 0, -1)
			end
		end,
	}

	-- Usar Telescope para mostrar opciones
	require('telescope.pickers').new({}, {
		prompt_title = "Select Colorscheme",
		finder = require('telescope.finders').new_table {
			results = options,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry,
					ordinal = entry,
				}
			end,
		},
		sorter = require('telescope.sorters').get_fuzzy_file(),
		previewer = previewer,
		attach_mappings = function(_, map)
			map('i', '<CR>', function(prompt_bufnr)
				local selection = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
				M.set_colorscheme(selection.value)           -- Establecer el colorscheme seleccionado
				require('telescope.actions').close(prompt_bufnr) -- Cerrar Telescope
			end)
			return true
		end,
	}):find()
end

-- Cargar el esquema de colores al iniciar Neovim
M.load_colorscheme()

return M
