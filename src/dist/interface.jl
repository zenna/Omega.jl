import Base: minimum, maximum
import Distributions: succprob, support, failprob, maximum, minimum, islowerbounded,
                      isupperbounded, isbounded, std, median, mode, modes,
                      skewness, kurtosis, isplatykurtic, ismesokurtic,
                      isleptokurtic, entropy, mean, var

"Algorithm to compute distributional properrty"
abstract type DistAlgorithm end


const distops_names = (:succprob, :support, :failprob, :maximum, :minimum, :islowerbounded,
           :isupperbounded, :isbounded, :std, :median, :mode, :modes,
           :skewness, :kurtosis, :isplatykurtic, :ismesokurtic,
           :isleptokurtic, :entropy, :mean, :var)

const distops = (succprob, support, failprob, maximum, minimum, islowerbounded,
           isupperbounded, isbounded, std, median, mode, modes,
           skewness, kurtosis, isplatykurtic, ismesokurtic,
           isleptokurtic, entropy, mean, var)

const distop_types = map(typeof, distops)
const DistOp = Union{distop_types...}