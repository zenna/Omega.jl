## Process data
## ============
using CSV
using PyCall
using DataFrames

push!(pyimport("sys")["path"], pwd());
data = pyimport("reader")[:getdata]()

const dform = DateFormat("[HH:MM:ss dd/mm/yy]")

function handle!(arr::Array{Any, 2}, df::DataFrame)
  for i = 1:size(arr, 1)
    wow = DataFrame([arr[i, 1], DateTime(arr[i, 2], dform), arr[i, 3], float(arr[i, 4])])
    @grab wow
    append!(df, DataFrame([arr[i, 1], DateTime(arr[i, 2], dform), arr[i, 3], float(arr[i, 4])], names(df)))
  end
end 

function handle!(arrs::Array{Array{Any,1},1}, df::DataFrame)
  j = 1
  for arr in arrs
    # @grab arr
    # @show j
    length(arr) != 4 && continue
    append!(df, DataFrame([arr[1], DateTime(arr[2], dform), arr[3], float(arr[4])], names(df)))
    j += 1
  end
end

function processdata(data)
  df = DataFrame(Id = String[], Time = DateTime[], Measure = Int[], Value = Float64[])
  for (k, arr) in enumerate(values(data))
    handle!(arr, df)
  end
  df
end

df = processdata(data)