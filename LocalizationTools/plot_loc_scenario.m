function [h_room,h_src,h_mics]=plot_loc_scenario(Mic_pos,src_pos,room_dim,font_size)
%% Function to plot the localization scenario - room, mics and source

% INPUTS TO THE FUNCTION: 
%%
%
% # _Mic_pos_ : Microphone locations within the enclosure. Each Mic in a row.
% # _src_pos_ : Source locations. Each source in a row.
% #  _room_dim_ : Dimensions of a recatangular enclosure (meter) in the
%                following format:
%                [x_lower_lim, y_lower_lim, z_lower_lim;
%                 x_upper_lim, y_upper_lim, z_upper_lim]
% # _font_size_ : Font Size to be used for text in the figure (axis labels)

% OUTPUTS OF THE FUNCTION:
%%
%
% # _h_room_ : Handle of the enclosure patch objects
% # _h_src_ : Handles of the source points 
% # _h_mics_ : Handles of the mics points

%%
% AUTHOR

% Code written by: Harshavardhan Sundar
% Ph. D. Scholar,
% Speech and Audio Group, 
% Department of Electrical Communication Engineering
% Indian Institute of Science,
% Bangalore, India - 560012% 
% email: harshas123@gmail.com
%%
dim1=size(Mic_pos,2);
if ~isempty(src_pos)
    dim2=size(src_pos,2);
    if dim1~=dim2
       error('Dimensions of Mics and source do not match...');
    else 
        dim=dim1;
    end
else
    dim=dim1;
end


% h=figure;
A=[eye(3);-eye(3)];
b=[room_dim(2,:)';-room_dim(1,:)'];

h_room=plotregion(-A,-b,[],[],'w',0.2);
group21legend(h_room);

hold on;
if dim>3
   error('Cannot plot data greater than 3D!!'); 
elseif dim==3 
    if ~isempty(src_pos)
        h_src=plot3(src_pos(:,1),src_pos(:,2),src_pos(:,3),'bd','MarkerSize',30,'MarkerFaceColor','b');
        group21legend(h_src);
    else
        h_src =[];
    end
    h_mics=plot3(Mic_pos(:,1),Mic_pos(:,2),Mic_pos(:,3),'ko','MarkerSize',20,'MarkerFaceColor','k');
    
    group21legend(h_mics);

%     for i=1:size(Mic_pos,1)
%        text(Mic_pos(i,1),Mic_pos(i,2),Mic_pos(i,3),['M_' num2str(i)],'Fontsize',20,'VerticalAlignment','bottom'); 
%     end
    zlabel('Z','FontSize',font_size);
    zlim([room_dim(1,3) room_dim(2,3)]);
elseif dim==2
    if ~isempty(src_pos)
        h_src=plot(src_pos(:,1),src_pos(:,2),'bd','MarkerSize',16,'MarkerFaceColor','b');
        group21legend(h_src);
    else
        h_src =[];
    end
    h_mics=plot(Mic_pos(:,1),Mic_pos(:,2),'ko','MarkerSize',10,'MarkerFaceColor','k');
    group21legend(h_mics);
%     for i=1:size(Mic_pos,1)
%        text(Mic_pos(i,1),Mic_pos(i,2),['M_' num2str(i)],'Fontsize',20,'VerticalAlignment','bottom'); 
%     end
end

xlabel('X','FontSize',font_size);
ylabel('Y','FontSize',font_size);


xlim([room_dim(1,1) room_dim(2,1)]);
ylim([room_dim(1,2) room_dim(2,2)]);


set(gca,'FontSize', font_size)
grid on;
