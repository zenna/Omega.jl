"Vector with pointer to element"
mutable struct CountVec{T}  
  data::Vector{T}
  count::Int
end

CountVec(xs::Vector{T}) where T = CountVec{T}(xs, 1)
CountVec{T}() where T = CountVec{T}(T[], 1)

function next!(cv::CountVec, T)
  if cv.count <= length(cv.data)
    val = cv.data[cv.count]
    cv.count += 1
    val
  else
    # @assert cv.count == length(cv.data) + 1
    cv.count += 1
    val = rand(T)
    push!(cv.data, rand(T))
    val
  end 
end
resetcount!(cv::CountVec) = cv.count = 1
