class sound_lib {
		//loading start
			static var loading_start = true;				// request to library sound loading start
			static var loading_ever_started = false;		// have it been started or not? - need for enterFrame correct using
		// Folder - папка, в которой находится звуковая библиотека.
			static var Folder:String = 'mice_engine_sound_lib';																							//папка, в которой находится библиотека звуков
		// libr - массив с названиями (путями) до файлов из текуще		го места без учета окончания ,mp3
		
			static var libr:Array = new Array(); var boop:Sound;  			
			static var player_models:Array = new Array('mouse','hamster','robot','jent');					
			static var player_sounds:Array = new Array('jump','hited','dead');
			
			static var weapon_types:Array = new Array('pistol','shotgun','sawed_off','rocket','tommy');
			static var weapon_actions:Array = new Array('fire','reload','equip');
			
			static var bullet_types:Array = new Array('bullets','shells','bombs','energys'); 	
			static var bullet_actions:Array = new Array('hit','get');
			
			static var ground_types:Array = new Array('common','met','water','bullets','shells','glass','robot'); 												
			static var ground_nums:Array = new Array(       15,    4,      4,        6,       5,	   4,      2);
			static var also:Array = new Array('weapons/rocket/reload_1','items/ammo_pack','items/no_ammo','items/bombs/hit_medium',"npc/other/alert",'enviropment/jumppad');
			
			static var sounds:Array = new Array();																											//all the sounds
			static var all_sounds_loaded:Boolean = false;																									//обновляем загрузчик и ждем конца
			static public function Load(){
				
				if (libr.length > 0){_root.console_trace ('@ Sound library recompiled');return;}
					 
					for (var i=0; i<player_models.length; i++)for (var j=0; j<player_sounds .length; j++) libr.push("npc/voice/"+player_models[i]+'/'+player_sounds [j]);
					for (var i=0; i<weapon_types.length; i++)for (var j=0; j<weapon_actions.length; j++) libr.push("weapons/"+weapon_types[i]+'/'+weapon_actions[j]);	// папка с звуками оружия
					for (var i=0; i<bullet_types.length; i++)for (var j=0; j<bullet_actions.length; j++) libr.push("items/"+bullet_types[i]+'/'+bullet_actions[j]);	// папка с звуками пуль
					for (var i=0; i<ground_types.length; i++)for (var j=1; j<=ground_nums[i]; j++)libr.push("npc/footsteps/"+ground_types[i]+'/'+'stp'+j);					// папка с звуками шагов
					for (var i=0; i<3; i++)libr.push('items/health'+i);
					for (var i=0; i<also.length; i++) libr.push(also[i]);
					
					var await_sounds:Number = libr.length; 																												// создаем массив звуков, в который запишем все наэкспорченное гавно
					
					_root.console_trace ('* Sound library compiled');
			}
			
		// Воспроизвести звук по имени. (Звук выбирается из массива sounds)
			static public function sound_start(nam:String){
				for (var i=0; i<sounds.length; i++)
					if (sounds[i].name.indexOf(nam)>=0){ sounds[i].start(0,1); return; }															//воспроизвести звук совпадающий по имени
				_root.console_trace("# No sound '"+nam+"' in library!"); 																			//если звука нет, бупнем и сообщим об ошибкe
			}
		// Берет у указанного персонажа sound_profile, если такой конечно есть и по его пути находит требуемый звук.
			static public function character_sound_start (who:MovieClip, nam:String){
				if (who.sound_profile != undefined)sound_start ('npc/voice/'+who.sound_profile+'/'+nam);
			}
		
		static var sp_ID = 0;	// индекс папки, в которой хранится нужный звук
		// var ground_types:Array = new Array('common','met','bullets','robot','water'); 	
			// { spec - 0\undefined - nothing special, 1 - quiet step, 2 - wall step, 3 - in water step }
			static public function footstep_sound (who:MovieClip){
				sp_ID = 0;
				if (who.sound_profile!=undefined)
					for(var i=0; i<ground_types.length; i++)if (ground_types[i] == who.sound_profile){ sp_ID = i; break; }
			// special cases
				if (who.last_ground.is_water)sp_ID = 2;	// если почва была водой - то автоматически сменять звук на водяной
				if (who.last_ground.is_wall)sp_ID = 1;	
				sound_start ("npc/footsteps/"+ground_types[sp_ID]+"/stp"+(random(ground_nums[sp_ID])+1));
			}

		// На входе в кадр продолжается загрузка звуков. После их окончательной загрузки выводится сообщение об окончании.
		// Библиотека звуков может быть проверена командами из консоли 
		// info sound - вывод всех звуков библиотеки, их длину
		// find sound <filter> - вывод всех звуков, соот-х фильтру.
		// test sound [x] - проиграть единожды звук за номером x
		// test all sounds - звуковой тест всего всего	
		static var max = 0; static var now = 0;		
		static function EnterFrame(){
				//trace('sound_lib: ent fr'); return;
				if (loading_start){ trace('inlib : started');
					// начало непосредственной загрузки - обявляет запрос на зугрузку по всем адресам
					// этот же участок кода отвечает за перезагрузку (подзагрузку) звуков при смене адреса библиотеки или др.
						loading_start = false; loading_ever_started = true;
							for (var i=0; i<libr.length; i++)sounds.push(new Sound());																		// заполняем его пустыми новыми звуками
							for (var i=0; i<libr.length; i++){																								// ставим каждый на загрузку соответствующего адреса
								sounds[i].loadSound(Folder+"/"+libr[i]+".mp3",false); sounds[i].name = libr[i];												// задаем каждому имя, по которому потом будем их разглядывать
								sounds[i].onLoad = function(success:Boolean):Void { if (success){ /*nice!*/}}		 										// при зугрузке трассируем сообщение об успехе, иначе о неудаче
							}			
					}
				// если загрузка никогда не начиналась 0 не поступало реквестов или наоборот все загружено и нет реквестов на перезагрузку
				if (!loading_ever_started || all_sounds_loaded) return;																					// после загрузки всех звуков (хотя бы попытки) больше ничего не делать
							max = 0; now = 0;																	// проход по всем звукам
							for (var i=0; i<sounds.length; i++)																							// если звук не забупан, то их текущий\мак размер добавляются в сумму
								{	if (sounds[i].isBoop != true){max += sounds[i].getBytesTotal(); now += sounds[i].getBytesLoaded(); }				// считается и выводится в общий текстбокс процент загрузки незабупаных звуков
									var pc:Number = Math.round(100*sounds[i].getBytesLoaded()/sounds[i].getBytesTotal()); 								// в случае, если показатель загрузки NaN - звук не может быть загружен
									if (isNaN(pc) && !sounds[i].isBoop)	{var temp = sounds[i].name;														// перехватываем его и под тем же именем суем в него предварительно отэкспорченный буп
										sounds[i] = new Sound(); sounds[i].name = temp; sounds[i].attachSound("boop"); sounds[i].isBoop = true;} 		// буп, если что, можно заменить на тишину, или просто убрать соответствующие строки
								}
							if (now == max && !all_sounds_loaded){all_sounds_loaded = true; 
							
								while (sounds[sounds.length-1] == undefined)sounds.pop();// cheking undefined sounds
								var loaded = 0; for (var i=0; i<sounds.length; i++)if (!sounds[i].isBoop)loaded++;	 // подсчет количество незабупанных звуков					
								var par = "completely "; if(loaded<libr.length)par = "partly "; if (loaded<=0)par = "was not ";
								_root.console_trace('> Sound library '+par+'loaded ('+loaded+'/'+libr.length+')');												//сообщение о количестве загруженных звуков
									if (par == "partly ")															// обработка незугруженных звуков
										{	_root.console_trace("# Following sounds were not loaded");				// были загружены не все - вывести список таковых
											for (var i=0; i<sounds.length; i++)										// если звук забупан, то пишем об этм
												if (sounds[i].isBoop)_root.console_trace("#   "+sounds[i].name);}
									if (par == "was not ")															// если вообще вся библиотека не загружена, знач скорей всего
										{ 	_root.console_trace("# Library adress ( ../"+Folder+"/ ) is invalid");
											_root.console_trace("@ Use console command <sound library adress = [folder1/folder2/.../sound_lib]>");
											_root.console_trace("@ After this command sound library will be automaticly reloaded");
											_root.console_trace("@ ");
											}// адрес неправильный - выводит текущий адрес и просит релоаднуть вручную
							}	
			}
			
		static var loader_dist = 40; static var res:String = "";
			static public function get_current_load ():String{
				if (max == 0 || now==undefined || max == undefined)return "> Sounds are not loading";		// not loading in a moment
				if (now == max && max!=0)return ">Sounds loading finished";
					res = '> Sounds loading: '+Math.round(now/max*100)+" % |"; for (var i=0; i<loader_dist; i++)if (i<now/max*loader_dist)res+="▐";else res+=" ";
					res+= "| "+Math.round(now/1024/1024*100)/100+'/'+Math.round(max/1024/1024*100)/100;
					return res;
			}
}

