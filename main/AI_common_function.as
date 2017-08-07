class AI_common_function {
	static var can_be_target = new Array();
	// whatever common
	// вспомогательные модули
		static function chooseClosestTarget (who:MovieClip):MovieClip{
			can_be_target = new Array();
				for (var i=0; i<_root.all_hitable.length; i++)
					if (_root.all_hitable[i].team >0 && _root.all_hitable[i].team != who.team && _root.all_hitable[i].hp>0)
						can_be_target.push(_root.all_hitable[i]);//target = _root.mouse; 
				can_be_target.sort(order);
				if (can_be_target.length == 0)return null;
				return can_be_target[0]; 
		}
		
		// target choosing
	// для сортировки целей по расстояниям
		static function order(t1, t2):Number { 
		// дистанция высчитывается между началами мувиклипов
			var dist1 = Math.sqrt(Math.pow(_x - t1._x,2)+Math.pow(_y - t1._y + t1._height/2,2));
			var dist2 = Math.sqrt(Math.pow(_x - t2._x,2)+Math.pow(_y - t2._y + t2._height/2,2));
			if (dist1 > dist2)return -1; if (dist2 < dist1)return 1; return 0;
		} 
	
}