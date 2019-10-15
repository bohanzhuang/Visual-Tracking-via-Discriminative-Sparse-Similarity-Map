function [drawopt,p] = drawtrackresult(drawopt, fno, frame, sz, param_mat)
%drawopt = drawtrackresult(drawopt, num, frame, tmpl, param); 
 
%%         param:
%%        -param.est:           The estimation of the affine state of the tracked target 
%%        -param.wimg:          The collected sample for update

if (isempty(drawopt))       %% drawing properties 
  figure('position',[30 50 size(frame,2) size(frame,1)]); clf;                               
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');

  drawopt.curaxis = [];
  drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end

%%draw the whole figure
curaxis = drawopt.curaxis;
axes(curaxis.frm);      
imagesc(frame, [0,1]); 
hold on;     

%% draw the bounding box
p = drawbox(sz, param_mat, 'Color','r', 'LineWidth',2.5);

text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
text(30, 15, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',24);

axis equal tight off;
hold off;
drawnow;        %%  update

