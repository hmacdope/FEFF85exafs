      subroutine acoef(ispin, amat)
c     performs the sum of the product of 4 3j symbols
c       ispin - type of spin calculation
c       amat  - matrix to calculate density via
c             \mu=\mu_at*(1- Im \sum_kp,kpp rkk(kp)*rkk(kpp)*
c                         \sum_m1,m2 bmat(kp,kpp,m1,m2)*G_lp,m2;lpp,m1 )

      implicit double precision (a-h,o-z)
      include '../HEADERS/dim.h'
      integer ispin

      real  amat(-lx:lx,2,2, 3,0:lx)
      real t3j(0:lx,0:lx,0:1), operls (0:1, 0:1, 3)
      real xms, xml, xmj

      external cwig3j

      do 10 i5 =  0,lx
      do 10 i4 =  1,3 
      do 10 i3 =  1,2
      do 10 i2 =  1,2
      do 10 i1 = -lx,lx
         amat(i1,i2,i3,i4,i5)=0
  10  continue
      ms = 1
      if (ispin.lt.0) ms=0
      print*, ' Spin = ', 2*ms-1

      do 100 ml = -lx, lx
        mj = 2*ml + (2*ms-1)
        xmj = 0.5e0*mj
        mj = -mj
c       mj is conserved for all operators of interst (s_z, l_z, t_z)
c       tabulate necessary Clebsh-Gordon coefficients
        do 20 lp = 0,lx
        do 20 jp = 0,lx
        do 20 mp = 0,1
           lp2 = 2*lp
           jp2 = 2*jp+1
           mp2 = 2*mp-1
           t3j(lp,jp,mp) = (-1)**lp *sqrt(jp2+1.e0) * 
     1                    real( cwig3j ( 1, jp2, lp2, mp2, mj, 2) )
 20     continue

        do 90 lpp = 0,lx
          do 30 m1=0,1
          do 30 m2=0,1
          do 30 iop=1,3
            operls(m1,m2,iop) = 0
            if (m1.eq.m2) then
              xms =  m1 - 0.5e0
              xml = xmj-xms
              if (abs(ml+ms-m1).le.lpp) then
                if (ispin.eq.0) then
c                 occupation numbers N_l, N_j- , N_j+
                  operls(m1,m2,iop) = 2
                elseif (iop.eq.1) then
c                 s_z operator in ls basis
                  operls(m1,m2,iop) = xms
                elseif (iop.eq.2 .and. abs(ispin).eq.1) then
c                 l_z operator
                  operls(m1,m2,iop) = xml
                elseif (iop.eq.2 .and. abs(ispin).eq.2) then
c                 unit operator for occupation numbers
                  operls(m1,m2,iop) = 1
                elseif (iop.eq.3 .and. abs(ispin).eq.1) then
c                 t_z operator
                  operls(m1,m2,iop) = xms*2*(3*xml**2-lpp*(lpp+1))
     1                                /(2*lpp+3) /(2*lpp-1)
                elseif (iop.eq.3 .and. abs(ispin).eq.2) then
c                 occupation number for j=l+1/2
                  operls(m1,m2,iop) = t3j(lpp,lpp,m1)**2
                endif
              endif
            else
c             t_z only has nonzero off diagonal matrix elements 
              if (iop.eq.3 .and. abs(ispin).le.1 .and.
     1        nint( 0.5e0+abs(xmj)).lt.lpp)  then
                 operls(m1,m2,iop)=3*xmj*
     1           sqrt(lpp*(lpp+1)-(xmj**2-0.25e0)) /(2*lpp+3) /(2*lpp-1)
              elseif (iop.eq.3 .and. abs(ispin).gt.1) then
                 operls(m1,m2,iop)= t3j(lpp,lpp,m1)* t3j(lpp,lpp,m2)
              endif
            endif
  30      continue

c         calculate energy and r independent matrix amat
c         which is equivalent to integration over angular coordinates
c         for assumed density matrix
          do 80 i1=1,2
             call kfromi(i1,lpp,jj,k1)
             if (k1.eq.0) goto 80
             do 70 i2=1,2
                call kfromi(i2,lpp,jp,k2)
                if (k2.eq.0) goto 70
                do 60 iop=1,3
                do 60 m2=0,1
                do 60 m1=0,1
                  amat(ml,i1,i2,iop,lpp) =  amat(ml,i1,i2,iop,lpp) +
     1            operls(m1,m2,iop) * t3j(lpp,jp,ms)* t3j(lpp,jp,m1)*
     2            t3j(lpp,jj,m2)*t3j(lpp,jj,ms)
  60            continue
  70         continue
  80      continue
  90    continue
 100  continue

      return
      end

      subroutine kfromi (i, lpp, jj, k)
c     input index i1 and orb. mom. lpp
c     output: final state kappa - k; jj=tot.mom(k)-1/2
      integer i, lpp, jj, k

      jj = lpp + i - 2
      k = - lpp - 1
      if (i.eq.1) k = lpp

      return
      end
