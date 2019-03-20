using Omega
using Test

@test Bool(anyₛ([3.0 >ₛ 2.0, 1.0 ==ₛ 0.3]))
@test !Bool(!anyₛ([3.0 >ₛ 2.0, 1.0 ==ₛ 0.3]))
@test Bool(allₛ([3.0 >ₛ 2.0, 110.0 <ₛ 203.3]))
@test !Bool(allₛ([3.0 >ₛ 5.0, 110.0 <ₛ 203.3]))
