addpath( '../third_party/gmmreg-read-only/' );
addpath( '../file_management/' );
addpath( genpath( '../third_party/CoherentPointDrift' ) );
addpath( '../plant_registration' );
addpath( '../PointCloudGenerator/' );
rms_e_all = [];
R =  [ 0.9101   -0.4080    0.0724 ;
       0.4118    0.8710   -0.2681 ;
       0.0463    0.2738    0.9607 ];
t = [ 63.3043,  234.5963, -46.8392 ];
for q=4:11

filename_0 = sprintf( '~/Data/PlantDataPly/plants_converted82-%03d-clean.ply', 0 );
[Elements_0,varargout_0] = plyread(filename_0);
X = [Elements_0.vertex.x';Elements_0.vertex.y';Elements_0.vertex.z']';
    
filename_1 = sprintf( '~/Data/PlantDataPly/plants_converted82-%03d-clean.ply', q );
[Elements_1,varargout_1] = plyread(filename_1);
Y = [Elements_1.vertex.x';Elements_1.vertex.y';Elements_1.vertex.z']';

for j=1:q
        Y_dash = R*Y';
        Y = Y_dash';
end
%Y = Y + repmat(t,size(Y,1),1)';

X = X(1:40:end,:);
Y = Y(1:40:end,:);

iters_rigid = 50;
iters_nonrigid = 0;
lambda = 1;
beta = .1;
min_size = 50;
Yr_subdiv = ones(size(Y));

[Yr_subdiv(:,1),Yr_subdiv(:,2),Yr_subdiv(:,3)] = register_surface_subdivision_upper_bound( ...
                                           X,Y,iters_rigid,iters_nonrigid,...
                                           lambda,beta, min_size );
                                       
[neighbour_id,neighbour_dist] = kNearestNeighbors(X, Yr_subdiv, 1 );
% get nearest neighbour for each point in the original cloud in the
% matched cloud


neighbour_id_unique = unique(neighbour_id);

X_reg = ones(size(X(neighbour_id_unique,:)));
[X_reg(:,1),X_reg(:,2),X_reg(:,3)] = register_surface_subdivision_upper_bound( ...
                                          Y,X(neighbour_id_unique,:),iters_rigid,iters_nonrigid,lambda, beta );
                                       
[neighbour_id_reg,neighbour_dist_reg] = ...
                    kNearestNeighbors(X_reg, X, 1 );
sprintf('RMS-E: ' )
rms_e = sqrt( sum(neighbour_dist_reg(:)) / length(neighbour_dist_reg(:)) )
rms_e_all = [rms_e_all rms_e];
end