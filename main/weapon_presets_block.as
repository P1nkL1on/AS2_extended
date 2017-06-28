class weapon_presets_block {
	/*
			
		//set_a_gun(sp0, "enemy_rifle_bullet", Math.PI/30, 3, 60, 180, true, 40, 2, 3, 1, 'enemy_rifle', new Array(4,5)); set_a_gun_host(sp0, mouse); 
			function set_a_gun (who:MovieClip,
								ammo_type,			-1\undefined - DO NOT CONSUME THE AMMO {0 - bullets, 1 - shells, 2 - energys, 3 - bombs, -1 - none}
								bullet_type:		String, - bullet path in library {"rocket_bullet", "pistol_bullet", etc}
								bullet_spread:		Number, - angle of spread in rad. {Math.PI/3, Math.PI/15}
								realoadPartly:		Number, - frames between shots
								ammo:				Number, - max ammo
								reloadFull:			Number, - frames between refilling ammo
								automatic:			Boolean,- obvious
								host_dist:			Number, - distance on host hands in px. {20, -20, 0}
								ammo_per_shot:		Number, - ammo, consuming per 1 SHOT
								bullet_per_shot:	Number, - number off bullets, which fly out in 1 SHOT
								otdat:				Number, - per 1 BULLET
								effect_path:		String, - path of effect in library { "rocket_shot", "pistol_shoot" }  -- do not write "_effect" at end
								spread_stats:		Array,  - Array of random frames in spread { new Array(1,2,3) new Array(4,5), new Array(7,8,9,10) } 
								bullet_speed		number \ 'default'
								)
	*/
		// Стандартный отклик при загрузке
			static function Load (){
				_root.console_trace("* Weapon presets block loaded");
			}
			static var gun:MovieClip = null; 
			static var guns_total:Number = -1;
		// спавнит болванку для создания из нее пушки
		// указывай куда, путь в библиотеке и Х, У - если она не имеет хозяина или host + undefined - если у нее уже есть хозяин 
		// (будет автоматически вставлена ему в руки)
			static function export_gun (where:MovieClip, path:String, host, y0){
				++guns_total; where.attachMovie(path, path+'_'+guns_total, where.getNextHighestDepth()); gun = where[path+'_'+guns_total];
				if (y0 != undefined){ gun._x = host; gun._y = y0; }else{ weapon_block.set_a_gun_host(gun, host); }
			}
			
		// где, тип пушки, Х, У (аналогично), фуловая ли? (если не фуловая, то надо будет перезарядить перед использованием)
			static var type_based_path:String = "";
			static function spawn_a_gun (where, type:String, host, y0, isFull:Boolean){
					if (where == undefined || where == 'default'){ if (_root.player_layer != undefined)where = _root.player_layer; else where = _root; } 
				// spawn a bolvan
					export_gun (where, type, host, y0);
				// get it specialistics based on type of gun
					switch (type){
						case 'fast_gun':						weapon_block.set_a_gun(gun, 0, 'circle_bullet', Math.PI/20, 60, 30, 100, true, 10, 1, 1, 7, 'tommy_shoot', new Array(2,3),8); break;
						case 'laser_shotgun':					weapon_block.set_a_gun(gun, 2, 'laser_bullet', Math.PI/7, 10, 4, 200, true, 15, 4, 18, 3, 'laser_shoot', new Array(6,7,8),new Array(2,8)); break;
						case 'simple_tommygun':					weapon_block.set_a_gun(gun, 0, 'circle_bullet', Math.PI/20, 10, 40, 100, true, 15, 1, 1, 10, 'tommy_shoot', new Array(2,3),6); break;
						case 'rocket_launcher': 				weapon_block.set_a_gun(gun, 3, "rocket_bullet", Math.PI/18, 100, 3, 90, true, 0, 1, 1, 40, "rocket_shoot", new Array(1,2,3), 5); break;
						case 'simple_sawed_off_shotgun':		weapon_block.set_a_gun(gun, 1, "slow_bullet", Math.PI/3, 50, 2, 120, false, 18, 2, 12, 4, "pistol_shoot", new Array(1,2,3), new Array(4,10)); break;
						case 'simple_shotgun':					weapon_block.set_a_gun(gun, 1, "slow_bullet", Math.PI/6,5, 1, 95, false, 10, 1, 5, 5, "pistol_shoot", new Array(1,2,3), new Array(4,10)); break;
						case 'simple_pistol':					weapon_block.set_a_gun (gun, 0); break;
						default: _root.console_trace("# No weapon in library with type '"+type+"'"); weapon_block.set_a_gun (gun); break;
					}
				// updates
					gun.onEnterFrame = function (){ weapon_block.being_a_gun(this); }
				// loads
					if (isFull !=undefined && !isFull) gun.current_ammo = 0;
			}
}