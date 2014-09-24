;//the weather function. utilizes the wunderground api. 


;//main query function
alias weather {
  var %weather_id $ticks
  var %t = $+(wquery,%weather_id)
  hadd -m %t chan $chan
  hadd -m %t query $1-
  sockopen weatherquery [ $+ [ %weather_id ] ] api.wunderground.com 80
  .timer 1 5 hfree %t
  .timer 1 5 sockclose weatherquery [ $+ [ %weather_id ] ]
  .timer 1 5 sockclose weather [ $+ [ %weather_id ] ]
}

;//called after the query to preapre the message
alias wfquery {
  var %weather_id = $1
  var %t = $+(wquery,%weather_id)
  var %chan = $hget(%t,chan)
  if ( $hget(%t,location) != $null ) {
    _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),Current conditions for,$chr(32),,$sp(81,%chan),$hget(%t,location),$chr(32),$sp(71,%chan),$hget(%t,country),$sp(73,%chan),$chr(32),$sp(8,%chan),$chr(32),$&
      $hget(%t,weather),$chr(32),$sp(8,%chan),$chr(32),,$sp(81,%chan),Temp:,,$sp(82,%chan),$chr(32),$hget(%t,temperature),$chr(32),feeling like,$chr(32),$hget(%t,feelslike),$chr(32),$sp(8,%chan),$&
      $chr(32),,$sp(81,%chan),Wind:,,$sp(82,%chan),$chr(32),$hget(%t,wind),$chr(32),$sp(8,%chan),$chr(32),,$sp(81,%chan),Humidity:,,$sp(82,%chan),$chr(32),$hget(%t,humidity),$chr(32),$sp(8,%chan),$chr(32),$&
      $chr(32),$hget(%t,time),$chr(32),$sp(8,%chan),$chr(32),$hget(%t,link),$chr(32),$sp(4,$hget(%t,chan)))
  }
  else _msg $hget(%t,chan) $+($sp(1,$hget(%t,chan)),$chr(32),Can't find that location.,$chr(32),$sp(4,$hget(%t,chan)))
}

;//lookup the location id and then call the api for weather data from that id
on *:sockread:weatherquery*:{
  if ($sockerr > 0) return
  :nextreaddd
  sockread &temp
  var %weather_id $mid($sockname,13)
  var %t = $+(wquery,%weather_id)
  var %string = /q/zmw
  if ($bfind(&temp,1,%string) != 0) {
    var %pos = $calc($bfind(&temp,1,%string)+3)
    var %pos2 = $bfind(&temp,%pos,")
    hadd %t query $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  if ($bvar(&temp,$calc($bvar(&temp,0)-3),3) == 125 10 125) sockopen weather [ $+ [ %weather_id ] ] api.wunderground.com 80
  if ($sockbr == 0) return
  goto nextreaddd
}

;//parse the json response and populate the hashtable
on *:sockread:weather*:{
  if ($sockerr > 0) return
  :nextreaddd
  sockread &temp
  var %weather_id $mid($sockname,8)
  var %t = $+(wquery,%weather_id)
  var %pos
  var %pos2
  var %pos3

  var %string = "full"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    %pos3
    hadd %t location $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  %string = "elevation"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t elevation $round($bvar(&temp,%pos,$calc(%pos2 - %pos)).text) m
  }
  %string = "observation_location"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $bfind(&temp,1,%string)
    %pos2 = $calc($bfind(&temp,%pos,"country")+11)
    %pos3 = $bfind(&temp,%pos2,")
    hadd %t country $bvar(&temp,%pos2,$calc(%pos3 - %pos2)).text
  }
  %string = "observation_time"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t time $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  %string = "weather"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t weather $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  %string = "temperature_string"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t temperature $replace($bvar(&temp,%pos,$calc(%pos2 - %pos)).text,$+($chr(32),F),$+($chr(176),F),$+($chr(32),C),$+($chr(176),C))
  }
  %string = "relative_humidity"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t humidity $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  %string = "wind_string"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t wind $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  %string = "feelslike_string"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t feelslike $replace($bvar(&temp,%pos,$calc(%pos2 - %pos)).text,$+($chr(32),F),$+($chr(176),F),$+($chr(32),C),$+($chr(176),C))
  }
  %string = "visibility_km"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t visibility $bvar(&temp,%pos,$calc(%pos2 - %pos)).text km
  }
  %string = "pressure_mb"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t pressure $bvar(&temp,%pos,$calc(%pos2 - %pos)).text hPa
  }
  %string = "ob_url"
  if ($bfind(&temp,1,%string) != 0) {
    %pos = $calc($bfind(&temp,1,%string)+ $len(%string) +2)
    %pos2 = $bfind(&temp,%pos,")
    hadd %t link $bvar(&temp,%pos,$calc(%pos2 - %pos)).text
  }
  if ($bvar(&temp,$calc($bvar(&temp,0)-3),3) == 125 10 125) wfquery %weather_id
  if ($sockbr == 0) return 
  goto nextreaddd
}

;//create the http requests when the sockets are opened
on *:sockopen:weatherquery*:{
  var %weather_id $mid($sockname,13)
  var %t = $+(wquery,%weather_id)
  var %tmp = $+(/api/4e9689bb514402df/conditions/q/,$urlencode($hget(%t,query)),.json)
  sockwrite -nt $sockname GET %tmp HTTP/1.0
  sockwrite -nt $sockname Host: 1.2.3.4
  sockwrite -nt $sockname User-Agent: mirc
  sockwrite -nt $sockname Content-Type: text/html
  sockwrite -nt $sockname $crlf
}
on *:sockopen:weather*:{
  var %weather_id $mid($sockname,8)
  var %t = $+(wquery,%weather_id)
  var %tmp = $+(/api/4e9689bb514402df/conditions/q/,$urlencode($hget(%t,query)),.json)
  sockwrite -nt $sockname GET %tmp HTTP/1.0
  sockwrite -nt $sockname Host: 1.2.3.4
  sockwrite -nt $sockname User-Agent: mirc
  sockwrite -nt $sockname Content-Type: text/html
  sockwrite -nt $sockname $crlf
}
