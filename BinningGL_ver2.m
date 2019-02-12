function [fitness] = BinningGL_ver2(chromosome)
global idx cn img;
folderPath='with GT/';
idir = dir(strcat(folderPath,'i (*).jpg'));
nfiles = uint16(length(idir)*(1.0/10.0));    % Number of files found


accuracy = zeros(1,nfiles);
idx = chromosome;
cn = sum(chromosome(:));
idx(1) = 1;
for loop = 2:size(chromosome)
    idx(1,loop) = idx(1,loop-1) + idx(1,loop);
end

initialiseGT();

for img_loop=1:nfiles
    currentfilename = idir(img_loop).name;
    imagePath=strcat(folderPath,currentfilename);
    img = rgb2gray(imread(imagePath));
    
    textBoxes = boundingBoxes();
    
    accuracy(img_loop) = overlapAccuracy(textBoxes, currentfilename);
    fprintf('Accuracy ratio - %f\n',accuracy(img_loop));
end
disp(accuracy);
fitness = mean(accuracy);
end

function [textBBoxes] = boundingBoxes()
global idx cn img;
[width,height]=size(img);
x=zeros(2^8,1);
% x-> MATRIX OF ALL THE GRAY LEVELS FROM 0-255.
% x=[0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	70	71	72	73	74	75	76	77	78	79	80	81	82	83	84	85	86	87	88	89	90	91	92	93	94	95	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	164	165	166	167	168	169	170	171	172	173	174	175	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198	199	200	201	202	203	204	205	206	207	208	209	210	211	212	213	214	215	216	217	218	219	220	221	222	223	224	225	226	227	228	229	230	231	232	233	234	235	236	237	238	239	240	241	242	243	244	245	246	247	248	249	250	251	252	253	254	255];
% x=transpose(x);
for gli=1:2^8
    x(gli,1)=gli-1;
end
[idx,c]=kmeans(x,cn);% APPLY KMEANS ON ALL THE THE GRAY LEVELS
idx=transpose(idx);
c=round(transpose(c));
for i=1:cn % FOR EACH CLUSTER, A BIN OR A BINARY MASK WILL BE GENERATED
    bw=zeros(width,height);
    %PLACE THE CORRESPONDING CLUSTER NO. AGAINST THE GRAY LEVEL VALUE AT THE PIXEL POSITION OF THE GRAY IMAGE 
    for rw=1:width
        for cl=1:height
           if idx(find([x] <= img(rw,cl),1,'last'))==i
               bw(rw,cl)=1;
           end
        end
    end
    bwcc=bwconncomp(bw);
    bwStats = regionprops(bwcc, 'BoundingBox', 'Eccentricity','Centroid', ...
    'Area', 'Solidity', 'Extent', 'Euler', 'Image');
    filterIdx = [bwStats.Solidity] > .5;
    bwStats(filterIdx) = [];
    bw(filterIdx)=0;
    % figure, % % % imshow(bw);
%     title('Bin')
%     saveas(gca, fullfile('D:\MULTI-LINGUAL IMAGE DATABASE\Multi-Lingual Dataset\place names\binning', sprintf('image_%d_%d',kcount,i)), 'png');
%   -----------------------------CONNECTED COMPONENTS IN EACH BIN---------------
    
%

bboxes = vertcat(bwStats.BoundingBox);
    if i==1
        bb1=bboxes;
%         ccnt1=ccent;
        continue;
    end
    
    bb1=[bb1;bboxes];

end
[bbx,bby]=size(bb1);
% FILTERING OUT UNNECESSARY BOUNDING BOXES
bb1(bb1(:,4)<30,:)=[];
bb1(bb1(:,4)>height*0.2,:)=[];
bb1(bb1(:,3)<10,:)=[];
bb1(bb1(:,3)>width*0.7,:)=[];

% % BB combine
fi=zeros(width,height);
fi=insertShape(fi, 'FilledRectangle', bb1,'Color', {'white'}, 'Opacity', 1);

% BB combine 
se = strel('line',30,1);
fi=imdilate(fi,se);
figure; % % % imshow(fi);

fi=imerode(fi,se);
% figure, % % % imshow(fi);

ficc=bwconncomp(fi);
fiStats = regionprops(ficc, 'BoundingBox');
bbfi = vertcat(fiStats.BoundingBox);
bbfi(:,3)=[];
bbfi(:,5)=[];
% FinalOutput = insertShape(img,'Rectangle',bbfi,'Color','g','LineWidth',5);
% figure, % % % imshow(FinalOutput);

textBBoxes=[bbfi];
%disp(textBBoxes);
end

function [] = initialiseGT()
global list gtBoundingbox;
[list, temp] = xlsread('with GT/MISTI bboxes.xlsx','bboxes');
list = uint16(list);
gtBoundingbox = cell(1,size(temp,1)-1);
for i=1:size(list,1)
    gtBoundingbox{1,i} = temp{i+1,1};
end
end

function [accuracy] = overlapAccuracy(textBoxes, currentfilename)
global img list gtBoundingbox;
[row,col] = size(img);

mask = zeros(row,col);
textBoxes = uint16(textBoxes);
% mark the GT in mask
for i = 1:size(gtBoundingbox,2)
    if strcmp(gtBoundingbox{i},currentfilename)
        mask(list(i,1):list(i,1)+list(i,3)-1,list(i,2):list(i,2)+list(i,4)-1) = 1;
    end
end
% mark output in mask
for i =1:size(textBoxes,1)
    xmin = max(textBoxes(i,1),1);
    xmax = min(textBoxes(i,1)+textBoxes(i,3)-1,row);
    ymin = max(textBoxes(i,2),1);
    ymax = min(textBoxes(i,2)+textBoxes(i,4)-1,col);
    mask(xmin:xmax,ymin:ymax) = mask(xmin:xmax,ymin:ymax) + 2;
end
fprintf('textBox only - %d : intersection - %d : union - %d\n',sum(mask(:)==2),sum(mask(:)==3),sum(mask(:)~=0));
accuracy = sum(mask(:)==3)/(sum(mask(:)~=0));
end