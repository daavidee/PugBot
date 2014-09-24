;//all player and pug statistics functions are found here


;//get overall or mod-specific player statistics
alias get_playerstats {
  var %chan = $1
  var %ini = $+($network,_,%chan,_stats.ini)
  if ($3 == $null) var %auth = $2
  else {
    var %mod = $2
    var %auth = $3
  }
  if ($_auth(%auth) != $null) %auth = $_auth(%auth)
  %auth = $replace(%auth,[,~,],~)
  if ($prop == avgp) {
    ;echo -a $readini(%ini,$+(%chan,.playerstats.,%auth),bans)
    if ($readini(%ini,$+(%chan,.playerstats.,%auth),bans) != $null) {
      var %totalpugs
      var %picks
      var %tpicks
      var %captained
      var %ignoredpugs
      var %i = 1
      while (%i <= $ini(%ini,$+(%chan,.playerstats.,%auth),0)) {
        var %t = $ini(%ini,$+(%chan,.playerstats.,%auth),%i)
        if (totalpicks_* iswm %t) %tpicks = $calc(%tpicks + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (totalpugs_* iswm %t) %totalpugs = $calc(%totalpugs + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (picks_* iswm %t) %picks = $calc(%picks + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (captained_* iswm %t) %captained = $calc(%captained + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (ignoredpugs_* iswm %t) %ignoredpugs = $calc(%ignoredpugs + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        inc %i
      }
      var %avgp = $calc(%picks / (%totalpugs - (%ignoredpugs + %captained)))
      var %avgtp = $calc(%tpicks / (%totalpugs - (%ignoredpugs + %captained)))
      var %picks = $round($calc(%picks / %tpicks),3)
      if (%picks == 0) return 99
      else return %picks
    }
    else return 99
  }
  elseif ($readini(%ini,$+(%chan,.playerstats.,%auth),bans) == $null) _msg %chan $dout(%chan,No stats for %auth $+ .)
  elseif ($prop == $null) {
    var %starttime = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(starttime,_,%mod))
    var %totalpugs = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(totalpugs,_,%mod))
    var %last = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(last,_,%mod))
    var %captained = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(captained,_,%mod))
    var %ignoredpugs = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(ignoredpugs,_,%mod))
    var %picks = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(picks,_,%mod))
    var %tpicks = $readini(%ini,$+(%chan,.playerstats.,%auth),$+(totalpicks,_,%mod))
    var %bans = $readini(%ini,$+(%chan,.playerstats.,%auth),bans)
    if (%mod == $null) {
      var %i = 1
      while (%i <= $ini(%ini,$+(%chan,.playerstats.,%auth),0)) {
        var %t = $ini(%ini,$+(%chan,.playerstats.,%auth),%i)
        if (totalpugs_* iswm %t) %totalpugs = $calc(%totalpugs + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (picks_* iswm %t) %picks = $calc(%picks + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (totalpicks_* iswm %t) %tpicks = $calc(%tpicks + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (captained_* iswm %t) %captained = $calc(%captained + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (ignoredpugs_* iswm %t) %ignoredpugs = $calc(%ignoredpugs + $readini(%ini,$+(%chan,.playerstats.,%auth),%t))
        if (starttime_* iswm %t) {
          if (%starttime == $null) || ($readini(%ini,$+(%chan,.playerstats.,%auth),%t) < %starttime) %starttime = $readini(%ini,$+(%chan,.playerstats.,%auth),%t)
        }
        if (last_* iswm %t) {
          if (%last == $null) || ($readini(%ini,$+(%chan,.playerstats.,%auth),%t) > %last) %last = $readini(%ini,$+(%chan,.playerstats.,%auth),%t)
        }
        inc %i
      }
    }
    if (%last == $null) {
      _msg %chan $sp(1,%chan) No pugs yet. $sp(4,%chan)
      return
    }
    var %avgp = $round($calc(%picks / (%totalpugs - (%ignoredpugs + %captained))),2)
    var %avgtp = $round($calc(%tpicks / (%totalpugs - (%ignoredpugs + %captained))),2)
    if ($3 == $null) _msg %chan $+($sp(1,%chan),$chr(32),$sp(71,%chan),%auth,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Total Pugs:,$chr(32),$sp(71,%chan),$calc(%totalpugs),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
      $chr(32),Daily:,$chr(32),$sp(71,%chan),$round($calc(%totalpugs / (($ctime - %starttime)/86400)),2),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
      $chr(32),Avg Pick:,$chr(32),$sp(71,%chan),%avgp,$sp(72,%chan),%avgtp,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Captained:,$chr(32),$sp(71,%chan),$&
      %captained,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Ban count:,$chr(32),$sp(71,%chan),%bans,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),$&
      Last:,$chr(32),$sp(71,%chan),$duration($calc($ctime - %last)) ago,$sp(73,%chan),$chr(32),$sp(4,%chan))
    else _msg %chan $+($sp(1,%chan),$chr(32),$sp(71,%chan),%auth,$sp(73,%chan),$chr(32),$sp(71,%chan),%mod,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Total Pugs:,$chr(32),$sp(71,%chan),$calc(%totalpugs),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
      $chr(32),Daily:,$chr(32),$sp(71,%chan),$round($calc(%totalpugs / (($ctime - %starttime)/86400)),2),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
      $chr(32),Avg Pick:,$chr(32),$sp(71,%chan),%avgp,$sp(72,%chan),%avgtp,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Captained:,$chr(32),$sp(71,%chan),$&
      %captained,$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Last:,$chr(32),$sp(71,%chan),$duration($calc($ctime - %last)) ago,$sp(73,%chan),$chr(32),$sp(4,%chan))
  }
}

;//called for each player when a pug finishes
alias store_playerstats {
  var %chan = $1
  var %ini = $+($network,_,%chan,_stats.ini)
  var %mod = $2
  var %type = $3
  ;%type = 0 is normal picks
  ;%type = 1 is random, DM etc
  var %players = %players_ [ $+ [ %chan ] ]
  var %setpuggers = $4
  ;echo -s setpuggers: $4 players: %players 
  if ($calc($numtok(%players,32) -1) == %setpuggers) {
    var %i = 2
    while (%i <= $numtok(%players,32)) {
      var %auth = $gettok(%players,%i,32)
      if ($_auth(%auth) != $null) %auth = $_auth(%auth)
      %auth = $replace(%auth,[,~,],~)
      ;echo -s auth: %auth auth2: $_auth(%auth)
      if ( $readini(%ini,$+(%chan,.playerstats.,%auth),$+(starttime,_,%mod)) == $null ) {
        writeini -n %ini $+(%chan,.playerstats.,%auth) $+(bans) 0
        writeini -n %ini $+(%chan,.playerstats.,%auth) $+(captained,_,%mod) 0
        writeini -n %ini $+(%chan,.playerstats.,%auth) $+(starttime,_,%mod) $ctime
      }
      writeini -n %ini $+(%chan,.playerstats.,%auth) $+(totalpugs,_,%mod) $calc($readini(%ini,$+(%chan,.playerstats.,%auth),$+(totalpugs,_,%mod)) +1)
      writeini -n %ini $+(%chan,.playerstats.,%auth) $+(last,_,%mod) $ctime 
      if (%type == 0) {
        if (%i <= $calc($gettok(%players,1,32)+1)) writeini -n %ini $+(%chan,.playerstats.,%auth) $+(captained,_,%mod) $calc($readini(%ini,$+(%chan,.playerstats.,%auth),$+(captained,_,%mod)) +1)
        else {
          writeini -n %ini $+(%chan,.playerstats.,%auth) $+(picks,_,%mod) $calc($readini(%ini,$+(%chan,.playerstats.,%auth),$+(picks,_,%mod)) + %i - $gettok(%players,1,32) -1 )
          writeini -n %ini $+(%chan,.playerstats.,%auth) $+(totalpicks,_,%mod) $calc($readini(%ini,$+(%chan,.playerstats.,%auth),$+(totalpicks,_,%mod)) + %setpuggers - $gettok(%players,1,32))
        }
      }
      elseif (%type == 1) {
        writeini -n %ini $+(%chan,.playerstats.,%auth) $+(ignoredpugs,_,%mod) $calc($readini(%ini,$+(%chan,.playerstats.,%auth),$+(ignoredpugs,_,%mod)) +1)    
      }
      inc %i
    }
  }
  unset %players_ [ $+ [ %chan ] ]
}

;//this function can be used to separate the stats ini files by channel for faster lookup. can be used to import stats from older versions
alias fixini {
  var %ini = $+($network,_stats.ini)
  var %i = 1
  while (%i <= $ini(%ini,0)) {
    var %j = 1
    while (%j <= $ini(%ini,%i,0)) {
      var %chan = $gettok($ini(%ini,%i),1,46)
      echo -a  %i %j $+($network,_,%chan,_stats.ini) $ini(%ini,%i) $ini(%ini,%i,%j) $readini(%ini,$ini(%ini,%i),$ini(%ini,%i,%j))
      writeini -n $+($network,_,%chan,_stats.ini) $ini(%ini,%i) $ini(%ini,%i,%j) $readini(%ini,$ini(%ini,%i),$ini(%ini,%i,%j))
      inc %j
    }
    inc %i
  }
}

;//grabs overall channel statistics with no parameter, or specific mod statistics when a parameter is specified
alias get_pugstats {
  var %chan = $1
  var %ini = $+($network,_,%chan,_stats.ini)
  var %mod = $2
  var %starttime = $readini(%ini,$+(%chan,.,pugstats),$+(starttime,_,%mod))
  var %totalpugs = $readini(%ini,$+(%chan,.,pugstats),$+(totalpugs,_,%mod))
  var %players = $ini(%ini,0)
  var %last = $readini(%ini,$+(%chan,.,pugstats),$+(last,_,%mod))
  if (%mod == $null) {
    var %i = 1
    while (%i <= $ini(%ini,$+(%chan,.,pugstats),0)) {
      var %t = $ini(%ini,$+(%chan,.,pugstats),%i)
      if (totalpugs_* iswm %t) %totalpugs = $calc(%totalpugs + $readini(%ini,$+(%chan,.,pugstats),%t))
      if (starttime_* iswm %t) {
        if (%starttime == $null) || ($readini(%ini,$+(%chan,.,pugstats),%t) < %starttime) %starttime = $readini(%ini,$+(%chan,.,pugstats),%t)
      }
      if (last_* iswm %t) {
        if (%last == $null) || ($readini(%ini,$+(%chan,.,pugstats),%t) > %last) %last = $readini(%ini,$+(%chan,.,pugstats),%t)
      }
      inc %i
    }
  }
  if (%last == $null) {
    _msg %chan $sp(1,%chan) No pugs yet. $sp(4,%chan)
    return
  }
  if ($2 == $null ) _msg %chan $+($sp(1,%chan),$chr(32),Channel created on:,$chr(32),$sp(71,%chan),$asctime(%starttime,mmmm dd $+ $chr(44) yyyy),$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Total Pugs:,$chr(32),$sp(71,%chan),$calc(%totalpugs),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
    $chr(32),Daily:,$chr(32),$sp(71,%chan),$round($calc(%totalpugs / (($ctime - %starttime)/86400)),2),$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Unique Players:,$chr(32),$sp(71,%chan),%players,$sp(73,%chan), $&
    $chr(32),$sp(8,%chan),$chr(32),Last:,$chr(32),$sp(71,%chan),$duration($calc($ctime - %last)) ago,$sp(73,%chan),$chr(32),$sp(4,%chan))
  else _msg %chan $+($sp(1,%chan),$chr(32),$2 mod created on:,$chr(32),$sp(71,%chan),$asctime(%starttime,mmmm dd $+ $chr(44) yyyy),$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),Total Pugs:,$chr(32),$sp(71,%chan),$calc(%totalpugs),$sp(73,%chan),$chr(32),$sp(8,%chan), $&
    $chr(32),Daily:,$chr(32),$sp(71,%chan),$round($calc(%totalpugs / (($ctime - %starttime)/86400)),2),$sp(73,%chan), $&
    $chr(32),$sp(8,%chan),$chr(32),Last:,$chr(32),$sp(71,%chan),$duration($calc($ctime - %last)) ago,$sp(73,%chan),$chr(32),$sp(4,%chan))
}

;//called when a pug finishes
alias store_pugstats {
  var %chan = $1
  var %ini = $+($network,_,%chan,_stats.ini)
  var %mod = $2
  if ( $readini(%ini,$+(%chan,.,pugstats),$+(starttime_,%mod)) == $null ) writeini -n %ini $+(%chan,.,pugstats) $+(starttime,_,%mod) $ctime
  writeini -n %ini $+(%chan,.,pugstats) $+(totalpugs_,%mod) $calc($readini(%ini,$+(%chan,.,pugstats),$+(totalpugs,_,%mod)) +1)
  writeini -n %ini $+(%chan,.,pugstats) $+(last_,%mod) $ctime
}
