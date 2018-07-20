# RCD should satisfy law of total variance
x = coin
y = thrower_bias + fair_coin
a = mean(var(rcd(x, y)))
b = var(mean(rcd(x, y)))
c = var(x)
@test c ≊ a + b