/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      JavaPathSetupPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/JavaPathSetupPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.popup;

import mx.core.UIComponent;
import mx.events.FlexEvent;
import spark.utils.TextFlowUtil;
import actionScripts.events.FilePluginEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.SettingsEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.ConstantsCoreVO;
import flashx.textLayout.elements.TextFlow;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.MouseEvent;
import flash.external.*;
import flash.filters.DropShadowFilter;
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
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ListElement;
import flashx.textLayout.elements.ListItemElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;

import flashx.textLayout.events.FlowElementMouseEvent;
import mx.binding.*;
import mx.binding.IBindingClient;
import mx.containers.HBox;
import mx.controls.HRule;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.IStateClient2;
import mx.core.Mx_internal;

import mx.filters.*;
import mx.graphics.SolidColor;
import mx.states.AddItems;
import mx.states.State;
import mx.styles.*;
import spark.components.BorderContainer;
import spark.components.Button;
import spark.components.Group;
import spark.components.HGroup;
import spark.components.Image;
import spark.components.Label;
import spark.components.RichEditableText;
import spark.components.TextInput;
import spark.components.VGroup;

@:meta(States(name = 'permissionRequestOSX', name = 'default', name = 'noRequiredSDK'))
//  begin class def
class JavaPathSetupPopup extends spark.components.Group implements mx.binding.IBindingClient implements mx.core.IStateClient2 {

	//  instance variables
	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_Group2:spark.components.Group;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_HBox2:mx.containers.HBox;

	@:meta(Inspectable())
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_HGroup1:spark.components.HGroup;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_Image1:spark.components.Image;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_Image2:spark.components.Image;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_Image3:spark.components.Image;

	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_Label1:spark.components.Label;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_VGroup2:spark.components.VGroup;

	@:meta(Inspectable())
	/**
	 * @private
	 **/
	public var _JavaPathSetupPopup_VGroup3:spark.components.VGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var body:spark.components.BorderContainer;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnAllowAccess:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var buttonBar:mx.containers.HBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var buttonBarLine:mx.controls.HRule;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var retAutoDetectedNotif:spark.components.RichEditableText;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var retManualNotif:spark.components.RichEditableText;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtAutoDetectedPath:spark.components.TextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _JavaPathSetupPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_JavaPathSetupPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(JavaPathSetupPopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.autoLayout = true;
		this.horizontalCenter = 0;
		this.verticalCenter = 0;
		this.mxmlContent = [_JavaPathSetupPopup_BorderContainer1_i()];
		this.currentState = 'permissionRequestOSX';

		// events
		this.addEventListener('creationComplete', ___JavaPathSetupPopup_Group1_creationComplete);

		var _JavaPathSetupPopup_Button1_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Button1_i);
		var _JavaPathSetupPopup_Button2_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Button2_c);
		var _JavaPathSetupPopup_Button3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Button3_c);
		var _JavaPathSetupPopup_Button4_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Button4_c);
		var _JavaPathSetupPopup_HBox2_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_HBox2_i);
		var _JavaPathSetupPopup_HBox3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_HBox3_c);
		var _JavaPathSetupPopup_Image1_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Image1_i);
		var _JavaPathSetupPopup_Image2_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Image2_i);
		var _JavaPathSetupPopup_Image3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Image3_i);
		var _JavaPathSetupPopup_VGroup2_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_VGroup2_i);
		var _JavaPathSetupPopup_VGroup3_factory:DeferredInstanceFromFunction =
		new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_VGroup3_i);

		states = [
				new State({
					'name': 'permissionRequestOSX',
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_HBox3_factory,
								'destination': 'buttonBar',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_VGroup3_factory,
								'destination': '_JavaPathSetupPopup_HGroup1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['_JavaPathSetupPopup_Group2']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Image3_factory,
								'destination': '_JavaPathSetupPopup_Group2',
								'propertyName': 'mxmlContent',
								'position': 'first'
							})
			]
				}),
				new State({
					'name': 'default',
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Button2_factory,
								'destination': '_JavaPathSetupPopup_HBox2',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Button1_factory,
								'destination': '_JavaPathSetupPopup_HBox2',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_HBox2_factory,
								'destination': 'buttonBar',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_VGroup2_factory,
								'destination': '_JavaPathSetupPopup_HGroup1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['_JavaPathSetupPopup_Group2']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Image1_factory,
								'destination': '_JavaPathSetupPopup_Group2',
								'propertyName': 'mxmlContent',
								'position': 'first'
							})
			]
				}),
				new State({
					'name': 'noRequiredSDK',
					'overrides': [
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Button4_factory,
								'destination': '_JavaPathSetupPopup_HBox2',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Button3_factory,
								'destination': '_JavaPathSetupPopup_HBox2',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_HBox2_factory,
								'destination': 'buttonBar',
								'position': 'first'
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_VGroup2_factory,
								'destination': '_JavaPathSetupPopup_HGroup1',
								'propertyName': 'mxmlContent',
								'position': 'after',
								'relativeTo': ['_JavaPathSetupPopup_Group2']
							}),
					new AddItems().initializeFromObject({
								'itemsFactory': _JavaPathSetupPopup_Image2_factory,
								'destination': '_JavaPathSetupPopup_Group2',
								'propertyName': 'mxmlContent',
								'position': 'first'
							})
			]
				})
		];

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
	//  <Script>, line 29 - 207

	@:meta(Bindable())
	public var showAsHelperDownloader:Bool = false;

	public var showAsRequiresSDKNotification:Bool = false;
	public var isSDKSetupShowing:Bool = false;
	public var isDiscarded:Bool = false;

	@:meta(Bindable())
	private var userNotes:String;
	@:meta(Bindable())
	private var autoDetectedJavaPath:String;

	private var foundAndAccessNote:String = '<p>Code completion requires the Java Development Kit 1.8. Follow the instructions below to set up access,<br/></p><list listStyleType=\'decimal\'><li>Copy the path given below to clipboard</li><li>click on <span fontWeight=\'bold\'>Allow Access</span> button below</li><li>Press CMD-Shift-G. This will open a prompt where you can specify a path to navigate to</li><li>Right click in the text field and select Paste</li><li>Click <span fontWeight=\'bold\'>Open</span></li></list>';
	private var model:IDEModel = IDEModel.getInstance();

	private function onJavaPathSetupPopupCreationComplete(event:FlexEvent):Void {
		if (showAsRequiresSDKNotification) {
			onPermittedOSX();
		}

		var closeButtonUIC:UIComponent = new UIComponent();
		closeButtonUIC.width = closeButtonUIC.height = 27;
		closeButtonUIC.right = 0;

		var closeButton:Sprite = new Sprite();
		// Circle
		closeButton.graphics.lineStyle(1, 0xFFFFFF, 0.8);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawCircle(14, 12, 6);
		closeButton.graphics.endFill();
		// X (\)
		closeButton.graphics.lineStyle(2, 0xFFFFFF, 0.8, true);
		closeButton.graphics.moveTo(12, 10);
		closeButton.graphics.lineTo(16, 14);
		// X (/)
		closeButton.graphics.moveTo(16, 10);
		closeButton.graphics.lineTo(12, 14);
		// Hit area
		closeButton.graphics.lineStyle(0, 0x0, 0);
		closeButton.graphics.beginFill(0x0, 0);
		closeButton.graphics.drawRect(0, 0, 27, 25);
		closeButton.graphics.endFill();

		closeButton.addEventListener(MouseEvent.CLICK, closeButtonClickedRequest, false, 0, true);
		closeButtonUIC.addChild(closeButton);

		addElement(closeButtonUIC);
	}

	private function prepareNotifications():Void {
		// when opend as required SDK not present window
		if (showAsRequiresSDKNotification) {
			var flow:TextFlow = TextFlowUtil.importFromString('<p>Code completion requires Apache Flex® or FlexJS® SDK.<br/><br/>Make sure you have it defined in SDK list by clicking on <span fontWeight=\'bold\'>Fix Now</span> button. In case of MacOS, your SDK location needs to be in your <span fontWeight=\'bold\'>Downloads</span> folder.</p>');
			currentState = 'noRequiredSDK';
			body.alpha = 1;
			callLater(function():Void {
						retAutoDetectedNotif.textFlow = flow;
					});
		} else if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			model.flexCore.getJavaPath(onJavaPathDetectedInOSX);
		} else if (!AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
			// let user manually set Java path once
			onJavaPathDetectedInOSX(null);
		}
	}

	private function onPermittedOSX():Void {
		ConstantsCoreVO.IS_OSX_JAVA_SDK_PROMPT = true;
		currentState = 'default';
		prepareNotifications();
	}

	private function closeButtonClickedRequest(event:MouseEvent):Void {
		closeButtonClicked(event, true);
	}

	private function closeButtonClicked(event:MouseEvent, isDiscarded:Bool = false):Void {
		this.isDiscarded = isDiscarded;
		if (event != null) {
			event.target.removeEventListener(MouseEvent.CLICK, closeButtonClicked);
		}
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function onAllowAccess(event:MouseEvent):Void {
		model.fileCore.browseForDirectory('Select Java Path', onJavaDirectorySelected, null, autoDetectedJavaPath);
	}

	private function onJavaDirectorySelected(dir:Dynamic):Void {
		model.javaPathForTypeAhead = ((Std.is(dir, FileLocation))) ? AS3.as(dir, FileLocation) : new FileLocation(AS3.string(Reflect.field(dir, 'nativePath')));
		GlobalEventDispatcher.getInstance().dispatchEvent(new FilePluginEvent(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, model.javaPathForTypeAhead));

		// close this
		closeButtonClicked(null);
	}

	private function openJavaDownloadPage(event:MouseEvent):Void {
		flash.Lib.getURL(new URLRequest('http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html'), '_blank');
	}

	private function fixRequiredSDK(event:MouseEvent):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, 'actionScripts.plugins.as3project.mxmlc::MXMLCPlugin'));
		isSDKSetupShowing = true;

		// close this
		closeButtonClicked(null, true);
	}

	private function onJavaPathDetectedInOSX(path:String):Void {
		// in case java 1.8 found
		var flow:TextFlow;
		if (path != null) {
			autoDetectedJavaPath = path;

			var pattern:as3hx.Compat.Regex = new as3hx.Compat.Regex(new as3hx.Compat.Regex('(\\n)', 'g'));
			autoDetectedJavaPath = pattern.replace(autoDetectedJavaPath, '');

			// for OSX we'll need the user to select the folder
			// to let sandbox app access it
			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				flow = TextFlowUtil.importFromString(foundAndAccessNote);
				txtAutoDetectedPath.includeInLayout = txtAutoDetectedPath.visible = true;
				body.alpha = 1;
				callLater(function():Void {
							retAutoDetectedNotif.textFlow = flow;
						});
			} else {
				onJavaDirectorySelected(new FileLocation(autoDetectedJavaPath));
			}
		} else {
			body.alpha = 1;
			if (AS3.as(ConstantsCoreVO.IS_MACOS, Bool)) {
				retAutoDetectedNotif.includeInLayout = retAutoDetectedNotif.visible = false;
				// since link to ActionScript not worked in AS textFlow conversion
				retManualNotif.includeInLayout = retManualNotif.visible = true;
			} else {
				flow = TextFlowUtil.importFromString('<p>Code completion requires the Java Development Kit 1.8. To select the path click on <span fontWeight=\'bold\'>Allow Access</span> button</p>');
				callLater(function():Void {
							retAutoDetectedNotif.textFlow = flow;
						});
			}
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _JavaPathSetupPopup_BorderContainer1_i():spark.components.BorderContainer {
		var temp:spark.components.BorderContainer = new spark.components.BorderContainer();
		temp.width = 450;
		temp.minHeight = 200;
		temp.autoLayout = true;
		temp.alpha = 1;
		temp.backgroundFill = _JavaPathSetupPopup_SolidColor1_c();
		temp.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_JavaPathSetupPopup_Array3_c);
		temp.setStyle('cornerRadius', 6);
		temp.setStyle('borderColor', 2960685);
		temp.id = 'body';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		body = temp;
		mx.binding.BindingManager.executeBindings(this, 'body', body);
		return temp;
	}

	private function _JavaPathSetupPopup_SolidColor1_c():mx.graphics.SolidColor {
		var temp:mx.graphics.SolidColor = new mx.graphics.SolidColor();
		temp.color = 10526880;
		return temp;
	}

	private function _JavaPathSetupPopup_Array3_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_JavaPathSetupPopup_VGroup1_c()];
		return cast temp;
	}

	private function _JavaPathSetupPopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.gap = 0;
		temp.mxmlContent = [_JavaPathSetupPopup_HGroup1_i(), _JavaPathSetupPopup_HRule1_i(), _JavaPathSetupPopup_HBox1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _JavaPathSetupPopup_HGroup1_i():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.verticalAlign = 'middle';
		temp.gap = 0;
		temp.mxmlContent = [_JavaPathSetupPopup_Group2_i()];
		temp.id = '_JavaPathSetupPopup_HGroup1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_HGroup1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_HGroup1', _JavaPathSetupPopup_HGroup1);
		return temp;
	}

	private function _JavaPathSetupPopup_Group2_i():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.width = 98;
		temp.mxmlContent = [];
		temp.id = '_JavaPathSetupPopup_Group2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_Group2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_Group2', _JavaPathSetupPopup_Group2);
		return temp;
	}

	private function _JavaPathSetupPopup_Image1_i():spark.components.Image {
		var temp:spark.components.Image = new spark.components.Image();
		temp.source = _embed_mxml__elements_images_icoJava_png_314890023;
		temp.horizontalCenter = 0;
		temp.verticalCenter = 0;
		temp.id = '_JavaPathSetupPopup_Image1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_Image1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_Image1', _JavaPathSetupPopup_Image1);
		return temp;
	}

	private function _JavaPathSetupPopup_Image2_i():spark.components.Image {
		var temp:spark.components.Image = new spark.components.Image();
		temp.source = _embed_mxml__elements_images_icoSDKExclamation_png_2039436345;
		temp.horizontalCenter = 0;
		temp.verticalCenter = 0;
		temp.id = '_JavaPathSetupPopup_Image2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_Image2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_Image2', _JavaPathSetupPopup_Image2);
		return temp;
	}

	private function _JavaPathSetupPopup_Image3_i():spark.components.Image {
		var temp:spark.components.Image = new spark.components.Image();
		temp.source = _embed_mxml__elements_images_icoCodeCompletion_png_2045814831;
		temp.horizontalCenter = 0;
		temp.verticalCenter = 0;
		temp.id = '_JavaPathSetupPopup_Image3';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_Image3 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_Image3', _JavaPathSetupPopup_Image3);
		return temp;
	}

	private function _JavaPathSetupPopup_VGroup2_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.autoLayout = true;
		temp.paddingRight = 20;
		temp.paddingTop = 20;
		temp.paddingBottom = 20;
		temp.mxmlContent = [_JavaPathSetupPopup_RichEditableText1_i(), _JavaPathSetupPopup_RichEditableText2_i(), _JavaPathSetupPopup_TextInput1_i()];
		temp.id = '_JavaPathSetupPopup_VGroup2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_VGroup2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_VGroup2', _JavaPathSetupPopup_VGroup2);
		return temp;
	}

	private function _JavaPathSetupPopup_RichEditableText1_i():spark.components.RichEditableText {
		var temp:spark.components.RichEditableText = new spark.components.RichEditableText();
		temp.editable = false;
		temp.focusEnabled = false;
		temp.selectable = false;
		temp.percentWidth = 100.0;
		temp.setStyle('fontSize', 13);
		temp.id = 'retAutoDetectedNotif';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		retAutoDetectedNotif = temp;
		mx.binding.BindingManager.executeBindings(this, 'retAutoDetectedNotif', retAutoDetectedNotif);
		return temp;
	}

	private function _JavaPathSetupPopup_RichEditableText2_i():spark.components.RichEditableText {
		var temp:spark.components.RichEditableText = new spark.components.RichEditableText();
		temp.editable = false;
		temp.focusEnabled = false;
		temp.percentWidth = 100.0;
		temp.includeInLayout = false;
		temp.visible = false;
		temp.textFlow = _JavaPathSetupPopup_TextFlow1_c();
		temp.setStyle('fontSize', 13);
		temp.id = 'retManualNotif';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		retManualNotif = temp;
		mx.binding.BindingManager.executeBindings(this, 'retManualNotif', retManualNotif);
		return temp;
	}

	private function _JavaPathSetupPopup_TextFlow1_c():flashx.textLayout.elements.TextFlow {
		var temp:flashx.textLayout.elements.TextFlow = new flashx.textLayout.elements.TextFlow();
		temp.mxmlChildren = [_JavaPathSetupPopup_ParagraphElement1_c(), _JavaPathSetupPopup_ListElement1_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ParagraphElement1_c():flashx.textLayout.elements.ParagraphElement {
		var temp:flashx.textLayout.elements.ParagraphElement = new flashx.textLayout.elements.ParagraphElement();
		temp.mxmlChildren = ['Code completion requires the Java Development Kit 1.8. You can find and submit the path using the instructions below:', _JavaPathSetupPopup_BreakElement1_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_BreakElement1_c():flashx.textLayout.elements.BreakElement {
		var temp:flashx.textLayout.elements.BreakElement = new flashx.textLayout.elements.BreakElement();
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListElement1_c():flashx.textLayout.elements.ListElement {
		var temp:flashx.textLayout.elements.ListElement = new flashx.textLayout.elements.ListElement();
		temp.listStyleType = 'decimal';
		temp.mxmlChildren = [_JavaPathSetupPopup_ListItemElement1_c(), _JavaPathSetupPopup_ListItemElement2_c(), _JavaPathSetupPopup_ListItemElement3_c(), _JavaPathSetupPopup_ListItemElement4_c(), _JavaPathSetupPopup_ListItemElement5_c(), _JavaPathSetupPopup_ListItemElement6_c(), _JavaPathSetupPopup_ListItemElement7_c(), _JavaPathSetupPopup_ListItemElement8_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement1_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['If you have not installed Java 8 yet, you can do it here: ', _JavaPathSetupPopup_LinkElement1_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_LinkElement1_c():flashx.textLayout.elements.LinkElement {
		var temp:flashx.textLayout.elements.LinkElement = new flashx.textLayout.elements.LinkElement();
		temp.mxmlChildren = ['http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html'];
		temp.addEventListener('click', ___JavaPathSetupPopup_LinkElement1_click);
		temp.initialized(this, null);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_LinkElement1_click(event:flashx.textLayout.events.FlowElementMouseEvent):Void {
		openJavaDownloadPage(null);
	}

	private function _JavaPathSetupPopup_ListItemElement2_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Open a Terminal window'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement3_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Enter this command to get the Java path:', _JavaPathSetupPopup_BreakElement2_c(), _JavaPathSetupPopup_SpanElement1_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_BreakElement2_c():flashx.textLayout.elements.BreakElement {
		var temp:flashx.textLayout.elements.BreakElement = new flashx.textLayout.elements.BreakElement();
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_SpanElement1_c():flashx.textLayout.elements.SpanElement {
		var temp:flashx.textLayout.elements.SpanElement = new flashx.textLayout.elements.SpanElement();
		temp.fontWeight = 'bold';
		temp.mxmlChildren = ['/usr/libexec/java_home -v 1.8'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement4_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Copy the result to the clipboard'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement5_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Click on ', _JavaPathSetupPopup_SpanElement2_c(), ' button below'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_SpanElement2_c():flashx.textLayout.elements.SpanElement {
		var temp:flashx.textLayout.elements.SpanElement = new flashx.textLayout.elements.SpanElement();
		temp.fontWeight = 'bold';
		temp.mxmlChildren = ['Allow Access'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement6_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Press CMD-Shift-G. This will open a prompt where you can specify a path to navigate to'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement7_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Right click in the text field and select Paste'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_ListItemElement8_c():flashx.textLayout.elements.ListItemElement {
		var temp:flashx.textLayout.elements.ListItemElement = new flashx.textLayout.elements.ListItemElement();
		temp.mxmlChildren = ['Click ', _JavaPathSetupPopup_SpanElement3_c()];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_SpanElement3_c():flashx.textLayout.elements.SpanElement {
		var temp:flashx.textLayout.elements.SpanElement = new flashx.textLayout.elements.SpanElement();
		temp.fontWeight = 'bold';
		temp.mxmlChildren = ['Open'];
		temp.initialized(this, null);
		return temp;
	}

	private function _JavaPathSetupPopup_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.editable = false;
		temp.includeInLayout = false;
		temp.visible = false;
		temp.id = 'txtAutoDetectedPath';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtAutoDetectedPath = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtAutoDetectedPath', txtAutoDetectedPath);
		return temp;
	}

	private function _JavaPathSetupPopup_VGroup3_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.autoLayout = true;
		temp.paddingRight = 20;
		temp.mxmlContent = [_JavaPathSetupPopup_Label1_i()];
		temp.id = '_JavaPathSetupPopup_VGroup3';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_VGroup3 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_VGroup3', _JavaPathSetupPopup_VGroup3);
		return temp;
	}

	private function _JavaPathSetupPopup_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.maxDisplayedLines = 5;
		temp.percentWidth = 100.0;
		temp.setStyle('fontSize', 13);
		temp.id = '_JavaPathSetupPopup_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_JavaPathSetupPopup_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_Label1', _JavaPathSetupPopup_Label1);
		return temp;
	}

	private function _JavaPathSetupPopup_HRule1_i():mx.controls.HRule {
		var temp:mx.controls.HRule = new mx.controls.HRule();
		temp.percentWidth = 100.0;
		temp.bottom = 41;
		temp.setStyle('strokeWidth', 1);
		temp.setStyle('strokeColor', 3158064);
		temp.id = 'buttonBarLine';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		buttonBarLine = temp;
		mx.binding.BindingManager.executeBindings(this, 'buttonBarLine', buttonBarLine);
		return temp;
	}

	@:access(mx.containers.HBox) private function _JavaPathSetupPopup_HBox1_i():mx.containers.HBox {
		var temp:mx.containers.HBox = new mx.containers.HBox();
		temp.percentWidth = 100.0;
		temp.height = 41;
		temp.bottom = 0;
		temp.filters = [_JavaPathSetupPopup_DropShadowFilter1_c()];
		temp.setStyle('backgroundColor', 4473924);
		temp.setStyle('paddingRight', 10);
		temp.setStyle('paddingTop', 0);
		temp.setStyle('horizontalAlign', 'center');
		temp.setStyle('verticalAlign', 'middle');
		temp.id = 'buttonBar';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		temp._documentDescriptor =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.HBox,
					'id': 'buttonBar',
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': []
						};
					}
				});
		temp._documentDescriptor.document = this;
		buttonBar = temp;
		mx.binding.BindingManager.executeBindings(this, 'buttonBar', buttonBar);
		return temp;
	}

	private function _JavaPathSetupPopup_DropShadowFilter1_c():flash.filters.DropShadowFilter {
		var temp:flash.filters.DropShadowFilter = new flash.filters.DropShadowFilter();
		temp.alpha = 0.5;
		temp.angle = 90;
		temp.blurX = 0;
		temp.blurY = 7;
		temp.strength = 1;
		temp.distance = 1;
		temp.inner = true;
		return temp;
	}

	@:access(mx.containers.HBox) private function _JavaPathSetupPopup_HBox2_i():mx.containers.HBox {
		var temp:mx.containers.HBox = new mx.containers.HBox();
		temp.autoLayout = true;
		temp.id = '_JavaPathSetupPopup_HBox2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		temp._documentDescriptor =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.HBox,
					'id': '_JavaPathSetupPopup_HBox2',
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': []
						};
					}
				});
		temp._documentDescriptor.document = this;
		_JavaPathSetupPopup_HBox2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_JavaPathSetupPopup_HBox2', _JavaPathSetupPopup_HBox2);
		return temp;
	}

	private function _JavaPathSetupPopup_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Allow Access';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', __btnAllowAccess_click);
		temp.id = 'btnAllowAccess';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnAllowAccess = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnAllowAccess', btnAllowAccess);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnAllowAccess_click(event:flash.events.MouseEvent):Void {
		onAllowAccess(event);
	}

	private function _JavaPathSetupPopup_Button2_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Skip For Now';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___JavaPathSetupPopup_Button2_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Button2_click(event:flash.events.MouseEvent):Void {
		closeButtonClicked(null, true);
	}

	private function _JavaPathSetupPopup_Button3_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Fix Now';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___JavaPathSetupPopup_Button3_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Button3_click(event:flash.events.MouseEvent):Void {
		fixRequiredSDK(event);
	}

	private function _JavaPathSetupPopup_Button4_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Continue Without Code Completion';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___JavaPathSetupPopup_Button4_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Button4_click(event:flash.events.MouseEvent):Void {
		closeButtonClicked(event, true);
	}

	@:access(mx.containers.HBox) private function _JavaPathSetupPopup_HBox3_c():mx.containers.HBox {
		var temp:mx.containers.HBox = new mx.containers.HBox();
		temp.autoLayout = true;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		temp._documentDescriptor =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.HBox,
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': spark.components.Button,
								'events': {
									'click': '___JavaPathSetupPopup_Button5_click'
								},
								'propertiesFactory': function():Dynamic {
									return {
										'label': 'Configure & Enable',
										'styleName': 'darkButton'
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': spark.components.Button,
								'events': {
									'click': '___JavaPathSetupPopup_Button6_click'
								},
								'propertiesFactory': function():Dynamic {
									return {
										'label': 'No Thanks',
										'styleName': 'darkButton'
									};
								}
							})
				]
						};
					}
				});
		temp._documentDescriptor.document = this;
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Button5_click(event:flash.events.MouseEvent):Void {
		onPermittedOSX();
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Button6_click(event:flash.events.MouseEvent):Void {
		closeButtonClicked(event, true);
	}

	/**
	 * @private
	 **/
	public function ___JavaPathSetupPopup_Group1_creationComplete(event:mx.events.FlexEvent):Void {
		onJavaPathSetupPopupCreationComplete(event);
	}

	//  binding mgmt
	private function _JavaPathSetupPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (autoDetectedJavaPath);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'txtAutoDetectedPath.text');

		result[1] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (ConstantsCoreVO.MOONSHINE_IDE_LABEL) + ' optionally supports code completion for ActionScript(.as) files. Would you like to enable this now?';
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_JavaPathSetupPopup_Label1.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(JavaPathSetupPopup)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	@:meta(Embed(source = '/elements/images/icoSDKExclamation.png'))
	private var _embed_mxml__elements_images_icoSDKExclamation_png_2039436345:Class<Dynamic>;

	@:meta(Embed(source = '/elements/images/icoCodeCompletion.png'))
	private var _embed_mxml__elements_images_icoCodeCompletion_png_2045814831:Class<Dynamic>;

	@:meta(Embed(source = '/elements/images/icoJava.png'))
	private var _embed_mxml__elements_images_icoJava_png_314890023:Class<Dynamic>;

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