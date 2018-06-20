using Mu

suspension = bernoulli(0.6)
dry_field = bernoulli(0.7)
bonus = bernoulli(0.2)

function win_(rng)
  sus = Bool(suspension(rng[@id]))
  dry = Bool(dry_field(rng[@id]))
  bon = Bool(bonus(rng[@id]))

  # FIXME: Provide an interface for this kind of tabular probabilities
  if !sus & dry && bon
    bernoulli(rng[@id], 0.7)
  elseif !sus & dry && !bon
    bernoulli(rng[@id], 0.6)
  elseif !sus & !dry && bon
    bernoulli(rng[@id], 0.6)
  elseif !sus & !dry && !bon
    bernoulli(rng[@id], 0.5)
  elseif sus & dry && bon
    bernoulli(rng[@id], 0.6)
  elseif sus & dry && !bon
    bernoulli(rng[@id], 0.5)
  elseif sus & !dry && bon
    bernoulli(rng[@id], 0.5)
  elseif sus & !dry && !bon
    bernoulli(rng[@id], 0.4)
  end
end

win = iid(win_, Float64) # FIXME: Why inferred type is void?

win__ = Omega.rcd(win, bonus+dry_field+suspension) # FIXME, adding them to join
means = mean(win__)
