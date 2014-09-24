<?php
	include 'include/mainFunctions.php';
	create_top();
?>
		<div id="content">
			<div id="toc">
				<font size="4">
					&nbsp;&nbsp;On this page<br>
					<div class="contents">
							<a href="#About">&nbsp; About</a><br>
							<a href="#What_is_mIRC">&nbsp; What is mIRC?</a><br>
							<a href="#Features">&nbsp; Features</a><br>
							<a href="#Installation">&nbsp; Installation</a><br>
							<a href="#Usage">&nbsp; Usage</a><br>
							<a href="#Demo">&nbsp; Demo</a><br>
							<a href="#Source">&nbsp; Source</a><br>
					</div>
				</font>
			</div>
			

			
			<h2 id="About"><div class="anchor">About</div></h2>
			This is a mIRC script which facilitates pick-up games used for organized play of online games. Once 10 players have joined the queue, a set number of captains (2 or 4) pick teams in a configurable order, or alternatively teams can be picked at random. The bot can query external game, voice, and HTTP servers via UDP and TCP sockets and return the response. All the features of the bot facilitate the organization of these games or are features commonly used by the community. 

			<p>At its peak, this IRCBot was used concurrently by over a dozen different IRC channels across different IRC servers in North America, South America and Europe serving hundreds of players based around the game Unreal Tournament. This project started as my very first non-trivial programming project.</p>
			<h2 id="What_is_mIRC"><div class="anchor">What is mIRC?</div></h2>
			<a href = "http://www.mirc.com/">mIRC</a> is a popular client for the IRC protocol with a powerful event-based scripting language.
			<h2 id="Features"><div class="anchor">List of Features</div></h2>
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
				<li>Idle captain and player kick, recent PUG informational commands, promotion and administrative commands, and more. See <a href="#Usage">Usage</a> for a full list of commands</li>
			</ul>
			<h2 id="Installation"><div class="anchor">Installation</div></h2>
			<ol>
				<li>Place all files in the mIRC default scripts directory. This is the mIRC root folder for versions prior to 6.3 and %APPDATA%\mIRC for versions thereafter</li>
				<li>Type /load -rs pugmain.mrc in the server window</li>
				<li>Load up your IRC server of choice, join a channel and type: .pugbot on. <b> NOTE:</b> This bot works best on a network where it can be given the +B flag or similar permissions. If not, mIRC flood rules need to be enabled or the bot may be kicked for flooding</li>
			</ol>
			Upon connecting to the IRC server for the first time, an ini file will be created with the server's $network name with default variables.
			<h2 id="Usage"><div class="anchor">Usage</div></h2>

			Command prefixes are <b>! and . only</b>. The only exception is the query command which is just 'q server'. The bot can have multiple queues (mods) per channel. <b>If you only have one queue (mod) in your channel, ignore the &lt;mod&gt; part of the following commands unless stated otherwise.</b> All OPs in the channel have access to all admin commands.<br><br>
			
			<h4>Basic PUG Commands</h4>
			<table>
				<tr><th>Command Syntax</th><th>Description</th></tr>
				<tr>
					<td>!join || !j &lt;mod1|tag&gt; &lt;mod2|tag&gt;</td>
					<td>Joins multiple mods with the specified tag. Tags are shown in a .list and are used to specify information for picking purposes.</td>
				</tr>
				<tr>
					<td>!leave || !l &lt;mod1&gt; &lt;mod2&gt;</td>
					<td>Leaves the specified mods.</td>
				</tr>
				<tr>
					<td>!leaveall || !lva</td>
					<td>Leaves all mods you are joined, not just the ones in the channel you type it in.</td>
				</tr>
				<tr>
					<td>!list || !ls &lt;mod&gt;</td>
					<td>In channels with more than one mod, !list will list all the mods.</td>
				</tr>
				<tr>
					<td>!last || !la &lt;mod&gt;</td>
					<td>Information about the last PUG which was played. Can also use without &lt;mod&gt;.</td>
				</tr>
				<tr>
					<td>!liast || !lia</td>
					<td>Combines the list and last commands. Can also use without &lt;mod&gt;.</td>
				</tr>
				<tr>
					<td>!promote &lt;mod&gt;</td>
					<td>A notice to help get the queue filled.</td>
				</tr>
				<tr>
					<td>!turn</td>
					<td>Shows which captain is currently picking.</td>
				</tr>
				<tr>
					<td>!here</td>
					<td>Type this to prevent getting kicked for being an idle captain.</td>
				</tr>
				<tr>
					<td>!teams</td>
					<td>Shows current teams during picking.</td>
				</tr>
			</table>
			
			<br><h4>Admin Commands</h4>
			<table>
				<tr><th>Command Syntax</th><th>Description</th></tr>
				<tr>
					<td>!pugbot &lt;on|off&gt;</td>
					<td>Turns the pugbot on or off.</td>
				</tr>
				<tr>
					<td>!addmod &lt;mod&gt; &lt;tag&gt;</td>
					<td>Mod required. Adds a mod to the current list of mods.</td>
				</tr>
				<tr>
					<td>!delmod &lt;mod&gt;</td>
					<td>Mod required.</td>
				</tr>
				<tr>
					<td>!settag &lt;mod&gt; &lt;tag&gt;</td>
					<td>Tag is the little bit of info shown at the beginning of a .list or .last.</td>
				</tr>
				<tr>
					<td>!setlimit &lt;mod&gt; &lt;#&gt;</td>
					<td>Number of players required to start a PUG.</td>
				</tr>
				<tr>
					<td>!setpickorder &lt;mod&gt; &lt;#&gt;</td>
					<td>1 (default) or 2 (for 4-team PUGs).</td>
				</tr>
				<tr>
					<td>!setnumteams &lt;mod&gt; &lt;#&gt;</td>
					<td>Number of teams in the PUG. Maximum of 8 teams.</td>
				</tr>
				<tr>
					<td>!setpugtype &lt;mod&gt; &lt;#&gt;</td>
					<td>0 for manual picking PUGs, 1 for random PUGs, 2 for deathmatch PUGs (no teams).</td>
				</tr>
				<tr>
					<td>!sethybridPUG &lt;#&gt;</td>
					<td>0 (default): Must specify a mod in all commands. 1: Will allow commands without mod given (joins the 'PUG' mod). Still able to use mod in commands. Use .listall and .liastall for full PUGlists.</td>
				</tr>
				<tr>
					<td>!reset</td>
					<td>Resets captains and teams in the started PUG.</td>
				</tr>
				<tr>
					<td>!fullreset &lt;mod&gt;</td>
					<td>Fully resets the PUG, removing all players.</td>
				</tr>
				<tr>
					<td>!setcaptain &lt;player&gt;</td>
					<td>Manually sets a captain.</td>
				</tr>
				<tr>
					<td>!addplayer &lt;mod&gt; &lt;nick&gt;</td>
					<td>Adds a player to the specified PUG.</td>
				</tr>
				<tr>
					<td>!delplayer &lt;mod&gt; &lt;nick&gt;</td>
					<td>Removes a player from the specified PUG.</td>
				</tr>
				<tr>
					<td>!setlink# &lt;link&gt;</td>
					<td>Adds a .link# command to display the specified information.</td>
				</tr>
				<tr>
					<td>!dellink#</td>
					<td>Removes the .link# command.</td>
				</tr>
				<tr>
					<td>!addrule# &lt;rule&gt;</td>
					<td>Adds a .rule# command to display the specified rule.</td>
				</tr>
				<tr>
					<td>!delrule#</td>
					<td>Removes the .rule# command.</td>
				</tr>
				<tr>
					<td>!setip# &lt;name&gt;</td>
					<td>Adds a .ip# command to display the specified game server IP address, or to be used with the query command.</td>
				</tr>
				<tr>
					<td>!delip#</td>
					<td>Removes the .ip# command.</td>
				</tr>
				<tr>
					<td>!spamip#</td>
					<td>Spams 6 lines of the given server address.</td>
				</tr>
				<tr>
					<td>!setalias &lt;alias&gt;</td>
					<td>Adds an alias for the given ip to be used in the query command.</td>
				</tr>
				<tr>
					<td>!delalias &lt;alias&gt;</td>
					<td>Removes the specified alias.</td>
				</tr>
				<tr>
					<td>!setts# &lt;ip:port&gt;</td>
					<td>Adds a .ts# command to display the specified TS IP address, or to be used with the query command.</td>
				</tr>
				<tr>
					<td>!delts#</td>
					<td>Removes the specified TS command.</td>
				</tr>
				<tr>
					<td>!setvoicePUG &lt;0|1&gt;</td>
					<td>0: Allows anyone to PUG. 1: For voiced players only.</td>
				</tr>
				<tr>
					<td>!settheme &lt;theme&gt;</td>
					<td>Changes the current theme. Use .themes for a list of available themes.</td>
				</tr>
				<tr>
					<td>!setmaps &lt;maps&gt;</td>
					<td>Set the list of allowed maps.</td>
				</tr>
				<tr>
					<td>!setstream &lt;link&gt;</td>
					<td>Set the stream link.</td>
				</tr>
				<tr>
					<td>!setstats &lt;stats link&gt;</td>
					<td>Set the UTStats link.</td>
				</tr>
			</table>
			
			<br><h4>Miscellaneous</h4>
			<table>
				<tr><th>Command Syntax</th><th>Description</th></tr>
				<tr>
					<td>!taunt &lt;player&gt;</td>
					<td>Different messages before/during/when picked as captain.</td>
				</tr>
				<tr>
					<td>!deltag, !nomic, !tag &lt;tag&gt;</td>
					<td>!deltag removes tags, !nomic changes all PUGtags to nomic, !tag sets a custom tag for all mods.</td>
				</tr>
				<tr>
					<td>!translate || !gt &lt;id&gt; &lt;text&gt;</td>
					<td>Translates text into language specified by its shortform identifier. i.e. en, de, fr</td>
				</tr>
				<tr>
					<td>!google || !g &lt;text&gt;</td>
					<td>Performs a google query and returns the result.</td>
				</tr>
				<tr>
					<td>!rules</td>
					<td>Lists all the rules.</td>
				</tr>
				<tr>
					<td>!pickorders</td>
					<td>Returns all pickorders available.</td>
				</tr>
				<tr>
					<td>!pickorder &lt;mod&gt;</td>
					<td>Current pickorder for &lt;mod&gt;.</td>
				</tr>
				<tr>
					<td>!maps</td>
					<td>Lists all the allowed maps.</td>
				</tr>
				<tr>
					<td>!stream</td>
					<td>Responds with the stream link.</td>
				</tr>
				<tr>
					<td>!links</td>
					<td>Lists all of the links.</td>
				</tr>
				<tr>
					<td>!link#</td>
					<td>Responds with the specified link.</td>
				</tr>
				<tr>
					<td>!servers</td>
					<td>Notices the user of all the available game servers.</td>
				</tr>
				<tr>
					<td>!ip#</td>
					<td>Lists the specified server IP.</td>
				</tr>
				<tr>
					<td>!aliases</td>
					<td>Lists all the server aliases.</td>
				</tr>
				<tr>
					<td>!PUGstats</td>
					<td>Responds with the channnel PUG statistics.</td>
				</tr>
				<tr>
					<td>!stats</td>
					<td>UTStats link set from .setstats.</td>
				</tr>
				<tr>
					<td>!findstats &lt;*player*&gt;</td>
					<td>Wildcard search. Returns a maximum of 5 results.</td>
				</tr>
				<tr>
					<td>!stats &lt;player&gt; &lt;mod&gt;</td>
					<td>Statistics for the specified player and mod. Mod is optional.</td>
				</tr>
				<tr>
					<td>!ts&lt;#&gt; &lt;server:port&gt;</td>
					<td>Queries the voice server and returns the response.</td>
				</tr>
				<tr>
					<td>q &lt;{ut99/ut2k4/source engine} alias or ip#&gt;</td>
					<td>Queries the specified game server and returns the response.</td>
				</tr>
				<tr>
					<td>!scriptstats</td>
					<td>PUG script statistics.</td>
				</tr>
				<tr>
					<td>!about</td>
					<td>Responds with information about the script and ME!</td>
				</tr>
			</table>

			<h2 id="Demo"><div class="anchor">Demo</div></h2>
			The following is a demonstration of the list, join, translate, google search and voice/game server query commands:<br><br>
			<img src="demo/pugbot/pugbotDemo.png">
			<h2 id="Source"><div class="anchor">Source</div></h2>
			<a href = "projects/pugbot.zip"> <i class="fa fa-download"></i> Download</a><br>
			<a id="dirLink_pugbot" href="javascript:toggleView('pugbot', 'dir');"><i class="fa fa-chevron-down"></i> View Source</a>
			<div id="dirView_pugbot" style="display: none">
			<div class="spinner"></div>
			</div>
		</div>
<?php
	create_bottom();
?>