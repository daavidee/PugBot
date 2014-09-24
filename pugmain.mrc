;//the main script. all events are found in this script only (except the DNS event found in pugquery.mrc). the functions which are called here are found in the other pug scripts.
;//some supporting functions are also found here along with startup functions etc.


;//reload all pug scripts and pug data from ini file
alias rps {
  var %pos = $calc($len($mircdir) +1)
  var %i = 1
  while (%i <= $findfile($mircdir,pug*.mrc,0,1) ) {
    var %script = $mid($findfile($mircdir,pug*.mrc,%i,1),%pos)
    if (%script != pugmain.mrc) load -rs %script
    inc %i
  }
  reload -rs pugmain.mrc
  load_tables
}

;//stats about the pug script
alias pugscript_stats {
  var %i = 1
  var %size = 0
  var %lines = 0
  while ( %i <= $findfile($mircdir,pug*.mrc,0,1) ) {
    var %file = $findfile($mircdir,pug*.mrc,%i,1)
    %size = $calc(%size + $file(%file).size)
    %lines = $calc(%lines + $lines(%file))
    inc %i
  }
  return $+($sp(1),$chr(32),Pug Script Stats,$chr(32),$sp(8),$chr(32),$chr(32),Lines:,$chr(32),%lines,$chr(32),$sp(8),$chr(32),Size:,$chr(32),$round($calc(%size /1024),2),$chr(32),KB,$chr(32),$sp(4))
}

;//basic function for global adminning. OPs are by default admin on their channel
alias isAdmin {
  if ($address($1,2) == *!*@spydee.user.globalgamers.net) return yes
  elseif ($address($1,2) == *!*@spydee.users.quakenet.org) return yes
  elseif ($address($1,2) == *!*@x-lp.net) return yes
  elseif ($address($1,2) == *!*@Tim.Tim) return yes
}
on *:START:{
  rps
}

;//make ini file if connected to server for first time and reload pug data from ini
on *:CONNECT:{
  .ignore -td *!*@*
  if ($ri(pickorder1, global) == $null) copy pugDefaults.ini $+($network,.ini)
  load_tables
}

;//perform WHO to add auth info to AUTHs hashtable (for stats, adminning, etc.). add default values to ini if joining channel for first time
on *:JOIN:#:{
  who $nick n%na
  if ($nick == $me) {
    who $chan n%na
    if ($num_mods($chan) == 0) {
      .hmake $+($chan,_pug)
      if ($ri(pugbot) == $null) wi pugbot 0
      if ($ri($+($chan,_pug)) == $null) { 
        wi $+($chan,_pug) pug
        wi setpuggers_pug 10
      }
    }
  }
}

;//leave any joined pugs
on *:PART:#:{
  var %yy = 1
  while (%yy <= $hget(0)) {
    if ($chan isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) {
      var %pos = $pos($hget(%yy),_,$pos($hget(%yy),_,0))
      var %pchan = $mid($hget(%yy),1,$calc(%pos -1))
      $xleave(.leave,$mid($hget(%yy),$calc(%pos +1)),$nick,%pchan)
    }
    inc %yy
  }
}

;//add to stats if user is banned
on *:BAN:#:{
  if ($_auth($nick) != $null) writeini -n $+($network,_,$chan,_stats.ini) $+($chan,.playerstats.,$_auth($nick)) bans $calc($readini($+($network,_,stats.ini),$+($chan,.playerstats.,$_auth($nick)),bans) +1)
  ;write $+($network,_,bans.txt)
}

;//leave any joined pugs
on *:KICK:#:{
  var %yy = 1
  while (%yy <= $hget(0)) {
    if ($chan isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) {
      var %pos $pos($hget(%yy),_,$pos($hget(%yy),_,0))
      var %pchan $mid($hget(%yy),1,$calc(%pos -1))
      $xleave(.leave,$mid($hget(%yy),$calc(%pos +1)),$knick,%pchan)
    }
    inc %yy
  }
}

;//change nickname on AUTHs hashtable and on all joined pugs
on *:NICK:{
  if ($newnick != $nick) {
    hadd $+($network,_auths) $+(nick,$chr(7),$newnick) $_auth($nick)
    hdel $+($network,_auths) $+(nick,$chr(7),$nick)
    var %yy = 1
    while (%yy <= $hget(0)) {
      if ($chr(7) !isin $hget(%yy)) rename_player $hget(%yy) $nick $newnick
      inc %yy
    }
  }
}

;//remove from AUTHs hashtable leave any joined pugs
on *:QUIT:{
  hdel $+($network,_auths) $+(nick,$chr(7),$nick)
  var %yy = 1
  while (%yy <= $hget(0)) {
    if ($chr(95) isin $hget(%yy)) && ($chr(7) !isin $hget(%yy)) {
      var %pos $pos($hget(%yy),_,$pos($hget(%yy),_,0))
      var %pchan $mid($hget(%yy),1,$calc(%pos -1))
      $xleave(.leave,$mid($hget(%yy),$calc(%pos +1)),$nick,%pchan)
    }
    inc %yy
  }
}

;//separate functions alwasy requiring use of the mod parameter
alias needs_mod_param {
  if ($prop == 1) {
    if ( $cp($1) == j ) || ( join == $cp($1) ) return 1
    if ( $cp($1) == l ) || ( $cp($1) == leave ) return 1
    if ( $cp($1) == ls ) || ( $cp($1) == list ) return 1
    if ( $cp($1) == lia ) || ( $cp($1) == liast ) return 1
    if ( $cp($1) == reset ) || ( $cp($1) == fullreset ) return 1
    if ( $cp($1) == promote ) return 1
    if ( $cp($1) == pickorder ) return 1
  }
  if ($prop == 2) {
    if ( $cp($1) == addplayer ) || ( $cp($1) == delplayer ) return 1
    if ( $cp($1) == setlimit ) return 1
    if ( $cp($1) == setpickorder ) return 1
    if ( $cp($1) == setnumteams ) return 1
    if ( $cp($1) == setpugtype ) return 1
    if ( $cp($1) == settag ) return 1
  }
}

;//determines what parameters to give to join, leave etc. functions depending if it is local or network input, if chan requires use of mod parameter or not, etc.
alias commands_input {
  if ( $ri(pugbot,$chan) == 1 ) {
    if ($prop == input) var %nick = $me
    elseif ($prop == text) var %nick = $nick
    var %ptable = $+($chan,_,$started_pug($chan))
    if ($hfind(%ptable,captain*,0,w).data == $numcapts($chan)) && ( captain* iswm $hget(%ptable,$nick) ) {
      if ($timer(captain $+ $chan $+ $nick) != $null) .timercaptain $+ $chan $+ $nick off
    }
    var %s1 = $replace($1,$,,&,)
    var %s1- = $replace($1-,$,,&,)
    var %s2 = $replace($2,$,,&,)
    var %s2- = $replace($2-,$,,&,)
    var %s3 = $replace($3,$,,&,)
    var %s3- = $replace($3-,$,,&,)

    if ( $mid(%s1,1,1) == $chr(46) || $mid(%s1,1,1) == $chr(33) || $mid(%s1,1,1) == q ) {
      if ($num_mods($chan) == 1) && (($needs_mod_param(%s1).1 == 1) || ($needs_mod_param(%s1).2 == 1)) {
        var %1 = %s1
        var %2 = $num_mods($chan).mod
        var %3 = %s2
        var %2f = $num_mods($chan).mod
        var %3f = %s2-
      }
      elseif ($ri(hybridpug,$chan) != 0) && ($ri(hybridpug,$chan) != $null) {
        if (($needs_mod_param(%s1).1 == 1) && ($numtok(%s1-,32) == 1)) || (($needs_mod_param(%s1).2 == 1) && ($numtok(%s1-,32) == 2)) {
          var %1 = %s1
          var %2 = $gettok($ri(hybridpug,$chan),2,7)
          var %3 = %s2
          var %2f = $gettok($ri(hybridpug,$chan),2,7)
          var %3f = %s2-
        }
        else {
          var %1 = %s1
          var %2 = %s2
          var %3 = %s3
          var %2f = %s2-
          var %3f = %s3-
        }
      }
      else {
        var %1 = %s1
        var %2 = %s2
        var %3 = %s3
        var %2f = %s2-
        var %3f = %s3-
      }

      $helpcommands(%1)
      $admincommands(%nick,%1,%2,%3f)
      $xpugbot(%1,%2,%nick,%3f)
      $t_queries(%1,%2,%3f)

      var %num_mods 
      if ( $numtok(%2f,32) == 0 ) %num_mods = 1
      else %num_mods = $numtok(%2f,32)
      var %i = 1
      while (%i <= %num_mods) {
        if (leave == $cp(%1)) || (l == $cp(%1)) $xleave($strip(%1),$gettok(%2f,%i,32),%nick,$chan)
        if ( join == $gettok($cp(%1),1,32) ) || ( j == $gettok($cp(%1),1,32) ) $xjoin($strip(%1),$gettok(%2f,%i,32),%nick,$mid($gettok(%1,2,124),1,15))
        inc %i
      }
      if (leaveall == $cp(%1)) || (lva == $cp(%1)) {
        var %i = 1
        while (%i <= $hget(0)) {
          if ($hget(%i,%nick) != $null) && ($chr(7) !isin $hget(%i)) {
            var %numtok = $numtok($hget(%i),95)
            ;echo -a $gettok($hget(%i),%numtok,95) %nick $gettok($hget(%i),1- $+ $calc(%numtok -1),95)
            $xleave(.leave,$gettok($hget(%i),%numtok,95),%nick,$gettok($hget(%i),1- $+ $calc(%numtok -1),95))
          }
          inc %i
        }
      }
    }
  }
  toggleonoff $nick $1 $2
}

;//INPUT is triggered on local messages only, i.e. the mIRC the bot is running on
on *:INPUT:#:{
  $commands_input($1,$2,$3-).input
}

;//TEXT are all other messages other than local
on *:TEXT:*:#:{
  $commands_input($1,$2,$3-).text
}
