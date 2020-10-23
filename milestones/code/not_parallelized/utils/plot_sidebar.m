% Modified from script by Charlotte Maschke "modify_images.m" to fit with
% healthy tDCS pipeline
% Danielle Nadin 2020-04-30

function [] = plot_sidebar(imagepath,upper,lower,regions)

fig=openfig(imagepath);
caxis=([upper lower]);
newname=erase(imagepath,".fig");
saveas(fig,newname + ".png")
disp("figure saved")

F= length(find(strcmp(regions,'frontal')));
T= length(find(strcmp(regions,'temporal')));
C= length(find(strcmp(regions,'central')));
P= length(find(strcmp(regions,'parietal')));
O= length(find(strcmp(regions,'occipital')));

pos = get(gcf, 'Position'); %// gives x left, y bottom, width, height
width = pos(3);
height = pos(4);

i1=imread(newname + ".png");
image(i1)
hold on

Pixelsize=width/(F+T+C+P+O);

position =  [90+(Pixelsize*F/2) 610;...
    100+Pixelsize*F+((Pixelsize*T)/2) 610;...
    110+Pixelsize*F+Pixelsize*T+((Pixelsize*C)/2) 610;...
    120+Pixelsize*F+Pixelsize*T+Pixelsize*C+((Pixelsize*P)/2) 610;...
    130+Pixelsize*F+Pixelsize*T+Pixelsize*C+Pixelsize*P+((Pixelsize*O)/2) 610];

RGB = insertText(i1,position(1,:),'F','FontSize',30,...
    'TextColor',[255 128 0],'BoxOpacity',0,'Font','Arial Bold');

RGB = insertText(RGB,position(2,:),'T','FontSize',30,...
    'TextColor',[160 160 160],'BoxOpacity',0,'Font','Arial Bold');

RGB = insertText(RGB,position(3,:),'C','FontSize',30,...
    'TextColor',[0 122 204],'BoxOpacity',0,'Font','Arial Bold');

RGB = insertText(RGB,position(4,:),'P','FontSize',30,...
    'TextColor',[255 201 51],'BoxOpacity',0,'Font','Arial Bold');

RGB = insertText(RGB,position(5,:),'O','FontSize',30,...
    'TextColor',[76 153 0],'BoxOpacity',0,'Font','Arial Bold');

hold on 

imshow(RGB)

Pixelsize=(height*1.25)/(F+T+C+P+O);
%Vertical
rectangle('Position',[60,50,40,Pixelsize*F],...
         'LineWidth',1,'FaceColor',[1 128/255 0/255],'EdgeColor',[1 128/255 0/255])
     
rectangle('Position',[60,50+Pixelsize*F,40,Pixelsize*T],...
         'LineWidth',1,'FaceColor',[160/255 160/255 160/255],'EdgeColor',[160/255 160/255 160/255])
     
rectangle('Position',[60,50+Pixelsize*F+Pixelsize*T,40,Pixelsize*C],...
         'LineWidth',1,'FaceColor',[0 122/255 204/255],'EdgeColor',[0 122/255 204/255])
     
rectangle('Position',[60,50+Pixelsize*F+Pixelsize*T+Pixelsize*C,40,Pixelsize*P],...
         'LineWidth',1,'FaceColor',[1 201/255 51/255],'EdgeColor',[1 201/255 51/255])
 
     
rectangle('Position',[60,50+Pixelsize*F+Pixelsize*T+Pixelsize*C+Pixelsize*P,40,Pixelsize*O],...
         'LineWidth',1,'FaceColor',[76/255 153/255 0],'EdgeColor',[76/255 153/255 0])
     
    
hold on


Pixelsize=(width*1.075)/(F+T+C+P+O);

     % HORIZONTAL
rectangle('Position',[104,577,Pixelsize*F,35],...
         'LineWidth',1,'FaceColor',[1 128/255 0/255],'EdgeColor',[1 128/255 0/255])
     
rectangle('Position',[104+Pixelsize*F,577,Pixelsize*T,35],...
         'LineWidth',1,'FaceColor',[160/255 160/255 160/255],'EdgeColor',[160/255 160/255 160/255])
     
rectangle('Position',[104+Pixelsize*F+Pixelsize*T,577,Pixelsize*C,35],...
         'LineWidth',1,'FaceColor',[0 122/255 204/255],'EdgeColor',[0 122/255 204/255])
     
rectangle('Position',[104+Pixelsize*F+Pixelsize*T+Pixelsize*C,577,Pixelsize*P,35],...
         'LineWidth',1,'FaceColor',[1 201/255 51/255],'EdgeColor',[1 201/255 51/255])
     
rectangle('Position',[104+Pixelsize*F+Pixelsize*T+Pixelsize*C+Pixelsize*P,577,Pixelsize*O,35],...
         'LineWidth',1,'FaceColor',[76/255 153/255 0],'EdgeColor',[76/255 153/255 0])

saveas(fig,newname + ".png")
close(fig)
end



