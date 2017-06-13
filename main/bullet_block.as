class bullet_block {
	
	function Load (){
		_root.console_trace ( "* Bullet block loaded" ); 
	}
	
	//____________SHOOOTING___THINGS_________________
	//DEFAULT BULLET SPEEDS
		var bullet_types_array = new Array("pistol_bullet","enemy_rifle_bullet");
		var bullet_speed_array = new Array(              7,      new Array(1,10));
		var bullet_spread_array= new Array(              6,   		       	  1);
	
	function rnd_spd ( min, max ){ return  min + random(Math.round(100*(max-min)))/100 ; }
			
	//shoot a bullet
			var hero_bul = -1;
			function spawn_a_bullet( where:MovieClip, bullet_path:String, x0, y0, spd, ang, spread, spread_stats){
				//FPS предохранитель
						if (_root.menu.fps.fps < 10)return;
				//calculate default speed
						var ok = false; if (spd == 'default' || spread == 'default'){for (var i=0; i<bullet_types_array.length; i++)     if ((bullet_types_array[i]+"").indexOf(bullet_path+"")>=0)
							{ if (spd == 'default')spd = bullet_speed_array[i];  if (spread == 'default')spread = bullet_spread_array[i]; ok = true; break; }
						if (!ok){_root.console_trace("# No default speed for bullet '"+bullet_path+"'"); return;}}
						if (spd[1]!=undefined){ if (spd.length == 2)spd = rnd_spd (spd[0], spd[1]); }
				//spawn_a_bulelt
						hero_bul++; _root.total_bullets ++; 
						where.attachMovie(bullet_path,"hero_bul_"+hero_bul, where.getNextHighestDepth()); var b = where["hero_bul_"+hero_bul];
						b._x = x0; b._y = y0; b.spd = spd; b.ang = ang; b.damage = 1; b.damage_done = false;
						b.onUnload = function (){ _root.total_bullets--; }
				//spawn spread
					for (var i= 0; i<spread; i++){var spread_stat = spread_stats[random(spread_stats.length)];  spawn_a_spread (_root.hero_bullets, x0, y0, ang, spd, spread_stat, .001*(random(6)+5)+1);}
				//links
					_root.last_bullet = b;
			}
			var sprd = -1;
			function spawn_a_spread (where:MovieClip,  x0, y0, ang, spd_bul, stat, degrad){// return;
				sprd++; _root.total_spreads ++;
						where.attachMovie("bullet_fly_out", "bl_sprd"+sprd, where.getNextHighestDepth()); var s = where["bl_sprd"+sprd]; 
						s._x = x0; s._y = y0; s.ang = ang; s.stat = stat; s.timer = undefined; s.spd = Math.max(1,Math.min(3,spd_bul/3))*(random(80)/100+.3)*(1+.2*random(6)*(random(50)==0));
						s.degrade_speed = degrad; s.onUnload = function (){ _root.total_spreads--; }
			}
	//hitboxes problems
		function set_hitbox (hitbox:MovieClip, host:MovieClip){	//назначает хитбос для конкретного хоста
			 if (host == undefined){ _root.console_trace("# unknown hitbox host!"); return; }	//если хост не определен, то возврат с ошибкой
			 if (host.hitboxes.length <= 0)host.hitboxes = new Array();					//если нет такого массива, то создать его
			 host.hitboxes.push(hitbox); hitbox.hostID = host;							//добавление в массив хитбоксов, если все успешно
			 hitbox.onUnload = function (){var num = -1; for (var i=0; i<this.hostID.hitboxes.length; i++)if (this.hostID.hitboxes[i] == this){num = i; break;} if (num==-1)return; this.hostID.hitboxes.splice(num,1);}	//при отгрузке убрать хитбокс, чтобы не засорять массив
		}
	//bullet collision
		function test_collision (bullet:MovieClip, side:Number):Boolean{
			if (!bullet.damage_done)
				for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];
					if (((target.team != 1 && bullet._parent == _root.hero_bullets) || (target.team != 2 && bullet._parent == _root.enemy_bullets))												//team check
						&& target.hitTest(bullet._x, bullet._y, true)) for (var i=0; i<target.hitboxes.length; i++)if ( bullet.hitTest(target.hitboxes[i]) )						//collision operator
						{ bullet.gotoAndStop('dead'); bullet.damage_done = true; target.hitboxes[i].colors.hurted._alpha = 100; target.hp-= bullet.damage; target.sp_x0 += .1*bullet.spd*Math.cos(bullet.ang); return true; }			//collision action
			} return false; }
		//WARNING - NOW WORKING ONLY FILTERING UNITS WHO A AMMO HOLDERS
		function hittest_collision (thing:MovieClip):MovieClip{
			for (var tt = 0; tt<_root.all_hitable.length; tt++){ var target = _root.all_hitable[tt];
				if (target.hitTest(thing) && target.ammo_holder)for (var i=0; i<target.hitboxes.length; i++)if ( thing.hitTest(target.hitboxes[i]) ){ return target; }
			} return null;
		}
	
}