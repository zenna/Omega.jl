module OmegaZygote

import Zygote
import ..OmegaGrad
export ZygoteGrad

struct ZygoteGradAlg <: OmegaGrad.GradAlg end
const ZygoteGrad = ZygoteGradAlg()

function OmegaGrad.lineargradient(rv, ω, ::ZygoteGradAlg)
  @assert false "unimplemented"
end

function OmegaGrad.grad(rv, ω, ::ZygoteGradAlg)
  Zygote.gradient(rv, ω)
end


end