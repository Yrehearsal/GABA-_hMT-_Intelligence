for i=1:31
y=pure_data(:,32-i);
xx=linspace(0.0000,4.0000);
yy=spline(coordinate,y,xx);
plot(coordinate,y,'Color',all_colors(32-i,:),'lineWidth',2);
hold on
end

