execVM "briefing.sqf";
enableSaving [false, false];
enableSentences false;
sleep 1;
gameonscript = [startB, startO, leadB, leadO, [ofheli, bftruck1, bftruck2]] execVM "gameon.sqf";
junk setDamage 1;


if (side player == west) then {
	if (!(isnil "Alpha")) then {
		Alpha addGroupIcon ["b_inf",[0,0]];
		Alpha setGroupIconParams [[0,.25,1,1],"A",1,true];
	};
	if (!(isnil "Bravo")) then {
		Bravo addGroupIcon ["b_inf",[0,0]];
		Bravo setGroupIconParams [[0,.25,1,1],"B",1,true];
	};
	if (!(isnil "Lead")) then {
		Lead addGroupIcon ["b_inf",[0,0]];
		Lead setGroupIconParams [[0,.25,1,1],"SL",1,true];
	};
	setGroupIconsVisible [true,false];
	deleteMarkerLocal "ofgoalmarker";
	
	player addItem "AGM_CableTie";
	player addItem "AGM_CableTie";
	player unassignItem "rhsusf_ANPVS_14";
	player removeitem "rhsusf_ANPVS_14";

};

if (side player == east) then {
	if (!(isnil "Pilot")) then {
		Pilot addGroupIcon ["b_air",[0,0]];
		Pilot setGroupIconParams [[0,.25,1,1],"Rook",1,true];
	};
	if (!(isnil "Ground")) then {
		Ground addGroupIcon ["b_recon",[0,0]];
		Ground setGroupIconParams [[0,.25,1,1],"Knight",1,true];
	};
	setGroupIconsVisible [true,false];
	deleteMarkerLocal "bfgoalmarker";
	"bf1" setMarkerColorLocal "ColorRed";
	"bf2" setMarkerColorLocal "ColorRed";
};

if (side player == independent) then {

};

if (isserver) then {

	waituntil{scriptDone gameonscript};
	{_x setMarkerAlpha .2} foreach ["marker_fug1", "marker_fug2", "marker_fug3"];

	[] spawn {
		_cutterarray = [];
		{
			if (typeOf _x == "ClutterCutter_EP1") then {
			_cutterarray = _cutterarray + [_x];
			};
		}foreach list trig1;

		_crashpos = getpos (_cutterarray select random count _cutterarray);
		helis setpos _crashpos;
		helis setdir random 360;
		helis setDamage 1;

		{
			_safe = false;
			while {!_safe} do {
				_startPos = [_crashpos, 50, 60, 1, 0, 1, 0, [], [[1,1,1],[1,1,1]]] call BIS_fnc_findSafePos;
			
				if ((_startPos select 0) != 1) then {
					_safe = true;
					_x setpos _startPos;
					_x setDir random 360;
				};
			};
		} foreach [fug1, fug2, fug3];

		
		while
		{!(
			(
				({(side _x == civilian)&&(_x in [fug1,fug2,fug3])}count list goalB)
				+ 
				({(side _x == independent)&&(_x in [fug1,fug2,fug3])}count list goalO)
				== {alive _x}count [fug1,fug2,fug3]
			) or (
				{alive _x}count [fug1,fug2,fug3] == 0
			)
		)} do {
			sleep 5;
		};
		
		if ({alive _x}count [fug1,fug2,fug3] == 0) then {
		
			["All fugitives are dead!", "systemChat", true, false, true ] call BIS_fnc_MP;
			sleep 3;
			[["End1", false], "BIS_fnc_endMission", true, false, false] call BIS_fnc_MP;
			
		} else {
		
			_bscore = ({(side _x == civilian)&&(_x in [fug1,fug2,fug3])}count list goalB);
			_oscore = ({(side _x == independent)&&(_x in [fug1,fug2,fug3])}count list goalO);
		
			[ "All living fugitives are secured!", "systemChat", true, false, true ] call BIS_fnc_MP;
			sleep 1;
			[
				(format [
					"BLUFOR captured %1, OPFOR rescued %2.", 
					({(side _x == civilian)&&(_x in [fug1,fug2,fug3])}count list goalB),
					({(side _x == independent)&&(_x in [fug1,fug2,fug3])}count list goalO)
				]),
			"systemChat", true, false, true ] call BIS_fnc_MP;
			sleep 3;
			
			if (_bscore > _oscore) then {
				[["End2",(side player == west)],"BIS_fnc_endMission", true, false, true ] call BIS_fnc_MP;
			};	
			if (_bscore < _oscore) then {
				[["End3", (side player == east)],"BIS_fnc_endMission", true, false, true ] call BIS_fnc_MP;
			};
			if (_bscore == _oscore) then {
				["End4","BIS_fnc_endMission", true, false, true ] call BIS_fnc_MP;
			};
		};
	};

	[] spawn {
		_prevpos1 = getpos fug1;
		_rad1 = 500;
		while {!isnull fug1} do {
			sleep 30;
			_disp1 = _prevpos1 distance fug1;
			switch (true) do {
				case (_disp1 > 200): {_rad1 = 90};
				case (_disp1 > 160): {_rad1 = 150};
				case (_disp1 > 120): {_rad1 = 300};
				case (_disp1 > 100): {_rad1 = 400};
				case (_disp1 > 60): {_rad1 = 450};
				default {_rad1 = 500};
			};
			_ranDis1 = random (_rad1*.3);
			_ranDir1 = random 360;
			"marker_fug1" setmarkerpos [(getpos fug1 select 0) + _ranDis1 * (sin (_ranDir1 + 180)),(getpos fug1 select 1) + _ranDis1 * (cos (_ranDir1 + 180))];
			"marker_fug1" setMarkerSize [_rad1,_rad1];
			_prevpos1 = getpos fug1;
		};
	};

	[] spawn {
		_prevpos2 = getpos fug2;
		_rad2 = 500;
		while {!isnull fug2} do {
			sleep 30;
			_disp2 = _prevpos2 distance fug2;
			switch (true) do {
				case (_disp2 > 200): {_rad2 = 60};
				case (_disp2 > 160): {_rad2 = 150};
				case (_disp2 > 120): {_rad2 = 300};
				case (_disp2 > 100): {_rad2 = 400};
				case (_disp2 > 60): {_rad2 = 450};
				default {_rad2 = 500};
			};
			_ranDis2 = random (_rad2*.3);
			_ranDir2 = random 360;
			"marker_fug2" setmarkerpos [(getpos fug2 select 0) + _ranDis2 * (sin (_ranDir2 + 180)),(getpos fug2 select 1) + _ranDis2 * (cos (_ranDir2 + 180))];
			"marker_fug2" setMarkerSize [_rad2,_rad2];
			_prevpos2 = getpos fug2;
		};
	};

	[] spawn {
		_prevpos3 = getpos fug3;
		_rad3 = 500;
		while {!isnull fug3} do {
			sleep 30;
			_disp3 = _prevpos3 distance fug3;
			switch (true) do {
				case (_disp3 > 200): {_rad3 = 60};
				case (_disp3 > 160): {_rad3 = 150};
				case (_disp3 > 120): {_rad3 = 300};
				case (_disp3 > 100): {_rad3 = 400};
				case (_disp3 > 60): {_rad3 = 450};
				default {_rad3 = 500};
			};
			_ranDis3 = random (_rad3*.3);
			_ranDir3 = random 360;
			"marker_fug3" setmarkerpos [(getpos fug3 select 0) + _ranDis3 * (sin (_ranDir3 + 180)),(getpos fug3 select 1) + _ranDis3 * (cos (_ranDir3 + 180))];
			"marker_fug3" setMarkerSize [_rad3,_rad3];
			_prevpos3 = getpos fug3;
		};
	};
};

/* 
// refueling trigger condition

(ofheli in (list helipad))&&((getpos ofheli) select 2 < 1)&&((fuel ofheli) < 0.6);

// on act.

refuelaction = (driver ofheli) addaction [
	"Refuel, 20 minutes flight",
	{
		[ 40 ,[{
			[[[], {ofheli setfuel 0.16;}], "BIS_fnc_spawn", ofheli] call BIS_fnc_MP;
		}],"BIS_fnc_spawn","   Refueling..."]call AGM_Core_fnc_progressBar;

		(driver ofheli) removeaction refuelaction;

	}, (driver ofheli),0,true,true
];

// on dea.

(driver ofheli) removeAction refuelaction;


//

unburdened littlebird takes .008 fuel a minute, 20 minutes of fuel is only .16

[] spawn {while {true} do {sleep 10; systemchat format["fuel: %1", (fuel ofheli)]};}