;//sets and reads servers using the assault custom query/game setup mod. this has not been fully implemented

;//main server set function
alias server_set {
  var %serverpick = $2
  var %id = $ticks
  var %t = $+(server_set,%id)
  var %htable = $+($1,_,$started_pug($1))
  var %redpw = $+(red,$rand(1,99))
  var %bluepw = $+(blue,$rand(1,99))
  var %specpw = $+(spec,$rand(1,99))
  var %mod = $started_pug($1)
  hadd -m %t chan $1
  hadd -m %t mod %mod
  hadd -m %t ip $gettok($ri($2,$1),1,7)
  hadd -m %t ASUDPPort $gettok($ri($2,$1),2,7)
  hadd -m %t ASUDPPass $gettok($ri($2,$1),3,7)
  hadd -m %t redpw %redpw
  hadd -m %t bluepw %bluepw
  hadd -m %t specpw %specpw
  .timer 1 2 _msg $1 $dout($1,Spectator password set to %specpw)

  var %i = 1
  var %mapstr
  while (%i <= $hfind($+(%htable,_maps),included*,0,w).data ) {
    var %map = $gettok($hget($+(%htable,_maps),$hfind($+(%htable,_maps),$+(included,%i,*),1,w).data),2,7)
    ;echo -a %map
    if (%i == $hfind($+(%htable,_maps),included*,0,w).data) %mapstr = $+(%mapstr,%map)
    else %mapstr = $+(%mapstr,%map,:)
    inc %i
  }
  hadd -m %t mapstr %mapstr
  ;echo -a %mapstr


  sockudp -k $+(asudpSendData,%id) $hget(%t,ip) $hget(%t,ASUDPPort) $+(LOGIN::,$hget(%t,ASUDPPass))

  .timer 1 10 hfree %t


  return %t
}

;//send the required dtaa via udp
on *:udpRead:ASUDPSendData*: {
  if ($sockerr > 0) halt
  var %ip = $sock($sockname).saddr
  var %port = $sock($sockname).sport
  var %id = $mid($sockname,14)
  var %htable = $+(server_set,%id)
  sockread &query
  ;echo -a $bvar(&query,1,500).text
  if ($bvar(&query,1,500).text == LOGGEDIN!) {
    sockudp -k ASUDPSendData %ip %port ISMATCHINPROGRESS?
    sockudp -k ASUDPSendData %ip %port SETREDTEAMNAME::Red
    sockudp -k ASUDPSendData %ip %port SETBLUETEAMNAME::Blue
    sockudp -k ASUDPSendData %ip %port $+(SETREDPASSWORD::,$hget(%htable,redpw))
    sockudp -k ASUDPSendData %ip %port $+(SETBLUEPASSWORD::,$hget(%htable,bluepw))
    sockudp -k ASUDPSendData %ip %port SETGAMEPASSWORD::L4sx4ass
    sockudp -k ASUDPSendData %ip %port SETMODERATORPASSWORD::088147m0dr
    sockudp -k ASUDPSendData %ip %port $+(SETSPECTATORPASSWORD::,$hget(%htable,specpw))
    sockudp -k ASUDPSendData %ip %port SETFIRSTSTARTTIME::300
    ;sockudp -k ASUDPSendData %ip %port SETMAXTEAMSIZE::6
    sockudp -k ASUDPSendData %ip %port SETMATCHLENGTH::14
    .timer 1 1 ASDataToSend %ip %port %htable
  }
  if ($bvar(&query,1,500).text == HELLO!) {
    sockudp -k ASUDPSendData $sock($sockname).saddr $sock($sockname).sport STARTMATCH!
    sockudp -k ASUDPSendData $sock($sockname).saddr $sock($sockname).sport LOGOUT!
  }
}

;//rest of the data to send. needs to be sent after a delay.
alias ASDataToSend {
  var %ip = $1
  var %port = $2
  sockudp -k ASUDPSendData %ip %port SETTIWENABLED::TRUE
  sockudp -k ASUDPSendData %ip %port SETAUTHMODE::1
  sockudp -k ASUDPSendData %ip %port CONSOLESET::Engine.GameInfo bLocalLog False
  sockudp -k ASUDPSendData %ip %port SETATTACKONLY::False
  sockudp -k ASUDPSendData %ip %port SETTOURNAMENTMODE::TRUE
  sockudp -k ASUDPSendData %ip %port SETPLAYERLIMIT::12
  sockudp -k ASUDPSendData %ip %port SETSPECLIMIT::10
  sockudp -k ASUDPSendData %ip %port SETFRIENDLYFIRE::0
  sockudp -k ASUDPSendData %ip %port SETMUTATORLIST::Botpack.Assault
  sockudp -k ASUDPSendData %ip %port $+(SETMAPLIST::,$hget($3,mapstr))
}
