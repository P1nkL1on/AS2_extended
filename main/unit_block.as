class unit_block {
	// READ!!!!!!!!!!!!!!!!!!
	// в юните, который подлежит спавну, НЕ ДОЛЖНО быть внутренней enterFrame функции, чтобы они не наслаивались друг на друга
	// то, что должно проиойти таким образом заворачивать в ф-ю  function InnerEnterFrame ():Void{...}
	
		function Load(){
			_root.console_trace("* Unit AI block loaded");
		}
	
	
		var total_units:Number = -1;
		
	// Спавнит юнита из библиотеки на сцену (куда хочешь)
	// path - указание пути к инстансу в библиотеке, where - мувиклип окр. среды
	// AIpath - идентификатор поведенческой линии (посылается в функцию setAI beingAI и тд.)
	//		{ path = "jent", AIpath = "jent_shooting", power = "10"} || {  path = "jent", AIpath = "jent_passive", power = "0" }
	// team - команда, x0, y0,  - координаты
	// power - задаёт параметры соответственно АИ поведению
		function spawn_a_unit (where, path:String, AIpath:String, power:Number, x0, y0, team:Number, direct:Number){
			// стандартные значения
				if (where == 'default' || where == undefined) {if (_root.unit_layer == undefined)where = _root; else where = _root.unit_layer;}
				if (team == undefined)team = 0; if (x0 == undefined || y0 == undefined){ x0 = 0; y0 = 0; _root.console_trace("# Invalid spawn coordinates (_x, _y)"); }
			// spawn
				total_units++;
				where.attachMovie(path+'_unit', "unit_"+total_units, where.getNextHighestDepth()); var who = where["unit_"+total_units];
				who._x = x0; who._y = y0;  if (direct != undefined && direct != 0)who._xscale *= (direct)/Math.abs(direct);
			// внут пр-ые
				who.dead_timer = 0;
			// стандартные процедуры
				_root.set_moveble (who, .02, 1.04);			// все юниты перемещаются
				who.ground = false;							// переопределение земли
				_root.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
				_root.set_hitable (who, team);				// и могут быть отпинаны
				set_AI (who, AIpath, power);				// задаем интеллект
				who.onEnterFrame = function (){
					// какие-то общие черты всех юнитов
						_root.units_block.being_common (this);
					// персональные в зависимости от АИ
						_root.units_block.being_AI(this);
					// исчезание
						//_root.units_block.being_dead_remove (this)
						
				}
				// корректное удаление из массива all_hitable
				who.onUnload = function (){
					var ID = Number.POSITIVE_INFINITY; 	// чудеса техники - поиск и сдвиг в одном цикле!
					for (var i=0; i<_root.all_hitable.length; i++){ if (_root.all_hitable[i] == this) ID = i; if (i>ID)_root.all_hitable[i-1] = _root.all_hitable[i]; }
					if (ID < _root.all_hitable.length) _root.all_hitable.pop();
				}
		}
		var decay_time:Number = 600;
		function being_dead_remove (who:MovieClip){
			who.dead_timer += _root.timeElapsed*(who.dead == true);
			who._visible =(( Math.round(who.dead_timer/5)%2 == 0) || ( (who.dead_timer < decay_time / 6*5) ));
			if (who.dead_timer > decay_time)who.removeMovieClip();
		}
		
		// для сокращения писанины
		function being_common (who:MovieClip){
			who.InnerEnterFrame ();
			_root.being_moveble (who);
			_root.being_hitable (who);
		}
	
	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		function set_AI (who:MovieClip, AIpath:String, power:Number):Boolean{
			// стандартные значения пути и силы. Путь при неправильности - выкидывает к чертям
				if (AIpath == undefined){ _root.console_trace("# Invalid AI path"); return false;}
				if (power == undefined){ _root.console_trace("# Invalid power given. Set to 1"); power = 1; }
			// для обработки параметров фун-цией being_AI
				who.AI_profile = AIpath; who.AI_power = power;
				switch (AIpath){
					case "jent_passive":
								who.watchTo = _root.mouse; who.wY_offset = -20;
								/*do something*/ 
						return true;
					case "jent_shooting":
								who.watchTo = null; who.wY_offset = -20;
								who.gun_timer = 0; who.drops = random(5); who.bullets = 0;				
						return true;
					case "none":							// default AI, just stand and being hitable
								who.onEnterFrame = function (){
									being_common (this);
								}
						return true;					
					default:
						_root.console_trace("# No AI profile with name "+AIpath+" ("+power+")");return false;
				}
		}
		
	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		function being_AI (who:MovieClip){
			if (who.AI_profile == undefined){ _root.console_trace("# "+who._name+" has no AI profile");return; }
			switch (who.AI_profile){
				case "none": return;
				case "jent_passive": return;
				case "jent_shooting":
					if (who.hp>0){for (var i=0; i<_root.updates; i++){	
						if ((who.watchTo == null || who.watchTo.hp<=0) && who.gun_timer%120==0)who.watchTo = chooseClosestTarget(who);//choosing a target
					
						if (who.gun_timer++%15==0 && who.bullets-->0)										// bullet timing
							_root.spawn_a_bullet ( _root.enemy_bullets, 'enemy_rifle_bullet', who._x, who._y - 50, 'default',							// shooting
												Math.atan2(who._y - who.watchTo._y - who.watchTo._height/2, who._x - who.watchTo._x)+Math.PI, 'default', new Array(4,5), who);	// shooting
						if (who.gun_timer%240 == 0 && who.watchTo.hp > 0)who.bullets = Math.round((3+random(3))*who.AI_power);}}	// reloading
					else{																											//
							for (var n=0;n<_root.updates; n++){																		//
							if ( random(5)==0 && who.drops-->0){																	// drop goods on death
								var isMed = (random(3) == 0);																		// randomise drops
								_root.spawn_pickup (who._x, who._y - 20, (1+random(4))*!isMed + -1*isMed, random(3), 240*10);		// spawn drops
						}}}
					return;
				
				default: 
					_root.console_trace("# No AI profile with name "+who.AI_profile+"!");return;
			}
		}
		
		
		
	// вспомогательные модули
		function chooseClosestTarget (who:MovieClip):MovieClip{
			var can_be_target = new Array();
				for (var i=0; i<_root.all_hitable.length; i++)
					if (_root.all_hitable[i].team >0 && _root.all_hitable[i].team != who.team && _root.all_hitable[i].hp>0)
						can_be_target.push(_root.all_hitable[i]);//target = _root.mouse; 
				can_be_target.sort(order);
				if (can_be_target.length == 0)return null;
				return can_be_target[0]; 
		}
		
		// target choosing
	// для сортировки целей по расстояниям
		function order(t1, t2):Number { 
			var dist1 = Math.sqrt(Math.pow(_x - t1._x,2)+Math.pow(_y - t1._y + t1._height/2,2));
			var dist2 = Math.sqrt(Math.pow(_x - t2._x,2)+Math.pow(_y - t2._y + t2._height/2,2));
			if (dist1 > dist2)return -1; if (dist2 < dist1)return 1; return 0;
		} 

}