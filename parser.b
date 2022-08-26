implement Parser;

include "common.m";

init(mods : ref Mods)
{
}

Token.show(t₀ : self ref Token) : string
{
    pick t := t₀ {
        EOL    => return "EOL";
        Comma  => return "COMMA";
        Lambda => return "LAMBDA";
        Lparen => return "LPAREN";
        Rparen => return "RPAREN";
        String => return "'" + t.value + "'";
    }
}

Lexer.init(s : string) : ref Lexer
{
    return ref Lexer(s, 0);
}

isspace(c : int) : int
{
    return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f';
}

isreserved(c : int) : int
{
    return isspace(c) || c == ',' || c == 'λ' || c == '(' || c == ')' || c == '\\';
}

Lexer.peek(t : self ref Lexer) : int
{
    return t.buffer[t.pos];
}

Lexer.next(t : self ref Lexer) : ref Token
{
    while (t.pos < len t.buffer && isspace(t.peek())) t.pos++;
    if (t.pos == len t.buffer) return ref Token.EOL();

    case t.peek() {
        ','         => t.pos++; return ref Token.Comma();
        '\\' or 'λ' => t.pos++; return ref Token.Lambda();
        '('         => t.pos++; return ref Token.Lparen();
        ')'         => t.pos++; return ref Token.Rparen();
    }

    i₀ := t.pos; while (t.pos < len t.buffer && !isreserved(t.peek())) t.pos++;
    return ref Token.String(t.buffer[i₀:t.pos]);
}

lam(vs : list of string, e : ref Kernel->Expr) : ref Kernel->Expr
{
    if (vs == nil) return e;
    else return lam(tl vs, ref (Kernel->Expr).Lam(Kernel->Ident(hd vs, 0), e));
}

app(es : list of ref Kernel->Expr) : ref Kernel->Expr
{
    if (es == nil) return nil;
    else if (tl es == nil) return hd es;
    else return ref (Kernel->Expr).App(app(tl es), hd es);
}

take    : fn(nil : int, nil : ref Token, lex : ref Lexer) : ref Kernel->Expr;
takeAll : fn(nil : int, lex : ref Lexer) : ref Kernel->Expr;

take(depth : int, t₀ : ref Token, lex : ref Lexer) : ref Kernel->Expr
{
    pick t := t₀ {
        EOL    => return nil;
        Comma  => raise "unexpected “,”";
        Rparen => raise "unexpected “)”";
        Lparen => return takeAll(depth + 1, lex);
        String => return ref (Kernel->Expr).Var(Kernel->Ident(t.value, 0));
        Lambda => {
            vars : list of string;

            loop : for (;;) {
                pick tok := lex.next() {
                    String => vars = tok.value :: vars;
                    Comma  => break loop;
                    *      => raise ("unexpected token: " + tok.show());
                }
            }

            return lam(vars, takeAll(depth, lex));
        }
    }
}

takeAll(depth : int, lex : ref Lexer) : ref Kernel->Expr
{
    es : list of ref Kernel->Expr;

    for (;;) {
        pick t := lex.next() {
            Rparen => if (depth == 0) raise "unexpected “)”"; else return app(es);
            EOL    => return app(es);
            *      => es = take(depth, t, lex) :: es;
        }
    }
}

go(s : string) : ref Kernel->Expr
{
    return takeAll(0, Lexer.init(s));
}