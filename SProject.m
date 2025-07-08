clc;
clear;

videoReader =vision.VideoFileReader("C:\Users\alano\Videos\people.mov");%original video
videoPlayer=vision.VideoPlayer('Position',[300 100 1000 500]);

detector = peopleDetectorACF();

writerObj= VideoWriter("D:\Downloades\Matlab\Files\VideoFile\ProcessedVideo.mov");%the new Processed video
writerObj.FrameRate = 8;
open(writerObj);

while ~isDone(videoReader)
    frame = step(videoReader);
    I=double(frame);
    [bboxes,scores] = detect(detector,I);
    
    condition = zeros(size(bboxes,1),1);
    if ~isempty(bboxes)
       for i=1:(size(bboxes,1)-1)
           for j=(i+1):(size(bboxes,1)-1)
               dis1_vertical = abs(bboxes(i,1)+bboxes(i,3)-bboxes(j,1));
               dis2_vertical = abs(bboxes(j,1)+bboxes(j,3)-bboxes(i,1));
               dis1_horizantal = abs(bboxes(i,2)-bboxes(j,2));
               dis2_horizantal = abs(bboxes(i,2)+bboxes(i,4)-bboxes(i,2)-bboxes(i,4));
               if ((dis1_vertical<75 || dis2_vertical<75)&&(dis1_horizantal<50 || dis2_horizantal<50))
                   condition(i)=condition(i)+1;
                   condition(j)=condition(j)+1;
               else
                   condition(i)=condition(i)+0;
               end
           end
       end
    end
    
    I=insertObjectAnnotation(I,'rectangle',bboxes((condition>0),:),'Danger','color','r');
    I=insertObjectAnnotation(I,'rectangle',bboxes((condition==0),:),'Safe','color','g');
    
    step(videoPlayer,I);
    frame = im2frame(I);
    writeVideo(writerObj,frame);
end
release(videoReader);
release(videoPlayer);

close(writerObj);