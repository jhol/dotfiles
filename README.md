dotfiles - jhol's Nix home-manager modules
==========================================

Installation
------------

In `home.nix`:

```
{ flakeInputs, self, config, pkgs, ... }: {
  modules.jhol-dotfiles.all.enable = true;
}
```
