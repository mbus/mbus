default:	info

clean:
		@rm -f *.v *.h *.log *.tcl *.vec

ez:
		@ezwave -NOWindow -DO EZWAVE.tcl &

info:
		@m3_genRF -h

rf:
		@m3_genRF genRF.conf

vec:
		@m3_genRF genRF.conf input.inst

all:
		@m3_genRF genRF.conf input.inst -all
