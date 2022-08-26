Kernel : module
{
    Ident : adt
    {
        display : string; id : int;

        fresh : fn (nil : self Ident) : Ident;
        eq    : fn (i1, i2 : Ident) : int;
    };

    Expr : adt
    {
        pick {
            Var => ident : Ident;
            App => left, right : ref Expr;
            Lam => binder : Ident; value : ref Expr;
        }

    };

    init     : fn(mods : ref Mods);
    fresh    : fn(nil : ref Expr);
    showExpr : fn(nil : ref Expr) : string;
    eval     : fn(e : ref Expr) : ref Expr;
};