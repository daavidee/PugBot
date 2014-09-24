;//main query script. this script determines what kind of query is called from the 'q' command and executes the query function
;//found in the other pugscripts. also maintains the DNS lookup hashtable

;//update the dns hashtable
on *:DNS:{
  hadd -m dns.lookups $dns(0).addr $dns(0).ip
}

;//the query function. will determine what parameters to invoke to the main query functions, perform a DNS lookup
;//if necessary, etc. will modify the parameters to the correct syntax if needed
alias t_queries {
  var %chan = $chan
  if (ts* iswm $cp($1)) ts $1 $2
  if (g == $cp($1)) google $+($2,$chr(32),$3)
  if (gt == $cp($1)) gtranslate $+($2,$chr(32),$3)
  if (ip* iswm $cp($1)) {
    var %tmp = $cp($1)
    if (%tmp == ip) %tmp = ip1
    if ( $ri(%tmp) != $null ) {
      .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),$+(,$sp(81,%chan)),%tmp,:,$+(,$sp(82,%chan)),$chr(32),$chr(32),$ri(%tmp),$chr(32),$sp(4,%chan))
    }
    if ( $ri(%tmp) == $null ) {
      .timer 1 0 _msg %chan $+($sp(1,%chan),$chr(32),Alias not set.,$chr(32),$sp(4,%chan))
    }
  }
  if ($1 == q) {
    var %id $ticks
    var %host = $2
    if (%host == ip) %host = ip1
    if (($ri(%host)) && (ip* iswm %host)) %host = $ri(%host)
    elseif ($ri($2,servers)) %host = $ri($2,servers)
    if (unreal:// isin %host) %host = $gettok($mid(%host,$calc($pos(%host,unreal://,1)+9)),1,32)
    if ($chr(63) isin %host) %host = $gettok(%host,1,63)
    var %port
    if (: isin %host) {
      %port = $gettok(%host,2,58)
      %host = $gettok(%host,1,58)
    }
    else %port = 7777
    if ($hget(dns.lookups,%host)) %host = $hget(dns.lookups,%host)
    if ($is_ip_addr(%host) == no) {
      dns -h %tmp
      hadd -m $+(query_,%id) is_host yes
    }
    else hadd -m $+(query_,%id) is_host no
    .timer 1 5 hfree $+(query_,%id)
    hadd $+(query_,%id) host %host
    hadd $+(query_,%id) port %port
    hadd $+(query_,%id) chan %chan
    .timer -m 1 200 tq2 %id
  }
}

;//main query function. send a test query to determine what kind of server it is since this is not required in the 'q' command
alias tq2 {
  var %id = $1
  var %port = $hget($+(query_,%id),port)
  var %ip = $hget($+(query_,%id),host)
  if ($is_ip_addr(%ip) == no) {
    if ($hget(dns.lookups,%ip)) %ip = $hget(dns.lookups,%ip)
    else %ip =
  }
  hadd $+(query_,%id) ip %ip
  if ((%ip) && (%port)) {
    sockudp -k $+(test_query,%id) %ip $calc(%port + 1) \basic\
    .timer -m 1 100 sockudp -k $+(test_query,%id) %ip $calc(%port + 10) \basic\
    bset &q 1 255 255 255 255 85 255 255 255 255
    sockudp -k $+(test_query,%id) %ip %port &q
    .timer 1 3 sockclose test_query $+ %id
    .timer $+ tq $+ %id 1 3 _msg $hget($+(query_,%id),chan) $sp(1,$hget($+(query_,%id),chan)) query request timed out for $+($hget($+(query_,%id),ip),:,$hget($+(query_,%id),port)) $sp(4,$hget($+(query_,%id),chan))
  }
  else _msg $hget($+(query_,%id),chan) $sp(1,$hget($+(query_,%id),chan)) Invalid query. $sp(4,$hget($+(query_,%id),chan))
}

;//listen for the response and update the hashtable
on *:udpRead:test_query*: {
  if ($sockerr > 0) halt
  var %id $mid($sockname,11)
  bset &q 1 255 255 255 255
  sockread &query
  ;echo -a $bvar(&query,1,200).text
  if ($bfind(&query,1,\gamever\)) {
    var %startpos = $bfind(&query,1,\gamever\)
    var %endpos = $bfind(&query,$calc(%startpos +9),\)
    hadd $+(query_,%id) gamever $bvar(&query,$calc(%startpos +9),$calc(%endpos - %startpos -9)).text
    .timer $+ tq $+ %id off
    ut_query_ip %id
    sockclose test_query $+ %id
  }
  elseif ($bvar(&query,1,4) == $bvar(&q,1,4)) {
    .timer $+ tq $+ %id off
    hadd $+(query_,%id) cid $bvar(&query,6,4)
    csgo_query_ip %id
    sockclose test_query $+ %id
  }
}
