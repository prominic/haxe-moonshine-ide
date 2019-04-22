/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      NativeExtensionMessagePopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/NativeExtensionMessagePopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.popup;

import actionScripts.valueObjects.ConstantsCoreVO;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
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
import flashx.textLayout.elements.BreakElement;
import flashx.textLayout.elements.ListElement;
import flashx.textLayout.elements.ListItemElement;
import flashx.textLayout.elements.TextFlow;
import mx.binding.*;
import mx.binding.IBindingClient;
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
import spark.components.RichEditableText;
import spark.components.Scroller;

//  begin class def
class NativeExtensionMessagePopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _NativeExtensionMessagePopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_NativeExtensionMessagePopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(NativeExtensionMessagePopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 475;
		this.height = 280;
		this.minWidth = 400;
		this.minHeight = 200;
		this.controlBarContent = [_NativeExtensionMessagePopup_Button1_c()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_NativeExtensionMessagePopup_Array2_c);

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
	//  <Script>, line 28 - 31

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _NativeExtensionMessagePopup_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'OK';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___NativeExtensionMessagePopup_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___NativeExtensionMessagePopup_Button1_click(event:flash.events.MouseEvent):Void {
		closeThis();
	}

	private function _NativeExtensionMessagePopup_Array2_c():Array<Dynamic> {
		var temp:Array<Scroller> = [_NativeExtensionMessagePopup_Scroller1_c()];
		return cast temp;
	}

	private function _NativeExtensionMessagePopup_Scroller1_c():spark.components.Scroller {
		var temp:spark.components.Scroller = new spark.components.Scroller();
		temp.percentWidth = 90.0;
		temp.percentHeight = 90.0;
		temp.horizontalCenter = 0;
		temp.verticalCenter = 0;
		temp.viewport = _NativeExtensionMessagePopup_RichEditableText1_c();
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NativeExtensionMessagePopup_RichEditableText1_c():spark.components.RichEditableText {
		var temp:spark.components.RichEditableText = new spark.components.RichEditableText();
		temp.editable = false;
		temp.focusEnabled = false;
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.textFlow = _NativeExtensionMessagePopup_TextFlow1_c();
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NativeExtensionMessagePopup_TextFlow1_c():flashx.textLayout.elements.TextFlow {
		var temp:flashx.textLayout.elements.TextFlow = new flashx.textLayout.elements.TextFlow();
		temp.mxmlChildren = ['To run the simulator with native extension support, Moonshine needs to expand the ANE files to user\'s file system. Here are the steps:', _NativeExtensionMessagePopup_BreakElement1_c(), _NativeExtensionMessagePopup_BreakElement2_c(), _NativeExtensionMessagePopup_ListElement1_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_BreakElement1_c():flashx.textLayout.elements.BreakElement {
		var temp:flashx.textLayout.elements.BreakElement = new flashx.textLayout.elements.BreakElement();
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_BreakElement2_c():flashx.textLayout.elements.BreakElement {
		var temp:flashx.textLayout.elements.BreakElement = new flashx.textLayout.elements.BreakElement();
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_ListElement1_c():flashx.textLayout.elements.ListElement {
		var temp:flashx.textLayout.elements.ListElement = new flashx.textLayout.elements.ListElement();
		temp.paddingTop = 0;
		temp.mxmlChildren = [_NativeExtensionMessagePopup_ListItemElement1_c(), _NativeExtensionMessagePopup_ListItemElement2_c(), _NativeExtensionMessagePopup_ListItemElement3_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_ListItemElement1_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['The user defines a folder where native extensions are exists in the project configuration'];
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_ListItemElement2_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['When building and running the project, Moonshine expands all native extension files in the configured directories. The files are expanded in the same directory where they were found.'];
		temp.initialized(this, null);
		return temp;
	}

	private function _NativeExtensionMessagePopup_ListItemElement3_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Moonshine will execute the application using the expanded native extension files'];
		temp.initialized(this, null);
		return temp;
	}

	//  binding mgmt
	private function _NativeExtensionMessagePopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = 'How ' + (ConstantsCoreVO.MOONSHINE_IDE_LABEL) + ' supports native extension';
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'this.title');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(NativeExtensionMessagePopup)._watcherSetupUtil = watcherSetupUtil;
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