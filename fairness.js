// The population model
var popModel = function(sex){
    var ret  = [sex]

    var sex_less_1 = function(sex){
        var capital_gain = gaussian(568.4105, Math.sqrt(24248365.5428))

        if (capital_gain < 7298.0000){
            var age = gaussian(38.4208, Math.sqrt(184.9151))
            var education_num = gaussian(10.0827, Math.sqrt(6.5096))
            var capital_loss = gaussian(86.5949, Math.sqrt(157731.9553))
            return [sex, age, capital_gain, capital_loss, education_num]
        } else{
            var age = gaussian(38.8125, Math.sqrt(193.4918))
            var education_num = gaussian(10.1041, Math.sqrt(6.1522))
            var capital_loss = gaussian(117.8083, Math.sqrt(252612.0300))
            return [sex, age, capital_gain, capital_loss, education_num]
        }
    }

    var sex_greaterEQ_1 = function(sex){
        var capital_gain = gaussian(1329.3700, Math.sqrt(69327473.1006))
        if (capital_gain < 5178.0000){
            var age = gaussian(38.6361, Math.sqrt(187.2435))
            var education_num = gaussian(10.0817, Math.sqrt(6.4841))
            var capital_loss = gaussian(87.0152, Math.sqrt(161032.4157))
            return [sex, age, capital_gain, capital_loss, education_num]
        } else{
            var age = gaussian(38.2668, Math.sqrt(187.2747))
            var education_num = gaussian(10.0974, Math.sqrt(7.1793))
            var capital_loss = gaussian(101.7672, Math.sqrt(189798.1926))
            return [sex, age, capital_gain, capital_loss, education_num]
        }        
    }

    var fix_age = function(p){
        var sex = p[0]
        var age = p[1] 
        var capital_gain = p[2] 
        var capital_loss = p[3] 
        var education_num = p[4]
        if (education_num > age){
            return [sex, education_num, capital_gain, capital_loss]
        }else{
            return [sex, age, capital_gain, capital_loss]
        }
    }

    if (sex < 1){
        return fix_age(sex_less_1(sex))
    }
    else
        return fix_age(sex_greaterEQ_1(sex))
}

// classifiers
var sample_params = function(){ 
    var W = [gaussian(0.0006, 1.0), gaussian(-5.7363, 1.0), gaussian(-0.0002, 1.0)]

    var b = gaussian(1.0003, 1.0)

    var d = gaussian(-0.0003, 1.0)
    // return [W, b, d]
    return [0.0006, -5.7363, -0.0002]
}

var classifier = function(W, b, d, sex, age, capital_gain, capital_loss){
    var N_age = (age - 17.0) / 62.0
    var N_capital_gain = (capital_gain - 0.0) / 22040.0
    var N_capital_loss = (capital_loss - 0.0) / 1258.0
    // t = W[1] * N_age + W[2] * N_capital_gain + W[3] * N_capital_loss + b
    var t = W[1] * N_age + W[2] * N_capital_gain + W[3] * N_capital_loss + b
    if (sex > 1.0){
        var t1 = t + d
        // t = t + δ
        return t1 < 0
    }
return t < 0
}


var oneSample = function(){
    var maleModel = popModel(1.5)
    var femaleModel = popModel(0.5)
    var params = sample_params()

    display(classifier(params[0], params[1], params[2], maleModel[0], maleModel[1], maleModel[2], maleModel[3]))

    display(classifier(params[0], params[1], params[2], femaleModel[0], femaleModel[1], femaleModel[2], femaleModel[3]))
}

var loop = function (f, n){
    if (n == 0)
        return
    else{
        f()
        loop(f, n-1)
    }
}

loop(oneSample, 100)