using Plots

@recipe function plot_field(st::DummyStruct, field::Symbol; normalization=1.0, fill0=false)
    id = "DummyStruct: " * string(field)
    @assert hasfield(typeof(st), field) "$(location(st)) does not have field `$field`."

    # Record keyword arguments.
    assert_type_and_record_argument(id, AbstractFloat, "Normalization factor"; normalization)
    assert_type_and_record_argument(id, Bool, "Fill area under curve"; fill0)

    # Compute x and y values.
    yvalue = getfield(st, field)

    if typeof(yvalue) <: AbstractArray
        yvalue .*= normalization
    end

    # Create a series for plotting.
    @series begin
        xlabel --> "index"
        fill --> fill0
        yvalue
    end
end

@recipe function plot_field(st::NestedStruct; my_title="This is for NestedStruct")
    id = "NestedStruct: aa"

    # Record keyword arguments.
    assert_type_and_record_argument(id, String, "Title of plot"; my_title)

    # Create a series for plotting.
    @series begin
        title --> my_title
        st.aa
    end
end