"""
This function adds the power limits of generators when there are no CommitmentVariables
"""
function activepower(ps_m::canonical_model, devices::Array{H,1}, device_formulation::Type{D}, system_formulation::Type{S}, time_range::UnitRange{Int64}) where {H <: PowerSystems.HydroGen, D <: AbstractHydroDispatchForm, S <: PM.AbstractPowerFormulation}

    range_data = [(h.name, h.tech.activepowerlimits) for h in devices]

    device_range(ps_m, range_data, time_range, "hydro_active_range", "Phy")

end

"""
This function adds the power limits of renewable energy generators that can be dispatched
"""
function activepower(ps_m::canonical_model, devices::Array{R,1}, device_formulation::Type{HydroRunOfRiver}, system_formulation::Type{S}, time_range::UnitRange{Int64}) where {R <: PowerSystems.RenewableGen, S <: PM.AbstractPowerFormulation}

    ts_data = [(h.name, values(h.scalingfactor)*h.tech.installedcapacity) for h in devices]

    device_timeseries_ub(ps_m, ts_data , time_range, "hydro_active_ub", "Phy")

end

"""
This function adds the power limits of renewable energy generators that can be dispatched
"""
function activepower(ps_m::canonical_model, devices::Array{R,1}, device_formulation::Type{HydroSeasonalFlow}, system_formulation::Type{S}, time_range::UnitRange{Int64}) where {R <: PowerSystems.RenewableGen, S <: PM.AbstractPowerFormulation}

    #TODO: Add To Power Systems a data type to support this
    ts_data_ub = [(h.name, values(h.scalingfactor)*h.tech.installedcapacity) for h in devices]
    ts_data_lb = [(h.name, values(h.scalingfactor)*h.tech.installedcapacity) for h in devices]

    device_timeseries_ub(ps_m, ts_data_ub , time_range, "hydro_active_ub", "Phy")
    device_timeseries_lb(ps_m, ts_data_lb , time_range, "hydro_active_lb", "Phy")

end


"""
This function adds the power limits of generators when there are no CommitmentVariables
"""
function reactivepower(ps_m::canonical_model, devices::Array{H,1}, device_formulation::Type{D}, system_formulation::Type{S}, time_range::UnitRange{Int64}) where {H <: PowerSystems.HydroGen, D <: AbstractHydroDispatchForm, S <: AbstractACPowerModel}

    range_data = [(g.name, g.tech.reactivepowerlimits) for g in devices]

    device_range(ps_m, range_data, time_range, "hydro_reactive_range", "Qhy")

end