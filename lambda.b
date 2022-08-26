implement Lambda;

include "common.m";

sys    : Sys;
kernel : Kernel;
parser : Parser;
mods   : ref Mods;

Lambda : module
{
    init : fn(nil : ref Draw->Context, nil : list of string);
};

init(nil : ref Draw->Context, argv : list of string)
{
    sys    = load Sys Sys->PATH;
    kernel = load Kernel "kernel.dis";
    parser = load Parser "parser.dis";

    mods = ref Mods(sys, kernel, parser);
    kernel->init(mods);
    parser->init(mods);

    argv = tl argv;
    for (; argv != nil; argv = tl argv) {
        τ := parser->go(hd argv); kernel->fresh(τ);
        sys->print("%s -> %s\n", kernel->showExpr(τ), kernel->showExpr(kernel->eval(τ)));
    }
}