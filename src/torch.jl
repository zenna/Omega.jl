# Light wrapper over pytorch
@pyimport torch
@pyimport torch.nn as nn
@pyimport torch.autograd as autograd
@pyimport torch.optim as optim



Tensor = PyObject

"Put onto gpu"
cuda(x::Tensor) = x["cuda"]()
variable(x::Tensor) = autograd.Variable(x)
Base.sum(x::Tensor, args...) = torch.sum(x, args...)

backward!(x::Tensor, args...) = x["backward"](args...)

l1 = nn.Linear(100, 100)
l2 = nn.Linear(100, 100)
l3 = l1 ∘ l2

