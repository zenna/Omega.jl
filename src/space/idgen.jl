const ID = Int

const uidcounter = Counter(0)

# # __init__() = global uidcounter = Counter(0) #= also works =#
# __init__() = reset!(uidcounter)

"Unique id"
# uid() = (global uidcounter; @show increment!(uidcounter))
uid() = increment!(uidcounter)

@spec :nocheck (x = [uid() for i = 1:Inf]; unique(x) == x)

"Construct globally unique id for indices for ω"
macro id()
  uid()
end