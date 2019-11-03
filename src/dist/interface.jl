import Base: minimum, maximum
import Distributions: succprob, support, failprob, maximum, minimum, islowerbounded,
                      isupperbounded, isbounded, std, median, mode, modes,
                      skewness, kurtosis, isplatykurtic, ismesokurtic,
                      isleptokurtic, entropy, mean

"Algorithm to compute distributional properrty"
abstract type DistAlgorithm end


const distops_names = (:succprob, :failprob, :maximum, :minimum, :islowerbounded,
           :isupperbounded, :isbounded, :std, :median, :mode, :modes,
           :skewness, :kurtosis, :isplatykurtic, :ismesokurtic,
           :isleptokurtic, :entropy, :mean)

const distops = (succprob, failprob, maximum, minimum, islowerbounded,
           isupperbounded, isbounded, std, median, mode, modes,
           skewness, kurtosis, isplatykurtic, ismesokurtic,
           isleptokurtic, entropy, mean)

const distop_types = map(typeof, distops)
const DistOp = Union{distop_types...}