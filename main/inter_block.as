class inter_block {
	// Блок интерфейсов объектов
	// всех, кроме поведенческих, наверное
		// Загрузчик
			static function Load (){
				_root.console_trace("* Object's interfaces block loaded");
			}
			
		// Прикрепляет тело к выбранным ногам. Используйте стандартные ноги (как у мыши) для лучшего эффекта
		// body - тело, legs - ноги.
		// Используется в связке с being_body();
		// Подразумевается, что и тело и ноги являются подклипами одного мувиклипа объекта.
			static function set_body(body:MovieClip, legs:MovieClip){
				body.legs = legs; body.xs = body._xscale; body.stat = "idle"; body.anim = 0; body.stop();
			}
			
		// Каждый апдейт пододвигает тело в сооттветствующую точку для ног.
		// Исользуется только в связке с set_body();
			static function being_body(body:MovieClip){
				
				body._x = body.legs._x - 9*(Math.abs(body._parent.runningWall) == 1 or body.legs.taz.can_update > 0 )*body._parent.runningWall*(.5 + .5 * (body._parent.sp_y >= 0));
				body._y = body.legs._y + body.legs.taz._y;  body._rotation = body.legs.taz._rotation * (body.legs.taz._xscale / Math.abs(body.legs.taz._xscale));	// подгон по координатам
				body._xscale = body._parent.sp_x / Math.abs(body._parent.sp_x ) * body.xs;																			// _xscale определяется знаком горизонтальной скорости родителя
				if (!isNaN(body._parent.sp_x / Math.abs(body._parent.sp_x )))body._parent.wasScale = body._parent.sp_x / Math.abs(body._parent.sp_x );				// если скорость родителя 0, хитрое реешение, исользуется то, что было раньше
				body.anim++;																																		// базовый анимационный сдвиг
				anim_block.animate(body,anim_block.getByName(body,body.stat+"_start"),anim_block.getByName(body,body.stat+"_stop"),body.anim_spd);									// анимирование
			}
			
			
			
			
		// character control problems
		// Controlable - объект управляется с помощью ввода с клавиатуры и тд.
		// Задается сам объект, keys - массив клавиш для управления, клавиш должно быть 8 (мин. 4)
		// общие сведения { перемещение влево, перемещение вправо, вверх, вниз, перезарядка, взаимодействие, выбросить оружие, смена оружия }
		// maxXspeed - максимальная скорость пперемещение по горизонту, jumpHeigth - стандартная высота прыжка, задаётся в положительных числах
		
			static function set_controlable (who:MovieClip,keys:Array, maxXspeed:Number, jumpHeigth:Number){
				who.keyBinds = keys;	// left | right | up | down | reload (R) | interract (E) | drop (G) | swap (Q)
				who.keypresses = new Array(); for (var i=0; i<keys.length; i++) who.keypresses.push(0);
				who.sp_x_max = maxXspeed; who.jump_heigth = jumpHeigth;
			// является управляемым - для определения этого интерфейса
			// wantReload, wantDrop - бул-переменные для отслеживания желаний игрока со стороны пушек
				who.controlable = true; who.wantReload = false; who.wantDrop = false; 
			// бежит ли чар по стене
				who.runningWall = 0;
			}
		// moveble character
		// интерфейс перемещаемого объекта. объект может перемещаться под действием сил гравитации.
		// задаётся объект, задаются его ускорение, торможение (коэффицент около 1.005), отскок от поверхности (положительное число менее единицы), mass (коэффицент действия силы тяжести на об-т)
			static function set_moveble (who:MovieClip, acseleration:Number, desacseleration_k:Number, jumpBack:Number,  mass:Number, max_sp_y:Number){
				who.last_ground = null; 	// мувиклип последней земли, с которой взаимодействовал об-т
				who.sp_x = 0; who.sp_x0 = 0; who.sp_y0 = 0; who.acs = acseleration;  who.tormoz = desacseleration_k;		// назначение переменных
				who.sp_y = 0; who.ground = false; 																			// граунд - переменная бул, отвечающая за то, стоит ли сейчас на земле данный об-т
				who.max_sp_y = max_sp_y;
				if (mass == undefined) who.mass = 1; else who.mass = mass; if (jumpBack == undefined) who.jumpBack = 0; else who.jumpBack = jumpBack;	// дефолтное назначение второстепенных переменных
			}
		// being a moveble thing (даже тумбочка и золодильник должны это использывать)
		// каждый апдейт реализует действия интерфейса moveble. Используется в свзяке с set_moveble
		// параметром передается игнорирование земли (по дефолту false)
			/*static function being_moveble (who:MovieClip, ignore_ground:Boolean){
				if (ignore_ground == undefined) ignore_ground = false;	// default values
					for (var tick = 0; tick<_root.updates; tick++){		// каждый требуемый апдейт
						if (who.ground){ who.ground = defineGround(who); if (Math.abs(who.sp_x0) > 0.1) who.sp_x0 /= who.tormoz; else who.sp_x0 = 0; }	// замедление горизонтальной скорости на земле
						if (!who.ground){ who.sp_y += _root.G; if (who.max_sp_y != undefined && who.sp_y > Math.abs(who.max_sp_y)) who.sp_y = Math.abs(who.max_sp_y);
															   if (!ignore_ground){if (defineGround(who)){if (who.jumpBack == 0){ who.ground = true; who.sp_y = 0; if (who.sp_y0>0) who.sp_y0 = 0; }
																			// при сильном отскоке проигрывать звук удара о землю, если коэффицент jumpBack != 0, то притормаживать по Х и отражать по У. В противном случае приземлить об-т, сбросить все его скорости по У, замедлять по Х
																			 else{ if (Math.abs(who.sp_y)>=1){ if (Math.abs(who.sp_y)>=4)sound_lib.footstep_sound(who); who.sp_y0 = -who.jumpBack*who.sp_y; who.sp_x0 /= who.tormoz; who.sp_y = 0;} else {who.ground = true; who.sp_y = 0; who.sp_y0 = 0;}}}}}
					// other
						check_collision (who);
					// walls
						checkWallCollision (who);
					// movement applyes
						who._x += who.sp_x + who.sp_x0;
						who._y += who.sp_y + who.sp_y0; 
				}}*/
			static function being_moveble (who:MovieClip, ignore_ground:Boolean){
				if (ignore_ground == undefined)
					ignore_ground = false;	// default values
				for (var tick = 0; tick<_root.updates; tick++){		// каждый требуемый апдейт
						if (who.ground)
							{ 
								who.ground = defineGround(who); 
								if (Math.abs(who.sp_x0) > 0.1) 
									who.sp_x0 /= who.tormoz; else who.sp_x0 = 0; 
							}	// замедление горизонтальной скорости на земле
						if (!who.ground){ 
								who.sp_y += _root.G;	// если мы в воздухе, то увеличивается скорость У 
								if (who.max_sp_y != undefined && who.sp_y > Math.abs(who.max_sp_y))
									// если макс скорость установлена и скрость её превышает, то не допустить этого
									who.sp_y = Math.abs(who.max_sp_y);
								if (!ignore_ground)	// если мы не игнорим землю
									{
										if (defineGround(who))	// то определяем её и если столкновение, то...
										{
											if (who.jumpBack == 0 || Math.abs(who.sp_y + who.sp_y0) < 1)	// если отскока нет или он есть, о скорость уже потеряна
												{
												// при сильном отскоке проигрывать звук удара о землю, если коэффицент jumpBack != 0, то притормаживать по Х и отражать по У. В противном случае приземлить об-т, сбросить все его скорости по У, замедлять по Х
												/*otskok ili finish*/ 
													who.ground = true; who.sp_y = 0; 	// мы таки приземляемся, обнуляем все скорости
													who.sp_y0 = 0; 	// её тоже, хотя кажется она нигде не исользуется
												}
												else
												{ 	
													if (Math.abs(who.sp_y)>=4) sound_lib.footstep_sound(who);	// если скорость большая, то восроизвести звук падения
														who.sp_y0 = -who.jumpBack*who.sp_y;	// изменить скорости - сп_у переходит в сп_у0
														who.sp_x0 /= who.tormoz;			// замедление на полную по Х
														who.sp_y = 0;						// обнуление собственной скороси (теперь это энергия подрыгивания)
												}
										}
									}
							}
					// other
						check_collision (who);
					// walls
						checkWallCollision (who);
					// movement applyes
						who._x += who.sp_x + who.sp_x0;
						who._y += who.sp_y + who.sp_y0; 
				}
			}
		// define is object on ground or not
		// используя текущее положение мувиклипа (его центра масс), определяет, касается ли он 
		// какого-нибудь об-та из массива _root.ground_blocks
			static function defineGround (who:MovieClip):Boolean{
				// если все скорости нулевые, то не земля остается прежней. Ну ведь он никуда не может деться, если все его скорости нулевые
					if (who.sp_x + who.sp_x0 == 0 && who.sp_y+who.sp_y0 == 0){return who.ground;}
				// для каждого блока при положительной вертикальной скорсти и соответствующей коллизии, а также координатных совпадений
				// увеличивается переменная defiend - статистическое количество подсчетов земли. Для оптимизации процессов.
					for (var i=0; i<_root.ground_blocks.length; i++){ ++_root.defined;
						if (who.sp_y + who.sp_y0 >= 0 && who.hitTest(_root.ground_blocks[i].nad) &&
						(_root.ground_blocks[i].gr.hitTest(who._x, who._y + 1 + who.sp_y + who.sp_y0, true) ||
						 _root.ground_blocks[i].gr.hitTest(who._x, who._y + 1, true))){
									who._y = _root.ground_blocks[i]._y; 
									who.last_ground = _root.ground_blocks[i]; 
									water_check (who);// water special
									return true; 
								}}
				// нижний порог У координаты. Что-то вроде нижнего пола, ниже него опуститься нельзя.
					if (who._y + who.sp_y + who.sp_y0 >= _root.StageHeight-40){ who._y = _root.StageHeight-40; return true; }
				// если ни один из блоков не оказывается рядом, то вернуть false - объект в настоящий момент куда-то летит (падает)
					return false;
			}
		// cheking wall collision for a subject of stopping
		// Стены, которые мешают пройти (гениально)
			static function checkWallCollision (who:MovieClip){
				// если не движется по горизонтали, то не может ударится об сцену
					if (who.sp_x + who.sp_x0 == 0) return false;
				// выполнять проверку для каждого объекта из массива стена (те, которые действительно должны препятствовать движению должны быть помечены can_block = true)
					for (var i=0; i<_root.wall_blocks.length;i++ )
					{	wall = _root.wall_blocks[i];  
					// касается верхнего хитбокса и со смещением по скорости (помноженные на направление, куда смотрит хитбокс стены) касается основного хитбокса.
						if (wall.can_block == true && (who.hitTest(wall.nad)) && (wall.gr.hitTest(who._x -who._width / 4 * wall.direct + who.sp_x + who.sp_x0, who._y - 10))
								&& ((who.sp_x + who.sp_x0)*(wall.direct)<=0))
							// смещение на четверть ширины.
							{  who._x = wall._x+who._width / 4 * wall.direct; who.sp_x *= wall_diflect; who.sp_x0 *= wall_diflect; }
					}
			} 
		// переменная, в которой текущая стена.wall_dist - дистанция, на которой вохможно бенжать по стене (должна быть постоянной, тк
		// ширина об-та во время анимации может меняться). wall_deflect - к-т отражения от обычной стены по горизонтали
		static var wall = null; static var wall_dist = 25; static var wall_diflect = -.8;
			static function checkWallRun (who:MovieClip):Number{
				for (var i=0; i<_root.wall_blocks.length; i++){ 
				{ wall = _root.wall_blocks[i]; 
					// увеличиваем кол-во посчитанных счетчиков. Если об-т не на земле, касается стены таким же образом как и в пред. функции
					if ((++_root.defined || true) && wall.can_run == true && (!who.ground) && who.hitTest(wall.nad)
						 && wall.gr.hitTest( who._x - wall_dist*wall.direct + who.sp_x, who._y, true ) && ( who.sp_x + who.sp_x0 )*wall.direct <= 0
						// нажаты соответствующие кнопки удержания на стене (если стена проходима) или таймер стены не истек (стена непроходима) -- автоматическое прилипание
						 && ((wall.direct <= 0 && who._x < wall._x  && (who.keypresses[1] > 0 ||( wall.can_block == true && --wall.timer>0)))
						 || ( wall.direct >= 0 && who._x > wall._x  && (who.keypresses[0] > 0 || (wall.can_block == true && --wall.timer>0)))))
					
							{ who.sp_y = Math.min(Math.max(who.sp_y - _root.G * .4,-15), .2); who._x = wall._x+wall_dist*wall.direct; // пристроиться к стене и замедлить торможение по У
							  if (wall.direct == undefined) wall.direct = 0;											// вдруг директа нет - сторона, вкоторую направлена стена
							  who.sp_x = -.1*wall.direct; who.sp_x0 = -.1*wall.direct;									// изменение скорости по Х (.1 а не 0, чтобы не было бага проскальзывания)
							  if (who.keypresses[0]*(wall.direct>0)+who.keypresses[1]*(wall.direct<0)+who.keypresses[2]!=0)wall.timer = 60;				// таймер прилипания
							  who.last_ground = wall; return wall.direct; } }}																	// в случае, когда ты уже на стене, возвращает направление возможного отпрыга
				return 0;																								// ничего не нашел
			}
			
		// on every frame (non update depending)
		// исользуется в связке с set_controlable
		// отслеживает нажатие клавиш и желание сбрасывать оружие, брать оружие, взаимодейтсвовать и тд
			static function being_controlable (who:MovieClip){
				// rejoice with a keys
						for (var i=0; i<who.keyBinds.length; i++) if (Key.isDown(who.keyBinds[i])) who.keypresses[i]++; else {if (_root.updates>0)who.keypresses[i]=0;}
				for (var tick = 0; tick<_root.updates; tick++){
						// move accept from keys
						// используются промежутки от 1 до 60, тк на низких кадрах можно не уследить за равенством. [n] == 1 - из-за кол-ва апдейтов в кадр.
							who.wantDrop = (who.keypresses[6] >= 1 && who.keypresses[6] <= 60);			//want to drop weapon
							who.wantReload = (who.keypresses[4] >= 1 && who.keypresses[4] <= 60);		//want to reload a weapon
						// if left | right pressed increase speed
							if (who.keypresses[1]>0 && who.keypresses[0]==0) who.sp_x += who.acs * (who.sp_x + who.sp_x0 < who.sp_x_max);
							if (who.keypresses[0]>0 && who.keypresses[1]==0) who.sp_x -= who.acs * (who.sp_x + who.sp_x0 > -who.sp_x_max);
						// descresing speed when nothing is presseds
							if (who.ground && !((who.keypresses[0]>0 && who.sp_x<0) || (who.keypresses[1]>0 && who.sp_x>0)))if (Math.abs(who.sp_x)>.1)who.sp_x /= who.tormoz; else who.sp_x = 0;
						// watching a jumping
						// wall running
							who.runningWall = checkWallRun (who);
							if (who.runningWall == undefined) who.runningWall = 0;	// kostil
						// добавление звука прыжка от персонажа
							if (who.keypresses[2] >= 1 && who.keypresses[2] <= 3 && ( who.ground || who.runningWall!=0))
								{ 	who.keypresses[2] = 60;
									who.sp_x0 += who.runningWall*(3); who._x += who.runningWall*(2);// смещение по x при отпрыге от стены
									who.sp_y = -who.jump_heigth * (1-.2*(who.runningWall!=0)); 
									who._y -= 1; who.ground = false; sound_lib.character_sound_start(who,'jump');}
						// not working if is dead
						// массив автоматически сбрасывается в 0, если персонаж умирает. dead - св-во интерфейса set_health
							if (who.dead)who.keypresses = 0;
						}
			}
		
		
		// задает персонажу максимальное количество здоровье, текущее здоровье по дефолту приравнивается максимальному
		// regen - количество кадров до восполнение одного очка здоровье. ( прим. 120 - 1 HP в секунду )
			static function set_health ( who:MovieClip, healthMax:Number, regen:Number ){
				who.hpwas = who.hp = who.hpmax = healthMax; who.regenedHealth = 0; who.regenSpd = regen;
				who.dead = false; who.hited = 0; who.stop(); //times hited
			}
		// интерфейс, согласно которому объект может быть ударен.
		// об-ту присваивается команда из соотв-я { 0 - нейтралы и окружение, 1 - герой и сотоварищи, 2 - враги и их товарищи}}
			static function set_hitable (who:MovieClip, team:Number){		// 0 - nothing // 1 - friend // 2+ - enemy
				if (team == undefined)who.team = 0; else {who.team = team; if (team > 1)_root.total_enemyes++;}
				who.hitboxes = new Array();							// задаётся массив хитбоксов
				_root.all_hitable.push(who);						// добавление об-та в общий массив всех вещей, которые можно ударить. 
																	// Для проверки касания пуль и тд.
				who.last_hited_by = null;							// объект, который нанес свой удар последним
			}
		// каждый апдейт интерфейса hitable - спользуется в паре с назначителем set_hitable
		// проверяет наличие хитбоксов, выстраивает их цвет. спавнит звуки при смерте и получении урона.
		// при смерти уменьшает глоб пер-ые.
			static function being_hitable( who:MovieClip ){
				//check color of hitboxes
					if (!(who.hitboxes.length > 0))_root.console_trace("# "+who+" do not have any hitboxes!");
					for (var h = 0; h<who.hitboxes.length; h++)
						{who.hitboxes[h].colors.gotoAndStop(2+4*(who.hp<=0)+who.team);}
				if (who.hited>0)who.hited = 0;
				for (var tick = 0; tick < _root.updates; tick++){
					//is barely alife problems
						if (who.hp <=0 || who.dead){ if (!who.dead || who.hp>0){sound_lib.character_sound_start(who,'dead'); who.gotoAndStop('dead'); if( who.team > 1)_root.total_enemyes--;} who.dead = true; who.hp = 0; return;}
					//regeneration problems
						if (who.hp < who.hpmax){ who.regenedHealth += who.regenSpd; while (who.regenedHealth>1){ who.regenedHealth--; who.hp = Math.min(who.hpmax, who.hp+1); } }
					//accepting a hit
						if (who.hp <= who.hpwas-1){who.hited++; sound_lib.character_sound_start(who,'hited');} who.hpwas = who.hp;
				}
			}
		// (В будущем можно использовать и для пыли (др. эффектов))
		// функции для анимации эффектов хождения
		// в частности для хождения по воде
			static function water_check (who){
			// если скорость по Х не нулевая и приземлился или был совершен шаг (у об-та бул. поле step == true - последнгий шаг был сделан и еще не считан)
				if (who.last_ground.is_water && (!who.ground || (who.ground && Math.abs(who.sp_x + who.sp_x0)>0 && who.step)))
									  { export_block.export_effect('default','water_splash',who._x, who._y, 0); who.step = false;	// переназнчение совершенного шага
										_root.lastEffect._alpha = 80;	// созданному всплеску назначается прозрачность и соот-щий случаю кадр
										_root.lastEffect.gotoAndStop(detect_water(who, _root.lastEffect));}// define pluh
			}
		// по текущему состоянию мувиклипа (скорости Х и У) определяется размер совершенн
			static function detect_water (who:MovieClip, water:MovieClip):String{
				if (who._width >= 35){
					if (who.sp_y > 7)return "large";	// упал откуда-то с высоты - большой всплеску
					if (who.sp_y > 2)return "medium";}	// с небольшой высоты, но все таки упал
			// предотвращает ложное появление всплеска для слишком маленьких об-тов или незначительных высот (колебаний около земли)
				if (who._width < 4 || (who.sp_y <= .5 && who.sp_y!=0))water.removeMovieClip();	
			// по дефолту возвращает обычные круги на воде
				return "small";
			}
		// попытка в коллизии, как в автобусном проекте
		// если два объекта, оба из которых принадлежат интерфейсу isUnit
		// пересекаются своими основными массами и находятся на дистанции меньшей ширины одного из них на .5*
		// то их sp_x и sp_y меняются  начинают отталкиваются
			static function check_collision (who:MovieClip){
				if (who.isUnit != true && who.isCollisionable != true)return;
				for (var opponent = 0; opponent<_root.all_hitable.length; opponent++)
						{
						// если он подходит под 1 из интерфейсов, то
							if (!(_root.all_hitable[opponent]!= who && _root.all_hitable[opponent].isUnit || _root.all_hitable[opponent].isCollisionable))continue; else ++_root.defined;
						// высчитать дистанцию
							if (Math.sqrt(Math.pow(who._x - _root.all_hitable[opponent]._x,2)+Math.pow(2*(who._y - _root.all_hitable[opponent]._y),2))<who._width*.5)
								{
									var mod = Math.sqrt(Math.pow(Math.abs(who.sp_x + who.sp_x0)+Math.abs(_root.all_hitable[opponent].sp_x+_root.all_hitable[opponent].sp_x0),2)
													+Math.pow(Math.abs(who.sp_y + who.sp_y0)+Math.abs(_root.all_hitable[opponent].sp_y+_root.all_hitable[opponent].sp_y0),2))
									// угол между их центраи
									var summMass = _root.all_hitable[opponent].mass + who.mass;
									var angle = Math.atan2(who._y - who._height/2 - _root.all_hitable[opponent]._y + _root.all_hitable[opponent]._height/2, who._x - _root.all_hitable[opponent]._x);
									var anU = angle; var anO = angle + Math.PI;
									var dist = -1; var power = -.2;
									// отталкновение по оси столкновения и скорости
									// У зависит от земельного положения (если об-т на земле, то он не вспрыгнет от столкновения)
									// Х меняется по закону сохранения импульса
									// trace (who+'/'+_root.all_hitable[opponent]+'/'+who.mass+'/'+_root.all_hitable[opponent].mass);
									// изменение по Х
										who._x -= dist*Math.cos(anU); _root.all_hitable[opponent]._x -= dist*Math.cos(anO);
											who.sp_x0 += mod/2*Math.cos(anU+Math.PI)*power*( who.mass / summMass );  
											_root.all_hitable[opponent].sp_x0 += mod/2*Math.cos(anO+Math.PI)*power*( _root.all_hitable[opponent].mass / summMass );
									// изменение по У	
										who._y -= dist/2*Math.sin(anU); _root.all_hitable[opponent]._y -= dist/2*Math.sin(anO);
											who.sp_y += mod/2*Math.sin(anU+Math.PI)*power*(!who.ground)*( who.mass / summMass ); 
											_root.all_hitable[opponent].sp_y += mod/2*Math.sin(anO+Math.PI)*power*(!_root.all_hitable[opponent].ground)*( _root.all_hitable[opponent].mass / summMass );
				}}}
}