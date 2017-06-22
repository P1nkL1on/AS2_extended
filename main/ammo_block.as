class ammo_block {
	// Блок регулировки патронов. Определяются типы патронов, максимальное их количество для персонажа.
	// Также позволяет экспортировать подбираемые патроны и хилки на сцену.
	
	// Загрузчик
		static function Load(){
			_root.console_trace( "* Ammo logick block loaded" );
		}
	// Интерфейса, отвечающий за то, может ли персонаж иметь какой-то боезапас, подбирать патроны разных типов.
	// Смежно отвечает за то, что персонаж может подбирать хилки. (подробнее смотри в bullet_block.ac)
	// who - цель, ammo - массив из 4-х (по дефолту) чисел, отвечающих за начальное количество патронов каждого типа
	// набор параметров "this, new Array(50, 0, 0, Number.POSTIVE_INFINITY)" будет обозначать, что у этого мувиклипа
	// 50 пуль, 0 дроби, 0 энергии и БЕСКОНЕЧНОСТЬ бомб. Бесконечность также была предусмотрена для NPC
	
		static function set_ammo_holder (who:MovieClip, ammo:Array){	
			who.Ammo = ammo; who.Ammo_max = new Array(200, 60, 100, 40); who.ammo_holder = true;
		}
	
	// Функция, позволяющая в определенном месте спавнить патрон или хилку произвольного типа и размера
	// х0, у0 - координаты начала движения спавниваемого эл-та.
	// typ = целочисленный параметр, -1 == хилка, 1,2,3,4 - соответственный элемент патронов
	// fadetime - время, через которое дроп. автоматически исчезнет. Измеряется в кадрах. Может быть установлен -1 или POSITIVE_INFINITY.
	// В каждом из этих случаев, не пропадает в принципе.
	
	// typ == { 1, 2, 3, 4 } { 'bullets', 'shells', 'energys', 'bombs' } size = {0 - minimal , 1 - medium, 2 - large}
		static function spawn_pickup (x0:Number, y0:Number, typ, size, fadetime){
			if (typ == 0)typ = -1; if (size == undefined)size = 0; if (fadetime == undefined)fadetime = 120 * 10; var what_to_export = 'none';
			
			if (typ >= 1 && typ <= 4){ /*это патроны*/ if (size == 2) what_to_export = "pickup_large_ammo"; if (size == 1) for (var n=0;n<3; n++)spawn_pickup (x0, y0, typ, 0, fadetime); if (size == 0) what_to_export = "pickup_ammo";  }
			if (typ == -1){ /*здоровье*/ what_to_export = 'pickup_healing';}
			
			export_block.export_object (_root.item_layer, what_to_export, fadetime, x0 , y0, (random(200/100)-.5)*3,-random(300)/100-2, .2,1.8,1, false,.3);
			_root.last_exported.isPickUp = true; _root.last_exported.pickUpType = typ; _root.last_exported.siz = size;
		}
}