function [mri1c, mri2b, T, hfig] = align_mri2mri(mrifile1, mrifile2, hs, align2hs)

%%
% function to find the alignment between 2 anatomical images, with an
% optional extra step to align the first image to the headshape

if nargin < 4 || isempty(align2hs)
  align2hs = true;
end

mri1 = ft_read_mri(mrifile1);
mri2 = ft_read_mri(mrifile2);

if align2hs
  % It could be that mri1 and hs are not in register, this needs to be fixed
  % first. Here, we first do an interactive alignment to RAS/ACPC, followed
  % by an icp-based alignment
  cfg = [];
  cfg.intersectmesh = {hs};
  ft_sourceplot(cfg, mri1);

  cfg          = [];
  cfg.method   = 'interactive';
  cfg.coordsys = 'acpc';
  mri1b        = ft_volumerealign(cfg,mri1);

  cfg = [];
  cfg.intersectmesh = {hs};
  ft_sourceplot(cfg, mri1b);

  cfg = [];
  cfg.intersectmesh = {hs};
  ft_sourceplot(cfg, mri1b); % this should look better than before

  % reduce the number of points in the headshape, because otherwise it takes very long to compute.
  [hs2.tri, hs2.pos] = reducepatch(hs.tri, hs.pos, 0.2);
  hs2.unit = hs.unit;

  cfg        = [];
  cfg.method = 'headshape';
  cfg.headshape.headshape = hs2;
  mri1c      = ft_volumerealign(cfg,mri1b); % mri1c should now nicely align with the extracted headsurface that was used for the cast

  [p,f,e] = fileparts(mrifile1);
  cfg               = [];
  cfg.parameter     = 'anatomy';
  cfg.filename      = fullfile(p, sprintf('%s_aligned', f));
  cfg.filetype      = 'nifti_gz';
  ft_volumewrite(cfg, mri1c);

  % we can visualize the effect of the icp alignment
  icpinfo   = mri1c.cfg.icpinfo;
  delta_in  = zeros(size(hs2.pos,1),1); delta_in(icpinfo.p_idx)  = icpinfo.distancein;
  delta_out = zeros(size(hs2.pos,1),1); delta_out(icpinfo.p_idx) = icpinfo.distanceout;
  hfig(1) = figure;
  ax1 = subplot(1,2,1);ft_plot_headshape(hs2, 'vertexcolor', delta_in);  clim([-1 1].*max(abs(delta_in)));
  ax2 = subplot(1,2,2);ft_plot_headshape(hs2, 'vertexcolor', delta_out); clim([-1 1].*max(abs(delta_in)));
  ll  = linkprop([ax1, ax2], {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
  setappdata(gcf, 'StoreTheLink', ll);
else
  mri1c = mri;
  mri1c.coordsys = 'ras';
  hs2 = hs;
end

cfg = [];
cfg.intersectmesh = {hs2};
ft_sourceplot(cfg, mri1c); % this should look good now.
hfig(2) = gcf;

% now we proceed with aligning the mri images
cfg        = [];
cfg.method = 'spm';
mri2b      = ft_volumerealign(cfg, mri2, mri1c);
T          = mri2b.transform/mri2.transform;

[p,f,e] = fileparts(mrifile2);
cfg               = [];
cfg.parameter     = 'anatomy';
cfg.filename      = fullfile(p, sprintf('%s_aligned', f));
cfg.filetype      = 'nifti_gz';
ft_volumewrite(cfg, mri2b);
