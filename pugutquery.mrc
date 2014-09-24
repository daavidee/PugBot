;//send a query to a ut99 or ut2004 server


;//send a query to the ut server
alias ut_query_ip {
  var %id = $1
  var %t = $+(query_,%id)
  sockudp -k utquery $+ %id $hget(%t,ip) $calc($hget(%t,port) +1) \basic\\info\\teams\\rules\
  sockudp -k utquery $+ %id $hget(%t,ip) $calc($hget(%t,port) +1) \players\
  sockudp -k utquery $+ %id $hget(%t,ip) $calc($hget(%t,port) +1) \game_property\RemainingTime\
  if ($hget(%t,gamever) > 499) sockudp -k utquery $+ %id $hget(%t,ip) $calc($hget(%t,port) +10) \basic\\info\\players\\teams\\rules\\game_property\RemainingTime\
  .timer -m 1 500 fquery_ut %id
  .timer 1 3 sockclose utquery $+ %id
}

;//called after a timed delay. prepares a message from hashtable data
alias fquery_ut {
  var %id = $1
  var %t = $+(query_,%id)
  if ($hget(%t,servername) == $null) halt
  _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),,$sp(81,$hget(%t,chan)),$hget(%t,servername),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$sp(71,$hget(%t,chan)),$hget(%t,numplayers),$sp(72,$hget(%t,chan)),$hget(%t,maxplayers),$sp(73,$hget(%t,chan)),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),unreal://,$hget(%t,ip),:,$hget(%t,hostport)) $+($sp(71,$hget(%t,chan)),$hget(%t,gamever),$sp(73,$hget(%t,chan)),$chr(32),$sp(4,$hget(%t,chan)))
  if ($hget(%t,numplayers) != 0) {
    var %ut_0 = $+(,$sp(83,$hget(%t,chan)))
    var %ut_1 = $+(,$sp(84,$hget(%t,chan)))
    var %ut_2 = $+(,$sp(85,$hget(%t,chan)))
    var %ut_3 = $+(,$sp(86,$hget(%t,chan)))
    var %ut_255 = $+(,$sp(82,$hget(%t,chan)))
    var %ut_players_0
    var %ut_players_1
    var %ut_players_2
    var %ut_players_3
    var %ut_players_255
    var %ut_players_all

    var %i = 1
    var %sorted = $sorttok($hget(%t,players),32,nr)
    while ( %i <= $numtok(%sorted,32) ) {
      var %tk = $gettok(%sorted,%i,32)
      if ($hget(%t,maxteams) == $null) %ut_players_all = %ut_players_all $+(%ut_ [ $+ [ $gettok(%tk,3,5) ] ] ,$gettok(%tk,2,5),$sp(71,$hget(%t,chan)),$gettok(%tk,1,5),$sp(73,$hget(%t,chan)))
      else %ut_players_ [ $+ [ $gettok(%tk,3,5) ] ] = %ut_players_ [ $+ [ $gettok(%tk,3,5) ] ] $+(%ut_ [ $+ [ $gettok(%tk,3,5) ] ] ,$gettok(%tk,2,5),$sp(71,$hget(%t,chan)),$gettok(%tk,1,5),$sp(73,$hget(%t,chan)))
      inc %i
    }
  }
  if ($hget(%t,tr) != $null) var %timerem = $+($sp(8,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Time Remaining:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$sp(71,$hget(%t,chan)),$sec_c($hget(%t,tr)),$sp(73,$hget(%t,chan))) 
  if ($hget(%t,maxteams) == $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Map:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$hget(%t,mapname),$chr(32),%timerem,$chr(32),$sp(4,$hget(%t,chan))) 
  elseif (($hget(%t,maxteams) != $null) && ($hget(%t,score0) == $null)) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Map:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$hget(%t,mapname),$chr(32),%timerem,$chr(32),$+(,$sp(81,$hget(%t,chan))),$sp(4,$hget(%t,chan)))
  elseif ($hget(%t,maxteams) == 2) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Map:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$hget(%t,mapname),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$+(,$sp(83,$hget(%t,chan))),Red Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score0),0),$sp(73,$hget(%t,chan)),$chr(32),$+(,$sp(84,$hget(%t,chan))),Blue Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score1),0),$sp(73,$hget(%t,chan)),$chr(32),%timerem,$chr(32),$+(,$sp(81,$hget(%t,chan))),$sp(4,$hget(%t,chan)))
  elseif ($hget(%t,maxteams) == 4) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Map:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$hget(%t,mapname),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$+(,$sp(83,$hget(%t,chan))),Red Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score0),0),$sp(73,$hget(%t,chan)),$chr(32),$+(,$sp(84,$hget(%t,chan))),Blue Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score1),0),$sp(73,$hget(%t,chan)),$chr(32), $&
    $+(,$sp(85,$hget(%t,chan))),Green Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score2),0),$sp(73,$hget(%t,chan)),$chr(32),$+(,$sp(86,$hget(%t,chan))),Gold Score:,$chr(32),$sp(71,$hget(%t,chan)),$round($hget(%t,score3),0),$sp(73,$hget(%t,chan)),$chr(32),%timerem,$chr(32),$+(,$sp(82,$hget(%t,chan))),$sp(4,$hget(%t,chan)))
  if (%ut_players_0 != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(83,$hget(%t,chan))),Red Team:,$chr(32),%ut_players_0,$chr(32),$sp(4,$hget(%t,chan)))
  if (%ut_players_1 != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(84,$hget(%t,chan))),Blue Team:,$chr(32),%ut_players_1,$chr(32),$sp(4,$hget(%t,chan)))
  if (%ut_players_2 != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(85,$hget(%t,chan))),Green Team:,$chr(32),%ut_players_2,$chr(32),$sp(4,$hget(%t,chan)))
  if (%ut_players_3 != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(86,$hget(%t,chan))),Gold Team:,$chr(32),%ut_players_3,$chr(32),$sp(4,$hget(%t,chan)))
  if (%ut_players_255 != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),None:,$chr(32),%ut_players_255,$chr(32),$sp(4,$hget(%t,chan)))
  if (%ut_players_all != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Players:, $chr(32),%ut_players_all,$chr(32),$sp(4,$hget(%t,chan)))
  if ($hget(%t,specs) != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Spectators:,$chr(32),$+(,$sp(82,$hget(%t,chan))),$hget(%t,specs),$chr(32),$sp(4,$hget(%t,chan)))
}

;//supporting function to parse the response
alias utquery_bvar_search {
  var %offset = 0
  var %start = 1
  if ($2 != $null) %start = $2
  if ($3 != $null) %offset = $3
  var %s = $1
  var %pos = $calc($bfind(&query,%start,%s)+ $len($1) + %offset)
  var %pos2 = $bfind(&query,%pos,\)
  ;echo -a $1 $bvar(&query,%pos,$calc(%pos2 - %pos)).text
  return $bvar(&query,%pos,$calc(%pos2 - %pos)).text
}

;//parse the query response
on *:udpRead:utquery*: {
  if ($sockerr > 0) halt
  var %id $mid($sockname,8)
  var %t = $+(query_,%id)
  sockread &query
  ;echo -a $bvar(&query,1,500).text
  if ($bfind(&query,1,\gamever\)) hadd %t gamever $utquery_bvar_search(\gamever\)
  if ($bfind(&query,1,\hostname\)) hadd %t servername $strip($utquery_bvar_search(\hostname\))
  if ($bfind(&query,1,\hostport\)) hadd %t hostport $utquery_bvar_search(\hostport\)
  if ($bfind(&query,1,\mapname\)) hadd %t mapname $utquery_bvar_search(\mapname\)
  if ($bfind(&query,1,\numplayers\)) hadd %t numplayers $utquery_bvar_search(\numplayers\)
  if ($bfind(&query,1,\maxplayers\)) hadd %t maxplayers $utquery_bvar_search(\maxplayers\)
  if ($bfind(&query,1,\maxteams\)) hadd %t maxteams $utquery_bvar_search(\maxteams\)
  if ($bfind(&query,1,\Red\score_0\)) hadd %t score0 $utquery_bvar_search(\Red\score_0\)
  if ($bfind(&query,1,\Blue\score_1\)) hadd %t score1 $utquery_bvar_search(\Blue\score_1\)
  if ($bfind(&query,1,\Green\score_2\)) hadd %t score2 $utquery_bvar_search(\Green\score_2\)
  if ($bfind(&query,1,\Gold\score_3\)) hadd %t score3 $utquery_bvar_search(\Gold\score_3\)
  if ($bfind(&query,1,\RemainingTime\)) hadd %t tr $utquery_bvar_search(\RemainingTime\)
  var %team
  var %player
  var %frags
  var %mesh
  var %j = 1
  while (%j < $bvar(&query,0)) {
    if ($bfind(&query,%j,\player_) != 0 ) {
      var %pn = $utquery_bvar_search(\player_,%j)
      %player = $replace($strip($utquery_bvar_search(\player_ $+ %pn $+ \,%j)),$chr(160),**)
      ;echo -a %pn $utquery_bvar_search(\player_ $+ %pn $+ \,%j)
      %frags = $utquery_bvar_search(\frags_ $+ %pn $+ \,%j)
      %team = $utquery_bvar_search(\team_ $+ %pn $+ \,%j)
      %mesh = $utquery_bvar_search(\mesh_ $+ %pn $+ \,%j)
      ;echo -a %j $bvar(&query,0) $bvar(&query,$bfind(&query,%j,\player_),80).text
      ;echo -a %player %team %frags %mesh
      if (%mesh == Spectator) hadd -m %t specs $hget(%t,specs) %player
      else hadd %t players $hget(%t,players) $+(%frags,$chr(5),%player,$chr(5),%team)
      %j = $calc($bfind(&query,%j,\player_ $+ %pn)+1)
    }
    else break
  }
}
