class anim_block {
	// Реализует работу с анимируемыми объектами.
	// Обычные методы вроде play()  не могут быть надежно использованы из-за различного количества апдейтов в каждый кадр проекта.
	// Используется инструмент с конечным и начальным кадром.
	
	// Загрузчик
		function Load (){
			_root.console_trace("* Animation block loaded");
		}
		
	// main animate tool
	// who - объект воздействия, startFrame..finishFrame - начальный и конечный кадр анимации. (если последний кадр будет абстрактным - 1..100, а в клипе всего 20 кадров,
	// то анимация не будет цикличной.) speed - количество кадров оригинального времени 1\_root.FPS_stable, котореое должно пройти для перехода к след. кадру анимации
	// direct - направление анимации, по умолчанию задано 1 - прямое.
		function animate (who:MovieClip, startFrame, finishFrame, speed:Number, direct){	//animate an object according to improoved timeline
																							// direct -1 or 1 :: a side where do you wish to animate
				if (who == null) return; if (who.anim>300)who.anim%=300;					// ограничение - чтобы не накапливались слишком большие числа
				if (isNaN(who.anim)) {_root.console_trace("# Warning! Object ("+who+") can not be animate cause do not have an 'anim' property!"); return; }	//error
				if (isNaN(direct))direct = 1;												// default direction of animating is from left to right
				if (who.anim%speed == 0 || isNaN(speed)){									// если скорость неопределена или аним подоспел под скорость
					var fr = who._currentframe; fr += direct; if (fr<startFrame)fr = finishFrame; if (fr>finishFrame)fr = startFrame;	//increasing or descresing a frame counter
					who.gotoAndStop(fr);													// applying changes
		}}
	// framefinder. 
	// Исользует моментальный переход в кадр с заданным именем. Потом запоминает его номер и возвращается обратно. Помогает не высчитывать необходимые кадры и избавится
	// от привязки к числовым значениям кадров. Единственный минус - может вызывать срабатывание триггеров, которые находятся на этих кадрах.
	// Строго рекоммендую не ставить триггеры на кадры с ключевыми названиями.
	// getByName ( target:MovieClip, name_of_frame:String, Number )
		function getByName (who:MovieClip, nam:String):Number{
			var temp = who._currentframe; who.gotoAndStop(nam); var res = who._currentframe; who.gotoAndStop(temp);
			return res;
		}
	// animate automaticly
	// автоматически анимировать какой либо объект. Он должен иметь в себе характеристики anim - численное значение счетчика анимационного перехода
	// и stat - строку, в которой указано название промежутка анимации {'idle','run' etc}
	// autoAnimate (target_of_animation : MovieClip)
		function autoAnimate( who:MovieClip ){
			if (who.stat == undefined) {_root.console_trace("# ("+who + ") can not be auto-animated. Cause it do not have 'stat'"); return;} 	//have no state
			if (who.anim == undefined) {_root.console_trace("# ("+who + ") can not be auto-animated. Cause it do not have 'anim'"); return;}	//have no anim
			who.anim++; if (who.anim_spd == undefined) who.anim_spd = 2;	//if have no speed
			var str = _root.getByName(who,who.stat+"_start");
			var stp = _root.getByName(who,who.stat+"_stop");
			if (who.direct == undefined || who.anim_fix == undefined ||
			( who.anim_fix && ((who.direct > 0 && who._currentframe != stp)||(who.direct < 0 && who._currentframe != str)) ))
				{if (who.direct == undefined)_root.animate(who, str, stp,who.anim_spd);//animating
										else _root.animate(who, str, stp,who.anim_spd, who.direct);}
		}
}