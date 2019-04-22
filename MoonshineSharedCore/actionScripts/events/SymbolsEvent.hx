package actionScripts.events;

import actionScripts.valueObjects.SymbolInformation;
import flash.events.Event;

class SymbolsEvent extends Event {

	public static inline var EVENT_SHOW_SYMBOLS:String = 'newShowSymbols';

	//contains SymbolInformation or DocumentSymbol
	public var symbols:Array<Dynamic>;

	public function new(type:String, symbols:Array<Dynamic>) {
		super(type, false, false);
		this.symbols = symbols;
	}

}