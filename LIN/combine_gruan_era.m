% Replaces upper level sonde data with ERA


% pressure at which the transition from Sonde to ERA is done:

press_trans_wv=150; 
press_trans_temp=15; 


addpath /asl/matlib/h4tools 


loc='LIN';


filein_gruan=[loc,'_AIRS_layers.rtp']; 
filein_era=[loc,'_era_AIRS_layers.rtp']; 
[h ha p pa]=rtpread(filein_gruan); 
[h_era ha_era p_era pa_era]=rtpread(filein_era); 



wv_adjust = (p.plevs(:,1) < press_trans_wv);    % levels in wv to adjust  
index_wv_adjust = find(wv_adjust == 1);   % indices for adjusted wv 
istart_wv =max(index_wv_adjust); 
ntop=length(p.plevs(:,1));

temp_adjust = (p.plevs(:,1) < press_trans_temp); 
index_temp_adjust = find(temp_adjust == 1); 
istart_temp = max(index_temp_adjust); 


[nlev nprof]=size(p.plevs); 

% Do Replacement of WV.  

for iprof=1:nprof 
   for ilev=1:istart_wv 
      p.gas_1(ilev,iprof)=p_era.gas_1(ilev,iprof); 
   end 
end 

% Do Replacement of Temp; 


for iprof=1:nprof 
   for ilev=1:istart_temp 
       p.ptemp(ilev,iprof)=p_era.ptemp(ilev,iprof); 
   end 
end 

%  Add Ozone to Sonde Profile 

for iprof=1:nprof
   for ilev=1:ntop
       p.gas_3(ilev,iprof)=p_era.gas_3(ilev,iprof); 
   end 
end 


fileout=[loc,'_AIRS_adjust_layers.rtp']; 
rtpwrite(fileout,h,{},p,{}); 
