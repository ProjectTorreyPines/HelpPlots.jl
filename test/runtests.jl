using HelpPlots
using Test

struct NestedStruct
    aa::Vector{Float64}
end

struct DummyStruct
    a::Vector{Float64}
    b::Vector{Float64}

    X::NestedStruct
end


@testset "HelpPlots2" begin
    # The followings should fail because `Plots.jl` package is not loaded yet.
    @test_throws Exception help_plot(rand(5))
    @test_throws Exception help_plot!(rand(5))
end

@testset "HelpPlots.jl" begin
    # `Plots.jl` package is loaded in the `my_recipes.jl`
    include("my_recipes.jl")

    ST = DummyStruct(rand(20), rand(10), NestedStruct(rand(5)))

    @info "Normal plot ..."
    p = plot(ST, :a)
    @test typeof(p) <: Plots.Plot


    @info "Testing help_plot ..."
    p = help_plot(ST, :a)
    @test typeof(p) <: Plots.Plot

    help_plot!(ST, :a; normalization=5.0)
    @test_throws Exception help_plot!(ST, :a; normalization=true)


    p = help_plot!(ST, :b; fill0=true)
    @test typeof(p) <: Plots.Plot
    @test_throws Exception help_plot!(ST, :a; fill0=3)

    p = help_plot!(ST, :X; fill0=true)
    p = help_plot!(ST, :X; fill0=true, my_title="EEEEEE")
    @test_throws Exception p = help_plot!(ST, :X; my_title=34)

    display(p)
end
