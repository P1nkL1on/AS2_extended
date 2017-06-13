class export_block {
	
		function Load (){
			_root.console_trace("* Export block loaded");
		}
	
		var obs_fly:Number = -1;
		function export_object (where, path:String, time:Number, x0, y0, sp_x0, sp_y0, acs, tormoz, mass , ignore_ground ,  jumpBack ){
			//default values
				if (where == undefined){ _root.console_trace('# No place '+where); return; } if (path == undefined){ _root.console_trace('# No path: '+where); return; }
				if (time == undefined) time = _root.FPS_stable * 10; /*if time == -1 then this object will not be remooved*/
				if (x0 == undefined || y0 == undefined){ _root.console_trace('# Place is incorrect'); return;}
				if (sp_x0 == undefined) sp_x0 = 0;  if (sp_y0 == undefined) sp_y0 = 0; if (acs == undefined) acs = 0;  if (tormoz == undefined) tormoz = 1.05;
				if (mass == undefined) mass = 1; if (jumpBack == undefined) jumpBack = 0; if (ignore_ground == undefined) ignore_ground = false;
			//______________________________
					//exporting from library
						obs_fly ++;  _root.total_objects++; where.attachMovie(path, "ob_fl_"+obs_fly, where.getNextHighestDepth()); var s = where["ob_fl_"+obs_fly];
					//set vairables
							_root.set_moveble(s,acs, tormoz, jumpBack, mass); s._x = x0; s._y = y0; s.sp_x0 = sp_x0; s.sp_y = sp_y0; s.stop();  s.ignore_ground = ignore_ground; s.timer = time;
					//move as you want
							s.onEnterFrame = function (){ _root.being_moveble(this, ignore_ground); if (this.timer>0){this.timer -= _root.timeElapsed; if (this.timer<=0 || (! this.hitTest(_root.cam) && !this.isPickUp))this.removeMovieClip();} }
							s.onUnload = function (){ _root.total_objects--; }
					//add to linkage
							_root.last_exported = s;
		}
	//effect exporting
		var ef_sc:Number = -1;
		function export_effect (where, path:String, x0, y0, angle){
			ef_sc ++;  _root.total_effects++; where.attachMovie(path+"_effect", "ef_sc_"+ef_sc, where.getNextHighestDepth()); var e = where["ef_sc_"+ef_sc];
			e._x = x0; e._y= y0; e._rotation =( angle )/Math.PI*180; e.onUnload = function (){ _root.total_effects --; }
			_root.lastEffect = e;
		}
	
}