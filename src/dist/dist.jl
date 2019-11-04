module Dist

import Distributions
const Djl = Distributions
using DocStringExtensions: SIGNATURES

import ..Inference: defalg

import ..Omega:lift
import ..Prim
import ..Util: *ₛ
import ..NonDet: RandVar, elemtype
import ..Causal: ReplaceRandVar
import ..Inference: FailUnsat
using Spec

# Modules with dist props
import Statistics: mean, var
import Base: minimum, maximum

# Dist Ops 
export  succprob,
        support,
        failprob,
        maximum,
        minimum,
        islowerbounded,                    
        isupperbounded,
        isbounded,
        std,
        mean,
        median,
        mode,
        modes,
        skewness,
        kurtosis,
        isplatykurtic,
        ismesokurtic,
        isleptokurtic,
        entropy,
        prob
        
        # Dist Algs
export samplemean,
       sampleprob
        
        # Lifted distributional functions
export  succprobᵣ,
        failprobᵣ,
        maximumᵣ,
        minimumᵣ,
        islowerboundedᵣ,                    
        isupperboundedᵣ,
        isboundedᵣ,
        stdᵣ,
        medianᵣ,
        modeᵣ,
        modesᵣ,
        meanᵣ,
        probᵣ,
        skewnessᵣ,
        kurtosisᵣ,
        isplatykurticᵣ,
        ismesokurticᵣ,
        isleptokurticᵣ,
        entropyᵣ,
        meanᵣ,
        samplemeanᵣ,
        sampleprobᵣ


include("interface.jl")     # Distributional operators
include("distalgs.jl")      # Algorithms that compute distritbuional operators
include("djl.jl")           # Distributions.jl interop
include("liftdistop.jl")    # Lifting for higher order
include("defaults.jl")      # Distributions.jl interop


end