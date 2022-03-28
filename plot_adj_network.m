function a = plot_adj_network(A)
    a=size(A);
    g=graph([zeros(a(1),a(1)),A;A',zeros(a(2),a(2))]);
    plot(g)
end

