function  [Init_Index]  =  Block_matching(X, par,Neighbor_arr,Num_arr, SelfIndex_arr)
L         =   length(Num_arr);
Init_Index   =  zeros(par.patnum,L);

for  i  =  1 : L
    Patch = X(:,SelfIndex_arr(i));
    Neighbors = X(:,Neighbor_arr(1:Num_arr(i),i));
    Dist = sum((repmat(Patch,1,size(Neighbors,2))-Neighbors).^2);
    [val, index] = sort(Dist);
    indc = Neighbor_arr( index( 1:par.patnum ), i );%
    indc(indc==i) = indc(1); % added on 08/01/2017
    indc(1) = i; % to make sure the first one of indc equals to off
    Init_Index(:,i)=Neighbor_arr(index(1:par.patnum),i);
end
