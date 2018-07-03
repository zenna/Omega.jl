using Revise
using Omega

function popModel_(ω, sex)
    # sex = step_dis_(ω, [(0,1,0.3307), (1,2,0.6693)])
    # sex = Omega.categorical(ω, [0.3307, 0.6693])
    # sex -= 0.5
    if sex < 1
        capital_gain = normal(ω, 568.4105, 24248365.5428)
        if capital_gain < 7298.0000
            age = normal(ω, 38.4208, 184.9151)
            education_num = normal(ω, 10.0827, 6.5096)
            capital_loss = normal(ω, 86.5949, 157731.9553)
        else
            age = normal(ω, 38.8125, 193.4918)
            education_num = normal(ω, 10.1041, 6.1522)
            capital_loss = normal(ω, 117.8083, 252612.0300)
        end
    else
        capital_gain = normal(ω, 1329.3700, 69327473.1006)
        if capital_gain < 5178.0000
            age = normal(ω, 38.6361, 187.2435)
            education_num = normal(ω, 10.0817, 6.4841)
            capital_loss = normal(ω, 87.0152, 161032.4157)
        else
            age = normal(ω, 38.2668, 187.2747)
            education_num = normal(ω, 10.0974, 7.1793)
            capital_loss = normal(ω, 101.7672, 189798.1926)
        end
    end

    if (education_num > age)
        age = education_num
    end
    # sensitiveAttribute(sex < 1)
    # qualified(age > 18)
    return (sex, age, capital_gain, capital_loss)
end

function popModel(ω)
    sex = Omega.categorical(ω, [0.3307, 0.6693])
    sex -= 0.5
    return popModel_(ω,sex)
end

function maleModel(ω)
    return popModel_(ω,1.5)
end

function femaleModel(ω)
    return popModel_(ω,0.5)
end

W = randarray([normal(0.0006,1.0), normal(-5.7363,1.0), normal(-0.0002,1.0)])
b = normal(1.0003,1.0)
δ = normal(-0.0003,1.0)

function F(ω, sex, age, capital_gain, capital_loss)
    N_age = (age - 17.0) / 62.0
    N_capital_gain = (capital_gain - 0.0) / 22040.0
    N_capital_loss = (capital_loss - 0.0) / 1258.0
    t = W[1](ω) * N_age + W[2](ω) * N_capital_gain + W[3](ω) * N_capital_loss + b(ω)
    if sex > 1.0
        t = t + δ(ω)
    end
    return t < 0
    # fairnessTarget(t < 0)
end

t(ω) = F(ω, popModel(ω)[1], popModel(ω)[2],popModel(ω)[3],popModel(ω)[4])

rand(iid(popModel))

rand(iid(t))

m_isrich_(ω) = F(ω, maleModel(ω)[1], maleModel(ω)[2], maleModel(ω)[3], maleModel(ω)[4])
f_isrich_(ω) = F(ω, femaleModel(ω)[1], femaleModel(ω)[2], femaleModel(ω)[3], femaleModel(ω)[4])

m_isrich = iid(m_isrich_; T = Bool)
f_isrich = iid(f_isrich_; T = Bool)

fairness = prob(f_isrich ∥ (W,b,δ), 100) / prob(m_isrich ∥ (W,b,δ), 100) > 0.85

W_samples = rand(W, fairness)
