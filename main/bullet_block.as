class bullet_block {
	// Блок логики пуль.
	// Задает дефолтные значения параметров пуль и спредов
	// Проверяет коллизии.
	
	// Загрузчик.
			static function Load (){
				_root.console_trace ( "* Bullet block loaded" ); 
			}
	// * здесь и далее - спред (от англ. spread) - искорка, вылетающая из дула ствола вместе с пулей. Исключительно сложный визуальный эффект.
	// С точки зрения физики - продукт горения последействия пороховых газов ( для огнестрельного оружия ) или осколки энергии ( для энергетического )
	
	// Дефолтные значения скоростей пуль и количества спредов, извергаемых при их спавне.
		// В первом массиве указывается название пули, которое также служит путем для экспорта в библиотеке.
		// Во втором массиве указывается стандартная скорость пули, вызываемая в сигнатуре функции спавна пули параметром "default"
		// Если вместо одного числа исопльзуется массив, то это означает, что скорость должна быть случайной м-ду двумя этими параметрами.
		// Третий массив отвечает за дефолтное количество спредов при спавне пули. 
		// НАПОМИНАНИЕ: и скорость и кол-во спредов может быть задано самостоятельно, без какой-либо опоры или привязки к этим массивам.
			static var bullet_types_array = new Array("pistol_bullet","enemy_rifle_bullet","rocket_bullet","circle_bullet",  "slow_bullet","laser_bullet");
			static var bullet_speed_array = new Array(              7,     new Array(1,10),              2,				 5,new Array(6,10),             7);
			static var bullet_spread_array= new Array(              6,  			  	 4,             10,				 3,              2,             3);
	// Собственно элементарная функция для получения средне-случайного значения м-ду двумя числами.
			static function rnd_spd ( min, max ){ return  min + random(Math.round(100*(max-min)))/100 ; }
			
	// Функция спавна пули.
			static var hero_bul = -1; // Текущее количество пуль
		// where - место,в котором появится пуля. Обычно это hero_bullets или enemy_bullets - слои, отвечающие за хранение пуль. Но where также может принимать значения любого мувиклипа. В том числе _root
		// bullet_path - путь, по которому в библиотеке может быть найдена пуля. Также является её названием в массивах дефолтных значений
		// х0, у0, ang - значения начальной координаты и угла выстрела. Угол в радианах
		// spd - может быть задан числом, массивом 2х чисел (для случайной скорости), ключом 'default' - для автоматических подстановок значений
		// spread - кол-во спредов при выстреле. Аналогично скорости может быть задан ключом 'default'
		// spread_stats - массив допустимых кадров спредов. (см. подбробнее в мувиклипе самого спреда.)
		// host - тот, кто выпустил эту самую пулю
			static function spawn_a_bullet( where:MovieClip, bullet_path:String, x0, y0, spd, ang, spread, spread_stats, host){
				// where check, host check
						if (where == undefined)where = _root; if (host == undefined) host = null;
				//FPS предохранитель - если количество кадров очень низкое пули не производятся. Служит для предотвращения цикличности спавна низких частот.
						if (_root.menu.fps.fps < 10)return;
				//calculate default speed
				// Если переданный параметр скорости и/или кол-ва спредов "default", то проходим по массиву дефолтных значений, сверяя название пули с первым из них
				// После нахождения дефолтные величины заменяются на соответствующие найденным значения. Предусмотрен break;
				// В случае требования дефолтных значений от пуль, не указанных в массиве, пуля НЕ ПОЯВИТСЯ, а в консоль будет выведено сообщение оь ошибке.
						var ok = false; if (spd == 'default' || spread == 'default'){for (var i=0; i<bullet_types_array.length; i++)     if ((bullet_types_array[i]+"").indexOf(bullet_path+"")>=0)
							{ if (spd == 'default')spd = bullet_speed_array[i];  if (spread == 'default')spread = bullet_spread_array[i]; ok = true; break; }
						if (!ok){_root.console_trace("# No default speed for bullet '"+bullet_path+"'"); return;}}
				// Если второй элемент массива спд не выдуман, т.е. спд - массив, то скорость рандомится в значениях от и до.
						if (spd[1]!=undefined){ if (spd.length == 2)spd = rnd_spd (spd[0], spd[1]); }
				// spawn_a_bulelt
				// Плюсуем общий счетчик количества пуль на сцене. Экспортируем из библиотеки пулю. Задаем ей нач. коор-ты, скорость, угол, урон.
				// b.damage_done отвечает за то, был ли нанесен пулей урон. Как правило после первого попадания пуля теряет свои боевые свойства.
						hero_bul++; _root.total_bullets ++; 
						where.attachMovie(bullet_path,"hero_bul_"+hero_bul, where.getNextHighestDepth()); var b = where["hero_bul_"+hero_bul];
						b._x = x0; b._y = y0; b.spd = spd; b.ang = ang; b.damage = 1; b.damage_done = false; b.host = host;
					// При выгрузке уменьшает общее количество пуль. Исключиетнль остатистический элемент.
						b.onUnload = function (){ _root.total_bullets--; }
				// spawn spread
				// Также заставить появится спреды. spread_stat - случайный из предложенных состояний спреда. (влияет на его кадр). Появляется в том-же месте с теми же начальными координатами.
					for (var i= 0; i<spread; i++){var spread_stat = spread_stats[random(spread_stats.length)];  spawn_a_spread (where, x0, y0, ang, spd, spread_stat, .001*(random(6)+5)+1);}
				// На корне появляется сссылка на последнюю созданную пулю. На случай, если надо будет ещё что-то подправить вручную.
					_root.last_bullet = b;
			}
			static var sprd = -1; // число появившихся когда-либо спредов.
		// Сигнатура функции частично аналогична функции spawn_bullet
		// spd_bul - скорость пули хозяина. (Замечание: нигде не фигурирует привязка спреда к пули, т.е. они независимы. Не знаю, хорошо ли это.)
		// degrad - коэффицент, по которому уменьшается размер спреда со временем. Больше единицы, стремится к ней сверху. Стандартные значения около 1.005
			static function spawn_a_spread (where:MovieClip,  x0, y0, ang, spd_bul, stat, degrad){// return;
				// Все действия ф-ции аналогичны действияем в предыдущей ф-ции.
				sprd++; _root.total_spreads ++;
						where.attachMovie("bullet_fly_out", "bl_sprd"+sprd, where.getNextHighestDepth()); var s = where["bl_sprd"+sprd];
					// Таймер почему-то ни на что не влияет. (!Разобраться)
						s._x = x0; s._y = y0; s.ang = ang; s.stat = stat; s.timer = undefined; s.spd = Math.max(1,Math.min(3,spd_bul/3))*(random(80)/100+.3)*(1+.2*random(6)*(random(50)==0));
						s.degrade_speed = degrad; s.onUnload = function (){ _root.total_spreads--; }
			}
	// Добавляет в объект хитбокс.
		// Функция вызывается из самого хитбокса при его загрузке (как правило в блоке onLoad)
		// Указывается хозяин хитбокса. Чаще всего это (_parent или _parent._parent)
		// Хитбоксы хранятся у каждого ххоста в массиве хитбокосв host.hitboxes; Он создается в этой функции, если не предусмотрен заранее.
			static function set_hitbox (hitbox:MovieClip, host:MovieClip){									//назначает хитбос для конкретного хоста
				 if (host == undefined){ _root.console_trace("# unknown hitbox host!"); return; }	//если хост не определен, то возврат с ошибкой
				 if (host.hitboxes.length <= 0)host.hitboxes = new Array();							//если нет такого массива, то создать его
				 host.hitboxes.push(hitbox); hitbox.hostID = host;									//добавление в массив хитбоксов, если все успешно, в хитбоксе создается ссылка на хоста.
				 hitbox.onUnload = function ()	// Очень интересный момент: выгрузка хитбокса должна сопровождаться удалением его из массива всех хитбоков. Это проделано в цикле.
				 {var num = -1; for (var i=0; i<this.hostID.hitboxes.length; i++)if (this.hostID.hitboxes[i] == this){num = i; break;} if (num==-1)return; this.hostID.hitboxes.splice(num,1);}	//при отгрузке убрать хитбокс, чтобы не засорять массив
			}
	// Для пулевой логики. Проверка столкновения пули с чем-нибудь приемлимым.
		// bullet - пуля, для которой идет проверка. side - сторона этой пули.  { 0 - нейтральная сторона, предметы и окружение, 1 - дружественные персонажи (для игрока), 2  - враги и все им союзное, опасное }
		// Функция возвращает bool - есть ли собственно столкновение. Действия, которые происходят при столкновении описываются конкретно в этой функции.
			static function test_collision (bullet:MovieClip, side:Number):Boolean{
				if (!bullet.damage_done)				// Данная проверка нужна для того, чтобы при низком количестве кадров пуля не нанесла кому0нибудь урон дважды, а то и более раз
					for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];	// Текущая переменная target - в данный момент проверяемый владелец интерфейса hitable
						if (((target.team != 1 && bullet._parent == _root.hero_bullets) || (target.team != 2 && bullet._parent == _root.enemy_bullets))			// Если пуля и цель не являются союзниками
							&& target.hitTest(bullet._x, bullet._y, true)) for (var i=0; i<target.hitboxes.length; i++)if ( bullet.hitTest(target.hitboxes[i]) )// И если цель касается центра масс пули, а пуля касается одного из его хибоксов
						// Пуля отправляется в анимацию смерти, урон нанесен, хитбокс, в который попали делаем красным (трассировка), снимаем здоровье цели, увеличиваем её скорости по х. Возвращаем попадание.
							{ bullet.gotoAndStop('dead');for (var f=0; f<bullet.frame_offset; f++)bullet.nextFrame(); bullet.damage_done = true; target.hitboxes[i].colors.hurted._alpha = 100; target.hp-= bullet.damage; target.sp_x0 += .1*bullet.spd*Math.cos(bullet.ang);	 target.sp_y += .1*bullet.spd*Math.sin(bullet.ang);// collision action
							if (target.hpmax>0){target.hitBy = bullet.host; var trc = '~ '+getname(bullet.host)+' deals '+bullet.damage+' dmg. to '+getname(target)+' '; if (target.hp<=0 && !target.dead) trc ='~ '+getname(target)+' killed by '+getname(bullet.host)+' ';_root.console_trace(trc);} return true; }																		// trace
				} return false; }	// Ни с чем пока не соприкасется.
			static function getname (who:MovieClip):String{
				if (who == null) return 'unknown'; else return who._name;//return (who+"").substr((who+"").lastIndexOf(".")+1,(who+"").length - (who+"").lastIndexOf("."));
			}
	//WARNING - NOW WORKING ONLY FILTERING UNITS WHO A AMMO HOLDERS
		// Работает в данных условиях только для проверки столкновения с наследниками интерфейса hitable + ammo_holder
		// Возвращает подходящий условиям мувиклип, который соприкассается с заданным объектом.
		// Если такой не будет найден, то возвращает null.
			static function hittest_collision (thing:MovieClip):MovieClip{	// Схема проверки аналогична предыдущей функции и подробно рассматриватся не будет.
				for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];
					if (target.hitTest(thing) && target.ammo_holder)for (var i=0; i<target.hitboxes.length; i++)if ( thing.hitTest(target.hitboxes[i]) ){ return target; }
				} return null;
			}
	// Круговой выстрел - коллизия со взрывом и тд
	// Наносит урон и отталкивает всех в зоне поражения
			static function circle_damage (x0, y0, Rad, damage_max, damage_min){
				if (damage_max == undefined)damage_max = 2; if (damage_min == undefined)damage_min = 1;
				if (Rad == undefined) Rad = 50;
				for (var tt = 0; tt<_root.all_hitable.length; tt++){ 
					var target = _root.all_hitable[tt];		// цель
					var dist = Math.sqrt( Math.pow( x0 - target._x,2 ) + Math.pow( y0 - target._y + target._height/2,2 ) );	// расстояние до центра цели
					
					if (dist < Rad){var damage = damage_min + Math.round(dist/Rad*(damage_max - damage_min)); 
						if (target.hpmax>0){ 
						target.hp -= damage;   if (damage>0)for (var i=0; i<target.hitboxes.length; i++)target.hitboxes[i].colors.hurted._alpha = 100;	// красный цвет хитбоксов
						var ang = Math.atan2(y0 - target._y + target._height/2, x0 - target._x); target.sp_x0 -= (2+.1*damage)*Math.cos(ang); target.sp_y -= (2+.1*damage)*Math.sin(ang);	// отталкивать
						_root.console_trace("~ "+getname(target)+' receive '+damage+' dmg. from explosion');}}		//calculating damage
				}
			}
			
	// Функция, отвечающая за внешнюю самостоятельную баллистику пули (обобщенная)
	// who - сама пуля, defaultSpread - случайный угол при спавне ав радианах
	// timer - время, которое позволительно пуле лететь
	// teamFrameOffset - сколько нужно отсчитать кадров от начала, чтобы пуля стала враждебной
	// deadFrame - номер первой смерти пули (второй должен быть равен этому числу+ число смещения)
	// deadEffectFrame - номер кадра на эффекте столкновения, после которого пулю надо ремувнуть
	// sound_hit - полный адрес звука в библиотеке, который воспроизводится при столкновении пули с чем-либо
			static function set_a_bullet (who:MovieClip, defaultSpread:Number, timer:Number, sound_hit:String, deadFrame:Number, deadEffectFrame:Number, teamFrameOffset:Number){
				who.random_angle = defaultSpread; who.timer = timer; who.stop(); who.sounded = false;

				who._x += who._height/2 * Math.cos( who.ang ); who._y += who._height/2 * Math.sin (who.ang );// correct coords
				who._xscale *= (random(2)*2-1);																// random _xscale
				who.ang += random(Math.round(who.random_angle * 100 ))/100 - who.random_angle/2;			// random _rotation0
				who._rotation = who.ang/Math.PI*180 + 90; who.anim = 0; who.pass = 0; who.live = true;
				who.frame_offset = 0; who.hit_sound = sound_hit; who.dead_frame = deadFrame; who.dead_effect_frame = deadEffectFrame;
				if (who.host.team == 2){who.frame_offset = teamFrameOffset; who.gotoAndStop(teamFrameOffset+1);}stop(); // frame offset
				
			}
			
		// быть пулей не так уж и просто
			static var steps:Number = 0;
			static function being_a_bullet (who:MovieClip, acs_koeff:Number ){
				who.timer -= _root.timeElapsed; 
				if (who.timer <= 0 || who.pass > 1000) { who.removeMovieClip();	/*quiet removing*/}	// external remove sourse
				if (who.live){	// если пуля в полете
					// movement block
						if (_root.timeElapsed < 1){	// слоу моушн - пуля должна двигаться каждый кадр в любом случае
								who.pass += who.spd * _root.timeElapsed;	// pass ++
								who._x += who.spd * Math.cos(who.ang) * _root.timeElapsed; 	// coord changes
								who._y += who.spd * Math.sin(who.ang) * _root.timeElapsed;
								test_collision (who, 0);								// collision test
							}else{
								for (var u=0; u<_root.updates; u++){	// в кадре может быть более одного апдейта
									steps = 1; who.pass += who.spd;	// pass ++
									if (who.hitbox._height!=undefined && who.spd > who.hitbox._height){ steps = Math.round(1+who.spd / who.hitbox._height);  trace(steps);}
										for (var st=1; st<=steps; st++){			// растяжение по большой скорости 
												
												who._x += who.spd * Math.cos(who.ang) / steps; 	// coord changes
												who._y += who.spd * Math.sin(who.ang) / steps;
												if(test_collision (who, 0)) {who.spd=0; break; }			// collision test
										}
								}
							}
					// anyway do
						for (var u=0; u<_root.updates; u++)
							if (acs_koeff != undefined) {if (acs_koeff > 0)who.spd *= acs_koeff; else who.spd = Math.max(0, who.spd + acs_koeff); }	// acseleration over time
				}else{		// bullet dead animation
						if (!who.sounded){ who.sounded = true; sound_lib.sound_start(who.hit_sound); }	// sound of hitting an object
						gotoAndStop(who.dead_frame+who.frame_offset);								// go to 'dead' frame
						if (who.end._currentframe >= who.dead_effect_frame)who.removeMovieClip();
				}
			}
		// 
		// 
		// 
		static var x_c = 0; static var y_c = 0; static var ang_c = 0; static var ky = 1;
			static function spawn_shell (where, frame, direct:MovieClip, speed, angle_spread){
				// коэффицент 1 -1 в зависимости от поворота пистолета
					ky = direct._parent._yscale / direct._parent.ys;
				// угол для высчета координат
					ang_c = direct._parent._rotation / 180 * Math.PI;		
				// подсчет координат
						x_c = direct._parent._x + (direct._x * Math.cos(ang_c) + direct._y * Math.cos(ang_c + Math.PI/2) * ky);
						y_c = direct._parent._y + (direct._x * Math.sin(ang_c) + direct._y * Math.sin(ang_c + Math.PI/2) * ky);
				// пересчет координат
					//if (ky < 0){
						//x_c = direct._parent._x - (-direct._x * Math.cos(ang_c) + direct._x * Math.sin(ang_c));
						//y_c = direct._parent._y - (direct._y * Math.sin(ang_c) + direct._y * Math.cos(ang_c));}
					_root.tt._x = x_c; _root.tt._y = y_c;
				// угол под которым вылетет пуля
					ang_c = (direct._parent._rotation + direct._rotation ); if (ky<0) ang_c = (direct._parent._rotation - direct._rotation + 180);
				// from grad to rad && randomise an angle
					ang_c = ang_c / 180 * Math.PI;
					ang_c += random(angle_spread*100)/100-angle_spread/2;
					_root.tt._rotation = ang_c / Math.PI * 180;
				export_block.export_object ('default','shell',200+random(40), x_c, y_c,
										speed * Math.cos(ang_c) * ky, speed * Math.sin(ang_c) * ky,.2,1.5,1, false,.3);
				_root.last_exported.gotoAndStop(frame);
				/*
					angl_cor = _rotation/180*Math.PI - Math.PI/4; rad = 7;						//autodetect position
					angl_vibros = _rotation/180*Math.PI - (3+random(100)/100)*Math.PI/4;		//angle of start_fly
						
					if ((_yscale/ys)<1) {angl_vibros =  180 + angl_vibros + 45;	angl_cor = _rotation/180*Math.PI - 3* Math.PI/4}				//auto angle ys/ysscale FIX
					spd = 3+random(30)/10;														//speed randomiser
					export_block.export_object ('default', "shell", 
										 200+random(40), _x + 7*Math.cos( angl_cor ), _y + 7*Math.sin( angl_cor )*_yscale/ys,
										 spd * Math.cos(angl_vibros), spd * Math.sin(angl_vibros),.2,1.5,1, false,.3);
					_root.last_exported.gotoAndStop("pistol_shell");
				*/
			}
	
}