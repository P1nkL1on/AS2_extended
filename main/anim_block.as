class anim_block {
		function Load (){
			_root.console_trace("* Animation block loaded");
		}
		
	// main animate tool
		function animate (who:MovieClip, startFrame, finishFrame, speed:Number, direct){//animate an object according to improoved timeline
																			// direct -1 or 1 :: a side where do you wish to animate
				if (who == null) return; if (who.anim>300)who.anim%=300;	// ограничение - чтобы не накапливались слишком большие числа
				if (isNaN(who.anim)) {_root.console_trace("# Warning! Object ("+who+") can not be animate cause do not have an 'anim' property!"); return; }	//error
				if (isNaN(direct))direct = 1;								// default direction of animating is from left to right
				if (who.anim%speed == 0 || isNaN(speed)){					// если скорость неопределена или аним подоспел под скорость
					var fr = who._currentframe; fr += direct; if (fr<startFrame)fr = finishFrame; if (fr>finishFrame)fr = startFrame;	//increasing or descresing a frame counter
					who.gotoAndStop(fr);									// applying changes
		}}
	// framefinder. находит кадр в заданном мувиклипе по названию. Просто и гениально.
		function getByName (who:MovieClip, nam:String):Number{
			var temp = who._currentframe; who.gotoAndStop(nam); var res = who._currentframe; who.gotoAndStop(temp);
			return res;
		}
	// animate automaticlu
		function autoAnimate( who:MovieClip ){
			if (who.stat == undefined) {_root.console_trace("# ("+who + ") can not be auto-animated. Cause it do not have 'stat'"); return;} 	//have no state
			if (who.anim == undefined) {_root.console_trace("# ("+who + ") can not be auto-animated. Cause it do not have 'anim'"); return;}		//have no anim
			who.anim++; if (who.anim_spd == undefined) who.anim_spd = 2;	//if have no speed
			_root.animate(who,_root.getByName(who,who.stat+"_start"),_root.getByName(who,who.stat+"_stop"),who.anim_spd);//animating
		}
}