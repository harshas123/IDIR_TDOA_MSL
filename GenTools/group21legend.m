function h_group = group21legend(h)
h_group=hggroup;
set(h,'Parent',h_group);
set(get(get(h_group,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on');