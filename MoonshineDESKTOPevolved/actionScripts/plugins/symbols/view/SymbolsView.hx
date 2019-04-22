/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugins.symbols.view
 *  Class:      SymbolsView
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineDESKTOPevolved/src/actionScripts/plugins/symbols/view/SymbolsView.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:13:58 MSK
 */

package actionScripts.plugins.symbols.view;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.SymbolInformation;
import spark.components.Alert;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.events.AddTabEvent;
import actionScripts.locator.IDEModel;
import actionScripts.interfaces.ILanguageServerBridge;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.Position;
import actionScripts.ui.editor.text.TextEditorModel;
import actionScripts.ui.editor.text.TextEditor;
import actionScripts.events.OpenLocationEvent;
import actionScripts.valueObjects.DocumentSymbol;
import actionScripts.valueObjects.Location;
import actionScripts.valueObjects.Range;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.skins.ResizableTitleWindowSkin;
import flash.accessibility.*;
import flash.data.*;
import flash.debugger.*;
import flash.desktop.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.*;
import flash.filesystem.*;
import flash.geom.*;
import flash.html.*;
import flash.html.script.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import mx.binding.*;
import mx.binding.IBindingClient;
import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;
import mx.events.FlexEvent;
import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.Label;
import spark.components.List;
import spark.components.TextInput;
import spark.components.VGroup;
import spark.events.TextOperationEvent;

class SymbolsView extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lstSymbols:spark.components.List;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var symbols:mx.collections.ArrayCollection;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txt_query:spark.components.TextInput;

	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SymbolsView_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugins_symbols_view_SymbolsViewWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SymbolsView, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 600;
		this.height = 500;
		this.minWidth = 300;
		this.minHeight = 300;
		this.controlBarContent = [_SymbolsView_Button1_c()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SymbolsView_Array2_c);
		_SymbolsView_ArrayCollection1_i();

		// events
		this.addEventListener('addedToStage', ___SymbolsView_ResizableTitleWindow1_addedToStage);

		for (i in 0...bindings.length) {
			AS3.as(bindings[i], Binding).execute();
		}

	}

	/**
	 * @private
	 **/
	private var __moduleFactoryInitialized:Bool = false;

	/**
	 * @private
	 * Override the module factory so we can defer setting style declarations
	 * until a module factory is set. Without the correct module factory set
	 * the style declaration will end up in the wrong style manager.
	 **/
	override private function set_moduleFactory(factory:IFlexModuleFactory):IFlexModuleFactory {
		super.moduleFactory = factory;

		if (__moduleFactoryInitialized) {
			return factory;
		}

		__moduleFactoryInitialized = true;

		// our style settings
		//  initialize component styles
		if (!AS3.as(this.styleDeclaration, Bool)) {
			this.styleDeclaration = new CSSStyleDeclaration(null, styleManager);
		}

		this.styleDeclaration.defaultFactory = function():Void {
					this.skinClass = components.skins.ResizableTitleWindowSkin;
				};
		return factory;
	}

	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	public static inline var EVENT_QUERY_CHANGE:String = 'queryChange';

	private var _query:String = '';

	public var query(get, never):String;
	private function get_query():String {
		return this._query;
	}

	private function updateQuery():Void {
		this._query = Std.string(this.txt_query.text);
		this.dispatchEvent(new Event(EVENT_QUERY_CHANGE));
	}

	private function addedToStageHandler(event:Event):Void {
		this.symbols.filterFunction = null;
		this.symbols.refresh();
		//remove after clearing the filter or items might not be removed
		this.symbols.removeAll();
		if (this.txt_query != null) {
			//it may not be created yet
			this.txt_query.text = '';
			this.txt_query.setFocus();
		}
	}

	private function onListDoubleClicked(event:MouseEvent):Void {
		if (!AS3.as(lstSymbols.selectedItem, Bool)) {
			Alert.show('Please select an item to open.');
			return;
		}

		var selectedItem:Dynamic = lstSymbols.selectedItem;
		if (Std.is(selectedItem, SymbolInformation)) {
			var symbolInfo:SymbolInformation = AS3.as(selectedItem, SymbolInformation);
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, symbolInfo.location)
			);
		} else if (Std.is(selectedItem, DocumentSymbol)) {
			var documentSymbol:DocumentSymbol = AS3.as(selectedItem, DocumentSymbol);
			var activeEditor:BasicTextEditor = AS3.as(IDEModel.getInstance().activeEditor, BasicTextEditor);
			var uri:String = Std.string(activeEditor.currentFile.fileBridge.url);
			var range:Range = documentSymbol.range;
			var location:Location = new Location(uri, range);
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location)
			);
		}

		super.closeThis();
	}

	//  supporting function definitions for properties, events, styles, effects
	private function _SymbolsView_ArrayCollection1_i():mx.collections.ArrayCollection {
		var temp:mx.collections.ArrayCollection = new mx.collections.ArrayCollection();
		temp.initialized(this, 'symbols');
		symbols = temp;
		mx.binding.BindingManager.executeBindings(this, 'symbols', symbols);
		return temp;
	}

	private function _SymbolsView_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Open';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SymbolsView_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SymbolsView_Button1_click(event:flash.events.MouseEvent):Void {
		onListDoubleClicked(null);
	}

	private function _SymbolsView_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_SymbolsView_VGroup1_c()];
		return cast temp;
	}

	private function _SymbolsView_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 10;
		temp.paddingLeft = 12;
		temp.paddingBottom = 3;
		temp.paddingTop = 9;
		temp.paddingRight = 13;
		temp.horizontalAlign = 'center';
		temp.mxmlContent = [_SymbolsView_VGroup2_c(), _SymbolsView_VGroup3_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SymbolsView_VGroup2_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_SymbolsView_Label1_c(), _SymbolsView_TextInput1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SymbolsView_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Search for symbol by name:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SymbolsView_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.maxChars = 129;
		temp.addEventListener('change', __txt_query_change);
		temp.addEventListener('creationComplete', __txt_query_creationComplete);
		temp.id = 'txt_query';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txt_query = temp;
		mx.binding.BindingManager.executeBindings(this, 'txt_query', txt_query);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __txt_query_change(event:spark.events.TextOperationEvent):Void {
		updateQuery();
	}

	/**
	 * @private
	 **/
	public function __txt_query_creationComplete(event:mx.events.FlexEvent):Void {
		txt_query.setFocus();
	}

	private function _SymbolsView_VGroup3_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.mxmlContent = [_SymbolsView_Label2_c(), _SymbolsView_List1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SymbolsView_Label2_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Matching items:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SymbolsView_List1_i():spark.components.List {
		var temp:spark.components.List = new spark.components.List();
		temp.styleName = 'multiLineList';
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.labelField = 'name';
		temp.doubleClickEnabled = true;
		temp.addEventListener('doubleClick', __lstSymbols_doubleClick);
		temp.id = 'lstSymbols';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lstSymbols = temp;
		mx.binding.BindingManager.executeBindings(this, 'lstSymbols', lstSymbols);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __lstSymbols_doubleClick(event:flash.events.MouseEvent):Void {
		onListDoubleClicked(event);
	}

	/**
	 * @private
	 **/
	public function ___SymbolsView_ResizableTitleWindow1_addedToStage(event:flash.events.Event):Void {
		addedToStageHandler(event);
	}

	//  binding mgmt
	private function _SymbolsView_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'lstSymbols.dataProvider', 'symbols');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SymbolsView)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindings:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _watchers:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsByDestination:Dynamic = {};
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsBeginWithWord:Dynamic = {};

}