/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      ModifiedFileListPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/ModifiedFileListPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.popup;

import mx.collections.ArrayCollection;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.ui.menu.MenuPlugin;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.popup.ModifiedFileListPopupInnerClass0;
import components.skins.ResizableTitleWindowSkin;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.MouseEvent;
import flash.external.*;
import flash.geom.*;
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
import mx.collections.IList;
import mx.controls.Spacer;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;
import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.Label;
import spark.components.List;
import spark.components.VGroup;

//  begin class def
class ModifiedFileListPopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lstResources:spark.components.List;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ModifiedFileListPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_ModifiedFileListPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ModifiedFileListPopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 600;
		this.minWidth = 400;
		this.height = 400;
		this.minHeight = 200;
		this.title = 'Save Resources';
		this.controlBarContent = [_ModifiedFileListPopup_Button1_c(), _ModifiedFileListPopup_Button2_c(), _ModifiedFileListPopup_Spacer1_c(), _ModifiedFileListPopup_Button3_c()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_ModifiedFileListPopup_Array2_c);

		// events

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
					this.backgroundColor = 16119285;
					this.skinClass = components.skins.ResizableTitleWindowSkin;
				};
		return factory;
	}

	//  initialize()
	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	//  scripts
	//  <Script>, line 34 - 83

	@:meta(Bindable())public var collection:ArrayCollection;

	override private function closeByCrossSign(event:Event):Void {
		doBeforeExit();
		super.closeByCrossSign(event);
	}

	override private function onResizeKeyDownEvent(event:KeyboardEvent):Void {
		doBeforeExit();
		super.onResizeKeyDownEvent(event);
	}

	private function doBeforeExit():Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));
	}

	private function onSelectAllItems(value:Bool):Void {
		for (i in collection) {
			Reflect.setField(i, 'isSelected', value);
		}

		collection.refresh();
	}

	private function onSaveRequest(event:MouseEvent):Void {
		for (i in collection) {
			if (AS3.as(Reflect.field(i, 'isSelected'), Bool)) {
				Reflect.field(i, 'file').save();
			}
		}

		// close when done
		closeThis();
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _ModifiedFileListPopup_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Select All';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___ModifiedFileListPopup_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___ModifiedFileListPopup_Button1_click(event:flash.events.MouseEvent):Void {
		onSelectAllItems(true);
	}

	private function _ModifiedFileListPopup_Button2_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Deselect All';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___ModifiedFileListPopup_Button2_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___ModifiedFileListPopup_Button2_click(event:flash.events.MouseEvent):Void {
		onSelectAllItems(false);
	}

	private function _ModifiedFileListPopup_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ModifiedFileListPopup_Button3_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Save';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___ModifiedFileListPopup_Button3_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___ModifiedFileListPopup_Button3_click(event:flash.events.MouseEvent):Void {
		onSaveRequest(event);
	}

	private function _ModifiedFileListPopup_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_ModifiedFileListPopup_VGroup1_c()];
		return cast temp;
	}

	private function _ModifiedFileListPopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 10;
		temp.paddingLeft = 12;
		temp.paddingBottom = 3;
		temp.paddingTop = 9;
		temp.paddingRight = 13;
		temp.mxmlContent = [_ModifiedFileListPopup_Label1_c(), _ModifiedFileListPopup_List1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ModifiedFileListPopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Select the resources to save:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _ModifiedFileListPopup_List1_i():spark.components.List {
		var temp:spark.components.List = new spark.components.List();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.styleName = 'multiLineList';
		temp.itemRenderer = _ModifiedFileListPopup_ClassFactory1_c();
		temp.id = 'lstResources';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lstResources = temp;
		mx.binding.BindingManager.executeBindings(this, 'lstResources', lstResources);
		return temp;
	}

	private function _ModifiedFileListPopup_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = components.popup.ModifiedFileListPopupInnerClass0;
		temp.properties = {
					'outerDocument': this
				};
		return temp;
	}

	//  binding mgmt
	private function _ModifiedFileListPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'lstResources.dataProvider', 'collection');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ModifiedFileListPopup)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	//  end embed carrier vars

	//  binding management vars
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

//  end package def