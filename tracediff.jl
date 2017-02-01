
tri(x::AbstractMatrix) = trace(x^3)/6
lcc(x::AbstractMatrix) = diag(x^3)./2

using LightGraphs
# if length(ARGS) >=2
# nvertices = parse(Int, ARGS[1])
# efactor = parse(Int, ARGS[2])
# else
#     nvertices = 40
#     efactor = 8
# end

# V = nvertices
# E = efactor*V
# g = Graph(V, E)
# d = difference(Graph(V, 2V), g)
# A = adjacency_matrix(g)
# Δ = adjacency_matrix(d)

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

storage = spzeros(Int, size(A)...)
tmp = spzeros(Int, size(A)...)
function triupdate(A, Δ, storage, tmp)
    t = 0
    A_mul_B!(storage, A, A)
    A_mul_B!(tmp, storage, Δ)
    t += 3trace(tmp)
    A_mul_B!(storage, A, Δ)
    A_mul_B!(tmp, storage, Δ)
    t += 3trace(tmp)
    A_mul_B!(storage, Δ, Δ)
    A_mul_B!(tmp, storage, Δ)
    t += 1trace(tmp)
    return t/6
end

function ttrace(A,B,C)
    s = 0
    for i in 1:n
        for k in 1:m
            for l in 1:p
                s += A[i,k] * B[k,l] * C[l,i]
            end
        end
    end
    return s
end

function ttrace2(A, B, C)
    s = 0
    Z = B*C
    n = size(A,1)
    for i in 1:n
       s += dot(A[i,:], Z[:, i])
    end
    return s
end

function ttrace(A, C)
    n,m = size(C)
    t = 0
    for i in 1:m
        t += (A*C[:,i])[i]
    end
    return t
end

using Base.Test
B = A+Δ
# B.nzval .= 1
@test tri(B) == triupdate(A, Δ) + tri(A)
# @test triupdate(A, Δ, storage, tmp) == triupdate(A, Δ)
# @time triupdate(A, Δ, storage, tmp)
# println("streaming update")
# @time triupdate(A, Δ)
# println("streaming update 2")
# triupdate2(A, Δ)
# @time triupdate2(A, Δ)
# # Profile.print(Profile.fetch())
# println("old graph from scratch")
# @time tri(A)
# println("new graph from scratch")
# @time tri(B)
# # println("faster trace product")
# # not faster
# # ttrace2(A,A,A)
# # @time ttrace2(A, A, A)

using BenchmarkTools

function bench(n,ef)
    V = n
    E = ef*V
    g = Graph(V, E)
    d = difference(Graph(V, 2V), g)
    A = adjacency_matrix(g)
    Δ = adjacency_matrix(d)
    B = A+Δ

    @show @benchmark triupdate(A, Δ)
    @show @benchmark triupdate2(A, Δ)
    @show @benchmark tri(A)
    @show @benchmark tri(B)

    # @show median(@benchmark tri(A)).time
    # @show median(@benchmark tri(B)).time
    # @show median(@benchmark triupdate(A, Δ)).time
    # @show median(@benchmark triupdate2(A, Δ)).time

    # t = median(@benchmark tri(A)).time / 1000000
    # print("$n & $(ef*n) & $t")
    # t = median(@benchmark tri(B)).time / 1000000
    # print("& $t")
    # t = median(@benchmark triupdate(A, Δ)).time / 1000000
    # print("& $t")
    # t = median(@benchmark triupdate2(A, Δ)).time / 1000000
    # println("& $t\\\\")
end

macro R_str(s)
    s
end

println(R"$\mid V\mid$ & $\mid E \mid$ & $tri(A) (ms)$ & $tri(A+\Delta) (ms)$ & $triupate(A,\Delta) (ms)$ & $triupate2(A,\Delta) (ms)$ ")
bench(5000, 8)
bench(50000, 8)
bench(5000, 16)
bench(50000, 16)
