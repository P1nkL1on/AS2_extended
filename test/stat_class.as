
class stat_class
{
	static function pub_f (X){
		//Y++;
		trace('pub_f_'+X+"_");
	}
	static function f (X){
		//Y++;
		trace('f_'+X+"_");
		_root.checkA();
	}


}