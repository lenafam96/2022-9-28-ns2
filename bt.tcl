set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set mytrace [open out.tr w]
$ns trace-all $mytrace
set myNAM [open out.nam w]
$ns namtrace-all $myNAM
proc finish { } {
	global ns mytrace myNAM
	$ns flush-trace
	close $mytrace
	close $myNAM
	exec nam out.nam &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns duplex-link $n0 $n2 100Mb 5ms DropTail
$ns duplex-link $n1 $n2 100Mb 5ms DropTail
$ns duplex-link $n2 $n3 54Mb 10ms DropTail
$ns duplex-link $n2 $n4 54Mb 10ms DropTail
$ns simplex-link $n3 $n4 10Mb 15ms DropTail
$ns queue-limit $n2 $n3 40

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n4 orient right
$ns duplex-link-op $n2 $n3 orient right-down
$ns simplex-link-op $n3 $n4 orient up

set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 1

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 1000
$cbr set rate_ 2Mb

set tcp [new Agent/TCP]
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 2

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.05 "$ftp start"
$ns at 0.1 "$cbr start"
$ns at 60.0 "$ftp stop"
$ns at 60.5 "$cbr stop"
$ns at 61 "finish"

$ns run
