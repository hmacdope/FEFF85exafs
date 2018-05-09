      subroutine ortdat (ia)
c        * orthogonalization by the schmidt procedure*
c the ia orbital is orthogonalized toa all orbitals of the same
c symmetry if ia is positive, otherwise all orbitals of the same
c symmetry are orthogonalized
c        this program uses dsordf
 
      implicit double precision (a-h,o-z)
      common cg(251,30), cp(251,30), bg(10,30), bp(10,30),
     1         fl(30), fix(30), ibgp
      common/comdir/cl,dz,dg(251),ag(10),dp(251),ap(10),bidcom(783)
c  dg,ag,dp,ap are used to exchange data only with dsordf
      common/itescf/testy,rap(2),teste,nz,norb,norbsc
      common/ratom1/xnel(30),en(30),scc(30),scw(30),sce(30),
     1nq(30),kap(30),nmax(30)
      common/tabtes/hx,dr(251),test1,test2,ndor,np,nes,method,idim
c#mn
       external dsordf
 
      m=norb
      l= max(ia,1)
      if (ia.gt.0) go to 11
 5    m=l
      l=l+1
      if (l.gt.norb) go to 999
 11   do 15 i=1,idim
         dg(i)=0.0d 00
 15      dp(i)=0.0d 00
      maxl=nmax(l)
      do 21 i=1,maxl
         dg(i)=cg(i,l)
 21      dp(i)=cp(i,l)
      do 25 i=1,ndor
         ag(i)=bg(i,l)
 25      ap(i)=bp(i,l)
      do 51 j=1,m
         if (j.eq.l.or.kap(j).ne.kap(l)) go to 51
         max0=nmax(j)
         a=dsordf (j,j,0,3,fl(l))
         do 41 i=1,max0
            dg(i)=dg(i)-a*cg(i,j)
 41         dp(i)=dp(i)-a*cp(i,j)
         do 45 i=1,ndor
            ag(i)=ag(i)-a*bg(i,j)
 45         ap(i)=ap(i)-a*bp(i,j)
         maxl= max(maxl,max0)
 51   continue
      max0= maxl
      nmax(l)=max0
      a=dsordf (l,max0,0,4,fl(l))
      a= sqrt(a)
      do 71 i=1,max0
         cg(i,l)=dg(i)/a
 71      cp(i,l)=dp(i)/a
      do 75 i=1,ndor
         bg(i,l)=ag(i)/a
 75      bp(i,l)=ap(i)/a
      if (ia.le.0) go to 5
 999  return
      end
