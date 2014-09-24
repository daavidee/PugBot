;//all functions relating to a teamspeak 3 server query. teamspeak2 queries should also still work

;//set up and send a ts server query
alias ts {
  var %ts_id $ticks
  var %t = $+(tsquery,%ts_id)
  var %tmppp = $2
  var %tmp = $1
  if (ts* iswm $cp($1)) && ($2 == $null) {
    if ($cp($1) == ts) %tmp = .ts1 ;//.ts and .ts1 are the same call
    hadd -m %t is_aliasquery $mid(%tmp,2) ;//if second text token is $null, then no server is specified so lookup default server in channel vars
    if ($ri($mid(%tmp,2))) %tmppp = $ri($mid(%tmp,2))
  }
  .timer 1 5 hfree %t
  
  if (%tmppp != $null) {
    hadd -m %t chan $chan
    hadd %t ip $gettok(%tmppp,1,58)
    hadd %t port $gettok(%tmppp,2,58)
    sockopen ts [ $+ [ %ts_id ] ] $hget(%t,ip) 10011
    .timer 1 5 sockclose ts [ $+ [ %ts_id ] ]
    .timer -m 1 600 ftsquery %ts_id %tmppp
  }
}

;//called after the query and prepares the response
alias ftsquery {
  var %ts_id = $1
  var %t = $+(tsquery,%ts_id)
  var %chan = $hget(%t,chan)
  var %ip = $hget(%t,ip)
  var %port = $hget(%t,port)
  if ((%ip == $null) || (%port !isnum)) _msg $hget(%t,chan) $dout($hget(%t,chan),Invalid query. Use valid ip:port query.)
  elseif (( $hget(%t,server_maxusers) == $null ) && ($hget(%t,replied) != $null)) {
    if ($hget(%t,is_aliasquery) != $null) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),$hget(%t,is_aliasquery),:,$chr(32),$+(,$sp(82,$hget(%t,chan))),$2-,$chr(32),$sp(4,$hget(%t,chan)))
    else _msg $hget(%t,chan) $dout($hget(%t,chan),Incorrect port or invalid permissions for $+(%ip,:,%port))
  }
  elseif ($hget(%t,server_maxusers) != $null) {
    hadd %t server_currentusers $numtok($hget(%t,plist),32)
    _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),,$sp(81,$hget(%t,chan)),$replace($hget(%t,server_name),\s,$chr(32),\/,/,\\,\,\p,$chr(124)),$chr(32),$sp(8,$hget(%t,chan)),$chr(32),,$sp(81,$hget(%t,chan)),%ip,:,%port,$chr(32),$sp(8,$hget(%t,chan)),$chr(32),$sp(71,$hget(%t,chan)),$hget(%t,server_currentusers),$sp(72,$hget(%t,chan)),$hget(%t,server_maxusers),$sp(73,$hget(%t,chan)), $chr(32),$sp(4,$hget(%t,chan)))
    if ($hget(%t,plist) != $null) {
      _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Users:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$replace($hget(%t,plist),\s,$chr(32),\/,/,\\,\,\p,$chr(124)),$chr(32),$sp(4,$hget(%t,chan)))
      ;echo $hget(%t,chan) echo $+($sp(1,$hget(%t,chan)),$chr(32),$+(,$sp(81,$hget(%t,chan))),Users:,$+(,$sp(82,$hget(%t,chan))),$chr(32),$replace($hget(%t,plist),\s,$chr(32),\/,/,\\,\,\p,$chr(124)),$chr(32),$sp(4,$hget(%t,chan)))

    }
  }
  else _msg $hget(%t,chan) $dout($hget(%t,chan),$+($hget(%t,ip),:,$hget(%t,port)))
}

;//populate the hashtable with parsed data from the query
on *:sockread:ts*:{
  var %ts_id $mid($sockname,3)
  var %t = $+(tsquery,%ts_id)
  if ($sockerr > 0) return
  :nextreaddd
  sockread &temp
  if ($bfind(&temp,1,TeamSpeak)) hadd %t replied yes
  ;echo -a $bvar(&temp,$calc($bvar(&temp,0)-100),100).text
  if ($sockbr == 0) return
  var %y = virtualserver_name=
  if ($bfind(&temp,1, [ %y ] ) != 0) {
    var %1 = $bfind(&temp,1, [ %y ] )
    var %2 = $bfind(&temp,$calc(%1 + $len( [ %y ] )),virtu)
    hadd %t server_name $replace($bvar(&temp,$calc(%1 + $len( [ %y ] )),$calc(%2 - %1 -1 - $len( [ %y ] ))).text,\s,$chr(32))
  }
  %y = virtualserver_maxclients
  if ($bfind(&temp,1, [ %y ] ) != 0) {
    var %1 = $bfind(&temp,1, [ %y ] )
    var %2 = $bfind(&temp,$calc(%1 + $len( [ %y ] )),virtu)
    hadd %t server_maxusers $bvar(&temp,$calc(%1 + $len( [ %y ] )+1),$calc(%2 - %1 -1 - $len( [ %y ] ))).text
  }
  %y = virtualserver_clientsonline
  if ($bfind(&temp,1, [ %y ] ) != 0) {
    var %1 = $bfind(&temp,1, [ %y ] )
    var %2 = $bfind(&temp,$calc(%1 + $len( [ %y ] )),virtu)
    hadd %t server_currentusers $calc($bvar(&temp,$calc(%1 + $len( [ %y ] )+1),$calc(%2 - %1 -1 - $len( [ %y ] ))).text)
  }
  if ($hget(%t,server_currentusers) != $null) && ($bfind(&temp,1,nickname) != 0) {
    ;echo -a $bvar(&temp,1,500).text
    var %k = 1
    while (%k < $bvar(&temp,0)) {
      var %1 = $bfind(&temp,%k,nickname)
      var %2 = $bfind(&temp,%1,32)
      if (%2 != 0) && (%1 != 0) {
        var %nick = $+(",$bvar(&temp,$calc(%1 +9),$calc(%2 - %1 -9)).text,")
        ;echo -a $bvar(&temp,$calc(%1 +9),$calc(%2 - %1 -9))
        if ("Unknown\sfrom\s* !iswm %nick) {
          hadd %t plist $hget(%t,plist) %nick
          ;echo -a $hget(%t,plist)
        }
        %k = $calc(%2 + 1)
      }
      else %k = $bvar(&temp,0)
    }  
  }
  var %numtok = $numtok(%ts_ [ $+ [ %ts_id ] $+ plist ] ,32)
  goto nextreaddd
}

;//send query request when socket is opened
on *:sockopen:ts*:{
  if ($hget($+(tsquery,$mid($sockname,3)),port) isnum 1-65535) {
    sockwrite -n $sockname use $+(port=,$hget($+(tsquery,$mid($sockname,3)),port))
    sockwrite -n $sockname serverinfo
    sockwrite -n $sockname clientlist
  }
}
