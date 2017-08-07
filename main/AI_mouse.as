class AI_mouse {
	// AFTER
	/*
	inter_block.set_moveble (who, .02, 1.04);		// все юниты перемещаются
	who.ground = false;								// переопределение земли
	inter_block.set_health (who, 10, .001);			// и имеют стандартно 10 здоровья
	inter_block.set_hitable (who, team);			// и могут быть отпинаны*/
		static function set_AI (who:MovieClip){
			// 2.5 max spd - faster, .06 - better control
							// 2 - normal speed,     .02 - slow cpntrol
								//inter_block.set_controlable (this, new Array ( 65, 68, 87, 83, 82, 69, 71, 81 ), 2.5, 6);	//37, 39, 38, 40
								
								who.sound_profile = who.path;
								who.acs =  .06; who.tormoz = 1.1; var wheretail = who._parent; 
								
								// tail spawn
									if (who.path != 'mouse')return;
									wheretail.attachMovie("mouse_tail",'tail_of_'+who, who.getDepth()-101); var tail = wheretail['tail_of_'+who];
									tail.anim = 0; tail.stop(); tail.rot = 0; tail.parent = who; 
									
									tail.onEnterFrame = function (){
										for (var i=0; i<_root.updates; i++) 
											{this.anim++; anim_block.animate (this,1,22,20-10*(Math.abs(this.parent.sp_x)>1),1); this._rotation += (this.rot-this._rotation)/20;}
												this.rot = (this.parent.sp_y <= 0)*((this.parent.body._xscale < 0)*(60 + 30*(this.parent.sp_y < 0))-
													(this.parent.body._xscale > 0)*(20 + 30*(this.parent.sp_y < 0)));
										this._x = this.parent._x;
										this._y = this.parent._y - 20;
									}
	
		}
	/*AFTER
	who.InnerEnterFrame ();
	inter_block.being_moveble (who);
	inter_block.being_hitable (who);*/				
		static function being_AI (who:MovieClip){
			
		}
	
}