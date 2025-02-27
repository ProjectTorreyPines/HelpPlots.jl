module HelpPlotsExt

using HelpPlots
using Plots

"""
    help_plot(args...; kw...)

Prints plotting arguments for objects
Call `help_plot(...)` just like you would call `plot(...)`.

Returns the plot.
"""
function HelpPlots.help_plot(args...; kw...)
    empty!(HelpPlots._help_plot)
    p = plot(args...; kw...)
    display(HelpPlots._help_plot)
    return p
end

"""
    help_plot!(args...; kw...)

Prints plotting arguments for objects
Call `help_plot!(...)` just like you would call `plot!(...)`.

Returns the plot.
"""
function HelpPlots.help_plot!(args...; kw...)
    empty!(HelpPlots._help_plot)
    p = plot!(args...; kw...)
    display(HelpPlots._help_plot)
    return p
end


end  # module HelpPlotsExt
