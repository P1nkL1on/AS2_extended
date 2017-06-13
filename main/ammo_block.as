class ammo_block {
	
	function Load(){
		_root.console_trace( "* Ammo logick block loaded" );
	}
	
	function set_ammo_holder (who:MovieClip, ammo:Array){		// this, new Array(50, 0, 0, Number.POSTIVE_INFINITY);
		who.Ammo = ammo; who.Ammo_max = new Array(200, 60, 100, 40); who.ammo_holder = true;
	}
	
	// typ == { 1, 2, 3, 4 } { 'bullets', 'shells', 'energys', 'bombs' } size = {0 - minimal , 1 - medium, 2 - large}
	function spawn_pickup (x0:Number, y0:Number, typ, size, fadetime){
		if (typ == 0)typ = -1; if (size == undefined)size = 0; if (fadetime == undefined)fadetime = 120 * 10; var what_to_export = 'none';
		
		if (typ >= 1 && typ <= 4){ /*это патроны*/ if (size == 2) what_to_export = "pickup_large_ammo"; if (size == 1) for (var n=0;n<3; n++)spawn_pickup (x0, y0, typ, 0, fadetime); if (size == 0) what_to_export = "pickup_ammo";  }
		if (typ == -1){ /*здоровье*/ what_to_export = 'pickup_healing';}
		
		_root.export_object (_root, what_to_export, fadetime, x0 , y0, (random(200/100)-.5)*3,-random(300)/100-2, .2,1.8,1, false,.3);
		_root.last_exported.isPickUp = true; _root.last_exported.pickUpType = typ; _root.last_exported.siz = size;
	}
	
}