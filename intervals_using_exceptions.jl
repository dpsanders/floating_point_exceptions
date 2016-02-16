push!(LOAD_PATH, ".")

using FloatingPointExceptions

import Base.+
function +(a::Float64, b::Float64, r::RoundingMode)
    old = get_rounding(Float64)

    set_rounding(Float64, r)
    clear_floatexcept()

    c = a + b;

    #exceptions = get_floatexcept()
    #@show exceptions
    #inexact = FEInexact in exceptions

    is_inexact = is_floatexcept(FEInexact)

    set_rounding(Float64, old)

    c, is_inexact

end

@show +(0.1, 0.2, RoundDown)
