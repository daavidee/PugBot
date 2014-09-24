;//global functions used in many of the pug scripts


;//main message function with automatic splitting of long messages to maintain proper themed response
alias _msg {
  var %msglen = 455
  var %nummsgs = $gettok($calc($len($2-) / %msglen),1,46)
  if ($numtok($calc($len($2-) / %msglen),46) == 2) %nummsgs = $calc(%nummsgs +1)
  var %msgnum = 1
  var %i = 1
  while (%i <= $len($2-)) {
    if (%nummsgs > 1) {
      var %txt = $mid($2-,%i,%msglen)
      if (%txt == $sp(4,$1)) break
      var %numpos = $pos(%txt,$chr(32),0)
      var %pos = $pos(%txt,$chr(32),%numpos)
      if (%numpos == 0) %pos = %msglen
      if (%msgnum == 1) msg $1 $+($mid(%txt,1,%pos),$chr(32),$sp(4,$1))
      elseif (%msgnum == %nummsgs) msg $1 $+($sp(1,$1),$chr(32),$mid(%txt,1,%msglen))
      else msg $1 $+($sp(1,$1),$chr(32),$mid(%txt,1,%pos),$chr(32),$sp(4,$1))
      %i = $calc(%i + %pos)
      inc %msgnum
    }
    else {
      msg $1 $2-
      %i = $calc($len($2-) +1)
    }
  }
}

;//get auth from IRC nick
alias _auth {
  if ($hget($+($network,_auths),$+(nick,$chr(7),$1)) != $null) return $hget($+($network,_auths),$+(nick,$chr(7),$1))
}

;//list names of all hash tables
alias list_tables {
  var %i = 1
  while (%i <= $hget(0)) {
    echo -a $hget(%i)
    inc %i
  }
}

;//import ini to hashtables. different from default function
alias ini_to_hashtable {
  var %j = 1
  while (%j <= $ini($network $+ .ini,0) ) {
    var %i = 1
    while (%i <= $ini($network $+ .ini,%j,0) ) {
      var %t = $ini($network $+ .ini,%j,%i)
      echo -a $+($network,$chr(7),$ini($network $+ .ini,%j)) %t $readini($network $+ .ini,$ini($network $+ .ini,%j),%t)
      hadd -m $+($network,$chr(7),$ini($network $+ .ini,%j)) %t $readini($network $+ .ini,$ini($network $+ .ini,%j),%t)
      inc %i
    }
    inc %j
  }
}

;//load all ini file data to hashtables
alias load_tables {
  var %i = 1
  while (%i <= $ini($network $+ .ini,0)) {
    var %table = $+($network,$chr(7),$ini($network $+ .ini,%i))
    if ($hget(%table) != $null) hfree %table
    hmake %table
    .hload -i $+($network,$chr(7),$ini($network $+ .ini,%i)) $network $+ .ini $ini($network $+ .ini,%i)
    inc %i
  }
  echo -a reloaded tables
}

;//read data from ini file
alias ri {
  if ($2 == $null) return $hget($+($network,$chr(7),$chan),$1)
  else return $hget($+($network,$chr(7),$2),$1)
}

;//write to ini file
alias wi {
  var %1 = $replace($1,$,)
  var %2 = $replace($2,$,)
  if ($3 == $null) {
    hadd -m $+($network,$chr(7),$chan) $strip(%1) $strip(%2)
    if ($prop == $null) writeini -n $network $+ .ini $chan $strip(%1) $strip(%2)
  }
  else {
    hadd -m $+($network,$chr(7),$3) $strip(%1) $strip(%2)
    if ($prop == $null) writeini -n $network $+ .ini $3 $strip(%1) $strip(%2)
  }
}

;//delete from ini file
alias dli {
  if ($2 == $null) {
    hdel $+($network,$chr(7),$chan) $1
    remini -n $+($network,.ini) $chan $1
  }
  else {
    hdel $+($network,$chr(7),$2) $1
    remini -n $+($network,.ini) $2 $1
  }
}

;//get themed token
alias sp {
  var %chan = $chan
  if ($2 != $null) %chan = $2
  var %themeloc = theme.red
  if ( $ri(theme,%chan) != $null ) %themeloc = $+(theme.,$ri(theme,%chan))
  if ($1 == 1) return $ui2($+($ri(sp1,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 4) return $ui2($+($ri(sp4,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 8) return $ui2($+($ri(sp8,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 10) return $ui2($+($ri(sp10,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 71) return $ui2($+(,$ri(sp81,%themeloc),$ri(sp71,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 72) return $ui2($+(,$ri(sp81,%themeloc),$ri(sp72,%themeloc),,$ri(sp82,%themeloc)))
  if ($1 == 73) return $ui2($+(,$ri(sp81,%themeloc),$ri(sp73,%themeloc)))
  if ($1 == 81) return $+($ri(sp81,%themeloc))
  if ($1 == 82) return $+($ri(sp82,%themeloc))
  if ($1 == 83) return $+($ri(sp83,%themeloc))
  if ($1 == 84) return $+($ri(sp84,%themeloc))
  if ($1 == 85) return $+($ri(sp85,%themeloc))
  if ($1 == 86) return $+($ri(sp86,%themeloc))
}

;//encode given text to ini-safe text
alias ui {
  if ( *$* iswm $1 ) {
    notice $nick character $ is not allowed.
    return
  }
  else {
    var %u = 1
    var %txt
    while ( %u <= $len($1) ) {
      if ( $mid($1,%u,1) == $chr(2) ) %txt = %txt $+ &2&
      elseif ( $mid($1,%u,1) == $chr(3) ) %txt = %txt $+ &3&
      elseif ( $mid($1,%u,1) == $chr(32) ) %txt = %txt $+ &4&
      else %txt = %txt $+ $mid($1,%u,1)
      inc %u
    }
    return %txt
  }
}

;//dencode ini-safe text
alias ui2 {
  return  $replace($1,&2&,$chr(2),&3&,$chr(3),&4&,$chr(32),&31&,$chr(31))
}

;//user-specified theme creation
alias bot_themes {
  if ($1 isop $2) && ( ( .set sp* iswm $+($3,$chr(32),$4)) || ( !set sp* iswm $+($3,$chr(32),$4) ) ) {
    wi $4 $ui($5)
    notice $1 Done
  }
}

;//remove the . and ! identifier from first text token
alias cp {
  if ( $regex($mid($1,1,1),[.!]) ) return $mid($1,2)
}

;//wrap text as themed response
alias dout {
  return $sp(1,$1) $2 $sp(4,$1)
}
alias is_ip_addr {
  var %i = 1
  while (%i <= 4) {
    if ($gettok($1,%i,46) isnum 0-255) inc %i
    else return no
  }
  return yes
}

;//convert seconds to mm:ss format
alias sec_c {
  var %tmmp = $1
  if (%tmmp > 3600) %tmmp = $calc(%tmmp -3600)
  var %mins $calc( %tmmp / 60)
  if ( $gettok(%mins,2,46) == $null ) {
    return $+(%mins,:00)
  }
  else {
    var %secs $round($calc($+(0,$chr(46),$gettok(%mins,2,46)) * 60),0)
    if ($len(%secs) == 1) %secs = 0 $+ %secs
    return $+($gettok(%mins,1,46),:,%secs)
  }
}


;------------------------------------------------
; Base64 Encoding/Decoding by rkzad
; rkzad@hotmail.com
; Use $b64encode(text to encode here)
; and $b64decode(text to decode here)
; Please don't steal the code.
;------------------------------------------------
; · I changed the script so it now uses The
;   base64 industry standard character set.
;------------------------------------------------
; Yes MIME encoding looks really similiar,
; doesn't it? That's because MIME uses base64
; encoding. You can specify any character set you
; want for this.
;------------------------------------------------
; PS the reason it looks big is because there
; are a lot of comments
;------------------------------------------------
; Changed: Added b64left and b64right to easen
; things up.

; Bitwise left
alias b64left {
  return $base($base($1,10,2) $+ $str(0,$2),2,10)
}

; Bitwise right
alias b64right {
  return $base($int($calc($base($1,10,2) / (10 ^ $2))),2,10)
}

alias b64char {
  ; If the number isn't valid, pick '=' (empty). Returns the letter for the number passed in
  if ($1 < 0 || $1 > 63) { tokenize 32 64 }
  return $mid(ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=,$calc($1 + 1),1)
}

alias b64rchar {
  ; Will return position of the letter passed in
  var %reversed, %num = 1
  return $calc($poscs(ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=,$chr($1),1) - 1)
}

alias b64encode {
  var %n = 1, %t, %1, %2, %3
  while (%n <= $len($1-)) {
    ; Gets the next three bytes
    %1 = $asc($mid($1-,%n,1))
    %2 = $asc($mid($1-,$calc(%n + 1),1))
    %3 = $asc($mid($1-,$calc(%n + 2),1))

    ; Gets the first 6 bits of %1
    %t = %t $+ $b64char($b64right(%1,2))

    ; Puts the last 2 bits of %1 with the first 4 bits of %2
    %t = %t $+ $b64char($calc($b64left($and(%1,3),4) + $b64right(%2,4)))

    ; If we've reached the end of the string
    if ($calc(%n + 1) > $len($1-)) {
      ; Fill the rest with '=' signs (empty)
      %t = %t $+ $str($b64char(65),2)
    }
    else {
      ; Puts the last 4 bits of %2 with the first 2 bits of %3
      %t = %t $+ $b64char($calc($b64left($and(%2,15),2) + $b64right(%3,6)))

      ; If we've reached the end of the string
      if ($calc(%n + 2) > $len($1-)) {
        ; The last character is '=' (empty)
        %t = %t $+ $b64char(65)
      }
      else {
        ; Put the last 6 bits of %3
        %t = %t $+ $b64char($and(%3,63))
      }
    }
    ; Next 3 bits
    inc %n 3
  }
  ; The base64 encoded length of the text will be (((n - 1) / 3) + 1) * 4
  ; It takes the first three bytes and spreads it over four
  return %t
}

alias b64decode {
  var %n = 1, %t, %1, %2, %3, %4, %s = 0, %a
  while (%n <= $len($1-)) {
    ; Get the next 4 bytes
    %1 = $b64rchar($asc($mid($1-,%n,1)))
    %2 = $b64rchar($asc($mid($1-,$calc(%n + 1),1)))
    %3 = $b64rchar($asc($mid($1-,$calc(%n + 2),1)))
    %4 = $b64rchar($asc($mid($1-,$calc(%n + 3),1)))

    ; Put %1 with the first 2 bits of %2
    %a = $calc($b64left(%1,2) + $b64right(%2,4))

    if (%a = 32) {
      ; If it's a space, set %s to space so we don't lose it
      %s = 1
    }
    else if (%s) {
      ; If the last character was a space, make sure to put it in.
      %t = %t $chr(%a)
      %s = 0
    }
    else {
      ; Otherwise, just append the character to the string
      %t = %t $+ $chr(%a)
    }

    ; If %3 equals '=', then we know we're at the end
    if (%3 == 64) return %t

    ; The following lines are essentially the same
    %a = $calc($b64left($and(%2,15),4) + $b64right(%3,2))
    if (%a = 32) {
      %s = 1
    }
    else if (%s) {
      %t = %t $chr(%a)
      %s = 0
    }
    else {
      %t = %t $+ $chr(%a)
    }

    ; And again..
    if (%4 == 64) return %t

    %a = $calc($b64left($and(%3,3),6) + %4)
    if (%a = 32) {
      %s = 1
    }
    else if (%s) {
      %t = %t $chr(%a)
      %s = 0
    }
    else {
      %t = %t $+ $chr(%a)
    }

    ; Next 4 bits
    inc %n 4
  }
  return %t
}
