class inter_block {
		function Load (){
			_root.console_trace("* Object's interfaces block loaded");
		}
	
		function set_body(body:MovieClip, legs:MovieClip){
			body.legs = legs; body.xs = body._xscale; body.stat = "idle"; body.anim = 0; body.stop();
		}
		function being_body(body:MovieClip){
			body._y = body.legs._y + body.legs.taz._y;  body._rotation = body.legs.taz._rotation * (body.legs.taz._xscale / Math.abs(body.legs.taz._xscale));
			body._xscale = body._parent.sp_x / Math.abs(body._parent.sp_x ) * body.xs;			//_xscale as sp_x of parent
			if (!isNaN(body._parent.sp_x / Math.abs(body._parent.sp_x )))body._parent.wasScale = body._parent.sp_x / Math.abs(body._parent.sp_x );
			body.anim++;
			_root.animate(body,_root.getByName(body,body.stat+"_start"),_root.getByName(body,body.stat+"_stop"),body.anim_spd);//animating
		}
		
		
	//character control problems
		function set_controlable (who:MovieClip,keys:Array, maxXspeed:Number, jumpHeigth:Number){
			who.keyBinds = keys;	// left | right | up | down | reload (R) | interract (E) | drop (G) | swap (Q)
			who.keypresses = new Array(); for (var i=0; i<keys.length; i++) who.keypresses.push(0);
			who.sp_x_max = maxXspeed; who.jump_heigth = jumpHeigth;
			who.controlable = true; who.wantReload = false; who.wantDrop = false; 
		}
	//moveble character
		function set_moveble (who:MovieClip, acseleration:Number, desacseleration_k:Number, jumpBack:Number,  mass:Number){
			who.sp_x = 0; who.sp_x0 = 0; who.sp_y0 = 0; who.acs = acseleration;  who.tormoz = desacseleration_k;
			who.sp_y = 0; who.ground = false; 
			if (mass == undefined) who.mass = 1; else who.mass = mass; if (jumpBack == undefined) who.jumpBack = 0; else who.jumpBack = jumpBack;
		}
	//being a moveble thing (даже тумбочка и золодильник должны это использывать)
		function being_moveble (who:MovieClip, ignore_ground:Boolean){
		//default values
		if (ignore_ground == undefined) ignore_ground = false;
			for (var tick = 0; tick<_root.updates; tick++){
				if (who.ground){ who.ground = defineGround(who); if (Math.abs(who.sp_x0) > 0.1) who.sp_x0 /= Math.pow(who.tormoz,.25); else who.sp_x0 = 0;		}						//F трения 
				if (!who.ground){ who.sp_y += _root.G*who.mass; if (!ignore_ground){if (defineGround(who)){if (who.jumpBack == 0){ who.ground = true; who.sp_y = 0; if (who.sp_y0>0) who.sp_y0 = 0; }
																	/*otskok ili finish*/ else{ if (Math.abs(who.sp_y)>=1){ if (Math.abs(who.sp_y)>=4)_root.footstep_sound(); who.sp_y0 = -who.jumpBack*who.sp_y; who.sp_x0 /= who.tormoz; who.sp_y = 0;} else {who.ground = true; who.sp_y = 0; who.sp_y0 = 0;}}}}}
											//landing
			//movement applyes
				who._x += who.sp_x + who.sp_x0;
				who._y += who.sp_y + who.sp_y0; 
		}}
	
	//define is object on ground oe not
		function defineGround (who:MovieClip):Boolean{
			//maximum
			if (who.sp_x + who.sp_x0 == 0 && who.sp_y+who.sp_y0 == 0){return who.ground;}
			//defined ++; 
			for (var i=0; i<_root.ground_blocks.length; i++){
				if ((++_root.defined || true) and who.sp_y + who.sp_y0 >= 0 && who.hitTest(_root.ground_blocks[i].nad) &&
				(_root.ground_blocks[i].gr.hitTest(who._x, who._y + 1 + who.sp_y + who.sp_y0, true) || _root.ground_blocks[i].gr.hitTest(who._x, who._y + 1, true)))
					{ who._y = _root.ground_blocks[i]._y; return true; } }
			if (who._y + who.sp_y + who.sp_y0 >= 360){ who._y = 360; return true; }
			return false;
		}
		
	//on every frame (non update depending)
		function being_controlable (who:MovieClip){
			for (var tick = 0; tick<_root.updates; tick++){
				//rejoice with a keys
					for (var i=0; i<who.keyBinds.length; i++) if (Key.isDown(who.keyBinds[i])) who.keypresses[i]++; else who.keypresses[i]=0;
				//move accept from keys
						who.wantDrop = (who.keypresses[6] >= 1 && who.keypresses[6] <= 60);		//want to drop weapon
						who.wantReload = (who.keypresses[4] >= 1 && who.keypresses[4] <= 60);		//want to reload a weapon
					//if left | right pressed increase speed
						if (who.keypresses[1]>0 && who.keypresses[0]==0) who.sp_x += who.acs * (who.sp_x < who.sp_x_max);
						if (who.keypresses[0]>0 && who.keypresses[1]==0) who.sp_x -= who.acs * (who.sp_x > -who.sp_x_max);
					//descresing speed when nothing is presseds
						if (who.ground && !((who.keypresses[0]>0 && who.sp_x<0) || (who.keypresses[1]>0 && who.sp_x>0)))if (Math.abs(who.sp_x)>.1)who.sp_x /= who.tormoz; else who.sp_x = 0;
					//watching a jumping
						if (who.keypresses[2] == 1 && who.ground){ who.sp_y = -who.jump_heigth; who._y -= 5; who.ground = false; _root.character_sound_start(who,'jump');}
					//not working if is dead
						if (who.dead)who.keypresses = 0;
			}
	}
	
	
	
	
		function set_health ( who:MovieClip, healthMax:Number, regen:Number ){
			who.hpwas = who.hp = who.hpmax = healthMax; who.regenedHealth = 0; who.regenSpd = regen;
			who.dead = false; who.hited = 0; who.stop(); //times hited
		}
		function set_hitable (who:MovieClip, team:Number){		// 0 - nothing // 1 - friend // 2+ - enemy
			if (team == undefined)who.team = 0; else {who.team = team; if (team > 1)_root.total_enemyes++;}
			who.hitboxes = new Array();
			_root.all_hitable.push(who);
		}
		function being_hitable( who:MovieClip ){
			//check color of hitboxes
				if (!(who.hitboxes.length > 0))_root.console_trace("# "+who+" do not have any hitboxes!");
				for (var h = 0; h<who.hitboxes.length; h++)
					{who.hitboxes[h].colors.gotoAndStop(2+4*(who.hp<=0)+who.team);}
			if (who.hited>0)who.hited = 0;
			for (var tick = 0; tick < _root.updates; tick++){
				//is barely alife problems
					if (who.hp <=0 || who.dead){ if (!who.dead || who.hp>0){_root.character_sound_start(who,'dead'); who.gotoAndStop('dead'); if( who.team > 1)_root.total_enemyes--;} who.dead = true; who.hp = 0; return;}
				//regeneration problems
					if (who.hp < who.hpmax){ who.regenedHealth += who.regenSpd; while (who.regenedHealth>1){ who.regenedHealth--; who.hp = Math.min(who.hpmax, who.hp+1); } }
				//accepting a hit
					if (who.hp <= who.hpwas-1){who.hited++; _root.character_sound_start(who,'hited');} who.hpwas = who.hp;
			}
		}
}