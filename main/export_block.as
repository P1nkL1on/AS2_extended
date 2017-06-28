class export_block {
	// Блок для быстрого и удобного (ха) экспорта объектов из библиотеки на сцену.
	// Сделать в него обрабочтик ошибок!
		
		// Загрузчик
			static function Load (){
				_root.console_trace("* Export block loaded");
			}
		// Количество отэкспорченных объектов
			static var obs_fly:Number = -1;
		// Экспортировать объект, собсвтенно, главная функция
		// where - мувиклип, в котором все это произойдет. Чаще всего _root. !!1 Заменить
		// path - путь в библиотеке
		// time - время, которое объект будет на сцене. Измеряется в кадрах. При параметре -1, он останется на сцене навечно.
		// х0, у0, начальные скорости - вполне очевидные вещи
		// acs - ускорение, не исользуется, но является частью сигнатуры moveble ()
		// tormoz - коэффицент трения об поверхность, чем он больше, тем быстрее он затормозит об неё.
		// масс - не масса (ха), а процент воздействия силы всемирного тяготения на объект. При mass == 0 достигается невесомость.
		// ignore_ground - bool - если тру, то летящий объект игнорирует землю и вообще все. Хорош для визуальных эффектов вроде выпавших листов, искр и др.
		// jumpBack - в случае, если коллизия с зелмей все таки возможна, то устанавливается коэффицент отпрыгивания - он положителен и меньше 1. Пропорционально ему скорость по у меняется при ударе.
			static function export_object (where, path:String, time:Number, x0, y0, sp_x0, sp_y0, acs, tormoz, mass , ignore_ground ,  jumpBack ){
				//default values
					if (where == 'default') where = _root.item_layer;
					if (where == undefined){ _root.console_trace('# No place '+where+' for '+path); where = _root;} if (path == undefined){ _root.console_trace('# No path: '+path); return; }// Проверка места и пути, вывод ошибок
					if (time == undefined) time = _root.FPS_stable * 10; 																												// по дефолту - 10 секунд
					if (x0 == undefined || y0 == undefined){ _root.console_trace('# Place is incorrect '+path); x0 = 0; y0=0;}															// неподобающее место для старта
					if (sp_x0 == undefined) sp_x0 = 0;  if (sp_y0 == undefined) sp_y0 = 0; if (acs == undefined) acs = 0;  if (tormoz == undefined) tormoz = 1.05;						// стандартные значния сорокстей, ускорения и тормоза
					if (mass == undefined) mass = 1; if (jumpBack == undefined) jumpBack = 0; if (ignore_ground == undefined) ignore_ground = false;									// стандартные значения оставшихся параметрнов

						// exporting from library
							obs_fly ++;  _root.total_objects++; where.attachMovie(path, "ob_fl_"+obs_fly, where.getNextHighestDepth()); var s = where["ob_fl_"+obs_fly];
						// set vairables
								inter_block.set_moveble(s,acs, tormoz, jumpBack, mass); s._x = x0; s._y = y0; s.sp_x0 = sp_x0; s.sp_y = sp_y0; s.stop();  s.ignore_ground = ignore_ground; s.timer = time;
						// move as you want
						// Объект удаляется со сцены если 1. его таймер истек, 2. он не касается камеры и при этом не подбираемый (для экономии памяти)., предметы остаются предметами даже если ты а них не смотришь. 
								s.onEnterFrame = function (){inter_block.being_moveble(this, ignore_ground); if (this.timer>0){this.timer -= _root.timeElapsed; if (this.timer<=0 || (! this.hitTest(_root.cam) && _root.cam != undefined && !this.isPickUp))this.removeMovieClip();} }
								s.onUnload = function (){ _root.total_objects--; }
						// На сцене создается ссылка на последний экспортированный предмет, если надо что-нибудь поправить вручную
								_root.last_exported = s;
			}
		// effect exporting
			static var ef_sc:Number = -1;
		// Правктически полностью аналогично предыдущей функции.
		// В path - не надо дописывать _effect. Кстати, все пути эффектов должны заканчиваться на _effect.			
			static function export_effect (where, path:String, x0, y0, angle){
				if (where == 'default') where = _root.effect_layer;
				ef_sc ++;  _root.total_effects++; where.attachMovie(path+"_effect", "ef_sc_"+ef_sc, where.getNextHighestDepth()); var e = where["ef_sc_"+ef_sc];
				e._x = x0; e._y= y0; e._rotation =( angle )/Math.PI*180; e.onUnload = function (){ _root.total_effects --; }
				_root.lastEffect = e;
			}
	
}