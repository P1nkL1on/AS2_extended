class AI_robot {
	static function set_AI (who){
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
	}
	
	static function being_AI (who:MovieClip){
		//death
							if (who.hp<=0){ who.sp_x = 0; /*unit_block.drop_random_items(who);*/ return; }
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
												if (isNaN(who.targ_x)){who.watch_angle = (who.watch_angle-Math.PI / 800); if (who.watch_angle<-Math.PI)who.watch_angle+=2*Math.PI; who.scanEvery = 60; who.warned = true;}		// scan passivly first
																else{ if (who.warning_time-->0){
																		who.scanEvery = 20;
																		who.targ_x += who.targ_sp_x; who.targ_sp_x /= 1.02; // approxxime movement
																		who.targ_y = Math.min(who.targ_y + who.targ_sp_y, _root.StageHeight-60); who.targ_sp_y += _root.G/2;
																		watchTo(who, .5*(who.targ_x+who.targ_x0), .5*(who.targ_y+who.targ_y0));}		// follow last hear time
																	  	
																	  else{ who.targ_x = Number.NaN; who.targ_y = Number.NaN; }}}	
										else{ who.scanEvery = 4; if (who.targ!=null){watchTo(who, who.targ); 
											if (who.warning_time <= 0){sound_lib.sound_start("npc/other/alert"); /*fun*/who.sp_y -= 4;}// SPOTTED
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
	}
	
	
	
	
	
	
	
	// special functions
		static var WarningTime:Number = 120 * 15;
	
	// select someone in front of view
	// находит цель по смотрящему, его углу обзора и дистанции максимального взгляда
	// необходимый парметр смотрящего :: watch_angle - куда он смотрит сейчас
		static var can_be_target = new Array();
		static var en = null;
		static var ang = 0;
		static var fin_ang = 0;
		static function chooseClosestTargetAngle (who:MovieClip, angle:Number, dist:Number):MovieClip{
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
				can_be_target.sort(AI_common_function.order);	// closest one
			// если не обнаружено ничего
					if (can_be_target.length == 0)return null;
					return can_be_target[0]; 
		}
		
	// выставляет угол зрения на соотсветствующий угол
		static function watchTo (who:MovieClip, x0, y0){
			if (y0 == undefined){
				who.watch_angle = Math.atan2( -who._y + who._height/2 + x0._y,-who._x + x0._x );
			}else{
				who.watch_angle = Math.atan2( -who._y + who._height/2 + y0,-who._x +x0 );
			}
		}
	// become more standart movement
	// goto = {-1, 0, 1}
	// wantJump = {-1, 0, 1}
		static function wantMove (who:MovieClip, sp_x_max:Number, goto:Number, sp_y_max:Number, wantJump:Number){
			if (goto > 0) who.sp_x += goto*who.acs * (who.sp_x < sp_x_max)*(1 + 2*(who.sp_x < 0));
			if (goto < 0) who.sp_x += goto*who.acs * (who.sp_x > -sp_x_max)*(1 + 2*(who.sp_x > 0));
			if (goto == 0 && who.ground){if (Math.abs(who.sp_x)>.1)who.sp_x /= who.tormoz; else who.sp_x = 0;}
		}
	// massive alert!
		static var alarmed = 0;
		static function inform_other (who:MovieClip):Boolean{
			alarmed = 0;
			for (var i=0; i<_root.all_hitable.length; i++)
				if (_root.all_hitable[i].warning_time <= 0 && _root.all_hitable[i].team == who.team && Math.sqrt(Math.pow(_root.all_hitable[i]._x - who._x,2) + Math.pow(_root.all_hitable[i]._y - who._y,2))<300)
					{ _root.all_hitable[i].targ_x = who.targ._x;  _root.all_hitable[i].targ_y = who.targ._y;  _root.all_hitable[i].warning_time = WarningTime; alarmed++;}
			return (alarmed>0);
		}
}