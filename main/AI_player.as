class AI_player {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			inter_block.set_controlable (who, new Array ( 65, 68, 87, 83, 82, 69, 71, 81 ), 2.5, 6);	//37, 39, 38, 40// персонаж, за которого играет игрок
			weapon_block.set_a_gun_holder(who); 
			ammo_block.set_ammo_holder(who, new Array(128,32,32,32));
			who.followX = who._x; who.followY = who._y; who.gunYoffset = -20;
			//who.reload_multiply = .5;
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			inter_block.being_controlable (who);
			weapon_block.being_a_gun_holder (who);
			who.followX = _root._xmouse; who.followY = _root._ymouse;
		}
	
}