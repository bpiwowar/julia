using Base.Test
using Base: pushmeta!, popmeta!

macro leaftype(ex...)
    esc(_leaftype(ex[end], ex[1:(end-1)]...))
end

_leaftype(ex::Expr, symbols::Symbol...) = pushmeta!(ex, :leaftypemeta, symbols...)

# _leaftype(arg) = arg

@leaftype function f(x)
    for i in 1:1000 x += 0.5 end
    begin y = 1 end
end

function parseleaftype(ex::Any, checkleaftype::Bool)
    println("### Ignoring $(typeof(ex)) : $ex")
end

function parseleaftype(ex::LineNumberNode, checkleaftype::Bool)
    println(ex)
end

function parseleaftype(ex::SymbolNode, checkleaftype::Bool)
    if checkleaftype && !isleaftype(ex.typ)
        println("Bad type in $(ex)")
    end
end

function parseleaftype(ex::Expr, checkleaftype::Bool)
    hasleaftype, args = popmeta!(ex, :leaftypemeta)
    println("===> $hasleaftype, $args")
    if hasleaftype
        println("Found leaftypemeta")
        checkleaftype = true
    end

    for subex in ex.args
        parseleaftype(subex, checkleaftype)
    end
end


function leaftypeanalyze(ast)
    println(ast)
    parseleaftype(ast, false)
end

ast = @code_typed f(1)
leaftypeanalyze(ast[1])


# macro leaftype(ex...)
#     esc(_leaftype(ex[end], ex[1:(end-1)]...))
# end

# _leaftype(ex::Expr, symbols::Symbol...) = pushmeta!(ex, :leaftypemeta, symbols...)

# @leaftype function f1(x)
#     for i in 1:1000 x += 0.5 end
#     begin y = 1 end
# end

# @leaftype function f2(x)
#     for i in 1:1000 x += 0.5 end
# end

# findleaftype(ex::Any) = false

# function findleaftype(ex::Expr)
#     leaftypemeta, args = popmeta!(ex, :leaftypemeta)
#     if leaftypemeta return true end

#     for subex in ex.args
#         if findleaftype(subex) return true end
#     end

#     false
# end

# println("f1: ", findleaftype(@code_typed(f1(1))[1]))
# println("f2: ", findleaftype(@code_typed(f2(1))[1]))

