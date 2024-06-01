% test of FBP reconstructions in 3D

% TEST 1
% centered ball of radius 'r'

% make singoram
r = 0.15;
sino_ball_func = @(x) 2*(abs(x) < r)*sqrt(r^2 - x^2);

grid = linspace(-1, 1, 257);
sinogram_slice = arrayfun(sino_ball_func, grid);
nphi = 128;
sinogram = squeeze(repmat(sinogram_slice, [1 1 nphi]));
figure, imagesc(sinogram, [min(min(sinogram)), max(max(sinogram))]);
sinogram = sinogram';

% FBP in 2D
start_f = tic();
[nodes, values, jacobian_weights, Fs] = rtft2d(sinogram, 128, 257, 1.0, 2.0, true, 1, true);
recon2d = nfft_reconstruct_2d(1024, nodes, values, jacobian_weights, Fs, verbose_level = 1);
printf("Elapsed time: %f seconds\n", toc(start_f));

% plotting
figure, imagesc(real(recon2d), [min(min(recon2d)), max(max(recon2d))]), colorbar;
figure, plot(linspace(-1,1, 1024), recon2d(:, 512));

% TEST 2
% shifted ball

s_grid_size = 129;
nphi = 128;

s_grid = linspace(-1., 1., s_grid_size);
phi_grid = linspace(0, 2*pi, nphi + 1)(1:end-1);
[PP, SS] = ndgrid(phi_grid, s_grid);

% make singoram
r = 0.15;
shift = [0.0 0.4];
sino_ball_shifted_func = @(phi, s) 2*sqrt(max(0, ...
  r^2-(s-dot(shift, [cos(phi) sin(phi)]))^2));
sinogram = arrayfun(sino_ball_shifted_func, PP, SS);

% FBP in 2D
start_f = tic();
[nodes, values, jacobian_weights, Fs] = rtft2d(sinogram, nphi, s_grid_size, 1.0, 1.0, 1, true);
recon2d = nfft_reconstruct_2d(192, nodes, values, jacobian_weights, Fs);
printf("Elapsed time: %f seconds\n", toc(start_f));

% plotting
figure, imshow(squeeze(recon2d), [0,1]), colorbar, ...
  title(sprintf("shift=[%2.2f %2.2f]", shift(1), shift(2)));
figure, plot(linspace(-1,1, 192), recon2d(:, 117));

