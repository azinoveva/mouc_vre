function [F1, F2] = value(network, z)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    F1 = z' * network.Q * z + network.c1' * z;
    F2 = network.c2' * z;
end

