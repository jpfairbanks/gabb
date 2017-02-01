
using ReverseDiff

tri(x::AbstractMatrix) = trace(x^3)/6
lcc(x::AbstractMatrix) = diag(x^3)./2
g(f) = x -> gradient(f, x) # g = ∇f
x = [0 1 1 0 1;
     1 0 1 0 1;
     1 1 0 1 0;
     0 0 1 0 1;
     1 1 0 1 0;
     ]
h(x) = 2*triu(g(tri)(x) .* (ones(Int, size(x)).-(I+x)))
@show tri(x)
@show h(x)
@show g(x)

"""
l(A)[i,v*n+u] is the number of triangles created by inserting an edge between
vertices v and u into the graph A

"""
function l(A::AbstractMatrix)
    return 2*jacobian(lcc, A)
end
