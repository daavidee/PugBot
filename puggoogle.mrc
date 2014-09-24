;//google and google translate queries


;//encode aliases taken from mircscripts
alias urlencode return $regsubex($1-,/\G(.)/g,$iif(($prop && \1 !isalnum) || !$prop,$chr(37) $+ $base($asc(\1),10,16),\1))
alias urldecode return $replace($regsubex($1-,/%(\w\w)/g,$chr($iif($base(\t,16,10) != 32,$v1,1))),$chr(1),$chr(32))

;//set up and send google query
alias google {
  var %google_id $ticks
  var %t = $+(gquery,%google_id)
  hadd -m %t chan $chan
  hadd -m %t query $1 $2-
  sockopen google [ $+ [ %google_id ] ] google.com 80
  .timer 1 5 sockclose google [ $+ [ %google_id ] ]
  .timer 1 5 hfree %t
  .timer 1 5 .remove $+(google,%google_id)
}

;//call this after specified delay and message channel with the response
alias gfquery {
  var %google_id = $1
  var %t = $+(gquery,%google_id)
  if ( $hget(%t,result) != $null ) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),$hget(%t,result),$chr(32),$sp(4,$hget(%t,chan)))
  else _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),No Results,$chr(32),$sp(4,$hget(%t,chan)))
}

;//parse response and fill hashtable
on *:sockread:google*:{
  var %google_id $mid($sockname,7)
  var %t = $+(gquery,%google_id)
  if ($sockerr > 0) return
  :nextreaddd
  sockread &temp2
  bwrite $sockname -1 -1 &temp2
  if ($bvar(&temp2,$calc($bvar(&temp2,0)-10),10) == 116 109 108 62 13 10 48 13 10 13) {
    bread $sockname 1 $file($sockname).size &temp
    var %string = $chr(60) $+ h3 class="r"><a href="/url?q=
    if ($bfind(&temp,1,%string) != 0) && ($hget(%t,result) == $null) {
      var %pos = $bfind(&temp,$calc($bfind(&temp,1,%string)+ $len(%string)),http://)
      ;echo -a $bvar(&temp,%pos,100).text
      var %pos2 = $bfind(&temp,%pos,&amp)
      ;echo -a %pos2 $hget(%t,result)
      var %pos3 = $calc($bfind(&temp,%pos2,">) +2)
      var %pos4 = $bfind(&temp,%pos3,</a)
      if ($hget(%t,result) == $null) hadd %t result $+(,$sp(81,$hget(%t,chan)),$replace($bvar(&temp,%pos3,$calc(%pos4 - %pos3)).text,<b>,,</b>,,&#8722;,-,&#39;,',&#34;,",&#38;,&,&#60;,<,&#62;,>) $sp(8,$hget(%t,chan)) $urldecode($bvar(&temp,%pos,$calc(%pos2 - %pos)).text))
    }
    gfquery %google_id
    return
  }
  if ($sockbr == 0) return 
  goto nextreaddd
}

;//when socket is open, send the following http request
on *:sockopen:google*:{
  var %google_id $mid($sockname,7)
  var %t = $+(gquery,%google_id)
  var %tmp = $+(/search?q=,$urlencode($hget(%t,query)))
  sockwrite -nt $sockname GET %tmp HTTP/1.1
  sockwrite -nt $sockname Host: 1.2.3.4
  sockwrite -nt $sockname User-Agent: mirc
  sockwrite -nt $sockname Content-Type: text/html
  sockwrite -nt $sockname $crlf
}

;//set up and send google translate query
alias gtranslate {
  var %google_id $ticks
  var %t = $+(gtquery,%google_id)
  hadd -m %t chan $chan
  hadd -m %t language $1
  hadd -m %t query $2-
  sockopen gtranslate [ $+ [ %google_id ] ] translate.google.com 80
  .timer 1 5 sockclose gtranslate [ $+ [ %google_id ] ]
  .timer 1 5 hfree %t
  .timer -m 1 450 gtfquery %google_id
}

;//call this after specified delay and message channel with the response
alias gtfquery {
  var %google_id = $1
  var %t = $+(gtquery,%google_id)
  if ( $hget(%t,result) != $null ) _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),Translation:,$chr(32),$hget(%t,result),$chr(32),$sp(4,$hget(%t,chan)))
  else _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),Could not get translation,$chr(32),$sp(4,$hget(%t,chan)))
}

;//parse response and fill hashtable
on *:sockread:gtranslate*:{
  var %google_id $mid($sockname,11)
  var %t = $+(gtquery,%google_id)
  if ($sockerr > 0) return
  :nextreaddd
  sockread -nf &temp
  if ($sockbr == 0) return
  if ($bfind(&temp,1,[[[) != 0) {
    var %pos1 = $calc($bfind(&temp,1,[[[) +4)
    var %pos2 = $bfind(&temp,%pos1,")
    hadd %t result $bvar(&temp,%pos1,$calc(%pos2 - %pos1)).text
  }
  goto nextreaddd
}

;//when socket is open, send the following http request
on *:sockopen:gtranslate*:{
  var %google_id $mid($sockname,11)
  var %t = $+(gtquery,%google_id)
  ;echo -a $hget(%t,query) $urlencode($hget(%t,query))
  var %tmp = $+(/translate_a/t?client=t&text=,$urlencode($hget(%t,query)),&sl=auto&tl=,$hget(%t,language),&ie=UTF-8&oe=UTF-8&multires=1&ssel=0&tsel=0&sc=1)
  sockwrite -nt $sockname GET %tmp HTTP/1.1
  sockwrite -nt $sockname Host: 1.2.3.4
  sockwrite -nt $sockname User-Agent: mirc
  sockwrite -nt $sockname Content-Type: text/html
  sockwrite -nt $sockname $crlf
}
