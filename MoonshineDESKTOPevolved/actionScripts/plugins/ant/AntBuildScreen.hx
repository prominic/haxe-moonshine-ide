/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugins.ant
 *  Class:      AntBuildScreen
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineDESKTOPevolved/src/actionScripts/plugins/ant/AntBuildScreen.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:14:00 MSK
 */

package actionScripts.plugins.ant;

import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.validators.Validator;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.settings.renderers.LinkButtonSkin;
import actionScripts.plugin.settings.vo.PluginSetting;
import actionScripts.plugins.ant.events.AntBuildEvent;
import actionScripts.valueObjects.ConstantsCoreVO;
import components.popup.SDKDefinePopup;
import components.popup.SDKSelectorPopup;

import actionScripts.ui.IContentWindow;
import flash.accessibility.*;
import flash.data.*;
import flash.debugger.*;
import flash.desktop.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
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
import mx.containers.Canvas;
import mx.controls.HRule;
import mx.controls.Spacer;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponentDescriptor;
import mx.core.Mx_internal;

import mx.filters.*;
import mx.styles.*;
import mx.validators.StringValidator;
import spark.components.Button;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.VGroup;

class AntBuildScreen extends mx.containers.Canvas implements actionScripts.ui.IContentWindow implements mx.binding.IBindingClient {

	/**
	 * @private
	 **/
	public var _AntBuildScreen_Button2:spark.components.Button;

	/**
	 * @private
	 **/
	public var _AntBuildScreen_Button4:spark.components.Button;

	/**
	 * @private
	 **/
	public var _AntBuildScreen_Button6:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var antConfigureV:mx.validators.StringValidator;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var antHomeV:mx.validators.StringValidator;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnAntBuild:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnAntClear:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnAntConfigure:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnFlexSDK:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var flexSDKV:mx.validators.StringValidator;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hbConfigurepath:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hgAntBuild:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hgAntConfigure:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hgFlexSDK:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lblAntFilePath:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtAntConfigure:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtAntHome:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtFlexSdk:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var vgContainer:spark.components.VGroup;

	private var _documentDescriptor_:mx.core.UIComponentDescriptor;

	/**
	 * @private
	 **/
	public function new() {
		this._documentDescriptor_ =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.Canvas,
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': spark.components.VGroup,
								'id': 'vgContainer',
								'propertiesFactory': function():Dynamic {
									return {
										'percentHeight': 100.0,
										'percentWidth': 100.0,
										'paddingLeft': 15,
										'paddingTop': 15,
										'paddingRight': 15,
										'paddingBottom': 15,
										'horizontalAlign': 'center',
										'mxmlContent': [this._AntBuildScreen_HRule1_c(), this._AntBuildScreen_VGroup2_i(), this._AntBuildScreen_VGroup3_i(), this._AntBuildScreen_VGroup4_i(), this._AntBuildScreen_VGroup5_i(), this._AntBuildScreen_Spacer8_c(), this._AntBuildScreen_HGroup4_c()]
									};
								}
							})
				]
						};
					}
				});
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _AntBuildScreen_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugins_ant_AntBuildScreenWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(AntBuildScreen, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.percentHeight = 100.0;
		this.label = 'Ant Build';
		this.horizontalCenter = 0;
		this.verticalCenter = 0;
		_AntBuildScreen_StringValidator3_i();
		_AntBuildScreen_StringValidator2_i();
		_AntBuildScreen_StringValidator1_i();

		// events
		this.addEventListener('creationComplete', ___AntBuildScreen_Canvas1_creationComplete);

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
				};
		return factory;
	}

	/**
	 * @private
	 **/
	override public function initialize():Void {
		// mx_internal::setDocumentDescriptor(_documentDescriptor_);

		super.initialize();
	}

	@:meta(Bindable())
	private var _isFlexSDK:Bool = false;
	@:meta(Bindable())
	private var _isAntPath:Bool = false;
	@:meta(Bindable())
	private var _isAntConfigurPath:Bool = false;
	@:meta(Bindable())
	private var description:String = '\tAnt build process needs 3 files for build Flex application,i.e build.xml file,Apache Flex SDK and Ant Home. Pelase set these 3 files first before starting Ant Build.\n\n\tAnt Home : Set Ant Home path for Ant Build through browse Button.If you already set Ant Home path in setting then no need to set Ant Home path in this window.\n\n\tFlex SDK : Select Apache Flex SDK through Flex SDK Browse Button.If you already set Flex SDK in setting then no need to set Flex SDK in this window.\n\n\tAnt Configure : Set build.xml file for Ant build through Browse Button.You can also set Ant configure file from Menu also Ant -> Build Configure.If you already select build.xml file from Menu then no need to select file from this window.\n\n\tAnt Build : Start Ant Build if all paths are configured.';

	private var model:IDEModel = IDEModel.getInstance();
	private var file:FileLocation;
	private var sdkPopup:SDKSelectorPopup;
	private var sdkPathPopup:SDKDefinePopup;
	private var _customSDKAvailable:Bool = false;
	private var buildSDK:FileLocation;
	private var antHome:FileLocation;

	public var longLabel(get, never):String;
	private function get_longLabel():String {
		return 'But what is it good for?';
	}

	public function isChanged():Bool {
		return false;
	}

	public function isEmpty():Bool {
		return false;
	}

	public function save():Void {}

	public var customSDKAvailable(get, set):Bool;
	private function set_customSDKAvailable(sdk:Bool):Bool {
		_customSDKAvailable = sdk;
		return sdk;
	}

	private function get_customSDKAvailable():Bool {
		return _customSDKAvailable;
	}

	public function refreshValue():Void {
		if (!customSDKAvailable) {
			_isFlexSDK = true;
		} else {
			_isFlexSDK = false;
		}
		if (AS3.as(model.antHomePath, Bool)) {
			_isAntPath = true;
		} else {
			_isAntPath = false;
		}
		if (AS3.as(model.antScriptFile, Bool)) {
			_isAntConfigurPath = true;
			lblAntFilePath.text = model.antScriptFile.fileBridge.nativePath;
		} else {
			_isAntConfigurPath = false;
		}
	}

	private function onAntBuildScreenCreationComplete(event:FlexEvent):Void {
		// TODO Auto-generated method stub
		if (!customSDKAvailable) {
			_isFlexSDK = true;
		} else {
			_isFlexSDK = false;
		}
		if (AS3.as(model.antHomePath, Bool)) {
			_isAntPath = true;
		} else {
			_isAntPath = false;
		}
		if (AS3.as(model.antScriptFile, Bool)) {
			_isAntConfigurPath = true;
			lblAntFilePath.text = model.antScriptFile.fileBridge.nativePath;
		} else {
			_isAntConfigurPath = false;
		}

		var ps:PluginSetting = new PluginSetting('Ant Build', ConstantsCoreVO.MOONSHINE_IDE_LABEL + ' Project Team', 'Build Flex application through Ant script', false);
		vgContainer.addElementAt(ps.renderer, 0);

		/*   ps = new PluginSetting("Ant Build Description", "", description, false);
		  groupContainer.addElementAt(ps.renderer, 0); */
	}

	private function btnBrowseFlexSDK_clickHandler(event:MouseEvent):Void {
		// TODO Auto-generated method stub
		if (sdkPathPopup == null) {
			sdkPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SDKSelectorPopup, false), SDKSelectorPopup);
			sdkPopup.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
			sdkPopup.addEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
			PopUpManager.centerPopUp(sdkPopup);
		} else {
			PopUpManager.bringToFront(sdkPathPopup);
		}
	}

	private function onFlexSDKUpdated(event:ProjectEvent):Void {
		// in case user deleted the entry
		txtFlexSdk.text = event.anObject.path;
		onSDKPopupClosed(null);
	}

	private function onSDKPopupClosed(event:CloseEvent):Void {
		sdkPopup.removeEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
		sdkPopup.removeEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
		sdkPopup = null;
	}

	private function btnBrowseAnt_clickHandler(event:MouseEvent):Void {
		// TODO Auto-generated method stub
		model.fileCore.browseForDirectory('Select directory', openFile, openFileCancelled);
	}

	private function openFile(fileDir:Dynamic):Void {
		txtAntHome.text = Reflect.field(fileDir, 'nativePath');
		file = null;
	}

	private function openFileCancelled():Void {}

	private function btnAntConfigure_clickHandler(event:MouseEvent):Void {
		// TODO Auto-generated method stub
		model.fileCore.browseForOpen('Select Build File', selectBuildFile, cancelOpenFile, ['*.xml']);
	}

	private function cancelOpenFile():Void {
		/*event.target.removeEventListener(Event.SELECT, selectBuildFile);
		event.target.removeEventListener(Event.CANCEL, cancelOpenFile);*/
	}

	private function selectBuildFile(fileDir:Dynamic):Void {
		txtAntConfigure.text =Reflect.field(fileDir, 'nativePath');//model.antScriptFile.fileBridge.nativePath;
	}

	private function btnAntBuild_clickHandler(event:MouseEvent):Void {
		var tmpArr:Array<Dynamic> = new Array<Dynamic>();
		if (AS3.as(hgFlexSDK.visible, Bool)) {
			tmpArr.push(flexSDKV);
		}
		if (AS3.as(hgAntBuild.visible, Bool)) {
			tmpArr.push(antHomeV);
		}
		if (AS3.as(hgAntConfigure.visible, Bool)) {
			tmpArr.push(antConfigureV);
		}
		if (Validator.validateAll(tmpArr).length != 0) {
			return;
		}
		if (AS3.as(txtAntHome.text, Bool)) {
			antHome = new FileLocation(txtAntHome.text);
		}
		if (AS3.as(txtAntConfigure.text, Bool)) {
			model.antScriptFile = new FileLocation(txtAntConfigure.text);
		}
		if (AS3.as(txtFlexSdk.text, Bool)) {
			buildSDK = new FileLocation(txtFlexSdk.text);
		}
		this.dispatchEvent(new AntBuildEvent(AntBuildEvent.ANT_BUILD, buildSDK, antHome));
	}

	private function clearPath(event:MouseEvent):Void {
		if (Reflect.field(event.currentTarget, 'id') == 'btnAntClear') {
			txtAntHome.text = '';
		} else if (Reflect.field(event.currentTarget, 'id') == 'btnFlexSDK') {
			txtFlexSdk.text = '';
		} else if (Reflect.field(event.currentTarget, 'id') == 'btnAntConfigure') {
			txtAntConfigure.text = '';
		}
	}

	//  supporting function definitions for properties, events, styles, effects
	private function _AntBuildScreen_StringValidator3_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.requiredFieldError = 'You need to configure the script first.';
		temp.initialized(this, 'antConfigureV');
		antConfigureV = temp;
		mx.binding.BindingManager.executeBindings(this, 'antConfigureV', antConfigureV);
		return temp;
	}

	private function _AntBuildScreen_StringValidator2_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.requiredFieldError = 'Set Ant Home path first.';
		temp.initialized(this, 'antHomeV');
		antHomeV = temp;
		mx.binding.BindingManager.executeBindings(this, 'antHomeV', antHomeV);
		return temp;
	}

	private function _AntBuildScreen_StringValidator1_i():mx.validators.StringValidator {
		var temp:mx.validators.StringValidator = new mx.validators.StringValidator();
		temp.property = 'text';
		temp.requiredFieldError = 'Set Flex SDK path first.';
		temp.initialized(this, 'flexSDKV');
		flexSDKV = temp;
		mx.binding.BindingManager.executeBindings(this, 'flexSDKV', flexSDKV);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___AntBuildScreen_Canvas1_creationComplete(event:mx.events.FlexEvent):Void {
		onAntBuildScreenCreationComplete(event);
	}

	private function _AntBuildScreen_HRule1_c():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 14342874);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_VGroup2_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.paddingLeft = 15;
		temp.paddingTop = 15;
		temp.paddingRight = 15;
		temp.paddingBottom = 15;
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_AntBuildScreen_Label1_c(), _AntBuildScreen_Label2_i(), _AntBuildScreen_Spacer1_c(), _AntBuildScreen_HRule2_c()];
		temp.id = 'hbConfigurepath';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		hbConfigurepath = temp;
		mx.binding.BindingManager.executeBindings(this, 'hbConfigurepath', hbConfigurepath);
		return temp;
	}

	private function _AntBuildScreen_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Ant Build File:';
		temp.percentWidth = 100.0;
		temp.styleName = 'uiTextSettingsLabel';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Label2_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.percentWidth = 100.0;
		temp.styleName = 'uiTextSettingsLabel';
		temp.id = 'lblAntFilePath';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lblAntFilePath = temp;
		mx.binding.BindingManager.executeBindings(this, 'lblAntFilePath', lblAntFilePath);
		return temp;
	}

	private function _AntBuildScreen_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		temp.height = 5;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_HRule2_c():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 14342874);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_VGroup3_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.paddingLeft = 15;
		temp.paddingTop = 15;
		temp.paddingRight = 15;
		temp.paddingBottom = 15;
		temp.mxmlContent = [_AntBuildScreen_HGroup1_c(), _AntBuildScreen_TextInput1_i(), _AntBuildScreen_Spacer3_c(), _AntBuildScreen_HRule3_c()];
		temp.id = 'hgAntBuild';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		hgAntBuild = temp;
		mx.binding.BindingManager.executeBindings(this, 'hgAntBuild', hgAntBuild);
		return temp;
	}

	private function _AntBuildScreen_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_AntBuildScreen_Label3_c(), _AntBuildScreen_Spacer2_c(), _AntBuildScreen_Button1_i(), _AntBuildScreen_Button2_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Label3_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.text = 'Ant Home';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Spacer2_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Clear';
		temp.addEventListener('click', __btnAntClear_click);
		temp.id = 'btnAntClear';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnAntClear = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnAntClear', btnAntClear);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnAntClear_click(event:flash.events.MouseEvent):Void {
		clearPath(event);
	}

	private function _AntBuildScreen_Button2_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Change';
		temp.addEventListener('click', ___AntBuildScreen_Button2_click);
		temp.id = '_AntBuildScreen_Button2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_AntBuildScreen_Button2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_AntBuildScreen_Button2', _AntBuildScreen_Button2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___AntBuildScreen_Button2_click(event:flash.events.MouseEvent):Void {
		btnBrowseAnt_clickHandler(event);
	}

	private function _AntBuildScreen_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.styleName = 'uiTextSettingsValue';
		temp.percentWidth = 98.0;
		temp.setStyle('paddingTop', 10);
		temp.id = 'txtAntHome';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtAntHome = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtAntHome', txtAntHome);
		return temp;
	}

	private function _AntBuildScreen_Spacer3_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		temp.height = 5;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_HRule3_c():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 14342874);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_VGroup4_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.paddingLeft = 15;
		temp.paddingTop = 15;
		temp.paddingRight = 15;
		temp.paddingBottom = 15;
		temp.mxmlContent = [_AntBuildScreen_HGroup2_c(), _AntBuildScreen_TextInput2_i(), _AntBuildScreen_Spacer5_c(), _AntBuildScreen_HRule4_c()];
		temp.id = 'hgFlexSDK';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		hgFlexSDK = temp;
		mx.binding.BindingManager.executeBindings(this, 'hgFlexSDK', hgFlexSDK);
		return temp;
	}

	private function _AntBuildScreen_HGroup2_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_AntBuildScreen_Label4_c(), _AntBuildScreen_Spacer4_c(), _AntBuildScreen_Button3_i(), _AntBuildScreen_Button4_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Label4_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.text = 'Flex SDK';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Spacer4_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Button3_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Clear';
		temp.addEventListener('click', __btnFlexSDK_click);
		temp.id = 'btnFlexSDK';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnFlexSDK = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnFlexSDK', btnFlexSDK);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnFlexSDK_click(event:flash.events.MouseEvent):Void {
		clearPath(event);
	}

	private function _AntBuildScreen_Button4_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Change';
		temp.addEventListener('click', ___AntBuildScreen_Button4_click);
		temp.id = '_AntBuildScreen_Button4';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_AntBuildScreen_Button4 = temp;
		mx.binding.BindingManager.executeBindings(this, '_AntBuildScreen_Button4', _AntBuildScreen_Button4);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___AntBuildScreen_Button4_click(event:flash.events.MouseEvent):Void {
		btnBrowseFlexSDK_clickHandler(event);
	}

	private function _AntBuildScreen_TextInput2_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.styleName = 'uiTextSettingsValue';
		temp.percentWidth = 98.0;
		temp.setStyle('paddingTop', 10);
		temp.id = 'txtFlexSdk';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtFlexSdk = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtFlexSdk', txtFlexSdk);
		return temp;
	}

	private function _AntBuildScreen_Spacer5_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		temp.height = 5;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_HRule4_c():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 14342874);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_VGroup5_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.paddingLeft = 15;
		temp.paddingTop = 15;
		temp.paddingRight = 15;
		temp.paddingBottom = 15;
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_AntBuildScreen_HGroup3_c(), _AntBuildScreen_TextInput3_i(), _AntBuildScreen_Spacer7_c(), _AntBuildScreen_HRule5_c()];
		temp.id = 'hgAntConfigure';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		hgAntConfigure = temp;
		mx.binding.BindingManager.executeBindings(this, 'hgAntConfigure', hgAntConfigure);
		return temp;
	}

	private function _AntBuildScreen_HGroup3_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_AntBuildScreen_Label5_c(), _AntBuildScreen_Spacer6_c(), _AntBuildScreen_Button5_i(), _AntBuildScreen_Button6_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Label5_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.text = 'Ant Script to Run';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Spacer6_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Button5_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Clear';
		temp.addEventListener('click', __btnAntConfigure_click);
		temp.id = 'btnAntConfigure';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnAntConfigure = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnAntConfigure', btnAntConfigure);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnAntConfigure_click(event:flash.events.MouseEvent):Void {
		clearPath(event);
	}

	private function _AntBuildScreen_Button6_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Change';
		temp.addEventListener('click', ___AntBuildScreen_Button6_click);
		temp.id = '_AntBuildScreen_Button6';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_AntBuildScreen_Button6 = temp;
		mx.binding.BindingManager.executeBindings(this, '_AntBuildScreen_Button6', _AntBuildScreen_Button6);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___AntBuildScreen_Button6_click(event:flash.events.MouseEvent):Void {
		btnAntConfigure_clickHandler(event);
	}

	private function _AntBuildScreen_TextInput3_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.styleName = 'uiTextSettingsValue';
		temp.percentWidth = 98.0;
		temp.setStyle('paddingTop', 10);
		temp.id = 'txtAntConfigure';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtAntConfigure = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtAntConfigure', txtAntConfigure);
		return temp;
	}

	private function _AntBuildScreen_Spacer7_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		temp.height = 5;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_HRule5_c():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 14342874);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Spacer8_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_HGroup4_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.horizontalAlign = 'center';
		temp.mxmlContent = [_AntBuildScreen_Button7_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _AntBuildScreen_Button7_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Ant Build';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', __btnAntBuild_click);
		temp.id = 'btnAntBuild';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnAntBuild = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnAntBuild', btnAntBuild);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnAntBuild_click(event:flash.events.MouseEvent):Void {
		btnAntBuild_clickHandler(event);
	}

	//  binding mgmt
	private function _AntBuildScreen_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'flexSDKV.source', 'txtFlexSdk');

		result[1] = new mx.binding.Binding(this,
				null,
				null,
				'antHomeV.source', 'txtAntHome');

		result[2] = new mx.binding.Binding(this,
				null,
				null,
				'antConfigureV.source', 'txtAntConfigure');

		result[3] = new mx.binding.Binding(this,
				function():Bool {
					return (_isAntConfigurPath);
				},
				null,
				'hbConfigurepath.visible');

		result[4] = new mx.binding.Binding(this,
				function():Bool {
					return (_isAntConfigurPath);
				},
				null,
				'hbConfigurepath.includeInLayout');

		result[5] = new mx.binding.Binding(this,
				function():Bool {
					return (!_isAntPath);
				},
				null,
				'hgAntBuild.includeInLayout');

		result[6] = new mx.binding.Binding(this,
				function():Bool {
					return (!_isAntPath);
				},
				null,
				'hgAntBuild.visible');

		result[7] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					btnAntClear.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'btnAntClear.skinClass');

		result[8] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					_AntBuildScreen_Button2.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'_AntBuildScreen_Button2.skinClass');

		result[9] = new mx.binding.Binding(this,
				function():Bool {
					return (_isFlexSDK);
				},
				null,
				'hgFlexSDK.includeInLayout');

		result[10] = new mx.binding.Binding(this,
				function():Bool {
					return (_isFlexSDK);
				},
				null,
				'hgFlexSDK.visible');

		result[11] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					btnFlexSDK.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'btnFlexSDK.skinClass');

		result[12] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					_AntBuildScreen_Button4.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'_AntBuildScreen_Button4.skinClass');

		result[13] = new mx.binding.Binding(this,
				function():Bool {
					return (!_isAntConfigurPath);
				},
				null,
				'hgAntConfigure.visible');

		result[14] = new mx.binding.Binding(this,
				function():Bool {
					return (!_isAntConfigurPath);
				},
				null,
				'hgAntConfigure.includeInLayout');

		result[15] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					btnAntConfigure.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'btnAntConfigure.skinClass');

		result[16] = new mx.binding.Binding(this,
				function():Class<Dynamic> {
					return (LinkButtonSkin);
				},
				function(_sourceFunctionReturnValue:Class<Dynamic>):Void {
					_AntBuildScreen_Button6.setStyle('skinClass', _sourceFunctionReturnValue);
				},
				'_AntBuildScreen_Button6.skinClass');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(AntBuildScreen)._watcherSetupUtil = watcherSetupUtil;
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