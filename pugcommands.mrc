;//all pug commands are found here. help, admin, and normal user commands and some of their supporting functions


;//turn pugbot on/off
alias toggleonoff {
  if (pugbot == $cp($2)) && ($1 isop $chan || $isAdmin($1) == yes) {
    if ($3 == on) && ( $ri(pugbot) == 0 ) {
      if ($ri(captain) == $null) { wi captain 0 }
      if ($ri(setpuggers) == $null) { wi setpuggers 10 }
      wi pugbot 1
      .timer 1 0 _msg $chan $+($sp(1),$chr(32),$chr(32),Pugbot on.,$chr(32),$sp(4)) 
    }
    elseif ($3 == off) && ( $ri(pugbot) == 1 ) {
      wi pugbot 0
      .timerrandcapt $+ $chan $+ * off
      .timercaptain $+ $chan $+ * off
      .timerplayeridle $+ $chan $+ * off
      hfree -w $+($chan,_*)
      .timer 1 0 _msg $chan $+($sp(1),$chr(32),Pugbot off.,$chr(32),$sp(4))
    }
  }
}

;//list of all commands and their usage
alias helpcommands {
  var %chan = $chan
  if ( (help == $cp($1)) || (commands == $cp($1)) || (admincommands == $cp($1)) ) {
    .timer 1 0 _msg %chan $sp(1) http://www.globalunreal.com/sbot/ $sp(4)
  }
}

;//only OPs or global admins can use these commands
alias admincommands {
  if (($1 isop $chan) || ($isadmin($1) == yes)) {
    var %mod = $started_pug($chan)
    if (reset == $cp($2)) {
      if ($ri($+($chan,_,%mod)) != $null) && ($hget($+($chan,_,%mod),0).item == $ri($+(setpuggers_,%mod))) {
        .timer 1 0 _msg $chan $dout($chan,Pug has been reset. Type .captain to become a captain. Random captains in 30 seconds.)
        $pug_stop($+($chan,_,$started_pug($chan)),%mod,$chan)
        .timerrandcapt $+ $chan $+ 1 1 15 randcapt15msg $chan $+(setpuggers_,%mod) $+($chan,_,%mod)
        .timerrandcapt $+ $chan $+ 2 1 25 randcapt5msg $chan $+(setpuggers_,%mod) $+($chan,_,%mod)
        .timerrandcapt $+ $chan $+ 3 1 30 randcapt0msg $chan $+(setpuggers_,%mod) $+($chan,_,%mod)
        if ($hget($+($chan,_,%mod,_maps)) != $null) .hfree $+($chan,_,%mod,_maps)
      }
    }
    elseif (spamip* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == spamip) %tmp = .spamip1
      var %s = 1
      while (%s <= 5) {
        $t_queries(. $+ $mid(%tmp,6),2,3)
        inc %s
      }
    }
    elseif (superspamip* iswm $cp($2)) && ($address($1,2) == *!*@spydee.user.globalgamers.net) {
      var %tmp = $2
      if ($cp($2) == superspamip) %tmp = .superspamip1
      var %s = 1
      while (%s <= 12) {
        $t_queries(. $+ $mid(%tmp,6),2,3)
        inc %s
      }
    }
    elseif (spamts* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == spamts) %tmp = .spamts1
	  
	  var %s = 1
      while (%s <= 5) {
        _msg $chan $dout($chan,$ri($mid(%tmp,6)))
        inc %s
      }
    }
    elseif (addplayer == $cp($2)) && ($3 != $null) && ($4 != $null) {
      if ($4 ison $chan) {
        if ( $hget($+($chan,_,$3),$4) == $null ) {
          $xjoin(.join,$3,$4,adminadded)
          .timer 1 0 _msg $chan $dout($chan,Player $r_mod($4,$chan) added to the $r_mod($3,$chan) pug.)
        }
        else _msg $chan $dout($chan,Player $r_mod($4,$chan) already in the $r_mod($3,$chan) pug.)
      }
      else _msg $chan $dout($chan,Player $r_mod($4,$chan) not on channel.)
    }
    elseif (delplayer == $cp($2)) && ($3 != $null) && ($4 != $null) {
      if ( $hget($+($chan,_,$3),$4) != $null ) {
        $xleave(.leave,$3,$4,$chan)
        .timer 1 0 _msg $chan $dout($chan,Player $r_mod($4,$chan) removed from the $r_mod($3,$chan) pug.)
      }
      else _msg $chan $dout($chan,Player $r_mod($4,$chan) not in the $r_mod($3,$chan) pug.)
    }
    elseif ((renameplayer == $cp($2)) || (rename == $cp($2))) && ($3 != $null) && ($4 != $null) {
      if ($4 ison $chan) {
        var %found
        var %i = 1
        while (%i <= $hget(0)) {
          if ($chr(7) !isin $hget(%i)) && ($chan isin $hget(%i)) {
            var %f = $rename_player($hget(%i),$3,$4)
            if (%f == found) %found = found
          }
          inc %i
        }
        if (%found == found) _msg $chan $dout($chan,Player $r_mod($3,$chan) renamed to $r_mod($4,$chan) for all mods.)
        else _msg $chan $dout($chan,Player $r_mod($3,$chan) not found in any mods.)
      }
      else _msg $chan $dout($chan,Player $r_mod($4,$chan) not found on channel.)
    }
    elseif (setlimit == $cp($2)) && ($4 != $null) && ($ri($+($chan,_,$3) ) != $null) {
      if ($4 >= 2) && ( $4 >= $hget($+($chan,_,$3),0).item ) {
        .timer 1 0 _msg $chan $+($sp(1),$chr(32),$chr(32),Player limit set to $r_mod($4,$chan) for the $r_mod($3,$chan) pug.,$chr(32),$sp(4))
        if ($hget($+($chan,_,$3),0).item == $ri(setpuggers $+ [ _ $+ [ $3 ] ] )) {
          .timer 1 0 _msg $chan $sp(1) The $r_mod($3,$chan) pug has been stopped. $sp(4)
          $pug_stop($+($chan,_,$3),$3,$chan)
        }
        wi $+(setpuggers,_,$3) $4
        if ($hget($+($chan,_,$3),0).item == $ri(setpuggers $+ [ _ $+ [ $3 ] ] ) ) $pug_start($+($chan,_,$3),$3,$chan,$+(setpuggers,_,$3))
        if ($4 isnum 2-3) $wi($+(pugtype_,$3),2)
      }
      else .timer 1 0 _msg $chan $+($sp(1),$chr(32),$chr(32),Invalid value.,$chr(32),$sp(4))
    }
    elseif (setcaptain == $cp($2)) && ($ri($+($chan,_,%mod)) != $null) {
      $set_captain($+($chan,_,%mod),$chan,$3,$+(setpuggers_,%mod))
    }
    elseif (setalias == $cp($2)) && ($3 != $null) && ($4 != $null) {
      if ($3 isalnum) && (ip* !iswm $3) {
        $wi($3,$4,servers)
        .timer 1 0 _msg $chan $dout($chan,Alias $r_mod($3,$chan) set to $r_mod($4,$chan) $+ .)
      }
      else .timer 1 0 _msg $chan $dout($chan,Use an alphanumeric alias.)
    }
    elseif (delalias == $cp($2)) && ($3 != $null) {
      $dli($3,servers)
      .timer 1 0 _msg $chan $dout($chan,Alias $r_mod($3,$chan) deleted.)
    }
    elseif (fullreset == $cp($2)) && ($3 != $null) {
      var %3
      if (%mod != $null) %3 = %mod
      else %3 = $3
      if ($ri($+($chan,_,%3)) != $null) {
        .timer 1 0 _msg $chan $dout($chan,The $r_mod(%3,$chan) pug has been reset (players removed).)
        .timerrandcapt $+ $chan $+ * off
        .timercaptain $+ $chan $+ * off
        .timerplayeridle $+ $chan $+ * off
        if ($hget($+($chan,_,$strip(%3))) != $null) hdel -w $+($chan,_,$strip(%3)) *
        unset %players_ [ $+ [ $chan ] ]
        if ($hget($+($chan,_,%mod,_maps)) != $null) .hfree $+($chan,_,%mod,_maps)
      }
    }
    elseif (setvoicepug == $cp($2)) && ($3 != $null) && ($4 isnum 0-1) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(voiceonly,_,$3),$4)
        if ($4 == 1) .timer 1 0 _msg $chan $dout($chan,Players will need voice for the $r_mod($3,$chan) pug.)
        elseif ($4 == 0) .timer 1 0 _msg $chan $dout($chan,Players will not need voice for the $r_mod($3,$chan) pug.)
      }
    }
    elseif (setassaultpug == $cp($2)) && ($3 != $null) && ($4 isnum 0-1) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(assaultpug,_,$3),$4)
        $wi($+(serverFF,_,$3),0)
        if ($4 == 1) .timer 1 0 _msg $chan $dout($chan,Assault pug enabled for the $r_mod($3,$chan) pug.)
        elseif ($4 == 0) .timer 1 0 _msg $chan $dout($chan,Assault pug disabled for the $r_mod($3,$chan) pug.)
        if ($ri($+(nummaps,_,$3)) == $null) $wi($+(nummaps,_,$3),7)
      }
    }
    elseif (setnummaps == $cp($2)) && ($3 != $null) && ($4 isnum) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(nummaps,_,$3),$4)
        .timer 1 0 _msg $chan $dout($chan,Number of maps for the $r_mod($3,$chan) pug set to $r_mod($4,$chan) $+ .)
      }
    }
    elseif (setFF == $cp($2)) && ($3 != $null) && ($4 isnum 0-1) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(serverFF,_,$3),$4)
        if ($4 == 1) .timer 1 0 _msg $chan $dout($chan,Friendly fire enabled for the $r_mod($3,$chan) pug.)
        elseif ($4 == 0) .timer 1 0 _msg $chan $dout($chan,Friendly fire disabled for the $r_mod($3,$chan) pug.)
      }
    }
    elseif (setIG == $cp($2)) && ($3 != $null) && ($4 isnum 0-1) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(serverIG,_,$3),$4)
        if ($4 == 1) .timer 1 0 _msg $chan $dout($chan,Instagib enabled for the $r_mod($3,$chan) pug.)
        elseif ($4 == 0) .timer 1 0 _msg $chan $dout($chan,Instagib disabled for the $r_mod($3,$chan) pug.)
      }
    }
    elseif (setSA == $cp($2)) && ($3 != $null) && ($4 isnum 0-1) {
      if ($ri($+($chan,_,$3)) != $null) {
        $wi($+(serverSA,_,$3),$4)
        if ($4 == 1) .timer 1 0 _msg $chan $dout($chan,Sniper Arena enabled for the $r_mod($3,$chan) pug.)
        elseif ($4 == 0) .timer 1 0 _msg $chan $dout($chan,Sniper Arena disabled for the $r_mod($3,$chan) pug.)
      }
    }
    elseif (sethybridpug == $cp($2)) && ($3 isnum 0-1) {
      if ($3 == 0) {
        .timer 1 0 _msg $chan $dout($chan,Hybrid pug disabled. Players must specify a mod for all commands.)
        $wi(hybridpug,$3)
      }
      elseif ($3 == 1) {
        if ($ri($+($chan,_,$4)) != $null) {
          .timer 1 0 _msg $chan $dout($chan,Commands without the mod given now default to the $r_mod($4,$chan) mod.)
          $wi(hybridpug,$+($3,$chr(7),$4))
        }
        else _msg $chan $dout($chan,Invalid paramaters. Usage is .sethybridpug 1 <mod>.)
      }
    }
    elseif (setstats == $cp($2)) && ($3 != $null) {
      $wi(stats,$3-)
      .timer 1 0 _msg $chan $dout($chan,Stats link set.)
    }
    elseif (setmaps == $cp($2)) && ($3 != $null) {
      $wi(maps,$3-)
      .timer 1 0 _msg $chan $dout($chan,Maps set to $r_mod($3,$chan) $+ .)
    }
    elseif (setstream == $cp($2)) && ($3 != $null) {
      $wi(stream,$3-)
      .timer 1 0 _msg $chan $dout($chan,Stream link set to $r_mod($3,$chan) $+ .)
    }
    elseif (setip* iswm $cp($2)) && ($3 != $null) {
      var %tmp = $2
      if ($cp($2) == setip) %tmp = .setip1
      $wi($mid(%tmp,5),$3-)
      .timer 1 0 _msg $chan $dout($chan,$r_mod($mid(%tmp,5),$chan) set.)
    }
    elseif (delip* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == delip) %tmp = .delip1
      if ($ri($mid($2,5))) .timer 1 0 _msg $chan $dout($chan,$r_mod($mid(%tmp,5),$chan) deleted.)
      else _msg $chan $dout($chan,$mid(%tmp,5) does not exist.)
      $dli($mid(%tmp,5))
    }
    elseif (setts* iswm $cp($2)) && ($3 != $null) {
      var %tmp = $2
      if ($cp($2) == setts) %tmp = .setts1
      $wi($mid(%tmp,5),$3-)
      .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) set to $3-)
    }
    elseif (delts* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == delts) %tmp = .delts1
      if ($ri($mid($2,5))) .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) deleted.)
      else _msg $chan $dout($chan,$mid(%tmp,5) does not exist.)
      $dli($mid(%tmp,5))
    }
    elseif (setlink* iswm $cp($2)) && ($3 != $null) {
      var %tmp = $2
      if ($cp($2) == setlink) %tmp = .setlink1
      $wi($mid(%tmp,5),$3-)
      .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) set.)
    }
    elseif (dellink* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == dellink) %tmp = .dellink1
      if ($ri($mid($2,5)) != $null) .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) deleted.)
      else _msg $chan $dout($chan,$mid(%tmp,5) does not exist.)
      $dli($mid(%tmp,5))
    }
    elseif (setrule* iswm $cp($2)) && ($3 != $null) {
      var %tmp = $2
      if ($cp($2) == setrule) %tmp = .setrule1
      $wi($mid(%tmp,5),$3-)
      .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) set.)
    }
    elseif (delrule* iswm $cp($2)) {
      var %tmp = $2
      if ($cp($2) == delrule) %tmp = .delrule1
      if ($ri($mid($2,5))) .timer 1 0 _msg $chan $dout($chan,$mid(%tmp,5) deleted.)
      else _msg $chan $dout($chan,$mid(%tmp,5) does not exist.)
      $dli($mid(%tmp,5))
    }
    elseif (addmod == $cp($2)) && ($3 != $null) && ($4 != $null) {
      if ($3 == 0) || ($chr(91) isin $3) || ($chr(93) isin $3) {
        _msg $chan $dout($chan,Invalid modname.)
      }
      elseif ($chr(35) !isin $2-) && ($chr(124) !isin $2-) {
        if ($ri($+($chan,_,$gettok($2-,2,32))) == $null) {
          wi $+(setpuggers_,$gettok($2-,2,32)) 10
          wi $+($chan,_,$gettok($2-,2,32)) $ui($gettok($2-,3-,32))
          _msg $chan $dout($chan,Mod $r_mod($gettok($2-,2,32),$chan) added with tag $r_mod($gettok($2-,3-,32),$chan) $+ .)
        }
        else _msg $chan $dout($chan,Mod $r_mod($3,$chan) already exists.)
      }
      else _msg $chan $dout($chan,$chr(35) and $chr(124) not allowed in modname.)
    }
    elseif (delmod == $cp($2)) && ($ri($+($chan,_,$3)) != $null) {
      var %i = 1
      var %chantable = $+($network,$chr(7),$chan)
      while (%i <= $hget(%chantable,0).item) {
        var %numtok = $numtok($hget(%chantable,%i).item,95)
        if (%numtok > 1) && ($gettok($hget(%chantable,%i).item,%numtok,95) == $3 ) dli $hget(%chantable,%i).item
        else inc %i
      }
      _msg $chan $dout($chan,Mod $r_mod($3,$chan) deleted.)
    }
    elseif (settag == $cp($2)) && ($ri($+($chan,_,$3)) != $null) && ($4 != $null) {
      wi $+($chan,_,$3) $ui($4-)
      .timer 1 0 _msg $chan $dout($chan,Tag changed to $r_mod($ui($4-),$chan) $+ .)
    }
    elseif (settheme == $cp($2)) {
      var %i = 1
      var %s = $+($network,$chr(7),theme.,$3)
      while (%i <= $hget(0)) {
        if (%s == $hget(%i)) {
          wi theme $3
          _msg $chan $sp(1) Theme set to: $+ $sp(81) $3 $sp(4)
          break
        }
        inc %i
      }
      if (%i > $hget(0)) _msg $chan $sp(1) Theme not found. Use .themes for a list of themes. $sp(4)
    }
    elseif (setpickorder == $cp($2)) && ($ri($+($chan,_,$3)) != $null) && ($ri($+(pickorder,$4),global) != $null) {
      wi $+(pickorder,_,$3) $4
      _msg $chan $dout($chan,Pickorder set to $ri($+(pickorder,$4),global) $+ . )
    }
    elseif (setnumteams == $cp($2)) && ($ri($+($chan,_,$3)) != $null) && ($4 >= 2) {
      wi $+(numcapts,_,$3) $4
      _msg $chan $dout($chan,Numteams changed to $4 for $3 $+ .)
    }
    elseif (setpugtype == $cp($2)) && ($ri($+($chan,_,$3)) != $null) && ($4 != $null) {
      if ($4 isnum 0-2) wi $+(pugtype,_,$3) $4
      if ($4 == 2) _msg $chan $dout($chan,Deathmatch gametype set for the $r_mod($3,$chan) pug.)
      if ($4 == 1) _msg $chan $dout($chan,Teams will be now be selected at random for the $r_mod($3,$chan) pug.)
      if ($4 == 0) _msg $chan $dout($chan,Teams will be picked manually for the $r_mod($3,$chan) pug.)
    }
    /*currently takes too much time, will need to put stats in hashtables or something...
    elseif (findstats == $cp($2) && $3 != $null) {
      var %names
      var %c = 82
      var %i = 1
      while (%i <= $ini($+($network,_,stats.ini),0)) {
        var %len = $calc($len($+($chan,.,playerstats))+2)
        var %line = $mid($ini($+($network,_,stats.ini),%i),%len)
        if ($+(*,$3,*) iswm %line ) {
          %names = %names $+(,$sp(%c,$chan),%line)
          if (%c == 81) %c = 82
          else %c = 81
          if ($numtok(%names,32) == 5) break
        }
        inc %i
      }
      _msg $chan $sp(1,$chan) Players matching $+(,$sp(81,$chan),*,$3,*:,$chr(32),$sp(8,$chan)) %names $sp(4,$chan)
    }
    */
  }
}

;//commands anyone can use
alias xpugbot {
  var %last = last
  var %setpuggers = setpuggers
  var %mod = $chan
  if ($2 != $null) && ($3 != $null) {
    set %mod $+($chan,_,$2)
    set %last $+(last_,$2)
    set %setpuggers $+(setpuggers_,$2)
  }
  if ($started_pug($chan) == $null) {
    var %cchan $chan
    var %ssetpuggers setpuggers
  }
  else {
    var %cchan $+($chan,_,$started_pug($chan))
    var %ssetpuggers $+(setpuggers_,$started_pug($chan))
  }
  if (liast == $cp($1)) || (lia == $cp($1)) || (list == $cp($1)) || (ls == $cp($1)) {
    if ( $hget(%cchan,0).item == $ri(%ssetpuggers) ) {
      $list_mod($1,$chan,$started_pug($chan))
    }
    else $list_mod($1,$chan,$2)
  }
  elseif (last* iswm $cp($1) || la == $cp($1)) {
    var %lmsg = $cp($1)
    if (%lmsg == lastlast) %lmsg = lastt
    elseif (%lmsg == lastlastlast) %lmsg = lasttt
    if ($2 != $null) %lmsg = $+(%lmsg,_,$2)
    if ($ri(%lmsg)) {
      var %x = 3
      var %lastmsg $sp(8)
      while (%x <= $numtok($ri(%lmsg),7)) {
        set %lastmsg %lastmsg $gettok($ri(%lmsg),%x,7) $sp(8)
        inc %x
      }
      .timer -m 1 50 _msg $chan $sp(1) $+($sp(71),$ui2($gettok($ri(%lmsg),1,7)),$sp(73)) $ui2(%lastmsg) $duration($calc($ctime - $gettok($ri(%lmsg),2,7))) ago $sp(4)
    }
    elseif ($ri($cp($1))) _msg $chan $dout($chan,No pugs yet).
  }
  elseif ((promote == $cp($1)) || (p == $cp($1))) && (($timer($+(promote,$chan)) == $null) || ($nick isop $chan)) && ($ri($+(setpuggers,_,$2)) != $null) && ( $ri($+(setpuggers,_,$2)) != $hget($+($chan,_,$2),0).item ) {
    .timer 1 0 .notice $chan $sp(1) Only $r_mod($calc($ri($+(setpuggers,_,$2),$chan) - $hget($+($chan,_,$2),0).item),$chan) more needed for the $r_mod($2,$chan) pug! $sp(4)
    .timer $+ promote $+ $chan 1 60 return
  }
  elseif (stats == $cp($1) && $2 == $null) {
    if ($ri(stats) != $null) _msg $chan $dout($chan,$r_mod($cp($1),$chan) $+ : $ri(stats))
  }
  elseif (nummaps == $cp($1) && $2 != $null) {
    if ($ri($+(nummaps,_,$2)) != $null) _msg $chan $dout($chan,Number of maps for the $r_mod($2) pug $+ : $ri($+(nummaps,_,$2)))
  }
  elseif (map == $cp($1) && $2 != $null) && ($hfind(%cchan,captain*,0,w).data == $numcapts($chan)) && ( captain* iswm $gettok($hget(%cchan,$nick),1,7) ) && ( $return_pickturn($calc(2 + $hfind($+(%cchan,_maps),included*,0,w).data ),2) == $right($gettok($hget(%cchan,$nick),1,7),1) ) {
    if ($gettok($hget($+(%cchan,_maps),$+(map,$2)),1,7) == excluded) {
      ;echo -a $hget($+(%cchan,_maps),$+(map,$2))
      ;echo -a $hget($+(%cchan,_maps),$+(map,$2))

      var %numincluded = $calc($hfind($+(%cchan,_maps),included*,0,w).data +1)
      hadd -m $+(%cchan,_maps) $+(map,$2) $puttok($hget($+(%cchan,_maps),$+(map,$2)),$+(included,%numincluded),1,7)

      ;//echo -a $hfind($+(%cchan,_maps),included*,0,w).data
      ;//echo -a $hfind($+(%cchan,_maps),included*,0,w).data == 0 _msg $dout($chan,$ri(maps,$chan))
      var %turn = $return_pickturn($calc(2 + $hfind($+(%cchan,_maps),included*,0,w).data ),2)
      ;//echo -a turn: %turn
      .timer 1 0 _msg $chan $dout($chan, $nick has picked $gettok($hget($+(%cchan,_maps),$+(map,$2)),2,7) $+ . $hfind(%cchan,$+(captain, $return_pickturn($calc(2 + $hfind($+(%cchan,_maps),included*,0,w).data ),2) ,*),1,w).data  picks next )
      .timer 1 0 list_maps $chan $started_pug($chan)

      ;//echo -a nextpicker: $hfind(%cchan,$+(captain, $return_pickturn($calc(3 + $hfind($+(%cchan,_maps),included*,0,w).data ),2) ,*),1,w).data
      ;//echo -a turn $return_pickturn($calc(3 + $hfind($+(%cchan,_maps),included*,0,w).data ),2)

      ;//echo -a $hfind($+(%cchan,_maps),included*,0,w).data == $ri($+(nummaps,_,$started_pug($chan)))

      if ( $hfind($+(%cchan,_maps),included*,0,w).data == $ri($+(nummaps,_,$started_pug($chan))) ) {
        var %teamtxt = $output_teams($chan)
        var %lastt = $+($ri($+($chan,_,$started_pug($chan))),$chr(7),$ctime,$chr(7),%teamtxt)
        var %redteam = $gettok($gettok($ui2($mid(%lastt,1,-1)),3,7),2,58)
        var %blueteam = $gettok($gettok($ui2($mid(%lastt,1,-1)),4,7),2,58)
        var %table = $server_set($chan,$ri(serverpick,$chan))
        var %i = 1
        while (%i <= $numtok(%redteam,32)) {
          _msg $gettok(%redteam,%i,32) $dout(%chan,Red team game password is: $hget(%table,redpw) )
          inc %i
        }
        %i = 1
        while (%i <= $numtok(%blueteam,32)) {
          _msg $gettok(%blueteam,%i,32) $dout(%chan,Blue team game password is: $hget(%table,bluepw) )
          inc %i
        }

        $pug_finish($chan,$started_pug($chan),$ui(%lastt),0)
      }
      ;//hdel $+(%cchan,_maps) $+(map,$2)
    }
    else {
      _msg $chan $dout($chan, Invalid map pick.)
    }

  }
  elseif (pickserver == $cp($1)) && ($hfind(%cchan,player*,0,w).data == 0) && ($started_pug($chan) != $null) {
    if ($ri($+(server,$2),$chan) != $null ) {
      wi serverpick $+(server,$2)
      .timer 1 0 _msg $chan $dout($chan,Server has been picked. Map selection now in progress)
      if ($hget($+($chan,_,$started_pug($chan),_maps))) hdel -w $+($chan,_,$started_pug($chan),_maps) *
      var %i = 1
      while (%i <= $numtok($ri(maps,$chan),32)) {
        hadd -m $+($chan,_,$started_pug($chan),_maps) $+(map,%i) $+(excluded,$chr(7),$gettok($ri(maps,$chan),%i,32))
        inc %i
      }
      .timer 1 0 list_maps $chan $started_pug($chan)
    }
  }
  elseif (maps == $cp($1)) {
    if ($started_pug($chan) == $null) && ($ri(maps) != $null) _msg $chan $+($sp(1),$chr(32),$r_mod(Maps:,$chan),$chr(32),$ri(maps),$chr(32),$sp(4))
    elseif ($started_pug($chan) != $null) .timer 1 0 list_maps $chan $started_pug($chan)
  }
  elseif (pick == $cp($1) || p == $cp($1)) && ($hfind(%cchan,captain*,0,w).data == $numcapts($chan)) && ( captain* iswm $gettok($hget(%cchan,$nick),1,7) ) && ( $captain_turn($chan) == $right($gettok($hget(%cchan,$nick),1,7),1) ) {
    if ($gettok($mid($hget(%cchan,$2),1,6),1,7) == player) || ( $hfind(%cchan,$+(player,$2,$chr(7),*),1,w).data ison $chan ) {
      if ($2 isnum) {
        set %players_ [ $+ [ $chan ] ] %players_ [ $+ [ $chan ] ] $hfind(%cchan,$+(player,$2,$chr(7),*),1,w).data
        var %playername = $hfind(%cchan,$+(player,$2,$chr(7),*),1,w).data
      }
      else {
        set %players_ [ $+ [ $chan ] ] %players_ [ $+ [ $chan ] ] $2
        var %playername = $2
      }
      .timercaptain $+ $chan $+ $nick off
      ;echo -a %playername
      hadd %cchan %playername $+(picked,$nick,$calc($hfind(%cchan,$+(picked,$nick,*),0,w).data +1),$chr(7),$gettok($hget(%cchan,%playername),2-,7))
      if ( $hfind(%cchan,player*,0,w).data > 1 ) {
        _msg $chan $sp(1) $+(,$captain_colour($captain_turn($chan),$chan).colour2,$hfind(%cchan,$+(captain,$captain_turn($chan),$chr(7),*),1,w).data,,$sp(82)) now picks $sp(4)
      }        
      else {
        set %players_ [ $+ [ $chan ] ] %players_ [ $+ [ $chan ] ] $hfind(%cchan,player*,1,w).data
        hadd %cchan $hfind(%cchan,player*,1,w).data $+(picked,$hfind(%cchan,$+(captain,$captain_turn($chan),$chr(7),*),1,w).data,$calc($hfind(%cchan,$+(picked,$hfind(%cchan,$+(captain,$captain_turn($chan),$chr(7),*),1,w).data,*),0,w).data +1),$chr(7),$gettok($hget(%cchan,%playername),2-,7))
      }
      var %teamtxt = $output_teams($chan)
      var %y = 1
      while (%y <= $numtok(%teamtxt,7)) {
        _msg $chan $sp(1) $gettok(%teamtxt,%y,7) $sp(4)
        inc %y
      }
      if ( $hfind(%cchan,player*,0,w).data == 0 ) {
        var %lastt = $+($ri($+($chan,_,$started_pug($chan))),$chr(7),$ctime,$chr(7),%teamtxt)
        if ($ri($+(assaultpug_,$started_pug($chan)),$chan) == 1) {
          .timer 1 0 _msg $chan $dout($chan,Red Captain now picks server.)
          ;.timer 1 0 reset_server_maps
          ;.timer 1 0 _msg $chan $dout($chan,Map selection now in progress. Blue team picks first.)
          ;if ($hget($+($chan,_,$started_pug($chan),_maps)) != $null) .hfree $+($chan,_,$started_pug($chan),_maps)
          ;.timer -m 1 250 list_server_maps $chan $started_pug($chan)
        }
        else {
          $pug_finish($chan,$started_pug($chan),$ui(%lastt),0)
        }
      }
    }
  }
  elseif (stats == $cp($1) && $2 != $null) {
    if ($4 != $null) get_playerstats $chan $4 $2
    else get_playerstats $chan $2
  }
  elseif (mystats == $cp($1)) {
    if ($2 != $null) get_playerstats $chan $2 $3
    else get_playerstats $chan $3
  }
  elseif (captain == $cp($1)) {    
    $set_captain(%cchan,$chan,$nick,%ssetpuggers)
  }
  elseif ((mic == $cp($1)) || (deltag == $cp($1))) {
    var %yy = 1
    var %isinpugs = no
    while (%yy <= $hget(0)) {
      if ($chan isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) && ($hget(%yy,$3) != $null) {
        %isinpugs = yes
        hadd $hget(%yy) $3 $puttok($hget(%yy,$3),mic,2,7)
      }
      inc %yy
    }
    if (%isinpugs == yes) && (mic == $cp($1)) notice $3 $+($sp(1),$chr(32),,$sp(81,$chan),Using mic for pugs.,$chr(32),$sp(4))
    if (%isinpugs == yes) && (deltag == $cp($1)) notice $3 $+($sp(1),$chr(32),,$sp(81,$chan),All tags deleted.,$chr(32),$sp(4))
  }
  elseif (nomic == $cp($1)) {
    var %yy = 1
    var %isinpugs = no
    while (%yy <= $hget(0)) {
      if ($chan isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) && ($hget(%yy,$3) != $null) {
        %isinpugs = yes
        hadd $hget(%yy) $3 $puttok($hget(%yy,$3),nomic,2,7)
      }
      inc %yy
    }
    if (%isinpugs == yes) .notice $3 $+($sp(1),$chr(32),,$sp(81,$chan),Not using mic for pugs.,$chr(32),$sp(4))
  }
  elseif (tag == $cp($1)) && ($2 != $null) {
    var %yy = 1
    var %isinpugs = no
    while (%yy <= $hget(0)) {
      if ($chan isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) && ($hget(%yy,$3) != $null) {
        %isinpugs = yes
        var %clr
        if ($mid($2,1,1) == $chr(3)) && ($mid($2,2,1) isnum ) var %clr = $+(,$mid($2,2,1))
        if ($mid($2,1,1) == $chr(3)) && ($mid($2,2,2) isnum ) var %clr = $+(,$mid($2,2,2))
        if ($replace($strip($2),$chr(44),,$chr(15),) != $null) hadd $hget(%yy) $3 $puttok($hget(%yy,$3),$+(%clr,$replace($mid($strip($2),1,16),$chr(44),,$chr(15),)),2,7)
      }
      inc %yy
    }
    if (%isinpugs == yes) .notice $3 $+($sp(1),$chr(32),,$sp(81,$chan),Nicktag changed to,$chr(32),%clr,$replace($mid($strip($2),1,16),$chr(44),,$chr(15),),.,$chr(32),$sp(4))
  }
  elseif (here == $cp($1)) && ($hfind(%cchan,captain*,0,w).data == $numcapts($chan)) && ( captain* iswm $hget(%cchan,$nick) ) {
    if ($timer(captain $+ $chan $+ $nick) != $null) {
      .notice $nick $dout($chan,Roger That.)
      .timercaptain $+ $chan $+ $nick off
    }
  }
  elseif ((w == $cp($1)) && ($2 != $null)) weather $2 $4-
  elseif (servers == $cp($1)) $list_stuff($chan,$3,ip,$chan)
  elseif ((stream == $cp($1)) && ($ri(stream) != $null)) {
    _msg $chan $+($sp(1),$chr(32),$r_mod(Stream:,$chan),$chr(32),$ri(stream),$chr(32),$sp(4))
  }
  elseif (turn == $cp($1)) {
    if ( $hget(%cchan,0).item == $ri(%ssetpuggers) ) {
      if ( $hfind(%cchan,captain*,0,w).data == $numcapts($chan) ) _msg $chan $sp(1) $+(,$captain_colour($captain_turn($chan),$chan).colour2,$hfind(%cchan,$+(captain,$captain_turn($chan),$chr(7),*),1,w).data,,$sp(82) is currently picking for the $captain_colour($captain_turn($chan),$chan).colour,.) $sp(4)
      else _msg $chan $dout($chan,Captains haven't been picked.)
    }
    else _msg $chan $dout($chan,Pug hasn't started yet.)
  }
  elseif (teams == $cp($1)) {
    if ( $hget(%cchan,0).item == $ri(%ssetpuggers) ) {
      var %teamtxt = $output_teams($chan)
      var %y = 1
      while (%y <= $numtok(%teamtxt,7)) {
        .timer -m 1 $calc(50 * %y ) _msg $chan $sp(1) $gettok(%teamtxt,%y,7) $sp(4)
        inc %y
      }
    }
    else _msg $chan $dout($chan,Pug hasn't started yet.)
  }
  elseif (aliases == $cp($1)) list_aliases $chan
  elseif (links == $cp($1)) $list_stuff($chan,$3,link,$chan)
  elseif (rules == $cp($1)) $list_stuff($chan,$3,rule,$chan)
  elseif (themes == $cp($1)) {
    var %s = $+($network,$chr(7),theme.)
    var %themes
    var %i = 1
    var %c = $sp(82)
    while (%i <= $hget(0)) {
      if (%s isin $hget(%i)) {
        if (%themes == $null) %themes = $+(,$sp(81),Themes:,,%c,$chr(32), $mid($hget(%i),$calc($len(%s)+1)))
        else %themes = $+(%themes,$chr(32),,%c,$mid($hget(%i),$calc($len(%s)+1)),$chr(32))
        if (%c == $sp(82)) %c = $sp(81)
        else %c = $sp(82)
      }
      inc %i
    }
    _msg $chan $sp(1) %themes $sp(4)
  }
  elseif (pugstats == $cp($1)) {
    $get_pugstats($chan,$2)
  }
  elseif (about == $cp($1)) _msg $chan $sp(1) Bot made by spydee. $+(,$sp(81)) $+ $gettok($read(pugmain.mrc,1),2,32) $sp(4)
  elseif ((link* iswm $cp($1)) || (rule* iswm $cp($1))) {
    var %link = $cp($1)
    if ($mid($1,-1,1) == $null) %link = $+($cp($1),1)
    ;echo -a %link
    if ($ri(%link) != $null) _msg $chan $+($sp(1),,$sp(81)) %link $+ : $+ $+(,$sp(82)) $ri(%link) $sp(4)
  }
  elseif (pickorder* iswm $cp($1)) {
    if (pickorders == $cp($1)) $list_stuff($chan,$3,pickorder,global)
    elseif ((pickorder == $cp($1)) && ($ri($+($chan,_,$2)) != $null)) {
      if ($ri($+(pickorder,_,$2)) != $null) _msg $chan $+($sp(1),$chr(32),,$sp(81,$chan),Pickorder,$ri($+(pickorder,_,$2)),:,,$sp(82,$chan),$chr(32),$ri($+(pickorder,$ri($+(pickorder,_,$2))),global),$chr(32),$sp(4))
      else _msg $chan $+($sp(1),$chr(32),,$sp(81,$chan),Pickorder1:,,$sp(82),$chr(32),$ri(pickorder1,global),$chr(32),$sp(4))
    }
  }
  elseif (scriptstats == $cp($1)) _msg $chan $pugscript_stats
  elseif (taunt == $cp($1)) {
    if ($2 == $null) _msg $chan $dout($chan,That's not how you taunt someone $3 $+ .)
    else {
      if ( $hget(%cchan,0).item == $ri(%ssetpuggers) ) {
        if ($hfind(%cchan,captain*,0,w).data < $numcapts($chan)) {
          if ( $gettok($mid($hget(%cchan,$2),1,6),1,7) == player ) {
            _msg $chan $dout($chan,$replace($read(pugtaunts.txt),,$2,,$3))
          }
          elseif ($2 !ison $chan) _msg $chan $dout($chan,$2 is not even on the channel...)
          elseif ($2 ison $chan) && ($hget(%cchan,$2) == $null) _msg $chan $dout($chan,You can't captain when you aren't in the pug.)
          else _msg $chan $dout($chan,$replace($read(pugtaunts3.txt),,$2,,$3))
        }
        else _msg $chan $dout($chan,$replace($read(pugtaunts3.txt),,$2,,$3))
      }
      else {
        if ($2 ison $chan) _msg $chan $dout($chan,$replace($read(pugtaunts2.txt),,$2,,$3))
        else _msg $chan $dout($chan,$2 isn't even on the channel.)
      }
    }
  }
}

;//function for assault pugs
alias list_maps {
  var %cchan = $+($1,_,$2))
  var %msg
  var %i = 1
  ;echo -a $+(%cchan,_maps),1
  while (%i <= $hget($+(%cchan,_maps),0).item) {
    ;echo -a $+(%cchan,_maps)
    if (excluded* iswm $hget($+(%cchan,_maps),$+(map,%i))) %msg = $+(%msg,$chr(32),,$sp(81,$chan),%i,$sp(10,$chan),$chr(32),$gettok($hget($+(%cchan,_maps),$+(map,%i)),2,7))
    inc %i
  }
  if (%msg != $null) _msg $1 $dout($1,Maplist: $sp(8,$1) %msg)
}

;//main function for leaving pugs
alias xleave {
  var %setpuggers $+(setpuggers,_,$2)
  var %chan = $4
  var %ptable = $+(%chan,_,$2)
  if ($2 == $null) {
    .notice $3 $dout(%chan,Usage is .leave <mod>.)
    return
  }
  if ($hget(%ptable,$3) != $null) {
    if ( $hget(%ptable,0).item <= $ri(%setpuggers,%chan) ) {
      .notice $3 $dout(%chan,You left the $r_mod($2,%chan) pug in %chan $+ .)
    }
    if ( $hget(%ptable,0).item == $ri(%setpuggers,%chan) ) {
      _msg %chan $dout(%chan,Pug stopped because $r_mod($3,%chan) quit.)
      if ( $hfind(%ptable,captain*,0,w).data == $numcapts(%chan) ) k_idle_captain %chan $3 10
      $pug_stop(%ptable,$2,%chan)
    }
    hdel %ptable $3
    order_table %ptable
  }
}     

;//main function for joining pugs  
alias xjoin {
  var %setpuggers $+(setpuggers,_,$2)
  var %chan = $chan
  var %ptable $+($chan,_,$2)
  if ($started_pug(%chan) != $null) {
    .notice $3 $dout(%chan,Wait until picking is done for the $r_mod($started_pug(%chan),%chan) pug before joining.)
    return
  }
  if ($2 == $null) {
    .notice $3 $dout(%chan,Usage is .join <mod>.)
    return
  }
  if ($hget(%ptable,$3) == $null) && ( $hget(%ptable,0).item != $ri(%setpuggers,%chan) ) && ($3 ison %chan) && ($ri(%setpuggers,%chan) != $null) {
    if ( $ri($+(voiceonly_,$2),%chan) == 1 ) && ($4 != adminadded) && ( $3 !isop %chan ) && ( $3 !isvoice %chan ) && ($3 !ishop %chan) && ($ri(pugbot,%chan) == 1) _msg $3 $dout(%chan,You need voice to pug in this channel.)
    else {
      .notice $3 $dout(%chan,You joined the $r_mod($2,%chan) pug in %chan $+ .)
      ._msg $3 $dout(%chan,You joined the $r_mod($2,%chan) pug in %chan $+ .)
      if ($timer($+(playeridle,$chan,$2)) != 1) .timer $+ playeridle $+ $chan $+ $2 0 1200 whois_players %chan $2 remove_idle
      if ($4 == nm) hadd -m %ptable $3 $+(player,$calc($hget(%ptable,0).item +1),$chr(7),nomic)
      elseif (($4 == $null) || ($4 == adminadded)) hadd -m %ptable $3 $+(player,$calc($hget(%ptable,0).item +1),$chr(7),mic)
      else hadd -m %ptable $3 $+(player,$calc($hget(%ptable,0).item +1),$chr(7),$4)
      if ( $hget(%ptable,0).item == $ri(%setpuggers,%chan) ) {
        $xotherpugs(%ptable)
        $pug_start(%ptable,$2,%chan,%setpuggers)
      }
    }
  }
}