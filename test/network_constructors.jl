@test try
    @info "testing copper plate network construction"
    ps_model = PSI.CanonicalModel(Model(GLPK_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PSI.CopperPlatePowerModel, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PSI.CopperPlatePowerModel, sys5b);
    PSI.constructnetwork!(ps_model, PSI.CopperPlatePowerModel, sys5b);
true finally end

@test try
    @info "testing DC-PF with PTDF formulation"
    PTDF, A = PowerSystems.buildptdf(branches5, nodes5)
    ps_model = PSI.CanonicalModel(Model(GLPK_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PSI.StandardPTDFModel, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PSI.StandardPTDFModel, sys5b);
    PSI.constructnetwork!(ps_model, PSI.StandardPTDFModel, sys5b; PTDF = PTDF)
true finally end


@test_throws ArgumentError try
    @info "testing error PTDF formulation with no PTDF supplied"
    ps_model = PSI.CanonicalModel(Model(GLPK_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PSI.StandardPTDFModel, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PSI.StandardPTDFModel, sys5b);
    PSI.constructnetwork!(ps_model, PSI.StandardPTDFModel, sys5b)
true finally end

@test try
    @info "testing DC-PF network construction"
    ps_model = PSI.CanonicalModel(Model(GLPK_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PM.DCPlosslessForm, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PM.DCPlosslessForm, sys5b);
    PSI.constructnetwork!(ps_model, PM.DCPlosslessForm, sys5b);
true finally end

@test try
    @info "testing AC-PF network construction"
    ps_model = PSI.CanonicalModel(Model(ipopt_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PM.StandardACPForm, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PM.StandardACPForm, sys5b);
    PSI.constructnetwork!(ps_model, PM.StandardACPForm, sys5b);
true finally end

@test try
    @info "testing AC-PF network construction with QCWRForm"
    ps_model = PSI.CanonicalModel(Model(ipopt_optimizer),
    Dict{String, JuMP.Containers.DenseAxisArray{JuMP.VariableRef}}(),
    Dict{String, JuMP.Containers.DenseAxisArray}(),
    nothing,
    Dict{String, PSI.JumpAffineExpressionArray}("var_active" => PSI.JumpAffineExpressionArray(undef, 5, 24),
                                               "var_reactive" => PSI.JumpAffineExpressionArray(undef, 5, 24)),
    Dict());
    PSI.constructdevice!(ps_model, PSY.ThermalGen, PSI.ThermalDispatch, PM.QCWRForm, sys5b); 
    PSI.constructdevice!(ps_model, PSY.PowerLoad, PSI.StaticPowerLoad, PM.QCWRForm, sys5b);
    PSI.constructnetwork!(ps_model, PM.QCWRForm, sys5b);
true finally end

#=
@test try
    @info "testing net flow"
    Net = PSI.StandardNetFlow
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys5);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys5);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys5)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 3400, atol = 1000)
finally end

@test try
    @info "testing PTDF 5-bus"
    Net = PSI.StandardPTDFModel
    m = Model(ipopt_optimizer);
    ptdf,  A = PSY.buildptdf(sys5.branches, sys5.buses)
    netinjection = PSI.instantiate_network(Net, sys5);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys5);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys5, PTDF = ptdf)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 3400, atol = 1000)
finally end

@test try
    @info "testing AngleDC-OPF 5-bus"
    Net = PM.DCPlosslessForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys5);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys5);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys5)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 3400, atol = 1000)
finally end

@test try
    @info "testing ACP-OPF 5-bus"
    Net = PM.StandardACPForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys5);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys5);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys5)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 3400, atol = 1000)
true finally end

@test try
    @info "testing ACP- QCWForm 5-bus"
    Net = PM.QCWRForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys5);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys5);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys5)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 3400, atol = 1000)
true finally end



include(joinpath(base_dir,"data/data_14bus_pu.jl"))
sys14 = PowerSystem(nodes14, generators14, loads14, branches14, nothing,  100.0);


@test try
    @info "testing copper plate 14-bus"
    Net = PSI.CopperPlatePowerModel
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
finally end


@test try
    @info "testing net 14-bus"
    Net = PSI.StandardNetFlow
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
finally end


@test_skip try
    @info "testing PTDF 14-bus"
    Net = PSI.StandardPTDFModel
    m = Model(ipopt_optimizer);
    ptdf,  A = PSY.buildptdf(sys14.branches, sys14.buses)
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14, PTDF = ptdf)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
finally end

@test try
    @info "testing AngleDC-OPF 14-bus"
    Net = PM.DCPlosslessForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
finally end

@test try
    @info "testing ACP-OPF 14-bus"
    Net = PM.StandardACPForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
true finally end

@test try
    @info "testing ACP-QCWForm 14-bus"
    Net = PM.QCWRForm
    m = Model(ipopt_optimizer);
    netinjection = PSI.instantiate_network(Net, sys14);
    PSI.constructdevice!(m, netinjection, ThermalGen, PSI.ThermalDispatch, Net, sys14);
    PSI.constructnetwork!(m, [(device=Line, formulation=PSI.PiLine)], netinjection, Net, sys14)
    JuMP.@objective(m, Min, m.obj_dict[:objective_function])
    JuMP.optimize!(m)
    isapprox(JuMP.objective_value(m), 1200, atol = 1000)
true finally end
=#