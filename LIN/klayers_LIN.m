addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /asl/matlib_new/rtptools
addpath /asl/packages/time
addpath /home/strow/Git/rtp_prod2/grib
addpath /home/strow/Git/rtp_prod2/util
addpath /home/strow/Git/rtp_prod2/emis
addpath /home/strow/Matlab/Math


loc='LIN'; 
klayers = '/asl/packages/klayersV205/BinV201/klayers_airs_wetwater';

% Call Klayers for ERA
% 
fip = [loc,'_era_AIRS.rtp'];
fop = [loc,'_era_AIRS_layers.rtp'];
klayerser = ['!' klayers ' fin=' fip ' fout=' fop '> junk.dat'];
eval(klayerser)



% Call Klayers for gruan data 
fip_gruan = [loc,'_AIRS.rtp'];
fop_gruan = [loc,'_AIRS_layers.rtp'];

klayerser_gruan =['!' klayers ' fin=' fip_gruan ' fout=' fop_gruan '> junk.dat'];
eval(klayerser_gruan)

