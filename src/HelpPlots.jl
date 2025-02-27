module HelpPlots

mutable struct HelpPlotsParameter
    name::String
    argument::Symbol
    type::Any
    description::String
    value::Any
end

const _help_plot = Vector{HelpPlotsParameter}()

# Stub definitions to allow extensions to add methods.
"""
    help_plot!(args...; kw...)

Throws an error indicating that the in-place plotting helper requires the Plots.jl package to be loaded.
"""
function help_plot(args...; kw...)
    return error("Need to load `Plots.jl` package to use `help_plot(args...; kw...)`")
end


"""
    help_plot!(args...; kw...)

Throws an error indicating that the in-place plotting helper requires the Plots.jl package to be loaded.
"""
function help_plot!(args...; kw...)
    return error("Need to load `Plots.jl` package to use `help_plot!(args...; kw...)`")
end


"""
    assert_type_and_record_argument(name::String, type::Type, description::String; kw...)

Checks that exactly one keyword argument is provided and that its value is a subtype of the specified type.
"""
function assert_type_and_record_argument(name::String, type::Type, description::String; kw...)
    @assert length(kw) == 1
    argument = collect(keys(kw))[1]
    value = collect(values(kw))[1]

    @assert typeof(value) <: type "\"$argument\" has the wrong type of [$(typeof(value))]. It must be a subtype of [$(type)]"

    this_plotpar = HelpPlotsParameter(name, argument, type, description, value)

    only_match = true
    all_same_values = all(plotpar.value == this_plotpar.value for plotpar in _help_plot if "$(plotpar.name), $(plotpar.argument)" == "$(name), $(argument)")
    for plotpar in _help_plot
        if "$(plotpar.name), $(plotpar.argument)" == "$(this_plotpar.name), $(this_plotpar.argument)"
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
    old_name = nothing
    for (k, plotpar) in enumerate(plotpars)
        if plotpar.name != old_name
            if k > 1
                print(io, "\n")
            end
            printstyled(io, "$(plotpar.name)"; color=:green)
            print(io, "\n")
        end
        old_name = plotpar.name
        print(io, "     ")
        show(io, x, plotpar)
        if k < length(plotpars)
            print(io, "\n")
        end
    end
end

export help_plot, help_plot!
export assert_type_and_record_argument

end
