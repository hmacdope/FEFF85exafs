      subroutine rhlbp (rs, xk, erl, eim)
c     This is a new broadened plasmon hl subroutine, 
c     using interpolation for the real and imaginary part.
c     test of multi-pole pole model
c     input:  
c        rs - r_s 
c        xk - k in a.u.
c     output: 
c        erl, eim - Re and Im part of self energy normalized to k_f**2/2

      implicit double precision (a-h,o-z)    
      include '../HEADERS/const.h'
      parameter (nrs=21, nx=51 )
      dimension rsmesh(nrs), xmesh(nx), sigma(nrs,nx,2)
      save ifirst, rsmesh, xmesh, sigma
      data  ifirst /0/

      xf = fa / rs
      ef = xf *xf / 2.  
      wp = sqrt (3 / rs**3) / ef
      xk0 = xk / xf
      xx = (xk0 ** 2  - 1) / sqrt(rs)

      if (ifirst .eq. 0) then
c        read self energy for grid points from bphl.dat
         open (unit=2, file='bphl.dat', status='old', iostat=ios)
         call chopen (ios, 'bphl.dat', 'rhlbp')
         xmesh(1) = 0.0
         do 200 irs = 1, nrs
            sigma (irs, 1, 1) = 0.0
            sigma (irs, 1, 2) = 0.0
c           irs correspond to grid in r_s: rs = 10.0**(0.1 * irs)
            do  100 ik = 2, nx
c              xmesh define grid in k-space as follows:
c              xmesh = ((ik-1) / 20.0) * (1.0 + ((ik-1) / 20.0)**4.0)
c              xmesh = (xk**2 - 1) / sqrt (rs)
c              xk = sqrt (xmesh * sqrt(rs) + 1.0)
c              xk = k / k_f
               read(2, *) rsmesh(irs), xmesh(ik), 
     1              sigma(irs, ik, 1), sigma(irs, ik, 2)
 100        continue
 200     continue
         ifirst = 1
         close (unit=2)
      endif

c     delev = xdel * ef * hart * rs
      call terp2d (rsmesh, xmesh, sigma(1, 1, 1), nrs, nx, rs, xx, erl)
      call terp2d (rsmesh, xmesh, sigma(1, 1, 2), nrs, nx, rs, xx, eim)
c     transfer to atomic units
      erl = erl / rs / hart
      eim = eim / rs / hart

      call quinn (xk0, rs, wp, ef, ei)
      if (eim .ge. ei)  eim = ei

      return
      end

      subroutine terp2d (x, y, z, nx, ny, x0, y0, z0)
c     Linear interpolation and extrapolation.
c     2d analog of terp.f
      implicit double precision (a-h, o-z)

      dimension x(nx), y(ny), z(nx,ny)

c     Find out between which x points x0 lies
      ix = locat (x0, nx, x)
c     if i < 1, set i=1, if i > n-1, set i=n-1
      ix = max (ix, 1)
      ix = min (ix, nx-1)
      if (x(ix+1) - x(ix) .eq. 0)  call par_stop('TERP-1')
c     Find out between which y points y0 lies
      iy = locat (y0, ny, y)
c     if i < 1, set i=1, if i > n-1, set i=n-1
      iy = max (iy, 1)
      iy = min (iy, ny-1)
      if (y(iy+1) - y(iy) .eq. 0)  call par_stop('TERP-1')

      dx = (x0 - x(ix)) / (x(ix+1) - x(ix))
      dy = (y0 - y(iy)) / (y(iy+1) - y(iy))
      z1 = z(ix,iy) +  dx * (z(ix+1,iy) - z(ix,iy))
      z2 = z(ix,iy) +  dx * (z(ix+1,iy) - z(ix,iy))
      z0 = z1 + dy * (z2 - z1)

      return
      end
