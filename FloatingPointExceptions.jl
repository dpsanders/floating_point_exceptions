# From Simon Byrne's pull request https://github.com/JuliaLang/julia/pull/6170

module FloatingPointExceptions

include("fenv_constants.jl")

## floating point exceptions ##
import Base: show, in, convert

export FloatExceptions, FEInexact, FEUnderflow, FEOverflow, FEDivByZero, FEInvalid, FloatExceptionSet,
FEAll, clear_floatexcept, get_floatexcept, is_floatexcept


abstract FloatExceptions

immutable FEInexact <: FloatExceptions end
immutable FEUnderflow <: FloatExceptions end
immutable FEOverflow <: FloatExceptions end
immutable FEDivByZero <: FloatExceptions end
immutable FEInvalid <: FloatExceptions end


# IEEE 754 requires the ability to check/set/clear multiple exceptions
immutable FloatExceptionSet
    flags::Cint
    FloatExceptionSet(e::Integer) = new(convert(Cint,e))
end

convert(::Type{FloatExceptionSet},::Type{FEInexact}) = FloatExceptionSet(JL_FE_INEXACT)
convert(::Type{FloatExceptionSet},::Type{FEUnderflow}) = FloatExceptionSet(JL_FE_UNDERFLOW)
convert(::Type{FloatExceptionSet},::Type{FEOverflow}) = FloatExceptionSet(JL_FE_OVERFLOW)
convert(::Type{FloatExceptionSet},::Type{FEDivByZero}) = FloatExceptionSet(JL_FE_DIVBYZERO)
convert(::Type{FloatExceptionSet},::Type{FEInvalid}) = FloatExceptionSet(JL_FE_INVALID)

const FEAll = FloatExceptionSet(JL_FE_INEXACT | JL_FE_UNDERFLOW | JL_FE_OVERFLOW | JL_FE_DIVBYZERO | JL_FE_INVALID)

in(fs1::FloatExceptionSet,fs2::FloatExceptionSet) = fs1.flags & fs2.flags != zero(Cint)
in{E<:FloatExceptions}(::Type{E},fs::FloatExceptionSet) = in(convert(FloatExceptionSet,E), fs)

show(io::IO,fe::FloatExceptionSet) = showcompact(io, filter(x->in(x,fe),subtypes(FloatExceptions)))



# IEEE754 2008 5.7.4 requires the following functions:
# lowerFlags, raiseFlags, testFlags, testSavedFlags (handled by "in"), restoreFlags, saveAllFlags

# lowerFlags
function clear_floatexcept(f::FloatExceptionSet)
    if ccall(:feclearexcept, Cint, (Cint,), f.flags) != zero(Cint)
        error("Could not clear floating point exception flag")
    end
end
clear_floatexcept{E<:FloatExceptions}(::Type{E}) = clear_floatexcept(convert(FloatExceptionSet,E))
clear_floatexcept() = clear_floatexcept(FEAll)

function get_floatexcept(f::FloatExceptionSet)
    FloatExceptionSet(ccall(:fetestexcept, Cint, (Cint,), f.flags))
end
# saveAllFlags
get_floatexcept() = get_floatexcept(FEAll)

# testFlags
is_floatexcept(f::FloatExceptionSet) = in(f,get_floatexcept(f))
is_floatexcept{E<:FloatExceptions}(::Type{E}) = is_floatexcept(convert(FloatExceptionSet,E))
is_floatexcept() = is_floatexcept(FEAll)

# TODO: raiseFlags, restoreFlags

end
