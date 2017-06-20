class unit_block {
	// READ!!!!!!!!!!!!!!!!!!
	// в юните, который подлежит спавну, НЕ ДОЛЖНО быть внутренней enterFrame функции, чтобы они не наслаивались друг на друга
	// то, что должно проиойти таким образом заворачивать в ф-ю  function InnerEnterFrame ():Void{...}
	
		function Load(){
			_root.console_trace("* Unit AI block loaded");
		}
	
		var now_units:Number = 0;
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
				total_units++; now_units++;
				where.attachMovie(path+'_unit', "unit_"+total_units, where.getNextHighestDepth()); var who = where["unit_"+total_units];
				who._x = x0; who._y = y0;  if (direct != undefined && direct != 0)who._xscale *= (direct)/Math.abs(direct); who.path = path;
			// массив - туда складывается все, что порождает об-т
				who.borned = new Array();
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
						_root.units_block.being_dead_remove (this)
						
				}
				// корректное удаление из массива all_hitable
				who.onUnload = function (){
					_root.units_block.now_units --; 
					for (var i=0; i<this.borned.length; i++)
						this.borned[i].removeMovieClip(); 	// очищаешь все, что создал для себя
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
// AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK 
// AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK 
// AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK // AI LOAD BLOCK 
	
	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		function set_AI (who:MovieClip, AIpath:String, power:Number):Boolean{
			// стандартные значения пути и силы. Путь при неправильности - выкидывает к чертям
				if (AIpath == undefined){ _root.console_trace("# Invalid AI path"); return false;}
				if (power == undefined){ _root.console_trace("# Invalid power given. Set to 1"); power = 1; }
			// для обработки параметров фун-цией being_AI
				who.AI_profile = AIpath; who.AI_power = power;
			// общие для джентов, роботов и др
				switch (who.path){
					case "robot":
								_root.attachMovie("view_field","vf_"+who, _root.getNextHighestDepth()); who.viewfield = _root["vf_"+who]; who.borned.push(who.viewfield);
								_root.attachMovie("sound_mark","sm_"+who, _root.getNextHighestDepth()); who.hear = _root["sm_"+who];	  who.borned.push(who.hear);
							// таймер жизни, частота скана
								who.acs = .015; who.sound_profile = 'robot';
								who.warned = true; who.lifetime = -random(360); who.scanEvery = 30; who.warningTimer = 0;
							// направление взгляда и цели
								who.watch_angle = Math.PI*(random(200)/100); who.targ = null; who.targ_was = null; who.sped = 0;
							// дистанция взгляда, ширина поля зрения, координаты последней цели
								who.view_distance = 200; who.view_angle = Math.PI; who.targ_x =Number.NaN; who.targ_y = Number.NaN;
							// увеличивают на сцене размер филда
								who.viewfield._xscale = who.view_distance; who.viewfield._yscale = who.view_distance;
							
							// progressive AI
								who.targ_sp_x = 0; who.targ_sp_y = 0; who.targ_x0 = 0; who.targ_y0 = 0; who.hp2 = 0;
							break;
					case "jent":
							break;
					default:
							break;
				}
			// частичности
				switch (AIpath){
					case "robot_usuall":
								who.followX = 600; who.followY = 0; who.drops = 8; who.hpmax = 4; who.hp = 4;
								// leave view parameters default
								return true;
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
		
// ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK
// ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK
// ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK // ENTER FRAME BLOCK
	var WarningTime:Number = 120 * 15;
	// AI intellectuals
	// настраивает профиль юнита с точки зрения AI
		function being_AI (who:MovieClip){
			if (who.AI_profile == undefined){ _root.console_trace("# "+who._name+" has no AI profile");return; }
			
			// общие для джентов, роботов и др
				switch (who.path){
					case "robot":
						//death
							if (who.hp<=0){ who.sp_x = 0; drop_random_items(who); return; }
						// eye update
							
						//life
							for (var u=0; u<_root.updates; u++){
										who.lifetime++;
									// scan process
										if (who.lifetime % who.scanEvery == 0){who.targ_was = who.targ; if (who.targ_was!=null){who.targ_x = who.targ_was._x; who.targ_y = who.targ_was._y - who.targ_was._height/2; who.targ_x0 = who.targ_x; who.targ_y0 = who.targ_y;}
																			   who.targ = _root.units_block.chooseClosestTargetAngle (who, who.view_angle, who.view_distance);}
									//  standart scan
										if (who.targ == null && who.targ_was == null)
											{ 	if (who.hp < who.hp2)who.targ = who.hitBy; who.hp2 = who.hp;
												if (isNaN(who.targ_x)){who.watch_angle -= Math.PI / 1600; who.scanEvery = 60; who.warned = true;}		// scan passivly first
																else{ if (who.warning_time-->0){
																		who.scanEvery = 20;
																		who.targ_x += who.targ_sp_x; who.targ_sp_x /= 1.02; // approxxime movement
																		who.targ_y = Math.min(who.targ_y + who.targ_sp_y, _root.StageHeight-60); who.targ_sp_y += _root.G/2;
																		watchTo(who, .5*(who.targ_x+who.targ_x0), .5*(who.targ_y+who.targ_y0));}		// follow last hear time
																	  	
																	  else{ who.targ_x = Number.NaN; who.targ_y = Number.NaN; }}}	
										else{ who.scanEvery = 4; if (who.targ!=null){watchTo(who, who.targ); 
											if (who.warning_time <= 0){_root.sound_start("npc/other/alert"); /*fun*/who.sp_y -= 4;}// SPOTTED
											who.warning_time = WarningTime;
											if (random(10)==0 && who.warned){who.warned =  !( inform_other(who)); }// inform all other
										// remember target movement
											who.targ_sp_x = who.targ.sp_x + who.targ.sp_x0; who.targ_sp_y = who.targ.sp_y + who.targ.sp_y0; }}
										
									//movement
										who.sped = -(2*(who._x > .5*(who.targ_x+who.targ_x0))-1); if (isNaN(who.targ_x))who.sped = 0;
										wantMove(who, 3, who.sped,  0, 0);
										if (who.warning_time>0 && who.ground && !(who.jump_cd-- > 0) && random(30)==0 ){ who.jump_cd = 240+random(240); who.sp_y -= 2+random(6); }
									// scene trace
										 who.hear._alpha = 100* who.warning_time / WarningTime;if (isNaN(who.targ_x)){ who.hear._visible = false; }else{ who.hear._visible = true; who.hear.f1._x = who.targ_x; who.hear.f1._y = who.targ_y; who.hear.f2._x = who.targ_x0; who.hear.f2._y = who.targ_y0; who.hear.fin._x = .5*(who.targ_x+who.targ_x0); who.hear.fin._y = .5*(who.targ_y+who.targ_y0); }
										 who.viewfield.gotoAndStop( 1+(who.targ!=null) );
										 who.viewfield._x = who._x + who.head._x;   who.viewfield._y = who._y + who.head._y;  who.viewfield._rotation = who.watch_angle / Math.PI*180;
							}
							break;
					case "jent":
							break;
					default:
							break;
				}
			// ЧАСТНОСТИ для AI
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
						else{	drop_random_items(who);}
						return;
					
					default: 
						break;
				}
			_root.console_trace("# No AI profile with name "+who.AI_profile+"!");
		}
		
		
// special functions
	// вспомогательные модули
		function chooseClosestTarget (who:MovieClip):MovieClip{
			can_be_target = new Array();
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
		// дистанция высчитывается между началами мувиклипов
			var dist1 = Math.sqrt(Math.pow(_x - t1._x,2)+Math.pow(_y - t1._y + t1._height/2,2));
			var dist2 = Math.sqrt(Math.pow(_x - t2._x,2)+Math.pow(_y - t2._y + t2._height/2,2));
			if (dist1 > dist2)return -1; if (dist2 < dist1)return 1; return 0;
		} 
	// select someone in front of view
	// находит цель по смотрящему, его углу обзора и дистанции максимального взгляда
	// необходимый парметр смотрящего :: watch_angle - куда он смотрит сейчас
		var can_be_target = new Array();
		var en = null;
		var ang = 0;
		var fin_ang = 0;
		function chooseClosestTargetAngle (who:MovieClip, angle:Number, dist:Number):MovieClip{
			// определенее угла просмотра
				if (who.watch_angle == undefined){ _root.console_trace("# "+who._name+" have no watch_agnle!"); who.watch_angle = 0; }
			// корректировка watch_agnle, если он не в диапазоне [0..2*PI]
				while (who.watch_angle<-Math.PI)who.watch_angle+=2*Math.PI; while (who.watch_angle>Math.PI)who.watch_angle-=2*Math.PI;
			// пихает в массив возможных целей
				can_be_target = new Array();
			// по всем hitable, если не обстановка и команда не равна твоей
				for (var i=0; i<_root.all_hitable.length; i++)if ( _root.all_hitable[i].team > 0 &&  _root.all_hitable[i].team != who.team){
					en = _root.all_hitable[i];
				// разгица углов по тригонометрическим фигням
					ang = Math.atan2( en._y - en._height/2 - who._y+who._height/2, en._x - who._x );
					fin_ang = ang - who.watch_angle;
					fin_ang = Math.abs(fin_ang); while (fin_ang>Math.PI)fin_ang -= Math.PI; if (Math.abs(ang - who.watch_angle)>Math.PI)fin_ang = Math.abs(fin_ang - Math.PI);
					_root.tt.text= Math.round(fin_ang/Math.PI*180);
				// проверка разностей по углам и дистанции
					if (fin_ang<angle/2 && Math.sqrt(Math.pow(en._x - who._x,2) + Math.pow( en._y - en._height/2 - who._y+who._height/2,2 ) )<dist)
						can_be_target.push(en);
				}
			// сортирует по расстоянию от смотрящего
				can_be_target.sort(order);	// closest one
			// если не обнаружено ничего
					if (can_be_target.length == 0)return null;
					return can_be_target[0]; 
		}
		
	// выставляет угол зрения на соотсветствующий угол
		function watchTo (who:MovieClip, x0, y0){
			if (y0 == undefined){
				who.watch_angle = Math.atan2( -who._y + who._height/2 + x0._y,-who._x + x0._x );
			}else{
				who.watch_angle = Math.atan2( -who._y + who._height/2 + y0,-who._x +x0 );
			}
		}
	// become more standart movement
	// goto = {-1, 0, 1}
	// wantJump = {-1, 0, 1}
		function wantMove (who:MovieClip, sp_x_max:Number, goto:Number, sp_y_max:Number, wantJump:Number){
			if (goto > 0) who.sp_x += goto*who.acs * (who.sp_x < sp_x_max)*(1 + 2*(who.sp_x < 0));
			if (goto < 0) who.sp_x += goto*who.acs * (who.sp_x > -sp_x_max)*(1 + 2*(who.sp_x > 0));
			if (goto == 0 && who.ground){if (Math.abs(who.sp_x)>.1)who.sp_x /= who.tormoz; else who.sp_x = 0;}
		}
	// massive alert!
		var alarmed = 0;
		function inform_other (who:MovieClip):Boolean{
			alarmed = 0;
			for (var i=0; i<_root.all_hitable.length; i++)
				if (_root.all_hitable[i].warning_time <= 0 && _root.all_hitable[i].team == who.team && Math.sqrt(Math.pow(_root.all_hitable[i]._x - who._x,2) + Math.pow(_root.all_hitable[i]._y - who._y,2))<300)
					{ _root.all_hitable[i].targ_x = who.targ._x;  _root.all_hitable[i].targ_y = who.targ._y;  _root.all_hitable[i].warning_time = WarningTime; alarmed++;}
			return (alarmed>0);
		}
		
		function drop_random_items (who){
			for (var n=0;n<_root.updates; n++){																					//
					if ( random(5)==0 && who.drops-->0){																		// drop goods on death
							var isMed = (random(3) == 0);																		// randomise drops
							_root.spawn_pickup (who._x, who._y - 20, (1+random(4))*!isMed + -1*isMed, random(3), 240*10);		// spawn drops
				}}
		}
}