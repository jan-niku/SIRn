% fit testing

xs=rand(1,75);
y=sqrt(xs)-0.1*(rand(1,75)-.025);
scatter(xs,y,'.')

c=polyfit(sqrt(xs), y, 1);

fit = @(x) c(1)*sqrt(x)+c(2);

xp=0:0.01:1;
yp=fit(xp);
hold on
plot(xp,yp)
hold off