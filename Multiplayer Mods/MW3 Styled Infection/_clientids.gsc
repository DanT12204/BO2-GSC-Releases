/*//////////////////
//MOD INFORMATION//
//////////////////

MW3 STYLE INFECTION GAMEMODE
DEVELOPED BY @ItsCahz

Free for use to the public
Released on plutonium forums by Cahz

This mod runs best with Team Deathmatch as the gamemode
The goal of Infected is to stay alive as long as possible

SURVIVORS
Random Primary (mtar, msmc, m27, or remmington)
Secondary (fiveseven)

INFECTED
First Infected gets survivor loadout until there is more than one person infected
Knife and Tomahawk only afterwards
*/

#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_globallogic;

init()
{
	level thread onPlayerConnect();
	level thread StartInfected();
	level thread EndInfected();
	//wait 1;
	//level thread spawnBot(10);	
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread checkName(player.name);
		player maps\mp\teams\_teams::changeteam("axis");
		player thread onScreenText();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	for(;;)
	{
		self waittill("spawned_player");
		level notify("update_text");
        
		self givePerks();
        
		if(!isDefined(self.isFirstSpawn))
		{
			self.isFirstSpawn = true;
			self iprintln("Welcome to MW3 Style Infection!");
			self iprintln("Developed by: ^5@ItsCahz");
		}
		if(self.pers["team"] == "axis")
		{
			if(isDefined(self.infected))
				self maps\mp\teams\_teams::changeteam("allies");
			else
			{
				self iprintlnbold("^5You Are Not Infected! Stay Alive!");
        		
				self thread giveWeapons("Survivor");
				self thread monitorWeapons();
				self thread waitForDeath();
        		
				level.totalAlive += 1;
			}
		}
		if(self.pers["team"] == "allies")
		{
			if(!isDefined(self.infected))
				self maps\mp\teams\_teams::changeteam("axis");
			else
			{
				self iprintlnbold("^1You Are Infected! Kill the Survivors!");
				
				if(level.infectedCount == 1)
					self thread giveWeapons("Survivors");
				else
					self thread giveWeapons("Infected");
				
				self thread monitorWeapons();
			}
		}
	}
}

checkName(text)
{
	if(IsInArray(level.infectedtable, text))
		self.infected = true;
}

saveName(text)
{
	if(!IsInArray(level.infectedtable, text))
		level.infectedtable[level.infectedtable.size] = text;
}

StartInfected()
{
	level.totalAlive = 0;
	level.infectedCount = 0;
	level.firstinfected = "";
	level.infectedtable = [];
    
	level.survivorWeapons = strTok("insas_mp,870mcs_mp,hk416_mp,tar21_mp", ",");
	
	level.survivorPrimary = RandomInt(level.survivorWeapons.size);
	level.survivorSecondary = "fiveseven_mp";
	
	level.infectedPrimary = "knife_mp";
	level.infectedSecondary = "hatchet_mp";
	level.infectedTactical = "tactical_insertion_mp";
	
	level thread updateText();
	
	level waittill("prematch_over");
	
	wait 3;
	iPrintlnBold("^1Picking First Infected!");
	wait 5;
	
	level.firstinfected = pickRandomPlayer();
	level.firstinfected.infected = true;
	level.firstinfected suicide();
	level.firstinfected maps\mp\teams\_teams::changeteam("allies");
	
	level.gameStarted = true;
}

pickRandomPlayer()
{
	randomnum = randomintrange(0, level.players.size);
	infected = level.players[randomnum];

	if (isAlive(infected))
		return infected;
	else
		return pickRandomPlayer();
}

giveWeapons(Team)
{
	self takeallweapons();
	if(Team == "Infected")
	{
		self giveWeapon(level.infectedPrimary);
		self giveWeapon(level.infectedSecondary);
		self giveWeapon(level.infectedTactical);
		self switchToWeapon(level.infectedPrimary);
	}
	else
	{
		self giveWeapon(level.survivorWeapons[level.survivorPrimary]);
		self giveWeapon(level.survivorSecondary);	
		self switchToWeapon(level.survivorWeapons[level.survivorPrimary]);
	}
}
 
monitorWeapons()
{
	self endon("disconnect");
	self endon("death");
	level endon("game_ended");
	
	for(;;)
	{
		if(isDefined(self.infected))
		{
			if(level.infectedCount == 1)
			{
				if(self getCurrentWeapon() != (level.survivorWeapons[level.survivorPrimary]) && self getCurrentWeapon() != level.survivorSecondary && self getCurrentWeapon() != "none")
					self thread giveWeapons("Survivor");
			}
			else
			{
				if(self getCurrentWeapon() != level.infectedPrimary && self getCurrentWeapon() != level.infectedSecondary  && self getCurrentWeapon() != level.infectedTactical && self getCurrentWeapon() != "none")
					self thread giveWeapons("Infected");
			 }
		}
		else
		{
			if(self getCurrentWeapon() != (level.survivorWeapons[level.survivorPrimary]) && self getCurrentWeapon() != level.survivorSecondary && self getCurrentWeapon() != "none")
				self thread giveWeapons("Survivor");
		}
		wait 0.05;
	}
}

waitForDeath()
{
	self endon("disconnect");
	self endon("first_infected");
	
	for(;;)
	{
		self waittill("death");
		
		self.infected = true;
		level.totalAlive -=1;
		level.infectedCount += 1;
		level notify("update_text");
		self maps\mp\teams\_teams::changeteam("allies");
		self thread saveName(self.name);
		break;
	}
}

givePerks()
{
	self ClearPerks();
	self setperk("specialty_additionalprimaryweapon");
	self setperk("specialty_fallheight");
	self setperk("specialty_fastequipmentuse");
	self setperk("specialty_fastladderclimb");
	self setperk("specialty_fastmantle");
	self setperk("specialty_fastmeleerecovery");
	self setperk("specialty_fasttoss");
	self setperk("specialty_fastweaponswitch");
	self setperk("specialty_longersprint");
	self setperk("specialty_sprintrecovery");
	self setperk("specialty_twogrenades");
	self setperk("specialty_twoprimaries");
	self setperk("specialty_unlimitedsprint");
}

EndInfected()
{
	level endon("game_ended");
    for(;;)
    {
		wait 0.05;
		if(level.totalAlive == 0 && isDefined(level.gameStarted))
			thread endgame( "allies", "^7The Infected Win!" );
	}
}

onScreenText()
{
	self.onScreenText = self createFontString("objective", 1.75);
	self.onScreenText setPoint("CENTER", "CENTER", -355, 150);
	self.onScreenText setText( "Survivors Left: ^5"+level.totalAlive);
}

updateText()
{
	for(;;)
	{
		level waittill("update_text");
		foreach(player in level.players)
		{
			if(level.totalAlive == 1 || level.totalAlive == 0)
				player.onScreenText setText( "Survivors Left: ^1"+level.totalAlive);
			else
				player.onScreenText setText( "Survivors Left: ^5"+level.totalAlive);
		}
	}
}

spawnBot(value)
{
	for(i = 0; i < value; i++)
	{
		self thread maps\mp\bots\_bot::spawn_bot( "axis" );
	}
}