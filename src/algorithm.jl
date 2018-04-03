abstract type Algorithm end

"Rejection Sampling"
abstract type RejectionSample <: Algorithm end

"Metropolis Hastings"
abstract type MH <: Algorithm end

"Single Site MH"
abstract type SSMH <: Algorithm end
