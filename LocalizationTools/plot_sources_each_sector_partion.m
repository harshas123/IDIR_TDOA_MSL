function plot_sources_each_sector_partion(src_info, h)
% Note the input is a struct which contains multiple partitions and each
% partition contains a cell array for each sector

partitions = fields(src_info);
num_partitions = length(partitions);
colors = distinguishable_colors(num_partitions);
h_src = cell(num_partitions,1);
figure(h);
hold on;
for part_id = 1:num_partitions
   h_src{part_id} = [];
   src_pos_cell = src_info.(partitions{part_id}).('src_pos'); 
    num_sectors = length(src_pos_cell);
    for sec_ind = 1:num_sectors
        src_pos = src_pos_cell{sec_ind};
        dim = size(src_pos,2);
        if dim==3
            tmp_src =plot3(src_pos(:,1),src_pos(:,2),src_pos(:,3),'bd','MarkerSize',15, 'MarkerFaceColor', colors(part_id,:));
        else
            tmp_src=plot(src_pos(:,1),src_pos(:,2),'bd','MarkerSize',15, 'MarkerFaceColor', colors(part_id,:));
        end
        h_src{part_id} = [h_src{part_id}; tmp_src];
        pause
    end
    group21legend(h_src{part_id})
end

