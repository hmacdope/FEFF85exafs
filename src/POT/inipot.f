      subroutine inipot (dgc, dpc, edenvl, vvalgs, xnmues)
c     initialize values of arrays to zero
      implicit double precision (a-h, o-z)
      include '../HEADERS/dim.h'
      parameter (zero=0.0d0)

      dimension dgc(251,30,0:nphx+1), dpc(251,30,0:nphx+1)
      dimension edenvl(251,0:nphx), vvalgs (251,0:nphx)
      dimension xnmues(0:lx,0:nphx)

      do 10 iph  = 0,nphx+1
      do 10 iorb = 1,30
      do 10 i = 1,251
   10    dgc(i,iorb,iph) = zero

      do 20 iph  = 0,nphx+1
      do 20 iorb = 1,30
      do 20 i = 1,251
   20    dpc(i,iorb,iph) = zero

      do 30 iph = 0, nphx
      do 30 i = 1, 251
   30    edenvl(i, iph) = zero

      do 40 iph = 0, nphx
      do 40 i = 1, 251
   40    vvalgs(i, iph) = zero

      do 50 iph = 0, nphx
      do 50 ll = 0, lx
   50    xnmues (ll, iph) = zero

      return
      end
