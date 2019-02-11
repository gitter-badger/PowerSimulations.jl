function device_linear_rateofchange(ps_m::CanonicalModel, rate_data::Array{Tuple{String,NamedTuple{(:up, :down),Tuple{Float64,Float64},Float64},1}, time_range::UnitRange{Int64}, cons_name::String, var_name::String)

    set_name = [r[1] for r in rate_data]

    ps_m.constraints["$(cons_name)_up"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_name, time_range)
    ps_m.constraints["$(cons_name)_down"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_name, time_range)

    for r in rate_data

        ps_m.constraints["$(cons_name)_up"][r[1], 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_name)"][i[1], 1] - r[3] <= r[2].up)
        ps_m.constraints["$(cons_name)_down"][r[1], 1] = JuMP.@constraint(ps_m.JuMPmodel, r[3] - ps_m.variables["$(var_name)"][i[1], 1] <= r[2].down)

    end

    for t in time_range[2:end], r in rate_data

        ps_m.constraints["$(cons_name)_up"][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_name)"][i[1], t-1] - ps_m.variables["$(var_name)"][i[1], t] <= r[2].up)
        ps_m.constraints["$(cons_name)_down"][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_name)"][i[1], t] - ps_m.variables["$(var_name)"][i[1], t-1] <= r[2].down)

    end

end

function device_mixedinteger_rateofchange(ps_m::CanonicalModel, rate_data::Array{Tuple{String,NamedTuple{(:up, :down),Tuple{Float64,Float64}},NamedTuple{(:min, :max),Tuple{Float64,Float64}},Float64},1}, time_range::UnitRange{Int64}, cons_name::String, var_names::(String,String,String))

    set_name = [r[1] for r in rate_data]

    ps_m.constraints["$(cons_name)_up"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_name, time_range)
    ps_m.constraints["$(cons_name)_down"] = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}(undef, set_name, time_range)

    for r in rate_data

        ps_m.constraints["$(cons_name)_up"][r[1], 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_names[1])"][i[1], 1] - r[4] <= r[2].up + r[3].max*ps_m.variables["$(var_names[2])"][i[1], 1])
        ps_m.constraints["$(cons_name)_down"][r[1], 1] = JuMP.@constraint(ps_m.JuMPmodel, r[3] - ps_m.variables["$(var_names[1])"][i[1], 1] <= r[2].down + r[3].min*ps_m.variables["$(var_names[3])"][i[1], 1])

    end

    for t in time_range[2:end], r in rate_data

        ps_m.constraints["$(cons_name)_up"][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_names[1])"][i[1], t-1] - ps_m.variables["$(var_names[1])"][i[1], t] <= r[2].up + r[3].max*ps_m.variables["$(var_names[2])"][i[1], t])
        ps_m.constraints["$(cons_name)_down"][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables["$(var_names[1])"][i[1], t] - ps_m.variables["$(var_names[1])"][i[1], t-1] <= r[2].down + + r[3].min*ps_m.variables["$(var_names[3])"][i[1], t])

    end
    
end



