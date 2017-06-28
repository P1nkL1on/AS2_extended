import flash.geom.Point;

class levels_block {
	
	static var back_num:Number = 0;
	
	static function set_background_1(){
		set_background ( new Array(
								   'test_back3',
								   'test_back1', 'test_back1', 'test_back1', 'test_back1',
								   'test_back2','test_back2','test_back2','test_back2','test_back2',
								   'test_back4'
								   )
						,new Array(	new Point(300, -40) ,
								   	new Point(100, -40), new Point(200,-40), new Point(400,-40), new Point(500, -40),
									new Point(120, -150),new Point(120, -350),new Point(480, -150), new Point(480, -350), new Point(300, -70),
									new Point(300, -450)
									));
	}
	
	static function set_background (what:Array, where:Array){
		// first clean all backgrounds
			_root.background_layer.removeMovieClip();
			//trace('_root.background_layer deleted '+_root.background_layer);
		// then respawn a background and draw all, what is need
			_root.set_layer ("background_layer"); _root.background_layer.swapDepths(_root.background_depth);
			//trace('_root.background_layer spawned '+_root.background_layer);
		// redraw
			for (var i=0; i< what.length; i++)
				// для каждого бэк-объекта отспавнить его и все
					draw_background_object (what[i], where[i]); 
			
		
	}
	
	static function draw_background_object (what, where:Point){
		_root.background_layer.attachMovie(what + '_background',what+"_background_object_"+back_num, _root.background_layer.getNextHighestDepth()); 
		var last_object:MovieClip = _root.background_layer[what+"_background_object_"+back_num]; back_num++;
		if (last_object == undefined){ _root.console_trace("# No background object, named <"+what+">");return; }
		// draw at point set cache
			last_object._x = where.x; last_object._y = where.y + _root.StageHeight;
			
			//if (last_object.getReady() != undefined)
			last_object.onEnterFrame = function (){// -- функция, которая находится внутри об-та и доводит его до полной готовности
				if (!this.ready){
					this.ready = true; 
					if (this.getReady != undefined)this.getReady ();		// - функция лоада (доводит об-т до ума)
				}
				if (this.InnerFunction != undefined)this.InnerFunction ();	// - функция, которая работает каждый кадр
			}
		// 
	}
	
}
