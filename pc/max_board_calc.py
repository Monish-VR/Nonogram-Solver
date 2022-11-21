def nCr(n, r):
    return (fact(n) / (fact(r) * fact(n - r)))

# Returns factorial of n
def fact(n):
    if n == 0:
        return 1
    res = 1
    for i in range(2, n+1):
        res = res * i
    return res

# FPGA cap = 50 MB ~ 419 million bits
## each line has at most nCr options where n is the number of slots (groups + empty) and r is the number of groups
## where a group is (black group + 1 white except in the case of the final black which has no following white)
## see https://towardsdatascience.com/solving-nonograms-with-120-lines-of-code-a7c6e0f627e4

# the fifo stores a total of (n+m) * max_options/line of size max(n,m) bits/option
# each line is max_options/line * max(n,m) = max_options * max_(n,m) bits
# a total mem costo of (n + m) * max_options * max(n,m)

# for a square board, this simplifies to:
# 2m * m * max_options
# the max num options is given by
# the max of nCr such that 2m^2 * nCr does not exceed capacity
# n is #groups + #empty slots, r = #groups => n > r
# n + r = m + 1 => if there is 1 black, r = 1, and there are m spots to choose from, n = 10

def mem_cost(m, n, r):
    max_num_options = int(nCr(n,r))
    return 2 * m**2 * max_num_options

def max_options(m):
    n = m
    r = 1
    options = nCr(n,r)
    while n > r:
        n -= 1
        r += 1
        new_options = nCr(n,r)
        if new_options >= options:
            options = new_options
        else:
            break
    return (options, n+1, r-1)

m = 11

options,n,r = max_options(m)
print((n,r))
print(options)
print(mem_cost(m,n,r))