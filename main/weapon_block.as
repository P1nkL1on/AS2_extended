class weapon_block {
	
			static function Load (){
				_root.console_trace ("* Weapon block loaded");
			}
	
		// на сколько затемнять пуху, которая висит за спиной
			static var shadow_level = 75;	
		// существо, которое может держать пушку (предположительно любую)
		// устанавливает массив пушек пустым, активное оружие -1, pQ, wA, wL - предыдущие значения этимх перемененных (wL == weapon.length)
			static function set_a_gun_holder (gunner:MovieClip){ gunner.weapons = new Array(); gunner.weaponActive = -1; gunner.pQ = 0; gunner.wA = -1; gunner.wL = 0;  }			
		
		// каждый апдейт на держателе пушек
			static function being_a_gun_holder (gunner:MovieClip){
					if (gunner.weaponActive != gunner.wA || gunner.weapons.length != gunner.wL){ gunner.wA = gunner.weaponActive;	gunner.wL = gunner.weapons.length;					//запрос на перераспределение глубин только при смене активного или добавлении нового
						for (var i=0; i<gunner.weapons.length; i++){ if (i == gunner.weaponActive)																						//
						{gunner.weapons[i].swapDepths( gunner.getDepth()+1 );  gunner.weapons[i].clr.setTransform({rb:0, gb:0, bb:0});}													//светлое оружие в руках
						else {gunner.weapons[i].swapDepths( gunner.getDepth()-1 - i ); gunner.weapons[i].clr.setTransform({ rb:-shadow_level, gb:-shadow_level, bb:-shadow_level })}}}	//каждое оружие на своем слое глубины (обеспечение оружия за спиной)
					
					if ((gunner.keypresses[7]>0 && gunner.keypresses[7]<60) && gunner.weapons.length>=2)																				//если у владельца есть желание сменить пушку
						{ gunner.keypresses[7] = 360;  gunner.weapons[ gunner.weaponActive ]._rotation = random(40)-20;																	//предыдущее оружие неактивное случайно повернуто и за спиной
					gunner.weaponActive = (gunner.weaponActive+1)%gunner.weapons.length; gunner.weapons[ gunner.weaponActive ].missValue = (random(40)/100+.2)*Math.PI*(random(2)*2-1);	//небольшая тряска при смене
						sound_lib.sound_start(gunner.weapons[ gunner.weaponActive ].sound_equip);}}																							//меняем активное оружие, ставим его активным, суем в руки, проигрываем звук
			
		
		// делает пушку пушкой
		// ammo_type == {0 - bullets, 1 - shells, 2 - energys, 3 - bombs, -1 - none}
		// function set_a_gun(GUN, ammo_type (0), bullet_type (pistol_bullet), bullet_spread(0), realoadPartly(18), ammo(6), reloadFull(120), automatic(false), host_dist(20), ammo_per_shot(1), bullet_per_shot(1), otadat(10))
			static function set_a_gun (who:MovieClip, ammo_type, bullet_type:String, bullet_spread:Number, realoadPartly:Number, ammo:Number, reloadFull:Number, automatic:Boolean,
								host_dist:Number, ammo_per_shot:Number, bullet_per_shot:Number, otdat:Number, effect_path:String, spread_stats:Array,
								bullet_speed){
					if (who == null) return; who.stop();
					if (ammo_type == undefined)who.ammo_type = -1;	 else who.ammo_type = ammo_type;							// тип потребляемых патронов (по дефолту их не потребляет)
					if (bullet_type == undefined)who.bullet_type = "pistol_bullet"; else who.bullet_type = bullet_type;			// тип пуль
					if (bullet_spread == undefined)who.bullet_spread = 0; else who.bullet_spread = bullet_spread;				// разброс угол
					if (realoadPartly == undefined)who.realoadPartly = 18; else who.realoadPartly = realoadPartly;				// перерыв между соседними выстрелами
					if (reloadFull == undefined)who.reloadFull = 120; else who.reloadFull = reloadFull;							// по истечению обоймы перезарядка
					if (ammo == undefined)who.ammo = 6; else who.ammo = ammo;													// магазин
					if (automatic == undefined)who.automatic = false; else who.automatic = automatic;							// автоматическая ли стрельба?
					if (host_dist == undefined)who.host_dist = 20; else who.host_dist = host_dist;								// расстояние, на котором владелец держит пушку
					if (otdat == undefined)who.otdat = 10; else who.otdat = otdat;												// отдача при вылете 1(!!!!!) пули
					if (ammo_per_shot == undefined)who.ammo_per_shot = 1; else who.ammo_per_shot = ammo_per_shot;				// затраченые на 1 выстрел патроны
					if (bullet_per_shot == undefined)who.bullet_per_shot = 1; else who.bullet_per_shot = bullet_per_shot;		// количество пуль, вылетающих при выстреле
					if (effect_path == undefined)who.effect_path = 'pistol_shoot'; else who.effect_path = effect_path;			// графический эффект выстрела (у ствола)
					if (spread_stats == undefined)who.spread_stats = new Array(1,2,3); else who.spread_stats = spread_stats;	// массив возможных состояний вылетающих спреадиков
					if (bullet_speed == undefined)who.bullet_speed = 'default'; else who.bullet_speed = bullet_speed;			// default - по дефолту, может быть массивом, может быть 1м числом
					
					
					who.clr = new Color(who); who.missValue = 0; who.host = null; who.watchR = 0; who.ys = who._yscale; who.reload_timer = 0; 
				// цвет для затемнения пушки, которая за спиной, мииВалуе - разброс при резкой смене пушки, хост - владелец данного экземпляра
				// ватчР - отслеживание перезаярдки, ys - yscale - для отражения пушки по в-ли, reload_timer - внутренний таймер для перезарядки
				// current_ammo - текущее кол-во патронов, watch1 - отслеживание нажатой мыши, невер_хостед - никогда не была использована
					who.current_ammo = who.ammo; who.watch1 = 0; who.ot_dist = 0; who.never_hosted = true;
			}
		//назначает пушке владельца
			static function set_a_gun_host (gun:MovieClip, host:MovieClip){
				gun.host = host; sound_lib.sound_start ( gun.sound_equip+"" ); 			// назначает нового хоста, проигрывает звук взятия пушки (на самой пушке)
				host.weapons.push(gun); host.weaponActive = host.weapons.length-1;	// добавляет оружие в массив оружий владельца, активным делает индекс последнего оружия в массиве (только что добавленной пушки)
				if (gun.never_hosted){ gun.never_hosted = false; if (gun.ammo_type >= 0)gun.host.Ammo[gun.ammo_type]+= gun.current_ammo; }
					// если никогда не была ношена, сделать ношенной и 1 раз дать владельцу своё боезапас ввиде патронов.
			}
		//being a GUN
			static var ang = 0;
			static function being_a_gun (gun:MovieClip){
				//хозяин впринципе не определен (null, если его таки нет)
					if (gun.host!= null && gun.host == undefined){ _root.console_trace('# '+gun+' have no host!');return;}			//no host check
				//если нет хозяина, то это просто валяющийся кусок железа
					if (gun.host == null){
						// если масса еще не определена, значит оружие никогда не было представлено, как физическое тело. Добавляем ему интерфейс оного, отправляем в свободный полет
							if (gun.mass == undefined){ inter_block.set_moveble(gun,0, 1.2, 0.1, 1); gun.ground = false; }else{ inter_block.being_moveble(gun); }	//falling and mooving
						// проверка подбора оружия (касание, координатное расстояние, нажатая клаива взаимодействия)
							for (var man = 0; man < _root.all_hitable.length; man++)
								if (_root.all_hitable[man].controlable == true && _root.all_hitable[man].hitTest(gun) && (_root.all_hitable[man].keypresses[5] > 1)){ if ( Math.abs( gun._x - _root.all_hitable[man]._x  )+Math.abs(gun._y - _root.all_hitable[man]._y)<40 ){set_a_gun_host (gun, _root.all_hitable[man]);   return;}} 
						// если хозяин не существует, или определен в этом кадре, то лействие на этом завершается
							return; }
				//если есть хозяин, но пушка лежит за пазухой (не активна), то просто перемещать её за игроком
					if (gun.host != null && gun!=gun.host.weapons[gun.host.weaponActive])	//является наактивной (проверка такая чтобы избежать переменной актив)
						{if (Math.abs(gun._rotation) >20)gun._rotation = random(40)-20; gun._x = gun.host._x - gun._width/5; gun._y = gun.host._y + gun.host.gunYoffset; return; }
				//если хозяин есть, но он эту пушку решил выкинуть к чертям
					if (gun.host.wantDrop){
								gun.host.keypresses[6] = 360; gun.host.wantDrop = false; gun.host.weapons.splice(gun.host.weaponActive,1); gun.host.weaponActive--; if (gun.host.weapons.length>0 && gun.host.weaponActive < 0){gun.host.weaponActive = 0;}//вычеркнуть из списка оружия владельца и сделать следующее оружие активным
								if (gun.mass == undefined){ inter_block.set_moveble(gun,0, 1.2, 0.1, 1); }	//если она не была объектом до этого
								gun.ground = false; if (gun.host.keypresses[3]==0 || gun.host.dead){ if (gun.host.dead) ang = -Math.PI*( .25+random(50)/100 );var pow = (5+random(20)/10)/gun.mass; gun.sp_y = pow*Math.sin(ang); gun.sp_x0 = .4*pow*Math.cos(ang);} gun.host = null; gun._rotation += random(121)-60; return; }			//пушка выкинута. ретурн.
				//каждый кадр смотреть туда, куда целится хозяин. Вне времени.
					if (gun.host.followX == undefined || gun.host.followY == undefined){_root.console_trace("# "+gun+"'s has no 'follow' variable!"); return;}			//у хозяина нет параметра цели. нечего тут ловить
				//хозяин мертв. (здесь можно допилить выбрасывание принудительное) - пока что выбрасывание происходит из-за обнуления массива клавишного нажатия владельца.
					if (gun.host.dead )return;
						if (gun.host.gunYoffset == undefined)gun.host.gunYoffset = 0;
					// проверка для того, чтобы не крутить стволом во время паузы
						if(_root.timeElapsed>0)ang = Math.atan2( gun.host._y + gun.host.gunYoffset - gun.host.followY, gun.host._x - gun.host.followX ) + Math.PI + gun.missValue;		//angle_calculate
						gun._rotation = ang/Math.PI*180; gun._yscale = (2*(gun._rotation > -90 && gun._rotation < 90)-1)*gun.ys;
					// регулировка смещения из-за отдачи и оффсета угла из-за смены оружия
						if (Math.abs(gun.ot_dist)<.1)gun.ot_dist = 0; for (var i=0;i<_root.updates;i++){gun.ot_dist/=1.1; gun.missValue /= 1.1; }
					// координаты сопутствуют координатам владельца с заданным смещением. host.Yoffset задается на самом владельце
						gun._x = gun.host._x + Math.cos(ang)* (gun.host_dist - gun.ot_dist); gun._y = gun.host._y + gun.host.gunYoffset + Math.sin(ang) * (gun.host_dist - gun.ot_dist);
				//пристрелки и все в таком духе
					var shot_this_frame = false;
					for (var tick = 0; tick<_root.updates; tick++){
						if (Key.isDown(1))gun.watch1++; else gun.watch1 = 0;		//when mouse is clicked || R is pressed
							gun.reload_timer -= (gun.reload_timer>0)*1;
						//no ammo case
							if (gun.reload_timer == 0 && gun.watch1 == 1 && !(gun.current_ammo >= gun.ammo_per_shot && ((gun.ammo_type<0)||(gun.ammo_type>=0 && gun.host.Ammo[gun.ammo_type] >= gun.ammo_per_shot))))sound_lib.sound_start('items/no_ammo');
						//reload
							if (gun.reload_timer<=0 && ((gun.current_ammo > 0 && gun.watch1 != 1 && gun.host.wantReload) || (gun.current_ammo == 0 && gun.watch1 + gun.host.wantReload*1==1)))
								{ gun.reload_timer += gun.reloadFull; gun.ost = gun.current_ammo; gun.current_ammo = gun.ammo; gun.gotoAndStop('hand_reload'); gun.reload_base.gotoAndStop(1);  }
						//shoot
						// если гашетка зажата и оружие автоматическое или она нажата 1 раз, а оружие неавтоматическое, притом в этом кадре еще не стреляли, притом таймер на нуле
							if (!shot_this_frame && gun.reload_timer<=0 && ((!gun.automatic && gun.watch1 == 1) || (gun.automatic && gun.watch1 > 0))){ /*SHOT*/ 
								//attach a bullet
										shot_this_frame = true;																																									// в этот кадр уже стреляли
									if (gun.current_ammo >= gun.ammo_per_shot && ((gun.ammo_type<0)||(gun.ammo_type>=0 && gun.host.Ammo[gun.ammo_type] >= gun.ammo_per_shot))){ gun.current_ammo -= gun.ammo_per_shot;  gun.host.Ammo[gun.ammo_type] -= gun.ammo_per_shot;
										if (gun.current_ammo > 0) {gun.reload_timer += gun.realoadPartly; gun.gotoAndStop('fire');}																								// обойма езе не кончилась \ спавн звук выстрела
															else  {gun.reload_timer += gun.realoadPartly+gun.reloadFull; gun.current_ammo = gun.ammo; gun.gotoAndStop('reload'); gun.reload_base.gotoAndStop(1); gun.ost = 0;}	// обойма кончилась \ спавн звук перезарядки
										var dulo_x = gun._x + Math.cos(gun._rotation/180*Math.PI) * (gun.dulo._x)  + Math.cos(gun._rotation/180*Math.PI+Math.PI/2) * gun.dulo._y *gun._yscale/gun.ys;							// просчет точки вылета пули из ствола
										var dulo_y = gun._y + Math.sin(gun._rotation/180*Math.PI) * (gun.dulo._x)  + Math.sin(gun._rotation/180*Math.PI+Math.PI/2) * gun.dulo._y*gun._yscale/gun.ys;
										var where = _root.enemy_bullets; if (gun.host.team == 1)where = _root.hero_bullets;
										export_block.export_effect (where, gun.effect_path+"", dulo_x, dulo_y, gun._rotation/180*Math.PI);
										for (var shot=0; shot<gun.bullet_per_shot; shot++){																																		// для каждой пули спавнить ее и увеличивать отдачу
												gun.ot_dist += gun.otdat; 
												gun.host.sp_x0 += - 0.02*gun.otdat * Math.cos(gun._rotation / 180 * Math.PI);
												bullet_block.spawn_a_bullet (where, gun.bullet_type, dulo_x, dulo_y, gun.bullet_speed, gun._rotation/180*Math.PI + random(Math.round(gun.bullet_spread*1000))/1000 - gun.bullet_spread/2, 'default', gun.spread_stats, gun.host);}}// bullet_spawn
								}
							}					
			}
		//gun reloading help functions
		// интерфейс прикрепляется к части ствола (внутри мувиклипа пушки), которая имеет анимацию перезаряжания
		// maxFrame - последний кадр перезарядки (в зависимости от него и времени будет рассчитана скорость анимации перезарядки)
			static function set_reloader (gun:MovieClip, maxFrame:Number){ gun.anim = 0; gun.stop(); gun.spd = (Math.round(gun._parent.reload_timer/maxFrame+.4)); }
		// ф-я, позволяющая каждый апдейт следовать интерфейсу перезарядной анимации
			static function being_reloader (gun:MovieClip){++gun.anim; if (gun._parent.host!=null && gun._parent.getDepth() > gun._parent.host.getDepth())anim_block.animate(gun,1,100,gun.spd);}
			
	
}