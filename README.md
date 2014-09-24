<h1>About</h1>
This is a mIRC script which facilitates pick-up games used for organized play of online games. Once 10 players have joined the queue, a set number of captains (2 or 4) pick teams in a configurable order, or alternatively teams can be picked at random. The bot can query external game, voice, and HTTP servers via UDP and TCP sockets and return the response. All the features of the bot facilitate the organization of these games or are features commonly used by the community. 

<h1>What is mIRC?</h1>
<a href = "http://www.mirc.com/">mIRC</a> is a popular client for the IRC protocol with a powerful event-based scripting language.

<h1>List of Features</h1>

<ul>
<li>Data mirroring into memory for reduced disk reads</li>
<li>Multiple queue capability with up to 99 players per queue with automatic removal from queue upon nick change, quit, part or filled queue (even from another channel)</li>
<li>Valve Source engine server query capability. Protocol specifications <a href="https://developer.valvesoftware.com/wiki/Server_queries">here</a></li>
<li>Unreal Tournament 99/2004 UDP server query capability. Protocol specifications <a href="http://wiki.beyondunreal.com/Legacy:UT_Server_Query">here</a></li>
<li>Teamspeak 2/3 voice TCP server query capability. Protocol specifications <a href="http://media.teamspeak.com/ts3_literature/TeamSpeak%203%20Server%20Query%20Manual.pdf">here</a></li>
<li>Google search query capability via HTTP requests</li>
<li>Weather query capability via <a href = "http://www.wunderground.com/weather/api/d/docs">wunderground API</a></li>
<li>Google Translate query capability via HTTP requests</li>
<li>Themed message responses with 3 default themes and the ability for user-specified themes</li>
<li>Tracked player and total PUG statistics by auth or irc nick if the user is not authenticated with the server</li>
<li>Rules, links, maps and server lists commands</li>
<li>Idle captain and player kick, recent PUG informational commands, promotion and administrative commands, and more. See Usage for a full list of commands</li>
</ul>


<h1>Installation</h1>
<ol>
				<li>Place all files in the mIRC default scripts directory. This is the mIRC root folder for versions prior to 6.3 and %APPDATA%\mIRC for versions thereafter</li>
				<li>Type /load -rs pugmain.mrc in the server window</li>
				<li>Load up your IRC server of choice, join a channel and type: .pugbot on. <b> NOTE:</b> This bot works best on a network where it can be given the +B flag or similar permissions. If not, mIRC flood rules need to be enabled or the bot may be kicked for flooding</li>
</ol>

Upon connecting to the IRC server for the first time, an ini file will be created with the server's $network name with default variables.
			
<h1>Usage</h1>

Command prefixes are ! and . only. The only exception is the query command which is just 'q server'. The bot can have multiple queues (mods) per channel. If you only have one queue (mod) in your channel, ignore the &lt;mod&gt; part of the following commands unless stated otherwise. All OPs in the channel have access to all admin commands.<br><br>
			
<h2>Basic PUG Commands</h2>
<table>
	<tr><th>Command Syntax</th><th>Description</th></tr>
	<tr>
		<td>!join || !j &lt;mod1|tag&gt; &lt;mod2|tag&gt;</td>
		<td>Joins multiple mods with the specified tag. Tags are shown in a .list and are used to specify information for picking purposes.</td>
	</tr>
</table>

<h2>Demo</h2>

The following is a demonstration of the list, join, translate, google search and voice/game server query commands:<br><br>
