class unit_block {
	// READ!!!!!!!!!!!!!!!!!!
	// в юните, который подлежит спавну, НЕ ДОЛЖНО быть внутренней enterFrame функции, чтобы они не наслаивались друг на друга
	// то, что должно проиойти таким образом заворачивать в ф-ю  function InnerEnterFrame ():Void{...}
	
		static function Load(){
			_root.console_trace("* Unit AI block loaded");
		}
	
		static var now_units:Number = 0;
		static var total_units:Number = -1;
	// последний юнит
		static var last_unit = null;
	// Спавнит юнита из библиотеки на сцену (куда хочешь)
	// path - указание пути к инстансу в библиотеке, where - мувиклип окр. среды
	// AIpath - идентификатор поведенческой линии (посылается в функцию setAI beingAI и тд.)
	//		{ path = "jent", AIpath = "jent_shooting", power = "10"} || {  path = "jent", AIpath = "jent_passive", power = "0" }
	// team - команда, x0, y0,  - координаты
	// power - задаёт параметры соответственно АИ поведению
		static function spawn_a_unit (where, path:String, AIpath:String, power:Number, x0, y0, team:Number, direct:Number){
			// стандартные значения
				if (where == 'default' || where == undefined) {if (_root.unit_layer == undefined)where = _root; else where = _root.unit_layer;}
				if (team == undefined)team = 0; if (x0 == undefined || y0 == undefined){ x0 = 0; y0 = 0; _root.console_trace("# Invalid spawn coordinates (_x, _y)"); }
			// spawn
				total_units++; now_units++;
				where.attachMovie(path+'_unit', "unit_"+total_units, where.getNextHighestDepth()); var who = where["unit_"+total_units];
				who._x = x0; who._y = y0;  if (direct != undefined && direct != 0)who._xscale *= (direct)/Math.abs(direct); who.path = path;
			// массив - туда складывается все, что порождает об-т
				who.borned = new Array(); who.isUnit = true;
			// внут пр-ые
				who.dead_timer = 0;
			// стандартные процедуры
				inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
				who.ground = false;								// переопределение земли
				inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
				inter_block.set_hitable (who, team);			// и могут быть отпинаны
				who.mass = Math.round(who._width * who._height / 160); trace(who+" ("+who.mass+")");									// юниты несколько тяжелее, чем обычные предметы
				set_AI (who, AIpath, power);					// задаем интеллект
				_root.set_status_bar (_root.unit_layer, who);	// статус бар =D
					who.onEnterFrame = function (){
						// какие-то общие черты всех юнитов
							being_common (this);
						// персональные в зависимости от АИ
							being_AI(this);
						// исчезание
							being_dead_remove (this)
						// drops
							if (this.hp <=0 )for (var u=0; u<_root.updates; u++)drop_random_items(who);
					}
				// корректное удаление из массива all_hitable
					who.onUnload = function (){
						now_units --; 
						for (var i=0; i<this.borned.length; i++)
							this.borned[i].removeMovieClip(); 	// очищаешь все, что создал для себя
						var ID = Number.POSITIVE_INFINITY; 	// чудеса техники - поиск и сдвиг в одном цикле!
						for (var i=0; i<_root.all_hitable.length; i++){ if (_root.all_hitable[i] == this) ID = i; if (i>ID)_root.all_hitable[i-1] = _root.all_hitable[i]; }
						if (ID < _root.all_hitable.length) _root.all_hitable.pop();
					}
				last_unit = who;
		}
		
	// dead remove body problems
		static var decay_time:Number = 600;
		static function being_dead_remove (who:MovieClip){
			who.dead_timer += _root.timeElapsed*(who.dead == true);
			who._visible =(( Math.round(who.dead_timer/5)%2 == 0) || ( (who.dead_timer < decay_time / 6*5) ));
			if (who.dead_timer > decay_time)who.removeMovieClip();
		}
		
	// для сокращения писанины
		static function being_common (who:MovieClip){
			who.InnerEnterFrame ();
			inter_block.being_moveble (who);
			inter_block.being_hitable (who);
		}

	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		static function set_AI (who:MovieClip, AIpath:String, power:Number):Boolean{
			// стандартные значения пути и силы. Путь при неправильности - выкидывает к чертям
				if (AIpath == undefined){ _root.console_trace("# Invalid AI path"); return false;}
				if (power == undefined){ _root.console_trace("# Invalid power given. Set to 1"); power = 1; }
			// для обработки параметров фун-цией being_AI
				who.AI_profile = AIpath; who.AI_power = power;
			// общие для джентов, роботов и др
				switch (who.path){
					case "robot":			AI_robot.set_AI(who);	break;
					case "jent": 			AI_jent.set_AI(who);	break;
					case "mouse":
					case "hamster":			AI_mouse.set_AI(who); 	break;
					default: 				break;
				}
			// частичности
				switch (AIpath){
					case "robot_usuall": AI_robot_usuall.set_AI(who);	return true;
					case "jent_passive": AI_jent_passive.set_AI(who); 	return true;
					case "jent_shooting":AI_jent_shooting.set_AI(who); 	return true;
					case "jent_dummy":	 AI_jent_dummy.set_AI(who); 	return true;
					case "player": 		 AI_player.set_AI(who); 		return true;
					case "none":		 who.onEnterFrame = function (){being_common (this);}; return true;					
					default: 			_root.console_trace("# No AI profile with name "+AIpath+" ("+power+")"); return false;
				}
		}


	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		static function being_AI (who:MovieClip){
			if (who.AI_profile == undefined){ _root.console_trace("# "+who._name+" has no AI profile");return; }
			
			// общие для джентов, роботов и др
				switch (who.path){
					case "robot":AI_robot.being_AI(who);break;
					case "jent":break;
					default:break;
				}
			// ЧАСТНОСТИ для AI
				switch (who.AI_profile){
					case "player": 		  AI_player.being_AI(who);	return;
					case "none": 									return;
					case "jent_passive": 							return;
					case "jent_shooting": AI_jent_shooting.being_AI (who); 	return;
					case "jent_dummy": 	  AI_jent_dummy.being_AI (who); 	return;
					case "robot_usuall": 							return;
					default: 										break;
				}
			_root.console_trace("# No AI profile with name "+who.AI_profile+"!");
		}
	// Просто дроп предметов с поверженного врага
		static function drop_random_items (who){
			for (var n=0;n<_root.updates; n++){																					//
					if ( random(5)==0 && who.drops-->0){																		// drop goods on death
							var isMed = (random(3) == 0);																		// randomise drops
							ammo_block.spawn_pickup (who._x, who._y - 20, (1+random(4))*!isMed + -1*isMed, random(3), 240*10);	// spawn drops
				}}
		}
		static function drop_need_items (who){
			for (var n=0;n<_root.updates; n++){																					//
					if ( random(5)==0 && who.drops-->0)																		// randomise drops
							ammo_block.spawn_pickup (who._x, who._y - 20, detect_need_ammo (who.last_hited_by), random(3), 240*10);	// spawn drops
				}
		}
		
		static function detect_need_ammo (who){
			if (who == null || who == undefined || who.hp < 0 || who.dead) return null;
			if ((random(2 + Math.round(6-who.hp / who.hpmax * 6))==0) && (who.hp < who.hpmax)) return -1;	// detect if target need health
			if (who.weaponActive < 0) return null;																					// если не носит оружие, то ему не нужны патроны
			var rnd_weapon = random(who.weapons.length);																			// выбрать патрон ля случайного оружия в запасе
			if (who.Ammo[who.weapons[rnd_weapon].ammo_type] < who.Ammo_max[who.weapons[rnd_weapon].ammo_type]) 
				return who.weapons[rnd_weapon].ammo_type+1;	// если оно неполное конечно
			return who.weapons[who.weaponActive].ammo_type+1;																		// энивей вернуть патрон для активного
		}
}