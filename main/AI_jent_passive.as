//

class AI_jent_passive {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			who.watchTo = _root.mouse; who.wY_offset = -20;
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			
		}
	
}