gpio_binary_sensor: gpio_binary_sensor.c
	gcc -o $@ $< -lwiringPi

dht22: dht22.c
	gcc -o $@ $< -lwiringPi

mhz19/mhz19: mhz19/mhz19.go
	#go mod download github.com/tarm/serial
	cd mhz19 && go build . && cd ..

433send/433send:
	cd 433send && make && cd ..

mhz19: mhz19/mhz19

433send: 433send/433send

all: gpio_binary_sensor dht22 mhz19 433send
