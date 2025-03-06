module HelpPlots

mutable struct HelpPlotsParameter
    dispatch::String
    argument::Symbol
    type::Any
    description::String
    value::Any
end

const _help_plot = Vector{HelpPlotsParameter}()

"""
    recipe_dispatch(args...)

Function used to return a string describing the recipe, starting from the arguments used for multiple dispatching of the recipie
"""
function recipe_dispatch(args...)
    return join(map(recipe_dispatch, args), ",")
end

"""
    recipe_dispatch(arg::Any)

Returns string representation of each of the arguments in the recipie. Packages using HelpPlots can specialize this for their specific types.
"""
function recipe_dispatch(arg::Any)
    return string(typeof(arg))
end

# Stub definitions to allow extensions to add methods.
"""
    help_plot(args...; kw...)

Prints plotting arguments for objects

Call `help_plot(...)` just like you would call `plot(...)`.

Returns the plot.
"""
function help_plot()
    return error("Need to load `Plots.jl` package to use `help_plot(args...; kw...)`")
end


"""
    help_plot!(args...; kw...)

Prints plotting arguments for objects

Call `help_plot!(...)` just like you would call `plot!(...)`.

Returns the plot.
"""
function help_plot!()
    return error("Need to load `Plots.jl` package to use `help_plot!(args...; kw...)`")
end

"""
    assert_type_and_record_argument(dispatch::AbstractString, type::Type, description::AbstractString; kw...)

Checks that exactly one keyword argument is provided and that its value is a subtype of the specified type.
"""
function assert_type_and_record_argument(dispatch::AbstractString, type::Type, description::AbstractString; kw...)
    @assert length(kw) == 1
    argument = collect(keys(kw))[1]
    value = collect(values(kw))[1]

    @assert typeof(value) <: type "\"$argument\" has the wrong type of [$(typeof(value))]. It must be a subtype of [$(type)]"

    this_plotpar = HelpPlotsParameter(dispatch, argument, type, description, value)

    only_match = true
    all_same_values = all(plotpar.value == this_plotpar.value for plotpar in _help_plot if "$(plotpar.dispatch), $(plotpar.argument)" == "$(dispatch), $(argument)")
    for plotpar in _help_plot
        if "$(plotpar.dispatch), $(plotpar.argument)" == "$(this_plotpar.dispatch), $(this_plotpar.argument)"
            if !all_same_values
                plotpar.value = :__MIXED__
            end
            only_match = false
        end
    end

    if only_match
        push!(_help_plot, this_plotpar)
    end

    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", plotpar::HelpPlotsParameter)
    printstyled(io, plotpar.argument; bold=true)
    printstyled(io, "::$(plotpar.type)"; color=:blue)
    printstyled(io, " = ")
    if plotpar.value == :__MIXED__
        printstyled(io, "MIXED"; color=:magenta, bold=true)
    else
        printstyled(io, "$(repr(plotpar.value))"; color=:red, bold=true)
    end
    return printstyled(io, "  # $(plotpar.description)"; color=248)
end

function Base.show(io::IO, x::MIME"text/plain", plotpars::AbstractVector{<:HelpPlotsParameter})
    old_id = nothing
    for (k, plotpar) in enumerate(plotpars)
        if plotpar.dispatch != old_id
            if k > 1
                print(io, "\n")
            end
            printstyled(io, "$(plotpar.dispatch)"; color=:green)
            print(io, "\n")
        end
        old_id = plotpar.dispatch
        print(io, "     ")
        show(io, x, plotpar)
        if k < length(plotpars)
            print(io, "\n")
        end
    end
end

export help_plot, help_plot!
export recipe_dispatch, assert_type_and_record_argument

const document = Dict()
document[Symbol(@__MODULE__)] = [name for name in Base.names(@__MODULE__; all=false, imported=false) if name != Symbol(@__MODULE__)]

end
