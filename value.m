function [F1, F2] = value(network, z)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    F1 = sum(z' .* network.Q .* z + network.c1' .* z, "all");
    F2 = sum(network.c2' .* z, "all");
end

