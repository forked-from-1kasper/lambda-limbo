implement Kernel;

include "common.m";

sys : Sys;

init(mods : ref Mods)
{
    sys = mods.sys;
}

Ident.eq(i1, i2 : Ident) : int
{
    return i1.display == i2.display && i1.id == i2.id;
}

gidx : int = 0;

Ident.fresh(i : self Ident) : Ident
{
    gidx = gidx + 1;
    return Ident(i.display, gidx);
}

showIdent(i : Ident) : string
{
    return i.display;
}

showExpr(e : ref Expr) : string
{
    pick v := e {
        Var => return showIdent(v.ident);
        App => return sys->sprint("(%s %s)", showExpr(v.left), showExpr(v.right));
        Lam => return sys->sprint("(λ %s, %s)", showIdent(v.binder), showExpr(v.value));
    }
}

Dict : adt
{
    add : fn(nil : self ref Dict, key : string, value : int) : ref Dict;
    get : fn(nil : self ref Dict, key : string) : int;

    pick {
        Nil  =>
        Cons => key : string; value : int; prev : ref Dict;
    }
};

Dict.add(σ : self ref Dict, key : string, value : int) : ref Dict
{
    return ref Dict.Cons(key, value, σ);
}

Dict.get(σ₀ : self ref Dict, key : string) : int
{
    pick σ := σ₀ {
        Cons => if (σ.key == key) return σ.value; else return σ.prev.get(key);
        Nil  => return 0;
    }
}

freshLoop(σ : ref Dict, e : ref Expr)
{
    pick v := e {
        Lam => v.binder = v.binder.fresh(); freshLoop(σ.add(v.binder.display, v.binder.id), v.value);
        App => freshLoop(σ, v.left); freshLoop(σ, v.right);
        Var => v.ident.id = σ.get(v.ident.display);
    }
}

fresh(e : ref Expr)
{
    return freshLoop(ref Dict.Nil(), e);
}

app(f : ref Expr, x : ref Expr) : ref Expr
{
    pick φ := f {
        Lam => return subst(φ.binder, x, φ.value);
        *   => return ref Expr.App (φ, x);
    }
}

subst(i : Ident, e : ref Expr, e′ : ref Expr) : ref Expr
{
    pick v := e′ {
        Var => if (Ident.eq(v.ident, i)) return e; else return e′;
        App => return app(subst(i, e, v.left), subst(i, e, v.right));
        Lam => if (Ident.eq(v.binder, i)) return e;
               else return ref Expr.Lam (v.binder, subst(i, e, v.value));
    }
}

eval(e : ref Expr) : ref Expr
{
    pick v := e {
        App => return app(eval(v.left), eval(v.right));
        Lam => return ref Expr.Lam (v.binder, eval(v.value));
        Var => return e;
    }
}
