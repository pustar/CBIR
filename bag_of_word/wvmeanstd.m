function tcd=wvmeanstd(image,nlvl,colorSpace)
%compute the texture and color descriptor based on the wavelet
%decomposition by extracting the standard deviation of every decomposition
%level and add a weight that decrease with increasing level of
%decomposition
%nlvl: number of levels of decomposition
%colorSpace: can be 'rgb' (default) in such case the graylevel image is considered or 'ycbcr'  (YCbCr)
%output: row vector of Ch*(3*nlvl=1)) values whereCh: #channels (1:rgb or 3:ycbcr)
%tcd=[sigma(An) sigma(Hn)  sigma(Vn) sigma(Dn) sigma(H(n-1)).....sigma(D1)]
%example: tcd=WWSD(imRef,3,'ycbcr')
if (nargin<3)||strcmp(colorSpace,'rgb')
    image=im2double(rgb2gray(image));
    nchannel=1;
elseif strcmp(colorSpace,'ycbcr')
    image=im2double(rgb2ycbcr(image));
    nchannel=3;
else
    error('Third argument must be only "rgb" or "ycbcr"');
end
WNAME='haar'; %type of wavelet function
tcd=[];
for i=1:nchannel
    [C, S] = wavefast(image(:,:,i), nlvl,WNAME);
    start=1;
    size=S(1,1)*S(1,2);
    tcd=[tcd mean(C(start:start+size-1)) std(C(start:start+size-1))];
    for j=2:nlvl+1
        if j==2
            start=start+size;%only approx component has been extracted
        else
            start=start+3*size;%H,V&D components have been extracted
        end
        size=S(j,1)*S(j,2);%size of component at the current level
        sigHstd=std(C(start:start+size-1));%extract standard deviation of H component of the current level
        sigHmean=mean(C(start:start+size-1));
        sigVstd=std(C(start+size:start+2*size-1));
        sigVmean=mean(C(start+size:start+2*size-1));
        sigDstd=std(C(start+2*size:start+3*size-1));
        sigDmean=mean(C(start+2*size:start+3*size-1));
        tcd=[tcd sigHmean sigHstd sigVmean sigVstd sigDmean sigDstd];%append 
    end
end
