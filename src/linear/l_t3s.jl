function l_t3s(
    contexts::Array,
    true_theta::Array,
    delta::Real,
    rate::Function,
    dist::String,
    greedy::Bool = true,
    sigma::Real = 1,
    kappa::Real = 1,
    frac::Real = 0.5,
    stopping::Symbol = :Chernoff,
)
    # Initialization
    condition = true
    num_contexts = length(contexts)
    dim = length(contexts[1])
    num_pulls = zeros(1, num_contexts)
    rewards = zeros(1, num_contexts)
    t = 0

    # Initialize the prior
    lambda = sigma^2 / kappa^2
    design_inverse = Matrix{Float64}(1 / lambda * I, dim, dim)
    #square_root_inverse = Matrix{Float64}(kappa / sigma * I, dim, dim)
    z_t = vec(zeros(1, dim))
    rls = vec(zeros(1, dim))
    var = Matrix{Float64}(kappa^2 * I, dim, dim)

    # Play each arm once
    for c = 1:num_contexts
        t += 1
        new_reward = compute_observation(contexts[c], true_theta, sigma)
        rewards[c] += new_reward
        num_pulls[c] = 1

        design_inverse = update_design_inverse(design_inverse, contexts[c])
        #square_root_inverse = update_square_root(square_root_inverse, contexts[c])
        z_t += new_reward * contexts[c]
        rls = design_inverse * z_t
        var = sigma^2 * design_inverse
    end

    best = 1
    while (condition)
        empirical_means = [dot(contexts[c], rls) for c = 1:num_contexts]
        # Empirical best arm
        best = randmax(empirical_means)
        # Compute the stopping statistic
        index = collect(1:num_contexts)
        deleteat!(index, best)
        # Compute the minimum GLR
        score = minimum([compute_transportation(contexts[best], contexts[i], rls, var) for i in 1:num_contexts if i != best])
        if (score > rate(t, delta))
            # Stop
            condition = false
        elseif (t > 1e7)
            condition = false
            best = 0
            println(num_pulls)
            println(rewards)
            num_pulls = zeros(1, num_contexts)
        else
            ts = zeros(num_contexts)
            for a = 1:num_contexts
                if dist == "Gaussian"
                    z = rand(MvNormal(dim, 1))
                    # theta = sigma * square_root_inverse * z + rls
                    theta = sigma * design_inverse^0.5 * z + rls
                    ts[a] = sum(theta .* contexts[a])
                end
            end

            if greedy
                best = argmax(ts)
                challenger = best
                while (challenger == best)
                    ts = zeros(num_contexts)
                    for a = 1:num_contexts
                        if dist == "Gaussian"
                            z = rand(MvNormal(dim, 1))
                            theta = sigma * design_inverse^0.5 * z + rls
                            ts[a] = sum(theta .* contexts[a])
                        end
                    end
                    challenger = argmax(ts)
                end

                new_sample = randmin([compute_confidence(
                    contexts[best],
                    contexts[challenger],
                    update_design_inverse(design_inverse, contexts[i]),
                ) for i = 1:num_contexts])
            else
                new_sample = argmax(ts)
                if (rand() > frac)
                    challenger = new_sample
                    condition = true
                    while (new_sample == challenger)
                        ts = zeros(num_contexts)
                        for a = 1:num_contexts
                            if dist == "Gaussian"
                                z = rand(MvNormal(dim, 1))
                                # theta = sigma * square_root_inverse * z + rls
                                theta = sigma * design_inverse^0.5 * z + rls
                                ts[a] = sum(theta .* contexts[a])
                            end
                        end
                        challenger = argmax(ts)
                    end
                    new_sample = challenger
                end
            end

            # Play the selected arm
            t += 1
            new_reward = compute_observation(contexts[new_sample], true_theta, sigma)
            rewards[new_sample] += new_reward
            num_pulls[new_sample] += 1

            # Update the posterior
            design_inverse = update_design_inverse(design_inverse, contexts[new_sample])
            #square_root_inverse = update_square_root(
            #    square_root_inverse,
            #    contexts[new_sample],
            #)
            z_t += new_reward * contexts[new_sample]
            rls = design_inverse * z_t
            var = sigma^2 * design_inverse
        end
    end
    recommendation = best
    return recommendation, num_pulls
end
