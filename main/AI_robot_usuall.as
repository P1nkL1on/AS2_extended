class AI_robot_usuall {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			who.followX = 600; who.followY = 0; who.drops = 8; who.hpmax = 4; who.hp = 4;
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			
		}
	
}