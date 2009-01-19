socket_client_open zadko 127.0.01 5003
fconfigure $audace(socket,client,zadko) -buffering none -blocking 0 -eofchar { ; }


socket_client_put zadko "#25;" ; after 100 ; socket_client_get zadko



# === pointage 17h -10d
socket_client_put zadko "#6,17,-10;" ; after 100 ; socket_client_put zadko "#12;"

socket_client_close zadko

socket_client_put zadko "#25;" ; after 100 ; read $audace(socket,client,zadko)
# #1.339175,15.999938,-10.000475,2008.500000,1.136131,17.339114,9.910129,2008.704437;

socket_client_put zadko "#26;" ; after 100 ; read $audace(socket,client,zadko)
# #5,228,0;

socket_client_put zadko "#28;" ; after 100 ; read $audace(socket,client,zadko)
# #16.000000,-10.000000,15.999889,-10.000483,1.346667;

# === park the telescope
socket_client_put zadko "#14,0,0,0,0;" ; after 100 ; socket_client_put zadko "#10;" ; after 100 ; socket_client_put zadko "#12;"

# === unpark the telescope,
socket_client_put zadko "#14,15.000,0,14.876,0;" 


socket_client_put zadko "#29,0;"


set octet 255
set pos 7 ; set bos pow(2,$pos) ; set bos [expr pow(2,$pos)] ; set b [expr int(floor($octet/$bos))] ; set octet [expr $octet-$bos*$b]

tel::create dfm com1
tel1 coord


