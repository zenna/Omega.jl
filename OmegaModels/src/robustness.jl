using Revise
using Omega

"Population model"
function popModel_(ω, sex)
    # sex = step_dis_(ω, [(0,1,0.3307), (1,2,0.6693)])
    # sex = Omega.categorical(ω, [0.3307, 0.6693])
    # sex -= 0.5
    if sex < 1
        capital_gain = normal(ω[@id], 568.4105, sqrt(24248365.5428))
        if capital_gain < 7298.0000
            age = normal(ω[@id], 38.4208, sqrt(184.9151))
            education_num = normal(ω[@id], 10.0827, sqrt(6.5096))
            capital_loss = normal(ω[@id], 86.5949, sqrt(157731.9553))
        else
            age = normal(ω[@id], 38.8125, sqrt(193.4918))
            education_num = normal(ω[@id], 10.1041, sqrt(6.1522))
            capital_loss = normal(ω[@id], 117.8083, sqrt(252612.0300))
        end
    else
        capital_gain = normal(ω[@id], 1329.3700, sqrt(69327473.1006))
        if capital_gain < 5178.0000
            age = normal(ω[@id], 38.6361, sqrt(187.2435))
            education_num = normal(ω[@id], 10.0817, sqrt(6.4841))
            capital_loss = normal(ω[@id], 87.0152, sqrt(161032.4157))
        else
            age = normal(ω[@id], 38.2668, sqrt(187.2747))
            education_num = normal(ω[@id], 10.0974, sqrt(7.1793))
            capital_loss = normal(ω[@id], 101.7672, sqrt(189798.1926))
        end
    end

    if (education_num > age)
        age = education_num
    end
    # sensitiveAttribute(sex < 1)
    # qualified(age > 18)
    return (sex, age, education_num, capital_gain)
end

function popModel(ω)
    sex = Omega.categorical(ω[@id], [0.3307, 0.6693])
    sex -= 0.5
    return popModel_(ω,sex)
end

function normalize(sex, age, education_num, capital_gain)
    N_age = ((age - 17.0) / 73.0  - 0.5) * 10 + 0.5
    N_education_num = ((education_num - 3.0) / 13.0  - 0.5) * 10 + 0.5
    N_capital_gain = ((capital_gain - 0.0) / 22040.0 - 0.5) * 10 + 0.5
    return (sex, N_age, N_education_num, N_capital_gain)
end

function F(ω, sex, N_age, N_education_num, N_capital_gain, params)
    W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2 = params
    h1 = W_h1[1](ω) * N_age +  W_h1[2](ω) * N_education_num +  W_h1[3](ω) * N_capital_gain +  b_h1(ω)
    if h1 < 0
        h1 = 0
    end
    h2 = W_h2[1](ω) * N_age +  W_h2[2](ω) * N_education_num +  W_h2[3](ω) * N_capital_gain +  b_h2(ω)
    if h2 < 0
        h2 = 0
    end
    o1 =  W_o1[1](ω) * h1 +  W_o1[2](ω) * h2 + b_o1(ω)
    if o1 < 0
        o1 = 0
    end
    o2 =  W_o2[1](ω) * h1 + W_o2[2](ω) * h2 +  b_o2(ω)
    if o2 < 0
        o2 = 0
    end
    # println("Result: $(o2-o1)")
    return o1 < o2
end

# the activation of F
function F_act(ω, sex, N_age, N_education_num, N_capital_gain, W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2)
    h1 = W_h1[1](ω) * N_age +  W_h1[2](ω) * N_education_num +  W_h1[3](ω) * N_capital_gain +  b_h1(ω)
    if h1 < 0
        h1 = 0
        act_h1 = false
    else
        act_h1 = true
    end
    h2 = W_h2[1](ω) * N_age +  W_h2[2](ω) * N_education_num +  W_h2[3](ω) * N_capital_gain +  b_h2(ω)
    if h2 < 0
        h2 = 0
        act_h2 = false
    else
        act_h2 = true
    end
    o1 =  W_o1[1](ω) * h1 +  W_o1[2](ω) * h2 + b_o1(ω)
    if o1 < 0
        o1 = 0
        act_o1 = false
    else
        act_o1 = true
    end
    o2 =  W_o2[1](ω) * h1 + W_o2[2](ω) * h2 +  b_o2(ω)
    if o2 < 0
        o2 = 0
        act_o2 = false
    else
        act_o2 = true
    end
    return (act_h1, act_h2, act_o1, act_o2, o1 < o2)
end

# the gradient of F such that F changes the currrent output.
function F_grad(ω, sex, N_age, N_education_num, N_capital_gain, W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2)
    input_grad = [1.0, 1.0, 1.0]

    (act_h1, act_h2, act_o1, act_o2, result) = F_act(ω, sex, N_age, N_education_num, N_capital_gain, W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2)

    if act_h1
        h1_grad = (input_grad[1] * W_h1[1](ω), input_grad[2] * W_h1[2](ω), input_grad[3] * W_h1[3](ω)) 
    else
        h1_grad = (0, 0, 0)
    end

    if act_h2
        h2_grad = (input_grad[1] * W_h2[1](ω), input_grad[2] * W_h2[2](ω), input_grad[3] * W_h2[3](ω)) 
    else
        h2_grad = (0, 0, 0)
    end

    if act_o1
        o1_grad = (h1_grad[1] * W_o1[1](ω) + h2_grad[1] * W_o1[2](ω),
        h1_grad[2] * W_o1[1](ω) + h2_grad[2] * W_o1[2](ω),
        h1_grad[3] * W_o1[1](ω) + h2_grad[3] * W_o1[2](ω))
    else
        o1_grad = (0, 0, 0)
    end

    if act_o2
        o2_grad = (h1_grad[1] * W_o2[1](ω) + h2_grad[1] * W_o2[2](ω),
        h1_grad[2] * W_o2[1](ω) + h2_grad[2] * W_o2[2](ω),
        h1_grad[3] * W_o2[1](ω) + h2_grad[3] * W_o2[2](ω))
    else
        o2_grad = (0, 0, 0)
    end

    # println("o1_grad: $(o1_grad)")
    # println("o2_grad: $(o2_grad)")

    if result
        return (0.0, o1_grad[1] - o2_grad[1], o1_grad[2] - o2_grad[2], o1_grad[3] - o2_grad[3])
    end

    return (0.0, o2_grad[1] - o1_grad[1], o2_grad[2] - o1_grad[2], o2_grad[3] - o1_grad[3])
end

ϵ = 0.2

function gen_attack(ω, sex, N_age, N_education_num, N_capital_gain, params)
    g = F_grad(ω, sex, N_age, N_education_num, N_capital_gain, params...)
    # not sure if argmax is implemented
    age_g = g[2]
    edu_g = g[3]
    cap_g = g[4]
    if age_g == 0 && edu_g == 0 && cap_g == 0
        return (0,0,0,0)
    end
    abs_age = abs(age_g)
    abs_edu_num = abs(edu_g)
    abs_cap_gain = abs(cap_g)
    if abs_age >= abs_edu_num && abs_age >= abs_cap_gain
        return (0, ϵ * age_g/abs_age , 0, 0)
    end
    
    if abs_edu_num >= abs_age && abs_edu_num >= abs_cap_gain
        return (0, 0, ϵ * edu_g / abs_edu_num, 0)
    end

    return (0, 0, 0, ϵ * cap_g / abs_cap_gain)
end

function infer_robust(n=10, rjct_samp = false)
    W_h1 = randarray([normal(-0.2277,1.0), normal(0.6434,1.0), normal(2.3643,1.0)])
    b_h1 = normal(3.7146,1.0)

    W_h2 = randarray([normal(-0.0236,1.0), normal(-3.3556,1.0), normal(-1.8183,1.0)])
    b_h2 = normal(-1.7810,1.0)

    W_o1 = randarray([normal(0.4865, 1.0), normal(1.0685, 1.0)])
    b_o1 = normal(-1.8079,1.0)

    W_o2 = randarray([normal(1.7044, 1.0), normal(-1.3880, 1.0)])
    b_o2 = normal(0.6830,1.0)
    params = (W_h1, b_h1, W_h2, b_h2, W_o1, b_o1, W_o2, b_o2)
    # State stability.
    input(ω) = popModel(ω)
    normal_input(ω) = normalize(input(ω)...)
    output(ω) = F(ω, normal_input(ω)..., params)
    δ(ω) =  gen_attack(ω, normal_input(ω)..., params)
    perturb_input(ω) = normal_input(ω) .+ δ(ω)
    perturb_output(ω) = F(ω, perturb_input(ω)..., params)

    output_ = ciid(output)
    perturb_output_ = ciid(perturb_output)

    # TODO: conditioning on KL draw samples of the parameters

    # Alternative: pointwise:
    class_same(ω) = (output(ω) == perturb_output(ω))
    class_same_ = ciid(class_same; T= Bool)
    stability = prob(class_same_∥ params) > 0.99 # 99% points robust

    if !rjct_samp
        return rand(params, stability; n = n)
    end
    return rand(params, stability, RejectionSample; n = n)
end 

function test_robustness(params)
    #draw 100 samples
    robust_count = 0
    pop = ciid(popModel)
    for i = 1:1000
        input = rand(pop)
        n_input = normalize(input...)
        # println(F_act(1.0, n_input...,params...))
        # println(n_input)
        output = F(1.0, n_input..., params)
        # println(output)
        δ = gen_attack(1.0, n_input..., params)
        # println(δ)
        n_input1 = n_input .+ δ
        # println(n_input1)
        # println("act: $(F_act(1.0, n_input1...,params...))")
        output1 = F(1.0, n_input1..., params)
        # println(output1)
        robust_count += (output == output1)
    end
    return robust_count
end

function wrap(v)
    f(ω) = v
    return f
end

function wrap_param(p)
    return [wrap.(p1) for p1 in p]
end

old_params = ((wrap(-0.2277), wrap(0.6434),wrap(2.3643)), 
        wrap(3.7146),
        (wrap(-0.0236), wrap(-3.3556), wrap(-1.8183)),
        wrap(-1.7810),
        (wrap(0.4865), wrap(1.0685)),
        wrap(-1.8079),
        (wrap(1.7044),wrap(-1.3880)),
        wrap(0.6830)
        )

# test_robustness(params)
# For some reason, if I pass n to rand with RejectionSample, it returns n-1 samples 
params = infer_robust(2,true)

for p in params
    println(test_robustness(wrap_param(p)))
end