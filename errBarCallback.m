function errBarCallback(src, evt, arg)

% src.Color = 'red';
delete(findall(gcf, 'type', 'annotation'))
%   for i=1:length(src.XData)
%     annotation(src.XData(i) + 0.5, src.YData(i), num2str(arg))
%   end
src.LineWidth = 1.0;
annotation('textbox',[.9 .5 .1 .2],'String',num2str(arg),'EdgeColor','none')

end