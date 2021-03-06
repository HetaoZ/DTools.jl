module DTools
using Distributed
@everywhere using DistributedArrays
export showdist!, showfield!

function showdist!(a::DArray)
    println("PID   |  localindices")
    for pid in workers()
        ind = @fetchfrom pid localindices(a)
        for i in ind
            if length(i) == 0
                ind = "-"
                break
            end
        end
        println(pid,"        ",ind)
    end
end

function showfield!(c::AbstractArray, str::String, inds::UnitRange{Int64}...; axis::Int = 0)
    s = Symbol(str)
    if length(inds) == 0
        inds = Tuple([1:size(c,i) for i = 1:length(size(c))])
    end
    a = Array{Any}(undef, size(view(c, inds...))) 
    firstinds = CartesianIndex(Tuple([inds[i][1] - 1 for i = 1:length(inds)]))
    if axis == 0
        for k in CartesianIndices(a)
            a[k] = getfield(c[k + firstinds], s)
        end
    else
        for k in CartesianIndices(a)
            ak = getfield(c[k + firstinds], s)
            a[k] = ak[axis]
        end
    end
    display(a)
end
end
