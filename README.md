## Filtered Backprojection algorithm in 2D/3D

This is a custom multi-threaded implementation in Octave/Matlab of Filtered-Backprojection algorithms in 2D/3D for parallel beam geometry.



The source code was written in Octave 8.4.0 but it should work in Matlab with minimal changes as most of the work is done by a third-party library.



### Why?

Built-in function `iradon` has unclear and limited interface (e.g., only standard filters are easy to use) and little control on the output size of the image. 



Possibly *you don't need this code* (and standard `iradon` should be enough)

* if you are doing pure image processing (without carrying much for correct scale of reconstructions)

* work only in 2D using very standard Fourier-filters (e.g., from standard `iradon` function)



This code can be *useful if*

* you want to control parameters of reconstructions and reconstruction scale matters
* you need to implement your custom filters in Fourier domain
* data and reconstructions are in 3D 



### Why Octave/Matlab and not Python/C++?

1. *Efficiency* - The core of the reconstruction is performed using [very efficient and scalable NUFFT library](https://www-user.tu-chemnitz.de/~potts/nfft/)
2. *Pedagogical reasons* - code is very simple and clear, so you can easily adapt it for your own needs (see [section below](#input-sinogram-format) for details on implemented sampling geometry and filters)



## Dependencies

1. Installed NUFFT library from [here](https://www-user.tu-chemnitz.de/~potts/nfft/) with Matlab/Octave support (compiled mex-file)
2. Octave/Matlab with added path to Matlab/Octave interface of NUFFT (use`addpath('path-to-folder with NUFFT .mex and .m files')`)
3. `cartprod.m` which is already in repository; original file is from [Matlab File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/5475-cartprod-cartesian-product-of-multiple-sets)



## Installation

No installation required apart of what is listed in [dependencies](#dependencies).



## Usage example

Look through `fbp_nfft3d_test.m`, `fbp_nfft2d_test.m` in `/tests` folder. 

* `rtft2d.m`, `rtft3d.m` - compute Fourier data (grid points and values) in 2D/3D space (filters are also applied at this stage)
* `nfft_reconstruct_2d.m`, `nfft_reconstruct_3d.m` - compute Fourier integral over the data



## Input sinogram format

#### Mathematical background

Radon transform of function $f$ is defined as 
$$
Rf(s,\theta) = \int\limits_{\langle x, \theta\rangle = s}f(x)\, dx, \, s\in \mathbb{R}, \, \theta\in S^{d-1}
$$

* For $d=2$ Radon transform of $f$ is given by its integrals over all lines

* For $d=3$ Radon transform of $f$ is given by its integrals over all 2D-planes in 3D



Filtered Backprojection Algorithm (FBP) implements operator $R^{-1}$ which reconstructs $f$ from its hyperplane integrals $Rf$. 



#### Implemented input format

Sinogram is given by array $Rf(s,\theta)$ on a grid $\{s_j\}_{j=1}^{N_s}$, $\{\theta_k\}_{k=1}^{N_{\theta}}$, where 

1. $\{s_j\}_{j=1}^{N_s}$ form a uniform grid on $[-1,1]$​ (endpoints included)



##### 2D


2. $\theta_k = (\cos\varphi_k, \sin\varphi_k)$, $\varphi_k = k\cdot \frac{2\pi}{N_{\theta}}$, $k\in \{0, \dots, N_{\theta}-1\}$



##### 3D

2. $\theta_k = (\sin\gamma_m\cos\varphi_n, \sin\gamma_m\sin\varphi_n, \cos\gamma_m)$, $k=(m,n)$, $m\in \{0,\dots N_\gamma-1\}$, $n\in \{0,\dots N_{\varphi}-1\}$

   $\varphi_n = n\cdot \frac{2\pi}{N_{\varphi}}$, $n\in \{0, \dots, N_{\varphi}-1\}$

   $\gamma_{m} = \arccos(t_m)$, $t_{m}$ - make a uniform grid on $(-1,1)$ (endpoints excluded)  



##### Underlying assumptions

* it assumed that $\mathrm{supp} f\subset B(1)$ (centered unit ball) - this is used for *zero padding* of the sinogram 
  * padding sinogram with zeros for compactly supported signal does not alter the reconstruction
  * padding is used for precision of the Fourier integral evaluated by NUFFT (greater padding increases precision at cost of higher RAM consumption) 



For ordering of the input array, check examples in `/tests`. 




## Note

Implementation is scalable, however, RAM consumption in 3D can be quite large (observed up to 80GB of RAM allocation in 3D case for large grids).
