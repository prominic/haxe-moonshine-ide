/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SDKDefinePopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/SDKDefinePopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.popup;

import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.utils.SDKUtils;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.SDKReferenceVO;

import actionScripts.plugin.findreplace.view.PromptTextInput;
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
import mx.graphics.SolidColor;
import mx.styles.*;
import spark.components.Button;
import spark.components.Form;
import spark.components.FormItem;
import spark.components.Group;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.VGroup;
import spark.layouts.FormLayout;
import spark.primitives.Rect;

//  begin class def
class SDKDefinePopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _SDKDefinePopup_FormLayout1:spark.layouts.FormLayout;

	/**
	 * @private
	 **/
	public var _SDKDefinePopup_Group1:spark.components.Group;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnCreate:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtLabel:actionScripts.plugin.findreplace.view.PromptTextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtPath:actionScripts.plugin.findreplace.view.PromptTextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SDKDefinePopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SDKDefinePopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SDKDefinePopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 500;
		this.autoLayout = true;
		this.title = 'Define a SDK Path';
		this.controlBarContent = [_SDKDefinePopup_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SDKDefinePopup_Array2_c);

		// events
		this.addEventListener('close', ___SDKDefinePopup_ResizableTitleWindow1_close);
		this.addEventListener('creationComplete', ___SDKDefinePopup_ResizableTitleWindow1_creationComplete);

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
	//  <Script>, line 31 - 118

	public var editedSDKPath:SDKReferenceVO;
	private var file:FileLocation;

	/**
	 * On this close button clicked
	 */
	private function onCloseWindow(event:CloseEvent):Void {
		editedSDKPath = null;
		file = null;

		PopUpManager.removePopUp(this);
	}

	private function onBrowserPath(event:MouseEvent):Void {
		var sdkPath:String;
		if (editedSDKPath != null) {
			sdkPath = editedSDKPath.path;
		}

		var model:IDEModel = IDEModel.getInstance();
		model.fileCore.browseForDirectory('Select directory', openFile, openFileCancelled, sdkPath);
	}

	private function openFile(dir:Dynamic):Void {
		//openFileCancelled(event);
		btnCreate.enabled = false;
		file = new FileLocation(AS3.string(Reflect.field(dir, 'nativePath')));

		var sdkDescription:SDKReferenceVO = SDKUtils.getSDKReference(file);
		if (sdkDescription != null) {
			txtPath.text = sdkDescription.path;
			txtLabel.text = sdkDescription.name;
			btnCreate.enabled = true;
		} else {
			txtLabel.text = 'Not a valid SDK directory.';
		}
	}

	private function openFileCancelled():Void {
		file = null;
	}

	private function onCreate(event:MouseEvent):Void {
		if (editedSDKPath != null) {
			editedSDKPath.path = txtPath.text;
			editedSDKPath.name = txtLabel.text;
		}

		dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, (editedSDKPath != null) ? editedSDKPath : {
					'label': txtLabel.text,
					'path': txtPath.text
				}));
		onCloseWindow(null);
	}

	private function onCreationCompletes(event:FlexEvent):Void {
		if (editedSDKPath != null) {
			txtLabel.text = editedSDKPath.name;
			txtPath.text = editedSDKPath.path;
			btnCreate.label = 'Update';
			btnCreate.enabled = true;
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _SDKDefinePopup_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Create';
		temp.enabled = false;
		temp.styleName = 'darkButton';
		temp.addEventListener('click', __btnCreate_click);
		temp.id = 'btnCreate';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnCreate = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnCreate', btnCreate);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnCreate_click(event:flash.events.MouseEvent):Void {
		onCreate(event);
	}

	private function _SDKDefinePopup_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_SDKDefinePopup_VGroup1_c()];
		return cast temp;
	}

	private function _SDKDefinePopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 0;
		temp.mxmlContent = [_SDKDefinePopup_Form1_c(), _SDKDefinePopup_Group1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKDefinePopup_Form1_c():spark.components.Form {
		var temp:spark.components.Form = new spark.components.Form();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.layout = _SDKDefinePopup_FormLayout1_i();
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SDKDefinePopup_Array4_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKDefinePopup_FormLayout1_i():spark.layouts.FormLayout {
		var temp:spark.layouts.FormLayout = new spark.layouts.FormLayout();
		temp.gap = 0;
		temp.paddingLeft = 12;
		temp.paddingTop = 9;
		temp.paddingRight = 16;
		_SDKDefinePopup_FormLayout1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SDKDefinePopup_FormLayout1', _SDKDefinePopup_FormLayout1);
		return temp;
	}

	private function _SDKDefinePopup_Array4_c():Array<Dynamic> {
		var temp:Array<FormItem> = [_SDKDefinePopup_FormItem1_c(), _SDKDefinePopup_FormItem2_c()];
		return cast temp;
	}

	private function _SDKDefinePopup_FormItem1_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Label';
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SDKDefinePopup_Array5_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKDefinePopup_Array5_c():Array<Dynamic> {
		var temp:Array<PromptTextInput> = [_SDKDefinePopup_PromptTextInput1_i()];
		return cast temp;
	}

	private function _SDKDefinePopup_PromptTextInput1_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.percentWidth = 100.0;
		temp.editable = false;
		temp.styleName = 'textInput';
		temp.id = 'txtLabel';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtLabel = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtLabel', txtLabel);
		return temp;
	}

	private function _SDKDefinePopup_FormItem2_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Path';
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SDKDefinePopup_Array6_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKDefinePopup_Array6_c():Array<Dynamic> {
		var temp:Array<HGroup> = [_SDKDefinePopup_HGroup1_c()];
		return cast temp;
	}

	private function _SDKDefinePopup_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_SDKDefinePopup_PromptTextInput2_i(), _SDKDefinePopup_Button2_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKDefinePopup_PromptTextInput2_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.percentWidth = 100.0;
		temp.editable = false;
		temp.styleName = 'textInput';
		temp.id = 'txtPath';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtPath = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtPath', txtPath);
		return temp;
	}

	private function _SDKDefinePopup_Button2_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Browse';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', ___SDKDefinePopup_Button2_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKDefinePopup_Button2_click(event:flash.events.MouseEvent):Void {
		onBrowserPath(event);
	}

	private function _SDKDefinePopup_Group1_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.percentWidth = 100.0;
		temp.height = 50;
		temp.mxmlContent = [_SDKDefinePopup_Rect1_c(), _SDKDefinePopup_Label1_c()];
		temp.id = '_SDKDefinePopup_Group1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SDKDefinePopup_Group1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SDKDefinePopup_Group1', _SDKDefinePopup_Group1);
		return temp;
	}

	private function _SDKDefinePopup_Rect1_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.fill = _SDKDefinePopup_SolidColor1_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _SDKDefinePopup_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 16119285;
		return temp;
	}

	private function _SDKDefinePopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Because of restrictions with the Apple Sandbox, you will only be able to use  external SDKs if they are installed within your Downloads directory.';
		temp.horizontalCenter = 0;
		temp.verticalCenter = 0;
		temp.maxDisplayedLines = 2;
		temp.percentWidth = 90.0;
		temp.setStyle('textAlign', 'center');
		temp.setStyle('fontSize', 11);
		temp.setStyle('color', 3355443);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKDefinePopup_ResizableTitleWindow1_close(event:mx.events.CloseEvent):Void {
		onCloseWindow(event);
	}

	/**
	 * @private
	 **/
	public function ___SDKDefinePopup_ResizableTitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreationCompletes(event);
	}

	//  binding mgmt
	private function _SDKDefinePopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Float {
					return ((AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) ? 10 : 14);
				},
				null,
				'_SDKDefinePopup_FormLayout1.paddingBottom');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(ConstantsCoreVO.IS_MACOS, Bool));
				},
				null,
				'_SDKDefinePopup_Group1.includeInLayout');

		result[2] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(ConstantsCoreVO.IS_MACOS, Bool));
				},
				null,
				'_SDKDefinePopup_Group1.visible');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SDKDefinePopup)._watcherSetupUtil = watcherSetupUtil;
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