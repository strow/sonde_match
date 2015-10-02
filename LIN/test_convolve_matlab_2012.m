% Convolve output from kcarta-matlab for LIN profiles. 

addpath /asl/matlab2012/kcarta
addpath /home/sergio/MATLABCODE 
addpath /asl/matlib/h4tools 

clist = 1:2378;
sfile = '/asl/matlib/srftest/srftables_m140f_withfake_mar08.hdf'; 
sfile = '/asl/matlab2012/srftest/srftables_m140f_withfake_mar08.hdf'; 

iMax = input('Enter number of profiles : ');

iChunk = 250;

jchunk = ceil(iMax/iChunk);

rKc = [];
for jj = 1 : jchunk
  iaInd = (1:iChunk) + (jj-1)*iChunk;
  if iaInd(end) > iMax
    iaInd = iaInd(1):iMax;
  end
  fprintf(1,'%4i : %4i %4i \n',jj,iaInd(1),iaInd(end))
  for ix = 1 : length(iaInd)
    ii = iaInd(ix);
    % [d,w] = readkcstd(['STD_LIN_2009/rad.dat' num2str(ii,'%04d')]);
    filename=['kcarta_matlab_2012/kc',num2str(ii,'%04d')]; 
    load(filename)
    dall(:,ix) = radkc;
  end
  [fKc,dKc] = convolve_airs(freqkc,dall,clist,sfile);
  rKc = [rKc dKc];
end % jj  

save kcarta_matlab_2012/test_convolved_kcarta.mat fKc rKc sfile
