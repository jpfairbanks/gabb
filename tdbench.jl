#tdbench.jl a benchmark of the tracediff code
# stripped down to just the essentials for benchmarking.

using LightGraphs
using Base.Test
using BenchmarkTools

macro R_str(s)
    s
end

println(R"$\mid V\mid$ & $\mid E \mid$ & $tri(A) (ms)$ & $tri(A+\Delta) (ms)$ & $triupate(A,\Delta) (ms)$ & $triupate2(A,\Delta) (ms)$ ")

tri(x::AbstractMatrix) = trace(x^3)/6

"""
    triupdate(A, Δ)

Computes the number of new triangles in a graph.
"""
function triupdate(A, Δ)
    return ( 3trace(( A^2 )*Δ) + 3trace(A*( Δ^2 )) + trace(Δ^3) )/6
    # return ( trace(( A^2 )*Δ + A*( Δ^2 ) + Δ^3 ) )
end


function triupdate2(A, Δ)
    t = (A*Δ)
    return ( 3trace(t*A) + 3trace(Δ*t) + trace(Δ^3) )/6
    # return ( 3ttrace(t,A) + 3ttrace(Δ,t) + ttrace(Δ, Δ^2) )/6
    # return ( trace(( A^2 )*Δ + A*( Δ^2 ) + Δ^3 ) )
end

function bench(n,ef)
    V = n
    E = ef*V
    g = Graph(V, E)
    d = difference(Graph(V, 2V), g)
    A = adjacency_matrix(g)
    Δ = adjacency_matrix(d)
    B = A+Δ

    # @show @benchmark triupdate($A, $Δ)
    # @show @benchmark triupdate2($A, $Δ)
    # @show @benchmark tri($A)
    # @show @benchmark tri($B)

    # @show median(@benchmark tri(A)).time
    # @show median(@benchmark tri(B)).time
    # @show median(@benchmark triupdate(A, Δ)).time
    # @show median(@benchmark triupdate2(A, Δ)).time

    t = median(@benchmark tri($A)).time / 1000000
    print("$n & $(ef*n) & $t")
    t = median(@benchmark tri($B)).time / 1000000
    print("& $t")
    t = median(@benchmark triupdate($A, $Δ)).time / 1000000
    print("& $t")
    t = median(@benchmark triupdate2($A, $Δ)).time / 1000000
    println("& $t\\\\")
end

bench(1000, 8)
bench(10000, 8)
bench(1000, 16)
bench(10000, 16)
