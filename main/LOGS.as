class LOGS{
	static function case_low_fps (){
	// info more - на слое с пулями героя дополнительная информация в реальном времени
				if (_root.hero_bullets.info._visible)
					_root.hero_bullets.info.text = 
					'Enemyes: '+_root.total_enemyes+
					'\nObjects: '+_root.total_objects+
					'\nEffects: '+_root.total_effects+
					'\nBullets: '+_root.total_bullets+
					'\nSpreads: '+_root.total_spreads+
					'\nGround defines: '+_root.defined; 
		// LOGS if very low fps
				if (_root.current_fps < 13 || (_root.current_fps < 10 && _root.updates == 0 && !_root.PAUSE))
					trace('['+_root.pad(10, Math.round(100*_root.total_time_elapsed)/100)+' ]: FPS: '+
							_root.pad(10, Math.round(_root.current_fps*1000)/1000)+'     UPD: '+
							_root.pad(3, _root.updates)+ '     BLT/SPRD: '+
							_root.pad(10, _root.total_bullets+'/'+_root.total_spreads)+'     EFF: '+
							_root.pad(5, _root.total_effects)+'     GRN: '+_root.pad(5, _root.defined));
		// external bad things
			if (--timer_change <= 0 && _root.time_automatic){
				_root.time_slow = 1;
				if (_root.updates > 8){ _root.time_slow = .5; timer_change = 60; _root.console_trace("# Forced time slow to 1/2");}
				if (_root.updates > 16){ _root.time_slow = .2; timer_change = 240; _root.console_trace("# Forced time slow to 1/10 (read LOGS)");}
			}
	}
	
	static var timer_change:Number = 0;
}