;//core functions to the pugbot. functions responsible for maintaining the queues, starting/stopping the pug, etc.

;//add to AUTHs hashtable
RAW 354:*:{
  if ($3 != 0) hadd -m $+($network,_auths) $+(nick,$chr(7),$2) $3
  haltdef
}

;//do not perform default behaviour (messages) for these events. keeps console clean
RAW 311:*:haltdef
RAW 319:*:haltdef
RAW 312:*:haltdef
RAW 330:*:haltdef
RAW 336:*:haltdef
RAW 338:*:haltdef
RAW 318:*:haltdef
RAW 315:*:haltdef

;//add to table length of time player is idle for
RAW 317:*:{
  hadd -mu10 $+($network,_idletimes) $2 $3
  haltdef
}

;//leave all other pugs player is in once pug is filled
alias xotherpugs {
  var %chan = $1
  var %yy = 1
  while ( %yy <= $hget(0) ) {
    if ($chr(7) !isin $hget(%yy)) {
      var %z = 1
      while (%z <= $hget(%chan,0).item) {
        if ( $hfind($hget(%yy),$hget(%chan,%z).item) != $null ) && ( $hget(%yy) != %chan ) {
          var %mod = $mid($hget(%yy),$calc($pos($hget(%yy),_,$pos($hget(%yy),_,0))+1))
          var %leavechan $mid($hget(%yy),1,$calc($len($hget(%yy))-$len(%mod) -1))
          $xleave(.leave,%mod,$hget(%chan,%z).item,%leavechan)
          ;echo %cs -gn $hget(%yy)  $hget($hget(%yy),0).item (another pug started) %chan $hget(%chan,%z).item
        }
        inc %z
      }
    }
    inc %yy
  }
}

;//list all server aliases (UT or Source game server, ts server, etc.)
alias list_aliases {
  var %chan = $1
  var %servers
  var %i = 1
  while (%i <= $hget($+($network,$chr(7),servers),0).item) {
    %servers = %servers $hget($+($network,$chr(7),servers),%i).item
    inc %i
  }
  var %c = 81
  %servers = $sorttok(%servers,32)
  var %servers2
  %i = 1
  while (%i <= $numtok(%servers,32)) {
    %servers2 = %servers2  $+(,$sp(%c,%chan),$gettok(%servers,%i,32))
    if (%c == 81) %c = 82
    else %c = 81
    inc %i
  }
  _msg %chan $sp(1,%chan) %servers2 $sp(4,%chan)
}

;//list links, rules, ips, etc.
alias list_stuff {
  var %listloc = $4
  var %stuff = $3
  var %chan = $1
  var %table = $+($network,$chr(7),%listloc)
  var %txt
  var %i = 1
  while (%i <= $hfind(%table,%stuff $+ *,0,w)) {
    %txt = $+(%txt,$mid($hfind(%table,%stuff $+ *,%i,w),$calc($len($3)+1)),$chr(7))
    inc %i
  }
  %txt = $sorttok(%txt,7,n)
  if (%txt == $null ) .notice $2 $sp(1,%chan) No $3 $+ s. $sp(4,%chan)
  else {
    var %i = 1
    while (%i <= $numtok(%txt,7)) {
      .notice $2 $sp(1,%chan) $+(,$sp(81,%chan),$3,$gettok(%txt,%i,7),:) $+(,$sp(82,%chan)) $+ $ri($+($3,$gettok(%txt,%i,7)),%listloc) $sp(4,%chan) 
      inc %i
    }
  }
}

;//count number of mods in the channel
alias num_mods {
  var %mod
  var %num = 0
  var %len = $calc($len($1)+1)
  var %i = 1
  var %table = $+($network,$chr(7),$1)
  while (%i <= $hfind(%table,$1 $+ *,0,w)) {
    if ( $mid($hfind(%table,$1 $+ *,%i,w),1,%len) == $+($1,_) ) {
      %mod = $mid($hfind(%table,$1 $+ *,%i,w),$calc(%len +1))
      inc %num
    }
    inc %i
  }
  if ($prop == mod) return %mod
  else return %num
}

;//wraps the mod in different styled text if it is not a one-pug channel
alias r_mod {
  var %chan = $2
  if ($1 == pug) return
  else return $+(,$sp(81,%chan),$1,,$sp(82,%chan))
}

;//what to do once a pug has started
alias pug_start {
  var %plist = $1
  var %chan = $3
  var %setpuggers = $4
  var %p = 1
  while (%p <= $hget(%plist,0).item ) {
    ._msg $hget(%plist,%p).item $dout(%chan,The $r_mod($2,%chan) pug has been filled in %chan $+ .)
    .notice $hget(%plist,%p).item $dout(%chan,The $r_mod($2,%chan) pug has been filled in %chan $+ .)
    inc %p
  }
  if ($ri($+(pugtype_,$2),%chan) == 1) {
    .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$chr(32),The $r_mod($2,%chan) pug has been filled. Teams will now be selected at random.,$chr(32),$sp(4,%chan))
    .timer -m 1 50 randteams %chan $2 1
  }
  elseif ($ri($+(pugtype_,$2),%chan) == 2) {
    .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$chr(32),The $r_mod($2,%chan) pug has been filled. Players are:,$chr(32),$sp(4,%chan))
    .timer -m 1 50 randteams %chan $2 2
  }
  else {
    .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$chr(32),The $r_mod($2,%chan) pug has been filled. Type .captain to become a captain. Random captains in 30 seconds.,$chr(32),$sp(4,%chan))
    .timerrandcapt $+ %chan $+ 1 1 15 randcapt15msg %chan %setpuggers %plist
    .timerrandcapt $+ %chan $+ 2 1 25 randcapt5msg %chan %setpuggers %plist
    .timerrandcapt $+ %chan $+ 3 1 30 randcapt0msg %chan %setpuggers %plist
  }
  var %i = 1
  while (%i <= $hget(%plist,0).item) {
    var %p = $hget(%plist,%i).item
    var %data = $hget(%plist,%i).data
    hadd %plist %p $+(%data,$chr(7),$get_playerstats(%chan,%p).avgp)
    inc %i
  }  
}

;//what to do once a pug has finished
alias pug_finish {
  var %chan = $1
  var %mod = $2
  var %lastmsg = $mid($3,1,-1)
  var %type = $4
  var %winmsg = $calc_winner($output_teams(%chan),%chan,%mod)


  .timercaptain $+ $chan $+ * off
  .hdel -w $+(%chan,_,%mod) *
  if ($hget($+(%chan,_,%mod,_maps)) != $null) .hfree $+(%chan,_,%mod,_maps)
  .timer 1 1 _msg %chan $dout(%chan,Picking has finished. %winmsg)
  if ($ri(lastt,%chan) != $null) $wi(lasttt,$ri(lastt,%chan),%chan)
  if ($ri(last,%chan) != $null) $wi(lastt,$ri(last,%chan),%chan)
  $wi(last,%lastmsg,%chan)
  if ($ri($+(lastt_,%mod),%chan) != $null) $wi($+(lasttt_,%mod),$ri($+(lastt_,%mod),%chan),%chan)
  if ($ri($+(last_,%mod),%chan) != $null) $wi($+(lastt_,%mod),$ri($+(last_,%mod),%chan),%chan)
  $wi($+(last_,%mod),%lastmsg,%chan)
  store_playerstats %chan %mod %type $ri($+(setpuggers_,%mod),%chan)
  store_pugstats %chan %mod
}

;//a winning percentage based on historical collected statistics
alias calc_winner {
  var %teams = $1
  var %chan = $2
  var %mod = $3
  var %htable = $+(%chan,_,%mod)
  var %i = 1
  while (%i <= $numtok(%teams,7)) {
    var %tok = $gettok(%teams,%i,7)
    var %team [ $+ [ %i ] ] = $+($mid(%tok,1,$calc($pos(%tok,:,1)-2)),$chr(5))
    %tok = $mid(%tok,$calc($pos(%tok,:,1)+2))
    var %j = 1
    while (%j <= $numtok(%tok,32)) {
      ;%team [ $+ [ %i ] ] = %team [ $+ [ %i ] ] $hget(%htable,$gettok(%tok,%j,32))
      inc %j
    }
    inc %i
  }
}

;//what to do once a pug has stopped
alias pug_stop {
  var %leavechan = $1
  var %mod = $2
  var %chan = $3
  unset %players_ [ $+ [ %chan ] ]
  .timerrandcapt $+ %chan $+ * off
  .timer 1 1 .timercaptain $+ %chan $+ * off
  var %ii = 1
  while ( %ii <= $hget(%leavechan,0).item ) {
    hadd %leavechan $hget(%leavechan,%ii).item $puttok($hget(%leavechan,%ii).data,player $+ %ii,1,7)
    inc %ii
  }
}

;//what to do when a player is renamed
alias rename_player {
  var %ptable = $1
  var %nick = $2
  var %newnick = $3
  if ($mid($gettok($hget(%ptable,%nick),1,7),1,6) == player) || ($mid($gettok($hget(%ptable,%nick),1,7),1,6) == picked) {
    hadd $hget(%ptable) %newnick $hget(%ptable,%nick)
    hdel $hget(%ptable) %nick
    return found
  }
  elseif (captain* iswm $gettok($hget(%ptable,%nick),1,7)) {
    var %ii = 1
    while ( %ii <= $hfind($hget(%ptable),$+(picked,%nick,*),0,w).data ) {
      var %n = $hfind($hget(%ptable),$+(picked,%nick,*),%ii,w).data
      if ($gettok($mid($hget(%ptable,%n),$calc($len(%nick)+7)),1,7) isnum) hadd $hget(%ptable) %n $+(picked,%newnick,$mid($hget(%ptable,%n),$calc($len(%nick)+7)))
      inc %ii
    }
    hadd $hget(%ptable) %newnick $hget(%ptable,%nick)
    hdel $hget(%ptable) %nick
    return found
  }
}

;//whether a captain is set randomly or manually, this function is called to start the picking
alias set_captain {
  var %cchan = $1
  var %chan = $2
  var %nick = $3
  var %ssetpuggers = $4
  if ($hfind(%cchan,captain*,0,w).data < $numcapts(%chan) || $hfind(%cchan,captain*,0,w).data == $null) && ($mid($hget(%cchan,%nick),1,6) == player) && ( $hget(%cchan,0).item == $ri(%ssetpuggers,%chan) ) {
    hadd %cchan %nick $puttok($hget(%cchan,%nick),captain $+ $calc($hfind(%cchan,captain*,0,w).data + 1),1,7)
    var %tag = $gettok($hget(%cchan,%nick),2,7)
    if (%tag == mic) %tag =
    else %tag = $+($sp(71,%chan),%tag,$sp(73,%chan))
    .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$chr(32),,$captain_colour($hfind(%cchan,captain*,0,w).data,%chan).colour2,%nick,%tag,,$sp(82,%chan),$chr(32),is captain for the $captain_colour($hfind(%cchan,captain*,0,w).data,%chan).colour,.,$chr(32),$sp(4,%chan))
    .timer 1 0 ._msg %nick $sp(1,%chan) You are captain for the $captain_colour($hfind(%cchan,captain*,0,w).data,%chan).colour $+ . $sp(4,%chan)
    .timer 1 0 .notice %nick $sp(1,%chan) You are captain for the $captain_colour($hfind(%cchan,captain*,0,w).data,%chan).colour $+ . $sp(4,%chan)
    if ($hfind(%cchan,captain*,0,w).data == $numcapts(%chan)) {
      .timer -m 1 20 _msg %chan $+($sp(1,%chan),$chr(32),$chr(32),Captains have been picked. $+(,$sp(83),$hfind(%cchan,$+(captain1,$chr(7),*),1,w).data,,$sp(82)) picks first. Captains type .here to prevent getting kicked.,$chr(32),$sp(4,%chan))
      .timer -m 1 100 list_mod .list %chan $started_pug(%chan)
      set %players_ [ $+ [ %chan ] ] $numcapts(%chan)
      var %q = 1
      while (%q <= $hfind(%cchan,captain*,0,w).data ) {
        .timercaptain $+ %chan $+ $hfind(%cchan,captain*,%q,w).data 1 120 k_idle_captain %chan $hfind(%cchan,captain*,%q,w).data 10
        set %players_ [ $+ [ %chan ] ] %players_ [ $+ [ %chan ] ] $hfind(%cchan,captain*,%q,w).data
        inc %q
      }
    }
  }
}

;//ban an idle captain
alias k_idle_captain {
  cs atb $1 $2 $3 $+ m banned
  .timer 1 1 cs kick $1 $2 $3 $+ m ban
}

;//return the currently picked teams
alias output_teams {
  var %cchan = $+($chan,_,$started_pug($1))
  var %qi = 1
  var %team
  var %teams
  while ( %qi <= $hfind(%cchan,captain*,0,w).data ) {
    var %temp
    var %ii = 1
    while ( %ii <= $hfind(%cchan,$+(picked,$hfind(%cchan,$+(captain,%qi,$chr(7),*),1,w).data,*),0,w).data ) {
      ;echo -a $hfind(%cchan,$+(captain,%qi,$chr(7),*),1,w).data $hfind(%cchan,$+(picked,$hfind(%cchan,$+(captain,%qi,$chr(7),*),1,w).data,%ii,$chr(7),*),1,w).data
      %temp = %temp $gettok($hfind(%cchan,$+(picked,$hfind(%cchan,$+(captain,%qi,$chr(7),*),1,w).data,%ii,$chr(7),*),1,w).data,1,7)
      inc %ii
    }
    %team = $+($captain_colour(%qi,$chan).colour,: $hfind(%cchan,$+(captain,%qi,$chr(7),*),1,w).data,$chr(32),%temp)
    %teams = $+(%teams,$chr(32),%team,$chr(32),$chr(7))
    inc %qi
  }
  ;echo -a %teams
  return %teams
}

;//reorder the hash table and maintain player's position in the list
alias order_table {
  var %tmp
  var %i = 1
  while (%i <= $hget($1,0).item) {
    if ( $hget($1,%i).item ison $gettok($1,1,95) ) {
      %tmp = $+(%tmp,$hget($1,%i).data $hget($1,%i).item,$chr(8))
    }
    inc %i
  }
  %tmp = $sorttok(%tmp,8,n)
  hdel -w $1 *
  %i = 1
  while (%i <= $numtok(%tmp,8)) {
    hadd $1 $gettok($gettok(%tmp,%i,8),2,32) $+(player,%i,$chr(7),$gettok($gettok($gettok(%tmp,%i,8),1,32),2,7))
    inc %i
  }
}

;//whois all players in the queue
alias whois_players {
  var %chan = $1
  var %mod = $2
  var %htable = $+($1,_,$2)
  var %i = 1
  while (%i <= $hget(%htable,0).item) {
    whois $hget(%htable,%i).item $hget(%htable,%i).item
    inc %i
  }
  if ($3 == remove_idle) {
    if (($hget(%htable,0).item == $null) || ($hget(%htable,0).item == 0) || ($ri(pugbot,%chan) == 0)) .timer $+ playeridle $+ %chan $+ $2 off
    else .timer 1 1 idle_player_remove $1 $2
  }
}

;//remove idle player from all queues
alias idle_player_remove {
  var %chan = $1
  var %mod = $2
  var %htable = $+($1,_,$2)
  var %i = 1
  while (%i <= $hget(%htable,0).item) {
    if ($hget($+($network,_idletimes),$hget(%htable,%i).item) >= 7200 ) {
      _msg $hget(%htable,%i).item $sp(1,%chan) You are idle and being removed from the %mod mod on %chan $+ . $sp(4,%chan)
      $xleave(.leave,%mod,$hget(%htable,%i).item,%chan)
    }
    inc %i
  }
}

;//create completely random teams
alias randteams {
  var %chan = $1
  var %mod = $2
  var %type = $3
  var %setpuggers = $ri($+(setpuggers_,%mod),%chan)
  var %numcapts = $numcapts(%chan)
  if ($3 == 2) %numcapts = 1
  var %team1
  var %team2
  var %team3
  var %team4
  var %c = $sp(81)
  var %i = 1
  while (%i <= %numcapts) {
    var %player = $hget($+(%chan,_,%mod),$rand(1,$hget($+(%chan,_,%mod),0).item)).item
    if (%numcapts == 1) {
      %team [ $+ [ %i ] ] = $+(,%c,%player)
      %c = $sp(82)
    }
    else %team [ $+ [ %i ] ] = $captain_colour(%i,%chan).colour $+ : %player
    hdel $+(%chan,_,%mod) %player
    inc %i
  }
  while ( $hget($+(%chan,_,%mod),0).item > 0 ) {
    if ( $hget($+(%chan,_,%mod),0).item > 0 ) && (%team1 != $null) {
      var %player = $hget($+(%chan,_,%mod),$rand(1,$hget($+(%chan,_,%mod),0).item)).item
      if (%numcapts == 1) {
        %team1 = %team1 $+(,%c,%player)
        if (%c == $sp(81)) %c = $sp(82)
        else %c = $sp(81)
      }
      else %team1 = %team1 %player
      hdel $+(%chan,_,%mod) %player
    }
    if ( $hget($+(%chan,_,%mod),0).item > 0 ) && (%team2 != $null) {
      var %player = $hget($+(%chan,_,%mod),$rand(1,$hget($+(%chan,_,%mod),0).item)).item
      %team2 = %team2 %player
      hdel $+(%chan,_,%mod) %player
    }
    if ( $hget($+(%chan,_,%mod),0).item > 0 ) && (%team3 != $null) {
      var %player = $hget($+(%chan,_,%mod),$rand(1,$hget($+(%chan,_,%mod),0).item)).item
      %team3 = %team3 %player
      hdel $+(%chan,_,%mod) %player
    }
    if ( $hget($+(%chan,_,%mod),0).item > 0 ) && (%team4 != $null) {
      var %player = $hget($+(%chan,_,%mod),$rand(1,$hget($+(%chan,_,%mod),0).item)).item
      %team4 = %team4 %player
      hdel $+(%chan,_,%mod) %player
    }
  }
  var %lastmsg = $+($ri($+(%chan,_,%mod),%chan),$chr(7),$ctime,$chr(7),)
  %i = 1
  while (%i <= %numcapts) {
    _msg %chan $sp(1,%chan) %team [ $+ [ %i ] ] $sp(4,%chan)
    if (%i < %numcapts ) %lastmsg = $+(%lastmsg,%team [ $+ [ %i ] ] ,$chr(7))
    else %lastmsg = $+(%lastmsg,%team [ $+ [ %i ] ] )
    inc %i
  }
  set %players_ [ $+ [ %chan ] ] %numcapts $gettok(%team1,3-,32) $gettok(%team2,3-,32) $gettok(%team3,3-,32) $gettok(%team4,3-,32)
  ;echo -a %players_ [ $+ [ %chan ] ]
  $pug_finish(%chan,%mod,$ui(%lastmsg),1)
}

;//responds with the currently started pug if one is started. otherwise returns $null
alias started_pug {
  var %i = 1
  while (%i <= $hget(0)) {
    var %setpuggers
    if ( $1 == $mid($hget(%i),1,$len($1)) ) {
      if ($chr(95) !isin $hget(%i)) set %setpuggers setpuggers
      else {
        var %pos $pos($hget(%i),_,$pos($hget(%i),_,0))
        var %pchan $mid($hget(%i),1,$calc(%pos -1))
        set %setpuggers $+(setpuggers_,$mid($hget(%i),$calc(%pos +1)))
      }
      if ($hget(%i,0).item == $ri(%setpuggers,%pchan)) return $mid($hget(%i),$calc(%pos +1))
    }
    inc %i
  }
}

;//the functions executed 15, 5 and 0 seconds before picking is about to start (if captains already haven't been picked)
alias randcapt15msg {
  var %setpuggers = $2
  if ( $hfind($3,captain*,0,w).data < $numcapts($1) ) && ($hget($3,0).item == $ri(%setpuggers,$1)) randcaptswarning $1 15 $3
}
alias randcapt5msg {
  var %setpuggers = $2
  if (($hfind($3,captain*,0,w).data < $numcapts($1)) && ($hget($3,0).item == $ri(%setpuggers,$1))) randcaptswarning $1 5 $3
}
alias randcapt0msg {
  var %setpuggers = $2
  if (($hfind($3,captain*,0,w).data < $numcapts($1)) && ($hget($3,0).item == $ri(%setpuggers,$1))) randcapts $1 $2 $3
}
alias randcaptswarning {
  if ( $hfind($3,captain*,0,w).data < $numcapts($1) ) {
    _msg $1 $+($sp(1,$1),$chr(32),$chr(32),Random captains in $2 seconds.,$chr(32),$sp(4,$1))
  }
}

;//set random captains. the first captain is random, the second one is one player to the left or right of the sorted list of player skills
alias randcapts {
  var %setpuggers = $2
  var %names
  var %i = 1
  while (%i <= $hget($3,0).item) {
    var %p = $hget($3,%i).item
    var %data = $hget($3,%i).data
    %names = $+(%names,$chr(32),$gettok(%data,3,7),$chr(7),%p)
    inc %i
  }
  %names = $sorttok(%names,32,nr)
  var %q = 1
  while ( %q <= $numcapts($1) ) {
    ;echo -s %q $hfind($3,$+(captain,%q,$chr(7),*),1,w).data %names
    if ( $hfind($3,$+(captain,%q,$chr(7),*),1,w).data == $null ) {
      var %captnick
      if (%q > 1) {
        var %prevcapt = $hfind($3,$+(captain,$calc(%q -1),$chr(7),*),1,w).data
        var %j = 1
        while (%j <= $numtok(%names,32)) {
          if ( $gettok($gettok(%names,%j,32),2,7) == %prevcapt ) {
            if (%j == 1) %captnick = $gettok($gettok(%names,$calc(%j +1),32),2,7)
            elseif (%j == $numtok(%names,32)) %captnick = $gettok($gettok(%names,$calc(%j -1),32),2,7)
            else {
              var %r = $rand(0,1)
              if (%r == 0) %captnick = $gettok($gettok(%names,$calc(%j -1),32),2,7)
              else %captnick = $gettok($gettok(%names,$calc(%j +1),32),2,7)
            }
            break
          }
          inc %j
        }
      }
      else {
        var %captnum = $rand(1,$calc($ri(%setpuggers,$1) - $hfind($3,captain*,0,w).data))
        %captnick = $hfind($3,player*,%captnum,w).data
      }
      set_captain $3 $1 %captnick %setpuggers
    }
    else {
      var %i = 1
      while (%i < %q) {
        if ($gettok($gettok(%names,%i,32),2,7) == $hfind($3,$+(captain,$calc(%q -1),$chr(7),*),1,w).data ) {
          %names = $remtok(%names,$gettok(%names,%i,32),32)
          break
        }
        inc %i
      }
    }
    inc %q
  }
}

;//list the players in the mod. if no mod specified, lists all the mods with the active_mods function
alias list_mod {
  var %chan = $2
  var %last = last
  var %setpuggers = setpuggers
  var %mod
  if ($3 != $null) {
    set %mod $+(%chan,_,$3)
    set %last $+(last_,$3)
    set %setpuggers $+(setpuggers_,$3)
    if ($ri(%setpuggers) != $null) {
      var %tempp
      var %i = 1
      while ( %i <= $hfind(%mod,player*,0,w).data ) {
        var %readtag = $gettok($hget(%mod,$hfind(%mod,player*,%i,w).data),2,7)
        var %tag
        if (%readtag != mic) %tag = $+($sp(71,%chan),%readtag,$sp(73,%chan))
        %tempp = $+(%tempp,$gettok($mid($hget(%mod,$hfind(%mod,player*,%i,w).data),7),1,7),$sp(10,%chan),$chr(32),$hfind(%mod,player*,%i,w).data,$+(,$sp(81,%chan)),%tag,$chr(7))
        ;echo -a %tempp
        inc %i
      }
      if ($hget($+(%chan,_,$3),0).item == 0) .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$ui2($ri(%mod)),$chr(32),$sp(8,%chan),$chr(32),$sp(71,%chan),$hget(%mod,0).item,$sp(72,%chan),$ri(%setpuggers),$sp(73,%chan),$chr(32),$sp(4,%chan),$replace($sorttok(%tempp,7,n),$chr(7),))
      else .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$ui2($ri(%mod)),$chr(32),$sp(8,%chan),$chr(32),$sp(71,%chan),$hget(%mod,0).item,$sp(72,%chan),$ri(%setpuggers),$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),,$sp(81,%chan), $replace($sorttok(%tempp,7,n),$chr(7),$chr(32)),$chr(32),$sp(4,%chan))
    }
  }
  else {
    _msg %chan $active_mods
  }
  if (liast* iswm $cp($1)) || (lia == $cp($1)) {
    if ($ri(%last)) {
      var %x = 3
      var %lastmsg = $sp(8,%chan)
      while (%x <= $numtok($ri(%last),7)) {
        set %lastmsg %lastmsg $gettok($ri(%last),%x,7) $sp(8,%chan)
        inc %x
      }
      .timer -m 1 50 _msg %chan $sp(1,%chan) $+($sp(71),$gettok($ri(%last),1,7),$sp(73,%chan)) $ui2(%lastmsg) $duration($calc($ctime - $gettok($ri(%last),2,7))) ago $sp(4,%chan)

    }
  }
}

;//lists all mods sorted from highest to lowest filled
alias active_mods {
  var %chan = $chan
  var %table = $+($network,$chr(7),$chan)
  var %i = 1
  var %txt
  var %len = $calc($len($chan)+2)
  while (%i <= $hfind(%table,$chan $+ *,0,w)) {
    var %mod = $+(_,$mid($hfind(%table,$chan $+ *,%i,w),$calc($len($chan)+2)))
    if ( $chan != $hfind(%table,$chan $+ *,%i,w) ) {
      if (%i == $hfind(%table,$chan $+ *,0,w) ) %txt = $+(%txt,$hget($+($chan,%mod),0).item,$chr(6),$chr(32),$mid($hfind(%table,$chan $+ *,%i,w),%len),$chr(32),$sp(71,%chan),$hget($+($chan,%mod),0).item,$sp(72,%chan),$ri($+(setpuggers,%mod)),$sp(73,%chan),$chr(32),$chr(7))
      else %txt = $+(%txt,$hget($+($chan,%mod),0).item,$chr(6),$chr(32),$mid($hfind(%table,$chan $+ *,%i,w),%len),$chr(32),$sp(71,%chan),$hget($+($chan,%mod),0).item,$sp(72,%chan),$ri($+(setpuggers,%mod)),$sp(73,%chan),$chr(32),$chr(7))
    }
    inc %i
  }
  %txt = $sorttok(%txt,7,nr)
  if (%txt == $null ) return $dout(%chan,No mods. Use .addmod <mod> <tag>)
  else {
    var %txt2
    var %i = 1
    while (%i <= $numtok(%txt,7)) {
      if (%i == $numtok(%txt,7)) %txt2 = $+(%txt2,$gettok($gettok(%txt,%i,7),2,6))
      else %txt2 = $+(%txt2,$gettok($gettok(%txt,%i,7),2,6),$sp(8,%chan))
      inc %i
    }
    return $sp(1,%chan) %txt2 $sp(4,%chan)
  }
}

;//returns colour-coded team name
alias captain_colour {
  if ($prop == colour) {
    if ($1 == 1) return $+(,$sp(83),Red Team)
    elseif ($1 == 2) return $+(,$sp(84),Blue Team)
    elseif ($1 == 3) return $+(,$sp(85),Green Team)
    elseif ($1 == 4) return $+(,$sp(86),Gold Team)
    elseif ($1 == 5) return 7Orange Team
    elseif ($1 == 6) return 13Magenta Team
    elseif ($1 == 7) return 5Maroon Team
    elseif ($1 == 8) return 14Grey Team
  }
  elseif ($prop == colour2) {
    if ($1 == 1) return $sp(83)
    elseif ($1 == 2) return $sp(84)
    elseif ($1 == 3) return $sp(85)
    elseif ($1 == 4) return $sp(86)
    elseif ($1 == 5) return 7
    elseif ($1 == 6) return 13
    elseif ($1 == 7) return 5
    elseif ($1 == 8) return 14
  }
}

;//returns number of captains in specified mod, or the currently started mod if one has started
alias numcapts {
  if ( $started_pug($1) == $null ) {
    if ( $ri(numcapts,$1) > 2 ) return $ri(numcapts,$1)
    else return 2
  }
  else {
    if ( $ri($+(numcapts_,$started_pug($1)),$1) > 2 ) return $ri($+(numcapts_,$started_pug($1)),$1)
    else return 2
  }
}

;//returns which captain gets to pick next. if a pickorder is specified in the ini then that will be used, otherwise default pickorder from function $return_pickturn will be used
alias captain_turn {
  var %chan = $1
  var %mod = $started_pug(%chan)
  var %ptable = $+(%chan,_,%mod)
  var %numplayers = $hfind(%ptable,picked*,0,w).data
  var %numcapts = $numcapts(%chan)
  if ( $ri( $+(pickorder_,%mod) ,%chan ) != $null ) return $gettok($ri($+(pickorder,$ri($+(pickorder_,%mod))),global),$calc(%numplayers +1),44)
  else {
    return $return_pickturn(%numplayers,%numcapts)
  }
}

;//default pickorder algorithm, 1 then 2, 2 then 1, 1 then 2 etc.
alias return_pickturn {
  var %numplayers = $1
  var %numcapts = $2
  var %num = $calc(%numplayers % %numcapts) 
  var %dir = $calc($mid($calc(%numplayers / %numcapts),1,1) % 2)
  if (%dir == 0) return $calc(%num +1)
  else return $calc(%numcapts +((%numcapts - %numplayers) % %numcapts))

}
;//add some players for testing
alias temppp {
  hadd -m $+($chan,_pug) t1 $+(player1,$chr(7),mic)
  hadd -m $+($chan,_pug) t2 $+(player2,$chr(7),mic)
  ;hadd -m $+($chan,_pug) t3 $+(player3,$chr(7),mic)
  ;hadd -m $+($chan,_pug) t4 $+(player4,$chr(7),mic)
  ;hadd -m $+($chan,_pug) t5 $+(player5,$chr(7),mic)
  ;hadd -m $+($chan,_pug) t6 $+(player6,$chr(7),mic)
  ;hadd -m $+($chan,_pug) t7 $+(player7,$chr(7),mic)
}
