/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      DeviceDefinePopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/DeviceDefinePopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.popup;

import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.validators.Validator;
import actionScripts.events.GeneralEvent;
import actionScripts.valueObjects.MobileDeviceVO;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.IEventDispatcher;
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
import mx.collections.ArrayList;
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
import mx.validators.StringValidator;
import spark.components.BorderContainer;
import spark.components.Button;
import spark.components.ComboBox;
import spark.components.Form;
import spark.components.FormItem;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.TitleWindow;
import spark.layouts.FormLayout;
import spark.layouts.VerticalLayout;

//  begin class def
class DeviceDefinePopup extends spark.components.TitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnCreate:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var cmbType:spark.components.ComboBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hValidator:mx.validators.StringValidator;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var nValidator:mx.validators.StringValidator;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtDPI:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtFHeight:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtFWidth:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtLabel:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtNHeight:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtNWidth:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var wValidator:mx.validators.StringValidator;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _DeviceDefinePopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_DeviceDefinePopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(DeviceDefinePopup, propertyName);
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
		this.title = 'Define a Device';
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array1_c);
		_DeviceDefinePopup_StringValidator3_i();
		_DeviceDefinePopup_StringValidator1_i();
		_DeviceDefinePopup_StringValidator2_i();

		// events
		this.addEventListener('close', ___DeviceDefinePopup_TitleWindow1_close);
		this.addEventListener('creationComplete', ___DeviceDefinePopup_TitleWindow1_creationComplete);

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
	//  <Script>, line 29 - 94

	public var editedDevice:MobileDeviceVO;

	/**
	 * On this close button clicked
	 */
	private function onCloseWindow(event:CloseEvent):Void {
		PopUpManager.removePopUp(this);
	}

	private function onCreate(event:MouseEvent):Void {
		var tmpArr:Array<Dynamic> = new Array<Dynamic>();
		if (Validator.validateAll(tmpArr).length == 0) {
			if (editedDevice == null) {
				editedDevice = new MobileDeviceVO(null);
			}

			editedDevice.name = Std.string(txtLabel.text);
			editedDevice.type = ((cmbType.selectedIndex == 0)) ? MobileDeviceVO.AND : MobileDeviceVO.IOS;
			editedDevice.dpi = Std.string(txtDPI.text);

			var normalSize:String = txtNWidth.text + 'x' + txtNHeight.text;
			normalSize += ':' + (((StringTools.trim(txtFWidth.text).length != 0 && StringTools.trim(txtFHeight.text).length != 0)) ? txtFWidth.text + 'x' + txtFHeight.text : normalSize);
			editedDevice.key = normalSize;

			dispatchEvent(new GeneralEvent(GeneralEvent.DONE, editedDevice));
			onCloseWindow(null);
		}
	}

	private function onCreationCompletes(event:FlexEvent):Void {
		if (editedDevice != null) {
			var splitSize:Array<String> = editedDevice.key.split(':');

			txtNWidth.text = splitSize[0].split('x')[0];
			txtNHeight.text = splitSize[0].split('x')[1];
			txtFWidth.text = splitSize[1].split('x')[0];
			txtFHeight.text = splitSize[1].split('x')[1];

			txtLabel.text = editedDevice.name;
			cmbType.selectedIndex = ((editedDevice.type == MobileDeviceVO.AND)) ? 0 : 1;
			txtDPI.text = editedDevice.dpi;
			btnCreate.label = 'Update';
			btnCreate.enabled = true;
		}
	}

	private function onTypesCompletes(event:FlexEvent):Void {
		cmbType.textInput.editable = cmbType.textInput.editable = false;
		cmbType.selectedIndex = 0;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _DeviceDefinePopup_StringValidator3_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.triggerEvent = 'click';
		temp.initialized(this, 'hValidator');
		hValidator = temp;
		mx.binding.BindingManager.executeBindings(this, 'hValidator', hValidator);
		return temp;
	}

	private function _DeviceDefinePopup_StringValidator1_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.triggerEvent = 'click';
		temp.initialized(this, 'nValidator');
		nValidator = temp;
		mx.binding.BindingManager.executeBindings(this, 'nValidator', nValidator);
		return temp;
	}

	private function _DeviceDefinePopup_StringValidator2_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.triggerEvent = 'click';
		temp.initialized(this, 'wValidator');
		wValidator = temp;
		mx.binding.BindingManager.executeBindings(this, 'wValidator', wValidator);
		return temp;
	}

	private function _DeviceDefinePopup_Array1_c():Array<Dynamic> {
		var temp:Array<BorderContainer> = [_DeviceDefinePopup_BorderContainer1_c()];
		return cast temp;
	}

	private function _DeviceDefinePopup_BorderContainer1_c():spark.components.BorderContainer {
		var temp:spark.components.BorderContainer = new spark.components.BorderContainer();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.layout = _DeviceDefinePopup_VerticalLayout1_c();
		temp.backgroundFill = _DeviceDefinePopup_SolidColor1_c();
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array2_c);
		temp.setStyle('borderVisible', false);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_VerticalLayout1_c():spark.layouts.VerticalLayout {
		var temp:spark.layouts.VerticalLayout = new spark.layouts.VerticalLayout();
		return temp;
	}

	private function _DeviceDefinePopup_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 14737632;
		return temp;
	}

	private function _DeviceDefinePopup_Array2_c():Array<Dynamic> {
		var temp:Array<Form> = [_DeviceDefinePopup_Form1_c()];
		return cast temp;
	}

	private function _DeviceDefinePopup_Form1_c():spark.components.Form {
		var temp:spark.components.Form = new spark.components.Form();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.layout = _DeviceDefinePopup_FormLayout1_c();
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array3_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_FormLayout1_c():spark.layouts.FormLayout {
		var temp:spark.layouts.FormLayout = new spark.layouts.FormLayout();
		temp.gap = -12;
		return temp;
	}

	private function _DeviceDefinePopup_Array3_c():Array<Dynamic> {
		var temp:Array<FormItem> = [_DeviceDefinePopup_FormItem1_c(), _DeviceDefinePopup_FormItem2_c(), _DeviceDefinePopup_FormItem3_c(), _DeviceDefinePopup_FormItem4_c(), _DeviceDefinePopup_FormItem5_c(), _DeviceDefinePopup_FormItem6_c()];
		return cast temp;
	}

	private function _DeviceDefinePopup_FormItem1_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Name';
		temp.required = true;
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array4_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array4_c():Array<Dynamic> {
		var temp:Array<TextInput> = [_DeviceDefinePopup_TextInput1_i()];
		return cast temp;
	}

	private function _DeviceDefinePopup_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.id = 'txtLabel';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtLabel = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtLabel', txtLabel);
		return temp;
	}

	private function _DeviceDefinePopup_FormItem2_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Type';
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array5_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array5_c():Array<Dynamic> {
		var temp:Array<ComboBox> = [_DeviceDefinePopup_ComboBox1_i()];
		return cast temp;
	}

	private function _DeviceDefinePopup_ComboBox1_i():spark.components.ComboBox {
		var temp:spark.components.ComboBox = new spark.components.ComboBox();
		temp.percentWidth = 100.0;
		temp.selectedIndex = 0;
		temp.dataProvider = _DeviceDefinePopup_ArrayList1_c();
		temp.setStyle('alternatingItemColors', [16777215, 16777215]);
		temp.setStyle('selectionColor', 13421772);
		temp.setStyle('rollOverColor', 15658734);
		temp.addEventListener('creationComplete', __cmbType_creationComplete);
		temp.id = 'cmbType';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		cmbType = temp;
		mx.binding.BindingManager.executeBindings(this, 'cmbType', cmbType);
		return temp;
	}

	private function _DeviceDefinePopup_ArrayList1_c():mx.collections.ArrayList {
		var temp:mx.collections.ArrayList = new mx.collections.ArrayList();
		temp.source = ['Android', 'iOS'];
		return temp;
	}

	/**
	 * @private
	 **/
	public function __cmbType_creationComplete(event:mx.events.FlexEvent):Void {
		onTypesCompletes(event);
	}

	private function _DeviceDefinePopup_FormItem3_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Normal width:height';
		temp.required = true;
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array8_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array8_c():Array<Dynamic> {
		var temp:Array<HGroup> = [_DeviceDefinePopup_HGroup1_c()];
		return cast temp;
	}

	private function _DeviceDefinePopup_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_DeviceDefinePopup_TextInput2_i(), _DeviceDefinePopup_Label1_c(), _DeviceDefinePopup_TextInput3_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_TextInput2_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.restrict = '0-9';
		temp.id = 'txtNWidth';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtNWidth = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtNWidth', txtNWidth);
		return temp;
	}

	private function _DeviceDefinePopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = ':';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_TextInput3_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.restrict = '0-9';
		temp.id = 'txtNHeight';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtNHeight = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtNHeight', txtNHeight);
		return temp;
	}

	private function _DeviceDefinePopup_FormItem4_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Fullscreen width:height';
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array10_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array10_c():Array<Dynamic> {
		var temp:Array<HGroup> = [_DeviceDefinePopup_HGroup2_c()];
		return cast temp;
	}

	private function _DeviceDefinePopup_HGroup2_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_DeviceDefinePopup_TextInput4_i(), _DeviceDefinePopup_Label2_c(), _DeviceDefinePopup_TextInput5_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_TextInput4_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.restrict = '0-9';
		temp.id = 'txtFWidth';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtFWidth = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtFWidth', txtFWidth);
		return temp;
	}

	private function _DeviceDefinePopup_Label2_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = ':';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_TextInput5_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.restrict = '0-9';
		temp.id = 'txtFHeight';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtFHeight = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtFHeight', txtFHeight);
		return temp;
	}

	private function _DeviceDefinePopup_FormItem5_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.label = 'Dots Per Inch';
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array12_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array12_c():Array<Dynamic> {
		var temp:Array<TextInput> = [_DeviceDefinePopup_TextInput6_i()];
		return cast temp;
	}

	private function _DeviceDefinePopup_TextInput6_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.text = '72';
		temp.restrict = '0-9';
		temp.id = 'txtDPI';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtDPI = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtDPI', txtDPI);
		return temp;
	}

	private function _DeviceDefinePopup_FormItem6_c():spark.components.FormItem {
		var temp:spark.components.FormItem = new spark.components.FormItem();
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_DeviceDefinePopup_Array13_c);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _DeviceDefinePopup_Array13_c():Array<Dynamic> {
		var temp:Array<Button> = [_DeviceDefinePopup_Button1_i()];
		return cast temp;
	}

	private function _DeviceDefinePopup_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Create';
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

	/**
	 * @private
	 **/
	public function ___DeviceDefinePopup_TitleWindow1_close(event:mx.events.CloseEvent):Void {
		onCloseWindow(event);
	}

	/**
	 * @private
	 **/
	public function ___DeviceDefinePopup_TitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreationCompletes(event);
	}

	//  binding mgmt
	private function _DeviceDefinePopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'nValidator.source', 'txtLabel');

		result[1] = new mx.binding.Binding(this,
				null,
				null,
				'nValidator.trigger', 'btnCreate');

		result[2] = new mx.binding.Binding(this,
				null,
				null,
				'wValidator.source', 'txtNWidth');

		result[3] = new mx.binding.Binding(this,
				null,
				null,
				'wValidator.trigger', 'btnCreate');

		result[4] = new mx.binding.Binding(this,
				null,
				null,
				'hValidator.source', 'txtNHeight');

		result[5] = new mx.binding.Binding(this,
				null,
				null,
				'hValidator.trigger', 'btnCreate');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(DeviceDefinePopup)._watcherSetupUtil = watcherSetupUtil;
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