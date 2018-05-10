## Process data
## ============
push!(pyimport("sys")["path"], pwd());
data = pyimport("reader")[:getdata]()

df = DataFrame(Id = String[], Time = String[], Measure = Int[], Value = Float64[])

function handle!(arr::Array{Any, 2}, df::DataFrame)
  for i = 1:size(arr, 1)
    append!(df, DataFrame([arr[i, 1], arr[i, 2], arr[i, 3], float(arr[i, 4])], names(df)))
  end
end 

function handle!(arrs::Array{Array{Any,1},1}, df::DataFrame)
  j = 1
  for arr in arrs
    # @grab arr
    # @show j
    length(arr) != 4 && continue
    append!(df, DataFrame([arr[1], arr[2], arr[3], float(arr[4])], names(df)))
    j += 1
  end
end

function processdata(data)
  df = DataFrame(Id = String[], Time = String[], Measure = Int[], Value = Float64[])
  for (k, arr) in enumerate(values(data))
    handle!(arr, df)
  end
  df
end
