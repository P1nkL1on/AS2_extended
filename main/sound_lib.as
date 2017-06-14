class sound_lib {
		// Folder - папка, в которой находится звуковая библиотека.
			var Folder:String = 'mice_engine_sound_lib';																							//папка, в которой находится библиотека звуков
		// libr - массив с названиями (путями) до файлов из текущего места без учета окончания ,mp3
			var libr:Array = new Array(); var boop:Sound;  			
			var player_models:Array = new Array('mouse'); 													var player_sounds:Array = new Array('jump','hited','dead');
			var weapon_types:Array = new Array('pistol','shotgun','sawed_off'); 							var weapon_actions:Array = new Array('fire','reload','equip');
			var bullet_types:Array = new Array('bullets','shells','bombs','energys'); 						var bullet_actions:Array = new Array('hit','get');
			var ground_types:Array = new Array('dir','met'); 												var ground_nums:Array = new Array(15, 4);
			
			
			var sounds:Array = new Array();																											//all the sounds
			var all_sounds_loaded:Boolean = false;																									//обновляем загрузчик и ждем конца
			public function Load(){
				
					for (var i=0; i<player_models.length; i++)for (var j=0; j<player_sounds .length; j++) libr.push("player/"+player_models[i]+'/'+player_sounds [j]);
					for (var i=0; i<weapon_types.length; i++)for (var j=0; j<weapon_actions.length; j++) libr.push("weapons/"+weapon_types[i]+'/'+weapon_actions[j]);	// папка с звуками оружия
					for (var i=0; i<bullet_types.length; i++)for (var j=0; j<bullet_actions.length; j++) libr.push("bullets/"+bullet_types[i]+'/'+bullet_actions[j]);	// папка с звуками пуль
					for (var i=0; i<ground_types.length; i++)for (var j=1; j<=ground_nums[i]; j++)libr.push("player/footsteps/"+ground_types[i]+''+j);					// папка с звуками шагов
					libr.push('bullets/ammo_pack'); libr.push('bullets/no_ammo'); for (var i=0; i<3; i++)libr.push('bullets/health'+i);
					
					var await_sounds:Number = libr.length; 																												// создаем массив звуков, в который запишем все наэкспорченное гавно
					for (var i=0; i<libr.length; i++)sounds.push(new Sound());																		// заполняем его пустыми новыми звуками
					for (var i=0; i<libr.length; i++){																								// ставим каждый на загрузку соответствующего адреса
						sounds[i].loadSound(Folder+"/"+libr[i]+".mp3",false); sounds[i].name = libr[i];												// задаем каждому имя, по которому потом будем их разглядывать
						sounds[i].onLoad = function(success:Boolean):Void { if (success){ /*nice!*/}}		 										// при зугрузке трассируем сообщение об успехе, иначе о неудаче
					}			
					_root.console_trace ('* Sound library compiled');
			}
			
		// Воспроизвести звук по имени. (Звук выбирается из массива sounds)
			public function sound_start(nam:String){
				for (var i=0; i<sounds.length; i++)
					if (sounds[i].name.indexOf(nam)>=0){ sounds[i].start(0,1); return; }															//воспроизвести звук совпадающий по имени
				_root.console_trace("# No sound '"+nam+"' in library!"); 																			//если звука нет, бупнем и сообщим об ошибкe
			}
		// Берет у указанного персонажа sound_profile, если такой конечно есть и по его пути находит требуемый звук.
			public function character_sound_start (who:MovieClip, nam:String){
				if (who.sound_profile != undefined)sound_start (who.sound_profile+''+nam);
			}

		// На входе в кадр продолжается загрузка звуков. После их окончательной загрузки выводится сообщение об окончании.
		// Библиотека звуков может быть проверена командами из консоли 
		// info sound - вывод всех звуков библиотеки, их длину
		// find sound <filter> - вывод всех звуков, соот-х фильтру.
		// test sound [x] - проиграть единожды звук за номером x
		// test all sounds - звуковой тест всего всего	
			public function EnterFrame(){
				if (all_sounds_loaded) return;																											// после загрузки всех звуков (хотя бы попытки) больше ничего не делать
				var max = 0; var now = 0;																												// проход по всем звукам
							for (var i=0; i<sounds.length; i++)																							// если звук не забупан, то их текущий\мак размер добавляются в сумму
								{	if (sounds[i].isBoop != true){max += sounds[i].getBytesTotal(); now += sounds[i].getBytesLoaded(); }				// считается и выводится в общий текстбокс процент загрузки незабупаных звуков
									var pc:Number = Math.round(100*sounds[i].getBytesLoaded()/sounds[i].getBytesTotal()); 								// в случае, если показатель загрузки NaN - звук не может быть загружен
									if (isNaN(pc) && !sounds[i].isBoop)	{var temp = sounds[i].name;														// перехватываем его и под тем же именем суем в него предварительно отэкспорченный буп
										sounds[i] = new Sound(); sounds[i].name = temp; sounds[i].attachSound("boop"); sounds[i].isBoop = true;} 		// буп, если что, можно заменить на тишину, или просто убрать соответствующие строки
								}
							if (now == max && !all_sounds_loaded){all_sounds_loaded = true; 
								var loaded = 0; for (var i=0; i<sounds.length; i++)if (!sounds[i].isBoop)loaded++;										// подсчет количество незабупанных звуков
								_root.console_trace('> Sound library loaded ('+loaded+'/'+libr.length+')');												//сообщение о количестве загруженных звуков
							}	
			}
}

