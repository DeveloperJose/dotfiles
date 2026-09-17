# DevJ's Init Script
Run
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/DeveloperJose/dotfiles/master/dot_config/nvim/init.sh)
```

or
```sh
bash <(wget -qO- https://raw.githubusercontent.com/DeveloperJose/dotfiles/master/dot_config/nvim/init.sh)
```

--- Upstream tracking ---
Split base (modular split): 40a9ba0 (Jun 2025)
Upstream modular (dam9000): master/origin/master at 96a9cdc
Upstream kickstart (nvim-lua): origin/master at 80743df
Upstream treesitter (nvim-treesitter): main at 9a168f63
Migration notes: treesitter moved from master to main (A); lua_ls fixes applied (bd53f28 + b01d052); upstream commits walked from dabce469/d132bd3/58170c7 to 96a9cdc; applicable patches applied; structural differences (vim.pack vs lazy split) remain.
