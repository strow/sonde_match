% sonde_summary.m
%
% Analysis of Gruan Sonde data
%

addpath /asl/matlab2012/airs/utils
addpath /asl/matlib/h4tools
addpath /asl/matlib/aslutil/
addpath ~/Matlab/Math
addpath /asl/packages/time
addpath ~/Matlab/Stats

load_fairs

% Note: cstr must include the substring "NEdT[" followed by 16 numbers.
cstr =[ 'bits1-4=NEdT[0.08 0.12 0.15 0.20 0.25 0.30 0.35 0.4 0.5 0.6 0.7' ...
  ' 0.8 1.0 2.0 4.0 nan]; bit5=Aside[0=off,1=on]; bit6=Bside[0=off,1=on];' ...
  ' bits7-8=calflag&calchansummary [0=OK, 1=DCR, 2=moon, 3=other]' ];

site = 'LIN';

%sarta_fn = ['../Data/' site '_era_AIRS_sarta.rtp'];
sarta_fn = ['../Data/' site '_airs_adjust_calc_sarta.rtp'];
[h,ha,p,pa]=rtpread(sarta_fn);
sarta_fn_tuned = ['../Data/' site '_airs_adjust_calc_sarta_tuned.rtp'];

%sarta_fn_tuned = '../Data/LIN_perr_calc.rtp';

[ht,hat,pt,pat]=rtpread(sarta_fn_tuned);
kcarta_fn = ['../Data/' site '_convolved_kcarta_2012.mat'];
load(kcarta_fn,'rKc');
rcal_k = rKc; clear rKc;
kcartao_fn = ['../Data/' site '_convolved_kcarta.mat'];
load(kcartao_fn,'rKc');
rcal_ko = rKc(:,3410); clear rKc;

% Look for bad channels and initialize counts
[nedt,ab,ical] = calnum_to_data(p.calflag,cstr);
n = length(p.rlat);
count_all = ones(2378,n);
for i=1:2378
% Find bad channels
   k = find( p.robs1(i,:) == -9999 | ical(i,:) ~= 0 | nedt(i,:) > 1);
   p.robs1(i,k) = NaN;
   p.rcalc(i,k) = NaN;
   pt.robs1(i,k) = NaN;
   pt.rcalc(i,k) = NaN;
   rcal_k(i,k) = NaN;
   rcal_ko(i,k) = NaN;
   count_all(i,k) = 0;
end

btobs = real(rad2bt(f,p.robs1));
btcal = rad2bt(f,p.rcalc);
btobs_t = real(rad2bt(f,pt.robs1));
btcal_t = rad2bt(f,pt.rcalc);
btcal_k = rad2bt(f,rcal_k);
btcal_ko = rad2bt(f,rcal_ko);
bias = btobs-btcal;
bias_t = btobs_t-btcal_t;
bias_k = btobs-btcal_k;
bias_ko = btobs-btcal_ko;

% Get rid of bad time matches, d = distance in km
d = distance(p.rlat,p.rlon,p.plat,p.plon);
d = deg2km(d);

% Get time mismatches
ptime = tai2dtime(p.ptime);
rtime = tai2dtime(p.rtime);
dtime = minutes(duration(ptime-rtime));

iclear = 759;  % Channel to look for clear (900.x cm-1)

% Gives zero bias in window channel
knight = find(bias(iclear,:) > -1  & bias(iclear,:) < 2 ...
              & d < 20  & p.solzen > 90 );%& ptime > datetime(2014,4,11));
% knight = find(bias(iclear,:) > -1  & bias(iclear,:) < 2 ...
%               & d < 10  & p.solzen > 90 & dtime < 25);

% Daytime can't get clean zero bias, stemp varying too much
kday  = find(bias(iclear,:) > -2  & bias(iclear,:) < 2 ...
              & d < 20  & p.solzen < 90);

% Almost same bias as kday!
% kday_tight  = find(bias(iclear,:) > -1  & bias(iclear,:) < 1 ...
%               & d < 20  & p.solzen < 90);

% Same answer with inight or iday
scount = sum(count_all,2);
maxstd = 4;   % Should vary with site?
ig = goodchan_stats(scount,nanstd(bias(:,knight),0,2),maxstd);


% LIN_AIRS_var_minus_adjust_calc_sarta_tuned.rtp
% LIN_AIRS_var_plus_adjust_calc_sarta_tuned.rtp
% LIN_AIRS_minus_adjust_calc_sarta_tuned.rtp
% LIN_AIRS_plus_adjust_calc_sarta_tuned.rtp
% LIN_AIRS_minus_calc_sarta_tuned.rtp
% LIN_AIRS_plus_calc_sarta_tuned.rtp