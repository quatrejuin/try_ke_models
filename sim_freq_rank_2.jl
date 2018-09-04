using DataStructures
# Predict the arg1 and arg2 using only the frequency feature in train data
# 1. Get the frequency distribution from train data
freq_dist_set_l = Dict{Int64,Int64}()
freq_dist_set_r = Dict{Int64,Int64}()

fd_l =  Dict{Int64,Dict{Int64,Int64}}()
fd_l_o =  Dict{Int64,OrderedDict{Int64,Int64}}()
fd_l_gp_keys =  Dict{Int64,Array{Int64}}()

fd_r =  Dict{Int64,Dict{Int64,Int64}}()
fd_r_o =  Dict{Int64,OrderedDict{Int64,Int64}}()
fd_r_gp_keys =  Dict{Int64,Array{Int64}}()

train_file = "/u/wujieche/Projects/OpenKE/data/RV15M/train2id.txt"
test_file = "/u/wujieche/Projects/OpenKE/data/RV15M/test2id.txt"


open(train_file) do f
    n = parse(Int,readline(f))
    for i in 1:n
        i%10^6==0?println(i):0
        line = readline(f)
        h,t,r = [parse(Int64,str) for str in split(line,"\t")]
        # Statistics left
        if !haskey(freq_dist_set_l,h)
            freq_dist_set_l[h] = 0
        end
        freq_dist_set_l[h] += 1

        

        # Precisely corresponde to relation Left
        if !haskey(fd_l,r)
            fd_l[r]=Dict()
        end
        if !haskey(fd_l[r],h)
            fd_l[r][h]=0
        end
        fd_l[r][h]+=1


        
        # Statistics right
        if !haskey(freq_dist_set_r,t)
            freq_dist_set_r[t] = 0
        end
        freq_dist_set_r[t] += 1
        
        
        # Precisely corresponde to relation Right
        if !haskey(fd_r,r)
            fd_r[r]=Dict()
        end
        if !haskey(fd_r[r],t)
            fd_r[r][t]=0
        end
        fd_r[r][t]+=1
    end
end

for r in keys(fd_l)
    fd_l_o[r]=OrderedDict(sort(collect(fd_l[r]), by=x->x[2], rev=true)) 
    fd_l_gp_keys[r]=collect(keys(fd_l_o[r]))
end
for r in keys(fd_r)
    fd_r_o[r]=OrderedDict(sort(collect(fd_r[r]), by=x->x[2], rev=true))
    fd_r_gp_keys[r]=collect(keys(fd_r_o[r]))
end


fd_set_l = OrderedDict(sort(collect(freq_dist_set_l), by=x->x[2], rev=true))
fd_set_r = OrderedDict(sort(collect(freq_dist_set_r), by=x->x[2], rev=true))
max_ent_l = length(fd_set_l)
max_ent_r = length(fd_set_r)
fd_keys_l = collect(keys(fd_set_l))
fd_keys_r = collect(keys(fd_set_r))


function get_index(od_k,v)
    n = findfirst(od_k,v)
    return n
end



# 2. Apply the prediction
tic()
cand_l = Dict{Int64,Array{Int64,1}}()
cand_r = Dict{Int64,Array{Int64,1}}()
open(test_file) do f
    n = parse(Int,readline(f))
    global result_list = Array{Int64,2}(n,5)
    for i in 1:n
        global fd_set_l
        println(i)
        line = readline(f)
        h,t,r = [parse(Int64,str) for str in split(line,"\t")]
         
        # Prediction Arg1
               
        mr_l = 0
        
        # If the relation is in the relation grouped table
        if haskey(fd_l_o,r)
            # Look for h in the relation grouped table
            mr_l = get_index(fd_l_gp_keys[r],h)
            
            # If the head is NOT in the relation grouped table
            if mr_l == 0
                if !haskey(cand_l,r)
                    cand_l[r] = setdiff(fd_keys_l, fd_l_gp_keys[r])
                end
            end
        end
        
        # If the head is NOT in the relation grouped table
        if mr_l==0
            if !haskey(cand_l,r)
                cand_l[r] = fd_keys_l
            end
            # Look for h in the frequence table
            mr_l = get_index(cand_l[r],h)
        end
        
        # If h NOT in the frequence table
        if mr_l==0
            mr_l = max_ent_l +1
        end
        
        
        
        # Prediction Arg2
        
        mr_r = 0
        if haskey(fd_r_o,r)
            mr_r = get_index(fd_r_gp_keys[r],t)
            if mr_r == 0
                if !haskey(cand_r,r)
                    cand_r[r] = setdiff(fd_keys_r, fd_r_gp_keys[r])
                end
            end
        end
        if mr_r==0
            if !haskey(cand_r,r)
                cand_r[r] = fd_keys_r
            end
            mr_r = get_index(cand_r[r],t)
        end
        if mr_r==0
            mr_r = max_ent_r +1
        end
        
        
        # Add arg1 and arg2 pred rank to list
        result_list[i,:] = [h t r mr_l mr_r]
    end
end
toc()


using DataFrames
df = DataFrame(result_list)
names!(df, [:arg1,:arg2,:rel,:mr_l,:mr_r])


# println("Total arg1 = $(length(fd_set_l))")
# println("Total arg2 = $(length(fd_set_r))")
println("MR arg1 = $(mean(df[:mr_l]))")
println("MR arg2 = $(mean(df[:mr_r]))")


import CSV
CSV.write(open("./df_sim_freq_gp_rel.csv","w"),df)