Parser : module
{
    Token : adt
    {
        pick {
            EOL    =>
            Comma  =>
            Lambda =>
            Lparen =>
            Rparen =>
            String => value : string;
        }

        show : fn (nil : self ref Token) : string;
    };

    Lexer : adt
    {
        buffer : string; pos : int;

        init : fn(nil : string) : ref Lexer;
        peek : fn(nil : self ref Lexer) : int;
        next : fn(nil : self ref Lexer) : ref Token;
    };

    init : fn(mods : ref Mods);
    go   : fn(s : string) : ref Kernel->Expr;
};