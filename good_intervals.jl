# Andrioni from pull request 6170:

using FloatingPointExceptions
using ValidatedNumerics

#set_rounding(Float64, RoundUp)

function test2(x)
    clear_floatexcept()
    before = get_floatexcept()
    ret = 1.0 / x
    after = get_floatexcept()
    return ret, before, after
end

function make_interval(x::Number)
    clear_floatexcept()
    #before = get_floatexcept()
    #b = float("$x") #2x / 2

    #b = with_rounding(Float64, RoundUp) do
    #b = 10 * x / 10

    b = float(x)

    #end

    if FEInexact ∈ get_floatexcept()
        Interval(prevfloat(b), b)
    else
        Interval(b)
    end
end

function make_interval(x::String)
    clear_floatexcept()
    #before = get_floatexcept()
    b = parsefloat(x)  # it's here that the exception is thrown

    if FEInexact ∈ get_floatexcept()
        Interval(prevfloat(b), b)
    else
        Interval(b)
    end
end
