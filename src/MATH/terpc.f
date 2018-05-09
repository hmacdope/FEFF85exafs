c     interpolation and extrapolation by m-th order polynomial
c     maximum m = 3. Change nmax if needed.
c     Input x and y arrays, returns y value y0 at requested x value x0.
c     Dies on error.

      subroutine terpc (x, y, n, m, x0, y0)
      implicit double precision (a-h, o-z)

      complex*16 y, y0, dy
      dimension x(n), y(n)

c     Find out between which x points x0 lies
      i = locat (x0, n, x)
      k = min( max(i-m/2,1) , n-m )
      call polinc( x(k), y(k), m+1, x0, y0, dy)

      return
      end

      subroutine polinc( xa, ya, n, x, y, dy)
c     draws a polynimial P(x) of order (n-1) through n points.
c     returns y = P(x) and dy - estimate of the error
c     adapted  from numerical recipies in fortran by Press et al.

      implicit double precision (a-h,o-z)
      complex*16 ya,y,dy,c,d,w,den
      integer n, nmax
      parameter (nmax=4)
      dimension xa(nmax), ya(nmax), c(nmax), d (nmax)

      ns = 1
      dif = abs (x-xa(1))
      do 10 i=1,n
         dift = abs(x-xa(i))
         if (dift.lt.dif) then
            ns = i
            dif = dift
         endif
         c(i) = ya(i)
         d(i) = ya(i)
  10  continue
      y = ya(ns)
      ns = ns-1
      do 30 m=1,n-1
         do 20 i=1,n-m
            ho = xa(i)-x
            hp = xa(i+m)-x
            w = c(i+1) - d(i)
            den = ho-hp
            if (den.eq.0) stop 'failure in polint'
            den = w/den
            d(i) = hp*den
            c(i) = ho*den
  20     continue
         if (2*ns .lt. n-m) then
            dy = c(ns+1)
         else
            dy = d(ns)
            ns = ns-1
         endif
         y = y + dy
  30  continue

      return
      end
