clear all;close all;clc;

config{1}=ReadYaml('/home/maxwell/projects/itia_ws/src/itia_fourbythree_driver/fourbythree_test/cfg/torque_multisine_joint1.yaml',1);

pathname='/home/maxwell/test/fourbythree/torque_multisine/joint1_6dof_2/';


first_time(1:2)=true;

%test_prefix={'multisine_20170323_P1_test','multisine_20170323_test'};
test_prefix={'multisine'};
marker={'o','d'};

cDq     = {[],[]};
cDtheta = {[],[]};
cDdelta  = {[],[]};

cq     = {[],[]};
ctheta = {[],[]};
cdelta  = {[],[]};

ctau    = {[],[]};
cfreq   = {[],[]};

for iPrefix=1:length(test_prefix)
  for iTest=1:10
    for iJoint=1:2
      complete_testname=sprintf('%s_jnt%d__test%d_jnt%d',test_prefix{iPrefix},iJoint,iTest,iJoint);
      testname=sprintf('test%d_jnt%d',iTest,iJoint);
      if exist([pathname complete_testname '_JointState__elastic_joint_states.bin'],'file')
        break;
      end
    end
    elastic_js=bin_convert([pathname,complete_testname,'_JointState__elastic_joint_states.bin'],4*3+1);
    ffw_js=bin_convert([pathname,complete_testname,'_JointState__joint_feedforward.bin'],2*3+1);
    sp_js=bin_convert([pathname,complete_testname,'_JointState__sp_joint_states.bin'],2*3+1);
    data=bin_resampling({elastic_js,ffw_js,sp_js},1e-3);
    
    clear nat_freq test_duration
    for iConfig=1:length(config)
      try
        nat_freq=[config{iConfig}.(testname).natural_frequency{:}];
        test_duration=config{iConfig}.(testname).test_duration;
        break;
      end
    end
    t=data{1}(:,1)-data{1}(1,1);
    idxs=find((t>10).*(t<(test_duration-5)));
    theta=data{1}(idxs,1+[1 3]);
    Dtheta=data{1}(idxs,5+[1 3]);
    delta=data{1}(idxs,1+[2 4]);
    Ddelta=data{1}(idxs,5+[2 4]);
    q=theta+delta;
    Dq=Dtheta+Ddelta;
    
    
    tau=data{1}(idxs,9+[1 3]);
    ffw_torque=data{2}(idxs,1+4+[1:2]);
    t=t(idxs)-t(idxs(1));
    
    
    %%
    iJoint= find(sum(abs(ffw_torque)),1);
    
    
    
    freq=sort(nat_freq)/2/pi;
    c_ffw=fourier_coeff(t,freq,ffw_torque(:,iJoint));
    c_tau=fourier_coeff(t,freq,tau(:,iJoint));
    
    c_Dtheta=fourier_coeff(t,freq,Dtheta(:,iJoint));
    c_theta=fourier_coeff(t,freq,theta(:,iJoint));

    c_Dq=fourier_coeff(t,freq,Dq(:,iJoint));
    c_q=fourier_coeff(t,freq,q(:,iJoint));
    
    c_delta=fourier_coeff(t,freq,delta(:,iJoint));
    c_Ddelta=fourier_coeff(t,freq,Ddelta(:,iJoint));
    
    ffw=fourier_series(t,freq,c_ffw);
    tau_fourier=fourier_series(t,freq,c_tau);
    Dtheta_fourier=fourier_series(t,freq,c_Dtheta);
    
    cDq{iJoint}=[cDq{iJoint};c_Dq];
    cDtheta{iJoint}=[cDtheta{iJoint};c_Dtheta];
    cDdelta{iJoint}=[cDdelta{iJoint};c_Ddelta];
    
    cq{iJoint}=[cq{iJoint};c_q];
    ctheta{iJoint}=[ctheta{iJoint};c_theta];
    cdelta{iJoint}=[cdelta{iJoint};c_delta];
    
    ctau{iJoint}=[ctau{iJoint};c_tau];
    cfreq{iJoint}=[cfreq{iJoint};freq'];
    
    figure(iJoint)
    subplot(211)
    semilogx(freq, 20*log10(abs(c_Dtheta./c_tau)),marker{iPrefix},'Color','g')
    hold all
    semilogx(freq, 20*log10(abs(c_delta./c_tau)),marker{iPrefix},'Color','k')
    semilogx(freq, 20*log10(abs(c_Dq./c_tau)),marker{iPrefix},'Color','r')
    semilogx(freq, 20*log10(abs(c_Dq./c_delta)),marker{iPrefix},'Color','b')
    subplot(212)
    semilogx(freq, 180/pi*(angle(c_Dtheta./c_tau)),marker{iPrefix},'Color','g')
    hold all
    semilogx(freq, 180/pi*(angle(c_delta./c_tau)),marker{iPrefix},'Color','k')
    semilogx(freq, 180/pi*(angle(c_Dq./c_tau)),marker{iPrefix},'Color','r')
    semilogx(freq, 180/pi*(angle(c_Dq./c_delta)),marker{iPrefix},'Color','b')
    
    if first_time(iJoint)
      freq=logspace(-1,2)';
      subplot(211)
      semilogx(freq, 20*log10(abs(1e4./(2*pi*freq))),'-m')
      semilogx(freq, 20*log10(abs(1e3./(2*pi*freq))),'-m')
      semilogx(freq, 20*log10(abs(1e2./(2*pi*freq))),'-m')
      
      legend('Dtheta/tau','delta/tau','Dq/tau','Dq/delta');
      first_time(iJoint)=false;
    end
    grid on
    drawnow
    %return
  end
end
figure(1)
h(1)=gca;
figure(2)
h(2)=gca;

linkaxes(h,'x')


for idx=1:length(cfreq)
  [cfreq{idx},idxs]=sort(cfreq{idx});
  cq{idx}    =cq{idx}(idxs);
  ctheta{idx}=ctheta{idx}(idxs);
  cdelta{idx}=cdelta{idx}(idxs);

  cDq{idx}=cDq{idx}(idxs);
  cDtheta{idx}=cDtheta{idx}(idxs);
  cDdelta{idx}=cDdelta{idx}(idxs);
  ctau{idx}=ctau{idx}(idxs);
end

%save ident_joint1_2 cDq cDtheta cDdelta cq ctheta cdelta ctau cfreq
return
%%
semilogx(cfreq{iJoint}, 20*log10(abs(cDq{iJoint}./ctau{iJoint})),marker{iPrefix},'Color','g')
    