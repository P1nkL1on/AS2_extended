class inter_block {
	// Блок интерфейсов объектов
	// всех, кроме поведенческих, наверное
		// Загрузчик
			function Load (){
				_root.console_trace("* Object's interfaces block loaded");
			}
			
		// Прикрепляет тело к выбранным ногам. Используйте стандартные ноги (как у мыши) для лучшего эффекта
		// body - тело, legs - ноги.
		// Используется в связке с being_body();
		// Подразумевается, что и тело и ноги являются подклипами одного мувиклипа объекта.
			function set_body(body:MovieClip, legs:MovieClip){
				body.legs = legs; body.xs = body._xscale; body.stat = "idle"; body.anim = 0; body.stop();
			}
			
		// Каждый апдейт пододвигает тело в сооттветствующую точку для ног.
		// Исользуется только в связке с set_body();
			function being_body(body:MovieClip){
				body._y = body.legs._y + body.legs.taz._y;  body._rotation = body.legs.taz._rotation * (body.legs.taz._xscale / Math.abs(body.legs.taz._xscale));	// подгон по координатам
				body._xscale = body._parent.sp_x / Math.abs(body._parent.sp_x ) * body.xs;																			// _xscale определяется знаком горизонтальной скорости родителя
				if (!isNaN(body._parent.sp_x / Math.abs(body._parent.sp_x )))body._parent.wasScale = body._parent.sp_x / Math.abs(body._parent.sp_x );				// если скорость родителя 0, хитрое реешение, исользуется то, что было раньше
				body.anim++;																																		// базовый анимационный сдвиг
				_root.animate(body,_root.getByName(body,body.stat+"_start"),_root.getByName(body,body.stat+"_stop"),body.anim_spd);									// анимирование
			}
			
			
			
			
		// character control problems
		// Controlable - объект управляется с помощью ввода с клавиатуры и тд.
		// Задается сам объект, keys - массив клавиш для управления, клавиш должно быть 8 (мин. 4)
		// общие сведения { перемещение влево, перемещение вправо, вверх, вниз, перезарядка, взаимодействие, выбросить оружие, смена оружия }
		// maxXspeed - максимальная скорость пперемещение по горизонту, jumpHeigth - стандартная высота прыжка, задаётся в положительных числах
		
			function set_controlable (who:MovieClip,keys:Array, maxXspeed:Number, jumpHeigth:Number){
				who.keyBinds = keys;	// left | right | up | down | reload (R) | interract (E) | drop (G) | swap (Q)
				who.keypresses = new Array(); for (var i=0; i<keys.length; i++) who.keypresses.push(0);
				who.sp_x_max = maxXspeed; who.jump_heigth = jumpHeigth;
			// является управляемым - для определения этого интерфейса
			// wantReload, wantDrop - бул-переменные для отслеживания желаний игрока со стороны пушек
				who.controlable = true; who.wantReload = false; who.wantDrop = false; 
			}
		// moveble character
		// интерфейс перемещаемого объекта. объект может перемещаться под действием сил гравитации.
		// задаётся объект, задаются его ускорение, торможение (коэффицент около 1.005), отскок от поверхности (положительное число менее единицы), mass (коэффицент действия силы тяжести на об-т)
			function set_moveble (who:MovieClip, acseleration:Number, desacseleration_k:Number, jumpBack:Number,  mass:Number){
				who.sp_x = 0; who.sp_x0 = 0; who.sp_y0 = 0; who.acs = acseleration;  who.tormoz = desacseleration_k;		// назначение переменных
				who.sp_y = 0; who.ground = false; 																			// граунд - переменная бул, отвечающая за то, стоит ли сейчас на земле данный об-т
				if (mass == undefined) who.mass = 1; else who.mass = mass; if (jumpBack == undefined) who.jumpBack = 0; else who.jumpBack = jumpBack;	// дефолтное назначение второстепенных переменных
			}
		// being a moveble thing (даже тумбочка и золодильник должны это использывать)
		// каждый апдейт реализует действия интерфейса moveble. Используется в свзяке с set_moveble
		// параметром передается игнорирование земли (по дефолту false)
			function being_moveble (who:MovieClip, ignore_ground:Boolean){
				if (ignore_ground == undefined) ignore_ground = false;	// default values
					for (var tick = 0; tick<_root.updates; tick++){		// каждый требуемый апдейт
						if (who.ground){ who.ground = defineGround(who); if (Math.abs(who.sp_x0) > 0.1) who.sp_x0 /= Math.pow(who.tormoz,.25); else who.sp_x0 = 0; }	// замедление горизонтальной скорости на земле
						if (!who.ground){ who.sp_y += _root.G*who.mass; if (!ignore_ground){if (defineGround(who)){if (who.jumpBack == 0){ who.ground = true; who.sp_y = 0; if (who.sp_y0>0) who.sp_y0 = 0; }
																			// при сильном отскоке проигрывать звук удара о землю, если коэффицент jumpBack != 0, то притормаживать по Х и отражать по У. В противном случае приземлить об-т, сбросить все его скорости по У, замедлять по Х
																			/*otskok ili finish*/ else{ if (Math.abs(who.sp_y)>=1){ if (Math.abs(who.sp_y)>=4)_root.footstep_sound(); who.sp_y0 = -who.jumpBack*who.sp_y; who.sp_x0 /= who.tormoz; who.sp_y = 0;} else {who.ground = true; who.sp_y = 0; who.sp_y0 = 0;}}}}}
					// movement applyes
						who._x += who.sp_x + who.sp_x0;
						who._y += who.sp_y + who.sp_y0; 
				}}
		
		//define is object on ground or not
			function defineGround (who:MovieClip):Boolean{
				// если все скорости нулевые, то не земля остается прежней. Ну ведь он никуда не может деться, если все его скорости нулевые
					if (who.sp_x + who.sp_x0 == 0 && who.sp_y+who.sp_y0 == 0){return who.ground;}
				// для каждого блока при положительной вертикальной скорсти и соответствующей коллизии, а также координатных совпадений
				// увеличивается переменная defiend - статистическое количество подсчетов земли. Для оптимизации процессов.
					for (var i=0; i<_root.ground_blocks.length; i++){
						if ((++_root.defined || true) and who.sp_y + who.sp_y0 >= 0 && who.hitTest(_root.ground_blocks[i].nad) &&
						(_root.ground_blocks[i].gr.hitTest(who._x, who._y + 1 + who.sp_y + who.sp_y0, true) || _root.ground_blocks[i].gr.hitTest(who._x, who._y + 1, true)))
							{ who._y = _root.ground_blocks[i]._y; return true; } }
				// нижний порог У координаты. Что-то вроде нижнего пола, ниже него опуститься нельзя.
					if (who._y + who.sp_y + who.sp_y0 >= 360){ who._y = 360; return true; }
				// если ни один из блоков не оказывается рядом, то вернуть false - объект в настоящий момент куда-то летит (падает)
					return false;
			}
			
		// on every frame (non update depending)
		// исользуется в связке с set_controlable
		// отслеживает нажатие клавиш и желание сбрасывать оружие, брать оружие, взаимодейтсвовать и тд
			function being_controlable (who:MovieClip){
				for (var tick = 0; tick<_root.updates; tick++){
					// rejoice with a keys
						for (var i=0; i<who.keyBinds.length; i++) if (Key.isDown(who.keyBinds[i])) who.keypresses[i]++; else who.keypresses[i]=0;
					// move accept from keys
					// используются промежутки от 1 до 60, тк на низких кадрах можно не уследить за равенством. [n] == 1 - из-за кол-ва апдейтов в кадр.
							who.wantDrop = (who.keypresses[6] >= 1 && who.keypresses[6] <= 60);			//want to drop weapon
							who.wantReload = (who.keypresses[4] >= 1 && who.keypresses[4] <= 60);		//want to reload a weapon
						// if left | right pressed increase speed
							if (who.keypresses[1]>0 && who.keypresses[0]==0) who.sp_x += who.acs * (who.sp_x < who.sp_x_max);
							if (who.keypresses[0]>0 && who.keypresses[1]==0) who.sp_x -= who.acs * (who.sp_x > -who.sp_x_max);
						// descresing speed when nothing is presseds
							if (who.ground && !((who.keypresses[0]>0 && who.sp_x<0) || (who.keypresses[1]>0 && who.sp_x>0)))if (Math.abs(who.sp_x)>.1)who.sp_x /= who.tormoz; else who.sp_x = 0;
						// watching a jumping
						// добавление звука прыжка от персонажа
							if (who.keypresses[2] == 1 && who.ground){ who.sp_y = -who.jump_heigth; who._y -= 5; who.ground = false; _root.character_sound_start(who,'jump');}
						// not working if is dead
						// массив автоматически сбрасывается в 0, если персонаж умирает. dead - св-во интерфейса set_health
							if (who.dead)who.keypresses = 0;
				}
			}
		
		
		// задает персонажу максимальное количество здоровье, текущее здоровье по дефолту приравнивается максимальному
		// regen - количество кадров до восполнение одного очка здоровье. ( прим. 120 - 1 HP в секунду )
			function set_health ( who:MovieClip, healthMax:Number, regen:Number ){
				who.hpwas = who.hp = who.hpmax = healthMax; who.regenedHealth = 0; who.regenSpd = regen;
				who.dead = false; who.hited = 0; who.stop(); //times hited
			}
		// интерфейс, согласно которому объект может быть ударен.
		// об-ту присваивается команда из соотв-я { 0 - нейтралы и окружение, 1 - герой и сотоварищи, 2 - враги и их товарищи}}
			function set_hitable (who:MovieClip, team:Number){		// 0 - nothing // 1 - friend // 2+ - enemy
				if (team == undefined)who.team = 0; else {who.team = team; if (team > 1)_root.total_enemyes++;}
				who.hitboxes = new Array();							// задаётся массив хитбоксов
				_root.all_hitable.push(who);						// добавление об-та в общий массив всех вещей, которые можно ударить. 
																	// Для проверки касания пуль и тд.
			}
		// каждый апдейт интерфейса hitable - спользуется в паре с назначителем set_hitable
		// проверяет наличие хитбоксов, выстраивает их цвет. спавнит звуки при смерте и получении урона.
		// при смерти уменьшает глоб пер-ые.
			function being_hitable( who:MovieClip ){
				//check color of hitboxes
					if (!(who.hitboxes.length > 0))_root.console_trace("# "+who+" do not have any hitboxes!");
					for (var h = 0; h<who.hitboxes.length; h++)
						{who.hitboxes[h].colors.gotoAndStop(2+4*(who.hp<=0)+who.team);}
				if (who.hited>0)who.hited = 0;
				for (var tick = 0; tick < _root.updates; tick++){
					//is barely alife problems
						if (who.hp <=0 || who.dead){ if (!who.dead || who.hp>0){_root.character_sound_start(who,'dead'); who.gotoAndStop('dead'); if( who.team > 1)_root.total_enemyes--;} who.dead = true; who.hp = 0; return;}
					//regeneration problems
						if (who.hp < who.hpmax){ who.regenedHealth += who.regenSpd; while (who.regenedHealth>1){ who.regenedHealth--; who.hp = Math.min(who.hpmax, who.hp+1); } }
					//accepting a hit
						if (who.hp <= who.hpwas-1){who.hited++; _root.character_sound_start(who,'hited');} who.hpwas = who.hp;
				}
			}
}