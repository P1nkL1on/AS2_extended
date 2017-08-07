//

class AI_jent_shooting {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			who.watchTo = _root.mouse; who.wY_offset = -20; who.gun_timer = 0; who.drops = 3; who.hpmax = 3; who.hp = 3;
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			if (who.hp>0){for (var i=0; i<_root.updates; i++){	
							if ((who.watchTo == null || who.watchTo.hp<=0) && ++who.gun_timer%120==0){who.watchTo = AI_common_function.chooseClosestTarget(who); trace(who.watchTo);}//choosing a target
							if (who.watchTo == null)return;	// no target bich
							if (who.gun_timer++%15==0 && who.bullets-->0)										// bullet timing
								bullet_block.spawn_a_bullet ( _root.enemy_bullets, 'enemy_rifle_bullet', who._x, who._y - 50, 'default',							// shooting
													Math.atan2(who._y - who.watchTo._y - who.watchTo._height/2, who._x - who.watchTo._x)+Math.PI, 'default', new Array(4,5), who);	// shooting
							if (who.gun_timer%240 == 0 && who.watchTo.hp > 0)who.bullets = Math.round((3+random(3))*who.AI_power);}}	// reloading
						
						
		}
	
}