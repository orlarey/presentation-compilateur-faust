repeat(1,f) = f;
repeat(n,f) = f <: _, repeat(n-1,f) :> _;

N = 6/2;

FX = mem;

process = repeat(N,FX);
