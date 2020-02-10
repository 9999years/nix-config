self: super:
{
    neovim = super.neovim.override {
        withNodeJs = true;
        vimAlias = true;
    };
}