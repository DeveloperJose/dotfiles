local function get_python(root)
  if root then
    local project_python
    if vim.fn.has 'win32' == 1 then
      project_python = vim.fs.joinpath(root, '.venv', 'Scripts', 'python.exe')
    else
      project_python = vim.fs.joinpath(root, '.venv', 'bin', 'python')
    end
    if vim.uv.fs_stat(project_python) then
      return project_python
    end
  end
  if vim.env.VIRTUAL_ENV then
    local active_python
    if vim.fn.has 'win32' == 1 then
      active_python = vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'Scripts', 'python.exe')
    else
      active_python = vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end
    if vim.uv.fs_stat(active_python) then
      return active_python
    end
  end
  local python = vim.fn.exepath 'python3'
  if python == '' then
    python = vim.fn.exepath 'python'
  end
  return python ~= '' and python or 'python'
end

return {
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend('force', config.settings or {}, {
      python = {
        pythonPath = get_python(config.root_dir),
      },
    })
  end,
}
