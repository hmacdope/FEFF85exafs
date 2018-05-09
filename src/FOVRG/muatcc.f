      subroutine muatcc(xnval) 
c               * angular coefficients *
c        sous programmes utilises  cwig3j
c
      implicit double precision (a-h,o-z)
      include '../HEADERS/dim.h'
      dimension xnval(30)
      common/itescf/testy,rap(2),teste,nz,norb,norbsc
      common/mulabc/afgkc
      dimension afgkc(-ltot-1:ltot,30,0:3)
      common/ratom1/xnel(30),en(30),scc(30),scw(30),sce(30),
     1nq(30),kap(30),nmax(30)
c#mn
       external cwig3j

      do 511 i=-ltot-1,ltot
      do 511 j=1,30
      do 511 k=0,3
 511  afgkc(i,j,k)=0.0d 00
      do 701 ikap=-ltot-1,ltot
         if (ikap .eq. 0) go to 701
         li= abs(ikap)*2-1
         do 700 j=1,norb-1
            lj= abs(kap(j))*2-1
            kmax=(li+lj)/2
            kmin= abs(li-lj)/2
            if ((ikap*kap(j)).lt.0) kmin=kmin+1
            if (xnval(j) .gt. 0.0d0) goto 700
c calculate b_k(i,j)
            do 675 k = kmin, kmax,2
               index=(k-kmin)/2
               afgkc(ikap,j,index)=xnel(j)*(cwig3j(li,k*2,lj,1,0,2)**2)
 675        continue
 700     continue
 701  continue
      return
      end
