!#####################################################################
!
! Este programa calcula los kai para poor-solvent en 1D-coordenadas
! polares usando un metodo de MC
!
!#####################################################################


subroutine kai

use globals
use layer
use volume 

implicit none
real*8 suma(ntot, ntot)
integer seed
real*8 xmin,xmax,ymin,ymax,zmin,zmax
integer MCsteps ! numero de steps de MC

real*8 R,theta,z
real*8 rn
integer i, ii
real*8 rands
real*8 pi
real*8 x1,x2,y1, y2, z1, z2, vect
integer iR, ix,iy,iz, itheta
integer j
real*8 radio

print*,'Kai calculation'
open(unit=111, file='kais.dat')

pi=dacos(-1.0d0)          ! pi = arccos(-1) 
radio = float(ntot)*delta

suma = 0.0
Xu = 0.0 ! vector Xu

seed = 1010
MCsteps = 100

do ii = 1, ntot ! loop sobre cada posicion del segmento

      ymax = 3.0*delta/2.0
      ymin = -3.0*delta/2.0

      zmax = 3.0*delta/2.0
      zmin = -3.0*delta/2.0

      xmax = 3.0*delta/2.0 + (dfloat(ii) - 0.5)*delta
      xmin = -3.0*delta/2.0 + (dfloat(ii) - 0.5)*delta
    
      do ix = 1, MCsteps
      do iy = 1, MCsteps
      do iz = 1, MCsteps

! coordenadas del segmento (x1,y1,z1) y del punto a integrar (x2,y2,z2)

         x1 = (dfloat(ii) - 0.5)*delta ! asume theta segmento = 0, z segmento = 0 y segmento en el centro de la layer
         y1 = 0.0
         z1 = 0.0

         x2 = xmin + (xmax-xmin)*dfloat(ix-1)/dfloat(MCsteps-1)
         y2 = ymin + (ymax-ymin)*dfloat(iy-1)/dfloat(MCsteps-1)
         z2 = zmin + (zmax-zmin)*dfloat(iz-1)/dfloat(MCsteps-1)

         select case (abs(curvature))
         case (0)
         R = x2
         case (1)
         R = sqrt(x2**2 + y2**2)
         case (2)
         R = sqrt(x2**2 + y2**2 + z2**2)
         end select

         vect = sqrt((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2) ! vector diferencia
         j = int(R/delta)+1 ! j tiene la celda donde cae el punto a integrar

         suma(ii, j) = suma(ii, j) + R

         if(vect.le.(1.5*delta)) then ! esta dentro de la esfera del cut-off   
         if(vect.ge.lseg) then ! esta dentro de la esfera del segmento
             Xu(ii, j) = Xu(ii, j) + ((lseg/vect)**6)*R ! incluye el jacobiano R(segmento)
        endif
        endif

      enddo
      enddo
      enddo

      do j = 1, ntot
      Xu(ii, j) = Xu(ii, j)/(MCsteps**3)*(3.0*delta)**3
      suma(ii, j) = suma(ii, j)/(MCsteps**3)*(3.0*delta)**3
     write(111,*)ii,j,Xu(ii,j) ! residual size of iteration vector
     enddo

end do ! ii

close(111)

end

