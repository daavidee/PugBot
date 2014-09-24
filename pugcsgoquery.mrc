;//csgo query script. should work for all valve source servers (may need some tweaks)

;//set up query and send to server
alias csgo_query_ip {
  var %id = $1
  var %t = $+(query_,%id)
  bset &q 1 255 255 255 255
  bset -t &q 5 TSource Engine Query
  bset &q 25 0
  sockudp -k $+(csgoquery,%id) $hget(%t,ip) $hget(%t,port) &q
  bset &q2 1 255 255 255 255 85 $hget(%t,cid)
  bset &q3 1 255 255 255 255 86 $hget(%t,cid)
  sockudp -k $+(csgoquery,%id) $hget(%t,ip) $hget(%t,port) &q2
  ;sockudp -k $+(csgoquery,%id) $hget(%t,ip) $hget(%t,port) &q3
  .timer -m 1 750 fquery_csgo %id
  .timer -m 1 2500 sockclose csgoquery $+ %id
}

;//called after a timed delay from the query. prepares message from the hashtable data
alias fquery_csgo {
  var %id = $1
  var %t = $+(query_,%id)
  var %gamename = $hget(%t,gamename)
  if (%gamename = Counter-Strike: Global Offensive) %gamename = CS:GO
  _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),,$sp(81,$hget(%t,chan)),$hget(%t,servername),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$sp(71,$hget(%t,chan)),$hget(%t,numplayers),$sp(72,$hget(%t,chan)),$hget(%t,maxplayers),$sp(73,$hget(%t,chan)),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$hget(%t,ip),:,$hget(%t,port),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Map:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$hget(%t,mapname),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$sp(71,$hget(%t,chan)),%gamename,$chr(32),v,$hget(%t,gamever),$sp(73,$hget(%t,chan)),$chr(32),$sp(4,$hget(%t,chan)))
  if ($hget(%t,players) != $null) {
    var %sorted = $sorttok($hget(%t,players),5,nr)
    var %tmp
    var %i = 1
    var %c = $+(,$sp(82,$hget(%t,chan)))
    while (%i <= $numtok(%sorted,5)) {
      %tmp = $+(%tmp,$chr(32),%c,$gettok($gettok(%sorted,%i,5),2,7),$sp(71,$hget(%t,chan)),$gettok($gettok(%sorted,%i,5),1,7),$sp(73,$hget(%t,chan)))
      if (%c == $+(,$sp(82,$hget(%t,chan)))) %c = $+(,$sp(81,$hget(%t,chan)))
      elseif (%c == $+(,$sp(81,$hget(%t,chan)))) %c = $+(,$sp(82,$hget(%t,chan)))
      inc %i
    }
    _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),Players: ,%tmp,$chr(32),$sp(4,$hget(%t,chan)))
  }
}

;//parse data from response and put in hashtable
on *:udpRead:csgoquery*: {
  if ($sockerr > 0) halt
  var %id $mid($sockname,10)
  var %t = $+(query_,%id)
  sockread &query
  bset &q 1 255 255 255 255
  if ($bvar(&query,1,4) == $bvar(&q,1,4)) {
    if ($bvar(&query,5,1) == 73) {
      var %pos = 7
      hadd %t servername $bvar(&query,%pos,$bfind(&query,1,0)).text
      %pos = $calc($bfind(&query,%pos,0)+1)
      hadd %t mapname $bvar(&query,%pos,$bfind(&query,%pos,0)).text
      %pos = $calc($bfind(&query,%pos,0)+1)
      %pos = $calc($bfind(&query,%pos,0)+1)
      hadd %t gamename $bvar(&query,%pos,$bfind(&query,%pos,0)).text
      %pos = $calc($bfind(&query,%pos,0)+1)
      hadd %t numplayers $bvar(&query,$calc(%pos +2),1)
      hadd %t maxplayers $bvar(&query,$calc(%pos +3),1)
      %pos = $calc($bfind(&query,%pos,0)+1)
      var %pos2 $calc($bfind(&query,$calc(%pos +1),0 1)+2)
      var %pos3 = $bfind(&query,%pos2,46)
      hadd %t gamever $bvar(&query,$calc(%pos3 -1),10).text
    }
    elseif ($bvar(&query,5,1) == 68) {
      var %numplayers = $bvar(&query,6,1)
      ;echo -a $bvar(&query,6,1)
      var %j = 0
      var %i = 7
      while (%j != %numplayers) {
        ;if (%j != $bvar(&query,%i,1)) break
        var %id = $bvar(&query,%i,1)
        var %player = $bvar(&query,$calc(%i +1),$bfind(&query,$calc(%i +1),0)).text
        var %frags = $bvar(&query,$calc(%i + $len(%player) +2)).long
        var %time = $bvar(&query,$calc(%i + $len(%player) +6)).long
        if ($hget(%t,players) == $null) hadd %t players $+(%frags,$chr(7),%player)
        else hadd %t players $+($hget(%t,players),$chr(5),%frags,$chr(7),%player)
        echo -a %j %player %frags
        %i = $calc(%i + $len(%player) +10)
        inc %j
      }
    }
  }
}

;//debugging code
alias csgo {
  bset &t 1 255 255 255 255 85 216 227 180 8
  sockudp -k csgo1 208.68.90.171 27015 &t
}
on *:udpRead:csgo*: {
  if ($sockerr > 0) halt
  sockread &query
  echo -a $bvar(&query,1,100).text
  var %i = 1
  while ($bfind(&query,%i,0) != $null) {
    echo -a $bvar(&query,%i,$bfind(&query,%i,0)).text
    %i = $calc($bfind(&query,%i,0)+1)
  }
}
