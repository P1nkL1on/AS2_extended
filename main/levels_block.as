import flash.geom.Point;

class levels_block {
	static function Load(){
			_root.console_trace("* Level design block loaded");
		}
	
	static var back_num:Number = 0;
	
	static function set_background_1(max_depths){
		set_background ( new Array(
								   'back_test5+2',
								   'test_back3+1','test_back3+1',
								   'test_back1+0','test_back1+0',
								   'test_back2+0','test_back2+0','test_back2+0',
								   'test_back4+0'
								   )
						,new Array(	new Point (300, -40), 
								   	new Point(90, -50) ,new Point(510, -50) ,
								   	new Point(120, -50),  new Point(480,-50),
									new Point(120, -350),new Point(480, -350), new Point(300, -270),
									new Point(300, -450)
									),
						max_depths);
	}
	// спавнит бэкгрануд по массиву what и where,
	// первый из которых содержэит путь и аргументы в формате'test_back3+5'
	// второй же - массив структур new Point(x,y)
			static function set_background (what:Array, where:Array, max_depths:Number){
				// first clean all backgrounds
					_root.background_layer.removeMovieClip();
					//trace('_root.background_layer deleted '+_root.background_layer);
				// then respawn a background and draw all, what is need
					_root.set_layer ("background_layer"); _root.background_layer.swapDepths(_root.background_depth);
					//trace('_root.background_layer spawned '+_root.background_layer);
				// redraw
					for (var i=0; i< what.length; i++)
						// для каждого бэк-объекта отспавнить его и все
							draw_background_object ((what[i]+"").split('+'), where[i], max_depths); 
			}
	
	// arsgs - массив - передает путь объекта 
	// 		где первое - путь объекта
	// 		где второе число указывает глубину сцены (необходимо для корректного затемнения)
	// where  - показывает точку, в которую его надо прилепить
		
		static var what = "none";
			static function draw_background_object (args:Array, where:Point, max_depths:Number){
			// максимальный размер тени на об-тени
				if (max_depths == undefined) max_depths = 255;
			// путь объекта идет первым в массиве аргументов
				what = args[0];
			// спавним его с таким вот именем на слой фона
				_root.background_layer.attachMovie(what + '_background',what+"_background_object_"+back_num, _root.background_layer.getNextHighestDepth()); 
			// если он не появился, то видимо его нет в библиотеке трэйсим ошибку
					var last_object:MovieClip = _root.background_layer[what+"_background_object_"+back_num]; back_num++;
			// после этого функция завершается
					if (last_object == undefined){ _root.console_trace("# No background object, named <"+what+">");return; }
				// draw at point set cache
					// глубина - вторая в списке аргументов
						last_object.depth = Math.pow(2,(args[1]))/16*max_depths	;	trace(args+'/'+last_object.depth+'/'+max_depths);
						last_object.dep = args[1];
					// /обработка доп арг
						last_object._x = where.x; last_object._y = where.y + _root.StageHeight;	// просчет координат
						last_object.clr = new Color(last_object);								// приготовиться к затемнению
						last_object.clr.setTransform({rb:-last_object.depth, gb:-last_object.depth, bb:-last_object.depth});					// выполнить затемнение
						last_object.xx = last_object._x; last_object.yy = last_object._y; 		// начальные координаты
						last_object.dir = random(200)/100 * Math.PI;							// смещение вращения
					//if (last_object.getReady() != undefined)
						last_object.onEnterFrame = function (){							// -- функция, которая находится внутри об-та и доводит его до полной готовности
								if (!this.ready){
									this.ready = true; 
									if (this.getReady != undefined)this.getReady ();		// - функция лоада (доводит об-т до ума)
								}
							// тряска от menu
							for (var i=0; i<_root.updates; i++){							// shaking
									this._x = this.xx + Math.cos(_root.menu.dir + this.dir)*_root.menu.background_amp * ((4 - this.dep) / 4); 
									this._y = this.yy + Math.sin(_root.menu.dir + this.dir)*_root.menu.background_amp * ((4 - this.dep) / 4);
								}
						if (this.InnerFunction != undefined)this.InnerFunction ();		// - функция, которая работает каждый кадр
					}
			}
	
}
