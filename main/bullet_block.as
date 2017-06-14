class bullet_block {
	// Блок логики пуль.
	// Задает дефолтные значения параметров пуль и спредов
	// Проверяет коллизии.
	
	// Загрузчик.
			function Load (){
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
			var bullet_types_array = new Array("pistol_bullet","enemy_rifle_bullet");
			var bullet_speed_array = new Array(              7,      new Array(1,10));
			var bullet_spread_array= new Array(              6,   		       	  1);
	// Собственно элементарная функция для получения средне-случайного значения м-ду двумя числами.
			function rnd_spd ( min, max ){ return  min + random(Math.round(100*(max-min)))/100 ; }
			
	// Функция спавна пули.
			var hero_bul = -1; // Текущее количество пуль
		// where - место,в котором появится пуля. Обычно это hero_bullets или enemy_bullets - слои, отвечающие за хранение пуль. Но where также может принимать значения любого мувиклипа. В том числе _root
		// bullet_path - путь, по которому в библиотеке может быть найдена пуля. Также является её названием в массивах дефолтных значений
		// х0, у0, ang - значения начальной координаты и угла выстрела. Угол в радианах
		// spd - может быть задан числом, массивом 2х чисел (для случайной скорости), ключом 'default' - для автоматических подстановок значений
		// spread - кол-во спредов при выстреле. Аналогично скорости может быть задан ключом 'default'
		// spread_stats - массив допустимых кадров спредов. (см. подбробнее в мувиклипе самого спреда.)
			function spawn_a_bullet( where:MovieClip, bullet_path:String, x0, y0, spd, ang, spread, spread_stats){
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
						b._x = x0; b._y = y0; b.spd = spd; b.ang = ang; b.damage = 1; b.damage_done = false;
					// При выгрузке уменьшает общее количество пуль. Исключиетнль остатистический элемент.
						b.onUnload = function (){ _root.total_bullets--; }
				// spawn spread
				// Также заставить появится спреды. spread_stat - случайный из предложенных состояний спреда. (влияет на его кадр). Появляется в том-же месте с теми же начальными координатами.
					for (var i= 0; i<spread; i++){var spread_stat = spread_stats[random(spread_stats.length)];  spawn_a_spread (_root.hero_bullets, x0, y0, ang, spd, spread_stat, .001*(random(6)+5)+1);}
				// На корне появляется сссылка на последнюю созданную пулю. На случай, если надо будет ещё что-то подправить вручную.
					_root.last_bullet = b;
			}
			var sprd = -1; // число появившихся когда-либо спредов.
		// Сигнатура функции частично аналогична функции spawn_bullet
		// spd_bul - скорость пули хозяина. (Замечание: нигде не фигурирует привязка спреда к пули, т.е. они независимы. Не знаю, хорошо ли это.)
		// degrad - коэффицент, по которому уменьшается размер спреда со временем. Больше единицы, стремится к ней сверху. Стандартные значения около 1.005
			function spawn_a_spread (where:MovieClip,  x0, y0, ang, spd_bul, stat, degrad){// return;
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
			function set_hitbox (hitbox:MovieClip, host:MovieClip){									//назначает хитбос для конкретного хоста
				 if (host == undefined){ _root.console_trace("# unknown hitbox host!"); return; }	//если хост не определен, то возврат с ошибкой
				 if (host.hitboxes.length <= 0)host.hitboxes = new Array();							//если нет такого массива, то создать его
				 host.hitboxes.push(hitbox); hitbox.hostID = host;									//добавление в массив хитбоксов, если все успешно, в хитбоксе создается ссылка на хоста.
				 hitbox.onUnload = function ()	// Очень интересный момент: выгрузка хитбокса должна сопровождаться удалением его из массива всех хитбоков. Это проделано в цикле.
				 {var num = -1; for (var i=0; i<this.hostID.hitboxes.length; i++)if (this.hostID.hitboxes[i] == this){num = i; break;} if (num==-1)return; this.hostID.hitboxes.splice(num,1);}	//при отгрузке убрать хитбокс, чтобы не засорять массив
			}
	// Для пулевой логики. Проверка столкновения пули с чем-нибудь приемлимым.
		// bullet - пуля, для которой идет проверка. side - сторона этой пули.  { 0 - нейтральная сторона, предметы и окружение, 1 - дружественные персонажи (для игрока), 2  - враги и все им союзное, опасное }
		// Функция возвращает bool - есть ли собственно столкновение. Действия, которые происходят при столкновении описываются конкретно в этой функции.
			function test_collision (bullet:MovieClip, side:Number):Boolean{
				if (!bullet.damage_done)				// Данная проверка нужна для того, чтобы при низком количестве кадров пуля не нанесла кому0нибудь урон дважды, а то и более раз
					for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];	// Текущая переменная target - в данный момент проверяемый владелец интерфейса hitable
						if (((target.team != 1 && bullet._parent == _root.hero_bullets) || (target.team != 2 && bullet._parent == _root.enemy_bullets))			// Если пуля и цель не являются союзниками
							&& target.hitTest(bullet._x, bullet._y, true)) for (var i=0; i<target.hitboxes.length; i++)if ( bullet.hitTest(target.hitboxes[i]) )// И если цель касается центра масс пули, а пуля касается одного из его хибоксов
						// Пуля отправляется в анимацию смерти, урон нанесен, хитбокс, в который попали делаем красным (трассировка), снимаем здоровье цели, увеличиваем её скорости по х. Возвращаем попадание.
							{ bullet.gotoAndStop('dead'); bullet.damage_done = true; target.hitboxes[i].colors.hurted._alpha = 100; target.hp-= bullet.damage; target.sp_x0 += .1*bullet.spd*Math.cos(bullet.ang); return true; }			//collision action
				} return false; }	// Ни с чем пока не соприкасется.
			
	//WARNING - NOW WORKING ONLY FILTERING UNITS WHO A AMMO HOLDERS
		// Работает в данных условиях только для проверки столкновения с наследниками интерфейса hitable + ammo_holder
		// Возвращает подходящий условиям мувиклип, который соприкассается с заданным объектом.
		// Если такой не будет найден, то возвращает null.
			function hittest_collision (thing:MovieClip):MovieClip{	// Схема проверки аналогична предыдущей функции и подробно рассматриватся не будет.
				for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];
					if (target.hitTest(thing) && target.ammo_holder)for (var i=0; i<target.hitboxes.length; i++)if ( thing.hitTest(target.hitboxes[i]) ){ return target; }
				} return null;
			}
	
}