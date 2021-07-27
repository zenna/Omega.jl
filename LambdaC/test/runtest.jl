using LambdaC
using Test
using SoftPredicates
function runtests()
  @test λc"(+ (* 1 2) (+ (+ 4 0) 1))" |> init_interpret == 7
  @test λc"(let x 3 (+ x (* x x)))" |> init_interpret == 12
  @test λc"(! false)" |> init_interpret == true
  @test λc"(& true false)" |> init_interpret == false
  @test λc"((λ x (+ x 1)) 12)" |> init_interpret == 13
  @test λc"(((λ x 
            (λ y (+ x y))) 5) 2)" |> init_interpret == 7
  @test λc"(let unif (λ j (λ w (w j)))
           (let x (λ ωq ((unif 1) ωq))
           (let ω (λ i (if (== i 1) then 0.2 else 0.5))
             (x ω))))" |> init_interpret == 0.2


  @test λc"(let x (λ ω (unif 1 ω))
           (let y (λ ω (unif 2 ω))
           (let z (λ ω (>ₛ (x ω) (y ω)))
               ((cond x z)
               (λ i (case i (=> 1 0.123)
                            (=> 2 0.313))))" |> soft_interpret == (0.123, 0.123 >ₛ 0.313)


  @test λc"((λ x (+ x 1)) 12)" |> init_interpret == 13
  # -- make cases
  # -- make apply work
  # -- make "do" work
end

function runtests2()
  @test λc"(+ (* 1 2) (+ (+ 4 0) 1))" |> init_sinterpret == 7
  @test λc"(let x 3 (+ x (* x x)))" |> init_interpret == 12
  @test λc"(! false)" |> init_interpret == true
  @test λc"(& true false)" |> init_interpret == false
  @test λc"((λ x (+ x 1)) 12)" |> init_interpret == 13
  @test λc"(((λ x 
            (λ y (+ x y))) 5) 2)" |> init_interpret == 7
  @test λc"(let unif (λ j (λ w (w j)))
           (let x (λ ωq ((unif 1) ωq))
           (let ω (λ i (if (== i 1) then 0.2 else 0.5))
             (x ω))))" |> init_interpret == 0.2


  @test λc"(let x (λ ω (unif 1 ω))
           (let y (λ ω (unif 2 ω))
           (let z (λ ω (>ₛ (x ω) (y ω)))
               ((cond x z)
               (λ i (case i (=> 1 0.123)
                            (=> 2 0.313))))" |> soft_interpret == (0.123, 0.123 >ₛ 0.313)


  @test λc"((λ x (+ x 1)) 12)" |> init_interpret == 13
  # -- make cases
  # -- make apply work
  # -- make "do" work
end

function f()
  λc"(let unif (λ j (λ w (w j)))
          (let x (λ ωq ((unif 1) ωq))
          (let ω (λ i (if (== i 1) then 0.2 else 0.5))
            (x ω))))" |> init_interpret
end

f()