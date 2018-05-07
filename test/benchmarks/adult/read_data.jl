using CSV
using Flux
using Flux: onehotbatch

train_path = "./adult.data"
test_path = "./adult.test"

columns = [
    "Age", "WorkClass", "fnlwgt", "Education", "EducationNum",
    "MaritalStatus", "Occupation", "Relationship", "Race", "Gender",
    "CapitalGain", "CapitalLoss", "HoursPerWeek", "NativeCountry", "Income"
   ]

function remove_white_space(ele)
    if isa(ele, SubString)
        ele = String(ele)
    end

    if isa(ele, String)
        return strip(ele)
    end
    return ele
end

function remove_missing(data)
    h,w = size(data)

    row_indices = []

    for i = 1:h
        r = data[i,:]
        if !("" in r)
            push!(row_indices, i)
        end
    end

    ret = data[row_indices,:]

    return ret
end

function change_Y(data)
    h,w = size(data)
    for i = 1:h
        if strip(String(data[i,w])) == "<=50K" || strip(String(data[i,w])) == "<=50K."
            data[i,w] = false
        else
            data[i,w] = true
        end
    end
    return data
end

function one_hot(data, cat_map = nothing)
    h,w = size(data)
    if cat_map == nothing
        cat_map = Dict()
        for i = 1:w
            col = data[:,i]
            if isa(col[1], String)
                cats = unique(col)
                println(cats)
                cat_map[i] = cats
            end
        end
    end

    n_w = w

    for v in values(cat_map)
        n_w -= 1
        n_w += length(v)
    end

    ret = Matrix(h, n_w)

    nm_idx = 1
    for i = 1:w
        if !(i in keys(cat_map))
            ret[:,nm_idx] = data[:,i]
            nm_idx +=1
        else
            cats = cat_map[i]
            n_cats = length(cats)
            ret[:,nm_idx:(nm_idx+n_cats-1)] = transpose(onehotbatch(data[:,i], cats))
            nm_idx += n_cats
        end
    end
    return (ret, cat_map)
end

function load_and_clean(path, cat_map=nothing)
    data = readcsv(path)
    data = remove_missing(data)
    data = remove_white_space.(data)
    data = change_Y(data)
    (data, cat_map) = one_hot(data, cat_map)
    return data[:, 1:end-1], data[:,end], cat_map
end

function get_train_and_test()
    train_data_X, train_data_Y, cat_map = load_and_clean(train_path)

    train_data_X = float.(train_data_X)

    train_data_Y = float.(train_data_Y)

    train_mean = mean(train_data_X, 1)
    train_std = std(train_data_X,1)

    train_data_X = (train_data_X .- train_mean) ./ train_std

    train_data_X = transpose(train_data_X)
    train_data_Y = transpose(hcat(1 .- train_data_Y, train_data_Y))

    test_data_X, test_data_Y, =load_and_clean(test_path, cat_map)

    test_data_X = (test_data_X .- train_mean) ./ train_std

    test_data_X = transpose(test_data_X)
    test_data_Y = transpose(hcat(1 .- test_data_Y, test_data_Y))

    return train_data_X, train_data_Y, test_data_X, test_data_Y
end
