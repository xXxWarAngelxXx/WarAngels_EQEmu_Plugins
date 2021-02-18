##############################################################################
##############################################################################
#:: Usage:			Single compilation of plugins from WarAngel
#:: Created:		10 May 2020
#:: Version:		wa_200422_02
#:: Author:			WarAngel
#:: Description:	To provide and support WarAngel's scripts (quests, etc...)
##############################################################################
##############################################################################



######################################################
#:: Usage:					plugin::wa_Decisions(); Decide whether to attack or do Non combat stuff.
#:: Created:				12April2020
#:: Version(ddmmyy):		wa_160221_01
#:: Author:					WarAngel
#:: Description:			To generate decisions for npcs.
#:: With help from:			Dencelle
#:: Plugins:				plugin::val('$npc');plugin::MobHealPercentage(5);plugin::wa_KillMode(400, 1200);
#:: 						plugin::wa_ChatMode();
#:: Future Plans:	
#######################################################

sub wa_Decisions
{
	#plugin::Debug("Decision start."); # The "D" in debug HAS to be UPPER CASE.
	my $npc = plugin::val('$npc');
	my $wa_intChoice = int(rand(100)); #Random number 0-99

	$wa_maxhp = $npc->GetMaxHP();
	$wa_HP = $npc->GetHP();
	$wa_perchp = (($wa_HP / $wa_maxhp) * 100);

	if($wa_perchp <= 20)
	{
		#plugin::Debug("Heal chosen.");
		#plugin::Debug("" . $npc->GetName() . " I am below 20 percent, healing.");			
		#plugin::Debug("Health check PERCENTAGE " . $wa_perchp . "");		
		plugin::MobHealPercentage(5);
		#plugin::Debug("" . $npc->GetName() . "Done healing.");

		last; # While we are in a state of no combat and below %20 health. Do not do other choices.
	}
	if ($wa_intChoice <= 8) #Below or at 8
	{
		#plugin::Debug("Kill chosen.");
		plugin::wa_KillMode();
		#plugin::wa_KillMode(400, 1200);	#Change the ranges for customizing the npc_player min and max agro radius...keeping this to give example of what you can do with plugins.
		#plugin::Debug("wa_intROLL BELOW 8 worked for ". $npc->GetName() .". Time to kill");
	}
	if ($wa_intChoice > 8) #Above 8
	{
		#plugin::Debug("Chat chosen.");
		plugin::wa_ChatMode();
		#plugin::Debug("wa_intROLL ABOVE 8 worked for ". $npc->GetName() .". Time for peace");
	}
}

####################################
#:: Usage:			plugin::wa_ChatMode(); To perform random chats and anim.
#:: Created:		12Apr202
#:: Version:		wa_200419_01
#:: Author:			WarAngel
#:: Description:	To have a NPC chat spam and animations.
#:: With help from:	TurmoilToad,Salvanna,Akkadius,Trust,Kinglykrab
#:: Plugins:		plugin::val('$npc'); plugin::SetAnim("sit"); plugin::DoAnim("dance");
#:: Future Plans	
####################################

sub wa_ChatMode
{
	my $npc = plugin::val('$npc');
	my $wa_intCHAT = int(rand(100)); #Random number 0-99

	#quest::shout("Hiyas folks I am ". $npc->GetName() ."!"); #This worked
	#quest::emote("Does the whole zone hear me!!"); #Works but emote has a limited range
	#plugin::RandomSay(chance(1-100), "Heyhey!!","How are you all doing?","How about it?");
				
	if ($wa_intCHAT <= 33) #Below or at 33
	{
		plugin::SetAnim("sit"); #Options (stand/sit/duck/dead/kneel)		
		#quest::shout2("worldwide only shout"); #Does not use...relies on the datbase name
		#quest::we(14, "World emote");
		#plugin::Debug("wa_intCHAT Sarcastic chat");
	}
	if ($wa_intCHAT > 33 && $wa_intCHAT <= 66) #Above between 33 66
	{
		plugin::SetAnim("stand"); #Options (stand/sit/duck/dead/kneel)
		#plugin::Debug("wa_intCHAT Positive chat");
	}
	if ($wa_intCHAT > 66) #above 66
	{
		plugin::DoAnim("dance");		
		#quest::shout("Zone shout"); #Does not use...relies on the dataase name
		#quest::ze(14, "Zone emote");
		#plugin::Debug("wa_intCHAT idiot chat");
	}
}

################################################################
#:: Usage:					plugin::wa_KillMode([minRange], [maxRange]); Example... plugin::wa_KillRange(500, 1000);
#:: Created:				12April2020
#:: Version(ddmmyy):		wa_160221_01
#:: Author:					Akkadius or Trevius, heavily modified by WarAngel
#:: Description:			To have a NPC create the illusion of other real world players running around. Attacking Mobs in a area range.
#:: With help from:			TurmoilToad,Salvanna,Akkadius,Trust,Kinglykrab
#:: Plugins:				plugin::val('$npc');plugin::RandomRange(0, 100);
#:: Future Plans:			Work on waypoint integration.
#################################################################

sub wa_KillMode
{
	#plugin::Debug("Killmode begin for " . $npc->GetName() . ""); #This broke my script. Why?
	my $npc = plugin::val('$npc'); #this was what I was missing. without this the plugin was not knowing who was calling
	my $entity_list = plugin::val('$entity_list');
	my $wa_minZone = $npc->GetEntityVariable("wa_minRange");
	my $wa_maxZone = $npc->GetEntityVariable("wa_maxRange");
	#my $wa_minZone = $_[0]; #pulled from first position in the plugin call...keeping this to give example of what you can do with plugins.
	#my $wa_maxZone = $_[1]; #pulled from second position in the plugin call...keeping this to give example of what you can do with plugins.

	$wa_disUpper = plugin::RandomRange($wa_minZone, $wa_maxZone);
	@npc_list = $entity_list->GetNPCList();
	#plugin::Debug("Killmode begin for " . $npc->GetName() . "");

	foreach $npc_ent (@npc_list) 
	{
		#plugin::Debug("Killmode subscript begin for " . $npc->GetName() . ""); #This debug will repeat for each NPC in the GetNPCList()
		next if $npc_ent->CalculateDistance($x, $y, $z) > $wa_disUpper; #skip mobs OVER $wa_disUpper distance, check those BELOW
		next if $npc_ent->CalculateDistance($x, $y, $z) < $wa_minRange; #skip mobs BELOW $wa_minRange distance, check those OVER
		next if $npc_ent->GetLevel() > $npc->GetLevel(); # Enemy level parameters...works
		next if $npc_ent->IsEngaged(); # Is target in combat?...works
		next if $npc_ent->GetID() == $npc->GetID(); #Lets not kill ourself.
		next if ($npc_ent->GetSpecialAbility(19) || $npc_ent->GetSpecialAbility(20) || $npc_ent->GetSpecialAbility(24) || $npc_ent->GetSpecialAbility(35)); #Immune to melee / magic / aggro / noharm SKIP.
		next if $npc_ent->GetBodyType() == 11; #skip untargetable NPCs.
		next if $npc_ent->GetOwnerID(); #skip pets.
		next if $npc_ent->CheckNPCFactionAlly(faction_id) == $npc->CheckNPCFactionAlly(faction_id); #We are brothers and sisters in arms, lets not kill each other
		#quest::shout("I am coming for you, " . $npc_ent->GetCleanName() . "!");
		quest::SetRunning(1);
		$npc->AddToHateList($npc_ent, 1); #We now HATE HIM!...Will go through the list thats left and pick the npc at the bottom of the list to attack
		#plugin::Debug("Killmode subscript end for " . $npc->GetName() . "");	
		last; #we found a valid target jump out of the loop
    }
}

######################################################
#:: Usage:			plugin::wa_NameGenerator();
#:: Created:		19April2020
#:: Version:		wa_200422_01
#:: Author:			Dencelle, made for WarAngel
#:: Description:	To generate a random elements of names for npcs.
#:: With help from:	
#:: Plugins:		plugin::val('$npc');plugin::wa_ChangeName();
#:: Future Plans:	Fill in my own name elements.
#:: Instructions:	Below you will see where there are pieces of names (syllables). Dependiing on gender and race_ID insert your own name elements.
#::					For example...
#::					..."Legolas"...break it down to "Leg ol as". Now below you will see many codes such as...
#::					...(4 => [1,'Mith Mar Murn Menth Mic','ol ea el','as ere as cha'],). In that code, in the [] there are three "areas" called arrays.
#::					Divided by the "," with elements inside (Mith Mar Murn...) In this case you have the first array with
#::					the first syllable of a name... "Mith". The second array with a second syllable of "ol". And the third with "as" for a name of Mitholas. 
#::					Now breaking a name down gives a random generated name in game! Again could have Mitholas or Mithelere or Murneacha...
#::					Race list...1-Human,2-Barbarian,3-Erudite,4-Wood Elf,5-High Elf,6-Dark Elf,7-Half Elf,8-Dwarf,9-Troll,10-Ogre,11-Halfling,12-Gnome
#::								128-Iksar,130-Vah Shir,330-Froglok,522-Drakkin
#######################################################

sub wa_NameGenerator
{
	my $npc = plugin::val('$npc');
	my $npcRace = $npc->GetRace();
	my $npcGender = $npc->GetGender();
	my %male = (
        1 => [0,'','',''],
        2 => [1,'Higd Muf Llod','up ris lurn','lok ard vukr _ _ _ _ _ _'], 
        3 => [0,'','',''],
        4 => [1,'Leg Lar Loa Luw Mith Murn Menth Mic Com Haw Boul Ain Elm Ber Ash Vis Cea Uin Gilr Bes Sae Von Ker Cyv','a e i o u ol ea na hg thorn bert ma eur der dre hol es nnai shade rock ie cal euh ad ia ith lil ni nin ehn ra l is thi ae ar par el','a e i o u as ere cha nin tive ill live hall ood ey per hollow ach an gaire ker in mire win vale lar fer go ant low ras wing dis rone deach ann olive ar st is ee ae tha ath _ _ _ _ _ _'],
        5 => [0,'','',''],
        6 => [1,'Br','tiz','zk _ _ _ _ _ _'],
        7 => [1,'Mith Mar Murn Menth','ol ea el','as ere cha _ _ _ _ _ _'],
        8 => [0,'','',''],
        9 => [1,'Zul Gro Ug','ra th nok','jas ok nok _ _ _ _ _ _'],
        10 => [1,'Ka Ug Me','dez nu no','ag ck crush _ _ _ _ _ _'],
        11 => [1,'Qui Mer Nor','nam lan vi','in as _ _ _ _ _ _'],
        12 => [1,'Vor Nes Br','zi gr ix','ver im _ _ _ _ _ _'],
        128 => [0,'','',''],
        130 => [0,'','',''],
        330 => [0,'','',''],
        522 => [0,'','',''],
    );
	my %female = (
        1 => [0,'','',''],
        2 => [1,'Ger Fre Ey Ein Sune','dur yv vin ar','if id dr _ _ _ _ _ _'],
        3 => [0,'','',''],
        4 => [1,'Loth Lir Fen Fil Fith Gw Cao Lleu Blo Cry Bry Fan Lin Eir Lama Ket Mai Fer','ea al ern ene im fa deu st nn ial owa euw an ilf ela lea lih aeth hes ar ath','a e i o u ish cha ira he nwy wedd ch rm yn ill et en inn la sh th ar as ah ti uil il _ _ _ _ _ _'],
        5 => [0,'','',''],
        6 => [1,'Hel','in','ia _ _ _ _ _ _'],
        7 => [1,'Fen Fil Fith','an ea al','a ish sha _ _ _ _ _ _'],
        8 => [0,'','',''],
        9 => [1,'Xu Vu Eg','kun zem nar','di bi cha _ _ _ _ _ _'],
        10 => [1,'Ble Mi Ir','gr kur eh','uk ate _ _ _ _ _ _'],
        11 => [1,'Eo Syl Cal','gra ti wy','ce na se _ _ _ _ _ _'],
        12 => [1,'Bree Lor Rep','wy iz hi','se yre na _ _ _ _ _ _'],
        128 => [0,'','',''],
        130 => [0,'','',''],
        330 => [0,'','',''],
        522 => [0,'','',''],
    );
	my %neut = (
        1 => [0,'','',''],
        2 => [0,'','',''],
        3 => [0,'','',''],
        4 => [0,'','',''],
        5 => [0,'','',''],
        6 => [0,'','',''],
        7 => [0,'','',''],
        8 => [0,'','',''],
        9 => [0,'','',''],
        10 => [0,'','',''],
        11 => [0,'','',''],
        12 => [0,'','',''],
        128 => [0,'','',''],
        130 => [0,'','',''],
        330 => [0,'','',''],
        522 => [0,'','',''],
    );
	if ($npcGender == 0) {
		while (($nRace, $vName) = each (%male)) {
			if ($male{$nRace}[0] and $npcRace == $nRace) {
				@wa_first = split / /, $male{$nRace}[1];
				@wa_middle = split / /, $male{$nRace}[2];
				@wa_last = split / /, $male{$nRace}[3];
				plugin::wa_ChangeName();
			}
		}
	} elsif ($npcGender == 1) {
		while (($nRace, $vName) = each (%female)) {
			if ($female{$nRace}[0] and $npcRace == $nRace) {
				@wa_first = split / /, $female{$nRace}[1];
				@wa_middle = split / /, $female{$nRace}[2];
				@wa_last = split / /, $female{$nRace}[3];
				plugin::wa_ChangeName();
			}
		}
	} else {
		while (($nRace, $vName) = each (%neut)) {
			if ($neut{$nRace}[0] and $npcRace == $nRace) {
				@wa_first = split / /, $neut{$nRace}[1];
				@wa_middle = split / /, $neut{$nRace}[2];
				@wa_last = split / /, $neut{$nRace}[3];
				plugin::wa_ChangeName();
			}
		}
	}
}

######################################################
#:: Usage:			plugin::wa_ChangeName(); Changes the name of the npc of the input elements from plugin::wa_NameGenerator():
#:: Created:		16April2020
#:: Version:		wa_200419_01
#:: Author:			WarAngel
#:: Description:	Takes information and spits out a random name for npc
#:: With help from:	Dencelle
#:: Plugins:		plugin::val('$npc');plugin::RandomRange(0,100);
#:: Future Plans:	
#######################################################

sub wa_ChangeName
{
	my $npc = plugin::val('$npc');
	#plugin::Debug("Changename begin");

	$wa_TotalF = @wa_first; # count the TOTAL number of array elements.
	$wa_TotalM = @wa_middle;
	$wa_TotalL = @wa_last;

	$wa_ran1 = plugin::RandomRange(0,$wa_TotalF-1); # to pick which element in a array starting at 0. Since an array starts at 0 not 1.
	$wa_ran2 = plugin::RandomRange(0,$wa_TotalM-1);
	$wa_ran3 = plugin::RandomRange(0,$wa_TotalL-1);

	$wa_speak1 = ("$wa_first[$wa_ran1]");
	$wa_speak2 = ("$wa_middle[$wa_ran2]");
	$wa_speak3 = ("$wa_last[$wa_ran3]");

	$fullname = join ("","$wa_speak1","$wa_speak2","$wa_speak3");

	#plugin::Debug("Total number of elements " . $wa_TotalF . "");
	#plugin::Debug("Fullanme is " . $fullname . "");

	$npc->TempName("$fullname");
}

####################################
#:: Usage:			plugin::wa_RandomGender(). Be sure to ****place this BEFORE any other scripts that call on gender information.****
#:: Created:		22April2020
#:: Version:		wa_200422_02
#:: Author:			WarAngel... inspired by Trevius
#:: Description:	To generate genders randomly
#:: With help from:	My first successful solo script!
#:: Plugins:		$npc = plugin::val('$npc');
#:: Future Plans:	
####################################

sub wa_RandomGender
{
	my $npc = plugin::val('$npc'); #Who called this plugin?
	my $GenChance = int(rand(100)); #Random number 0-99
	if ($GenChance >= 49)
		{
			$npc->SetGender(0);
		}
	if ($GenChance < 49)
		{
			$npc->SetGender(1);
		}
	}
}

return 1;	#This line is required at the end of every plugin file in order to use it
