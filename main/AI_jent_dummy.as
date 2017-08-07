//

class AI_jent_dummy {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			who.watchTo = _root.mouse; who.wY_offset = -20;
			who.hpmax = who.hp = Math.pow(10, 6); who.regen_timer = 0; who.regenSpd = 0; who.hp2 = who.hp; who.mass = 1200; who.xx = who._x;
				_root.attachMovie("dps_textbox","dp_"+who, _root.getNextHighestDepth()); who.dps = _root["dp_"+who];	  who.borned.push(who.dps);
				who.dps.blendMode = 10; who.dps._x = who._x; who.dps._y = who._y - who._height - 10; who.dmgs = new Array(); who.lst = 0; who.ttl = 0; who.dss = 0; who.avg = 0; who.skp = 1; who.amm = 10;
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			for (var i=0; i<_root.updates; i++){
						// dps counter interactions
							who.dps._x = who._x; who.dps._y = who._y - who.dps._height - who._height;
							who.dps.txt.text = "TTL: "+Math.round(who.ttl)+"\nDPS: "+who.dss+"\nAVG: "+Math.round(100*(who.ttl / (who.skp++) * 120))/100+"\nLST: "+Math.round(100*who.lst)/100;
							who.dmgs.push(Math.max(0,who.hp2 - who.hp)); if (who.dmgs.length > 120) who.dmgs.splice(0,1);
							if (who.hp2 - who.hp > 0 ){who.ttl += who.hp2 - who.hp; who.lst = who.hp2 - who.hp;}
							var summ = 0; for (var j=0; j<who.dmgs.length; j++)summ += who.dmgs[j]; who.dss = Math.round(100*120*summ / who.dmgs.length)/100; who.avg = summ;
						
				// сброс счетчика на реген
					if (who.hp < who.hp2 || who.hp >= who.hpmax){who.regen_timer = 0; if (who.amm <=0 )who.amm = 10;}  
					if (who.hp != who.hp2 ){
						// ! stop
							who.hp2 = who.hp; }
				// реген в случае чего
					if (who.hp >= who.hp2) who.regen_timer ++; 
				// regen speed
					who.regenSpd = 1 * (who.regen_timer > 120 * 8);
				// attacker ammo refill
					if (who.regen_timer > 120 * 8) { if (who.amm-->0 && unit_block.detect_need_ammo (who.last_hited_by) != null) 
						ammo_block.spawn_pickup (who._x, who._y - 20, unit_block.detect_need_ammo (who.last_hited_by), 0, 240*10, who.last_hited_by);} // _root.mouse.Ammo = _root.mouse.Ammo_max;
												
				// block movement
					who.sp_x = 0; who.sp_x0 = 0; who._x += (who.xx - who._x) / 5;
			}
		}
	
}