
using DifferentialEquations
using SimpleDiffEq
using Random
using Plots
using BenchmarkTools


function infection_rate(u,p,t)
    (S,I,R) = u
    (β,γ) = p
    N = S+I+R
    β*S*I/N
end
function infection!(integrator)
  integrator.u[1] -= 1
  integrator.u[2] += 1
end
infection_jump = ConstantRateJump(infection_rate,infection!)


function recovery_rate(u,p,t)
    (S,I,R) = u
    (β,γ) = p
    γ*I
end
function recovery!(integrator)
  integrator.u[2] -= 1
  integrator.u[3] += 1
end
recovery_jump = ConstantRateJump(recovery_rate,recovery!)


tspan = (0.0,50.0)
u0 = [999.0,1.0,0.0]
p = [0.5,0.25]
Random.seed!(1234)


prob = DiscreteProblem(u0,tspan,p)
prob_sir_jump = JumpProblem(prob,Direct(),infection_jump,recovery_jump)
sol_sir_jump = solve(prob_sir_jump,FunctionMap())


plot(sol_sir_jump,vars=[(0,1),(0,2),(0,3)])


@benchmark solve(prob_sir_jump,FunctionMap())
