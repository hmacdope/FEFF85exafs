       subroutine rdline(jinit, line)
c
c  return next "real" command line from input file(s)
c    -  allows use of "include file" or "load file" for reading
c       from other files, and manages the set of include files
c    -  checks for and ignores comment lines and blank lines.
c    -  opens and closes all input files, including initial file.
c
c   jinit  initialization/clean-up flag     [in]
c   line   next command line to parse   [in/out]
c
c notes:
c   1. to initialize, set jinit<0 and line= main_input_file_name.inp
c      if line=' ', routine will stop program.
c   2. returned line will be sent through triml and untab.
c   3. uses routine iscomm to test if line is a comment line.
c   4. special returned values:
c        'read_line_end'  = done reading all inputs
c        'read_line_error'= an error has occurred. the calling routine
c                        should probably stop
c   5. to clean up all open files, call with jinit=0
c
c matt newville march 1999
       implicit none
       integer mwords, ilen, i, jinit, mfil, nfil
       parameter (mwords=2, mfil=10)
       character*(*) line, stat*8
       character*90  files(mfil), errmsg, words(mwords)
       parameter (stat='old')
       integer   iunit(mfil), istrln, nwords, ierr, iexist
       logical   iscomm, open
       external  istrln, iscomm
       save      files, iunit, nfil
c
c jinit=-1: initialize
       if (jinit.eq.-1) then
          jinit  = 1
          do 10 i = 1, mfil
             iunit(i) = 0
             files(i) = ' '
 10       continue
          nfil     = 1
          files(1) = line
          call triml(files(1))
          call openfl(iunit(1), files(1), stat, iexist, ierr)
          if (iexist .lt. 0) go to 2600
          if (ierr   .lt. 0) go to 2800
c
c  jinit=0:  close all opened files (except unit 5!)
       elseif (jinit.eq.0) then
          jinit = 1
          do 25, i = 1, mfil
             if ((iunit(i).gt.0).and.(iunit(i).ne.5)) then 
                inquire(unit = iunit(i), opened=open)
                if (open) then
                   close(iunit(i))
                   iunit(i) = 0
                   files(i) = ' '
                endif 
             endif 
 25       continue 
          return
       end if
c  read next line from current input file
 100   continue
cc       print*, 'rdline 100: nfil , files(nfil), iunit = ',
cc     $      nfil,files(nfil)(:20), iunit(nfil)
       line   = ' '
       read(iunit(nfil),'(a)', err =1000, end = 500) line
c
c  check if command line is 'include filename'.
c  if so, open that file, and put it in the files stack
       call untab(line)
       call triml(line)
       if (iscomm(line)) go to 100
       nwords = mwords
       words(2) = ' '
       call bwords(line, nwords, words)
       call lower(words(1))
       if (((words(1) .eq. 'include').or.(words(1) .eq. 'load'))
     $      .and. (nwords .gt. 1)) then
          nfil = nfil + 1
          if (nfil .gt. mfil) go to 2000
          call getfln(words(2), files(nfil), ierr)
          if (ierr. ne. 0) go to 2400
c  test for recursion:
          do 400 i = 1, nfil - 1
             if (files(nfil) .eq. files(i)) go to 3000
 400      continue
          call openfl(iunit(nfil), files(nfil), stat, iexist, ierr)
          if (iexist .lt. 0) go to 2600
          if (ierr   .lt. 0) go to 2800
          go to 100
       end if
       return
c
c  end-of-file for command line file: drop nfil by 1,
c  return to get another command line
 500   continue
       inquire(unit = iunit(nfil), opened=open)
       if (open .and. (iunit(nfil) .ne. 5)) then
          close(iunit(nfil))
       end if
       iunit(nfil) = 0
       files(nfil) = ' '
       nfil = nfil - 1
       if (nfil.gt.0) go to 100
       line = 'read_line_end'
       return
c   error messages
 1000  continue
       call wlog(' # read error: general error')
       go to 4500
 2000  continue
       call wlog(' # read error: too many nested "include"s')
       write(errmsg, '(1x,a,i3)') ' # current limit is ', mfil
       ilen  = istrln(errmsg)
       call wlog(errmsg(1:ilen))
       go to 4500
 2400  continue
       call wlog(' # read error: cannot determine file name')
       go to 4500
 2600  continue
       call wlog(' # read error: cannot find file')
       go to 4500
 2800  continue
       call wlog(' # read error: cannot open file')
       go to 4500
 3000  continue
       call wlog(' # read error: recursive use of file')
       go to 4500
 4500  continue
       errmsg = ' # >> file name = '//files(nfil)(1:72)
       ilen   = istrln(errmsg)
       call wlog(errmsg(1:ilen) )
       line = 'read_line_error'
       return
c end subroutine read_line
       end
       subroutine getfln(strin, filnam, ierr)
c  strip off the matched delimeters from string, as if getting
c  a filename from "filename", etc.
       integer idel, iend, istrln, ierr
       character*(*) strin, filnam, tmp*144, ope*8, clo*8
       data ope, clo /'"{(<''[',  '"})>'']'/
c
       ierr  = 0
       tmp   = strin
       call triml(tmp)
       ilen  = istrln(tmp)
       idel  = index(ope,tmp(1:1))
       if (idel.ne.0) then
          iend = index(tmp(2:), clo(idel:idel) )
          if (iend.le.0) then
             ierr = -1
             iend = ilen 
          end if
          filnam = tmp(2:iend)
       else
          iend = index(tmp,' ') - 1
          if (iend.le.0) iend  = istrln(tmp) 
          filnam = tmp(1:iend)
       end if
       return
c end  subroutine getfln
       end
       subroutine openfl(iunit, file, status, iexist, ierr)
c  
c  open a file, 
c   if unit <= 0, the first unused unit number greater than 7 will 
c                be assigned.
c   if status = 'old', the existence of the file is checked.
c   if the file does not exist iexist is set to -1
c   if the file does exist, iexist = iunit.
c   if any errors are encountered, ierr is set to -1.
c
c   note: iunit, iexist, and ierr may be overwritten by this routine
       character*(*)  file, status, stat*10
       integer        iunit, iexist, ierr
       logical        exist

c make sure there is a unit number and file name
       ierr   = -3
       iexist =  -1
       if (file .eq. ' ') return
       iexist = 0
       iunit  = nxtunt(iunit)
c
c if status = 'old', check that the file name exists
       ierr = -2
       stat =  status                          
       call lower(stat)
       if (stat.eq.'old') then
          iexist = -1
          inquire(file=file, exist = exist)
          if (.not.exist) return
          iexist = iunit
       end if
c 
c open the file
       ierr = -1
       open(unit=iunit, file=file, status=status, err=100)
       ierr = 0
 100   continue
       return
c end  subroutine openfl
       end
