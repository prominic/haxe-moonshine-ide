/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.actionscript.as3project.settings
 *  Class:      NewProjectSourcePathListSettingRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/actionscript/as3project/settings/NewProjectSourcePathListSettingRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package actionScripts.plugin.actionscript.as3project.settings;

import actionScripts.valueObjects.FileWrapper;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.NewFileEvent;
import actionScripts.factory.FileLocation;
import components.popup.NewProjectFilePathPopup;
import components.popup.NewProjectSourcePathPopup;

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
import mx.graphics.SolidColorStroke;
import mx.styles.*;
import spark.components.Button;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.VGroup;
import spark.primitives.Rect;

//  begin class def
class NewProjectSourcePathListSettingRenderer extends spark.components.VGroup implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _NewProjectSourcePathListSettingRenderer_Button2:spark.components.Button;

	/**
	 * @private
	 **/
	public var _NewProjectSourcePathListSettingRenderer_Label1:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var pathFile:spark.components.TextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var pathFolder:spark.components.TextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _NewProjectSourcePathListSettingRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_actionscript_as3project_settings_NewProjectSourcePathListSettingRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(NewProjectSourcePathListSettingRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.gap = 0;
		this.paddingTop = 15;
		this.paddingBottom = 5;
		this.paddingLeft = 15;
		this.paddingRight = 15;
		this.mxmlContent = [_NewProjectSourcePathListSettingRenderer_Label1_i(), _NewProjectSourcePathListSettingRenderer_HGroup1_c(), _NewProjectSourcePathListSettingRenderer_Rect1_c(), _NewProjectSourcePathListSettingRenderer_Label2_c(), _NewProjectSourcePathListSettingRenderer_HGroup2_c()];

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
	//  <Script>, line 33 - 140

	@:meta(Bindable())
	public var setting:NewProjectSourcePathListSetting;

	private var newProjectSourcePathPopup:NewProjectSourcePathPopup;
	private var newProjectFilePathPopup:NewProjectFilePathPopup;
	private var sourceFolderWrapper:FileWrapper;
	private var sourceFolderLocation:FileLocation;
	private var sourceFileLocation:FileLocation;

	public function resetAllProjectPaths():Void {
		sourceFolderLocation = sourceFileLocation = null;
		pathFolder.text = pathFile.text = '';
		setting.stringValue = '';
	}

	private function onBrowseSourceDir():Void {
		if (newProjectSourcePathPopup == null) {
			newProjectSourcePathPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), NewProjectSourcePathPopup, true), NewProjectSourcePathPopup);
			newProjectSourcePathPopup.addEventListener(CloseEvent.CLOSE, handleSourceFolderPopupClose);
			newProjectSourcePathPopup.addEventListener(NewFileEvent.EVENT_FILE_SELECTED, onSourceFolderSelected);

			newProjectSourcePathPopup.wrapperBelongToProject = setting.project;
			PopUpManager.centerPopUp(newProjectSourcePathPopup);
		}
	}

	private function handleSourceFolderPopupClose(event:CloseEvent):Void {
		newProjectSourcePathPopup.removeEventListener(CloseEvent.CLOSE, handleSourceFolderPopupClose);
		newProjectSourcePathPopup.removeEventListener(NewFileEvent.EVENT_FILE_SELECTED, onSourceFolderSelected);
		newProjectSourcePathPopup = null;
	}

	private function onSourceFolderSelected(event:NewFileEvent):Void {
		pathFolder.text = getLabelFor(event.insideLocation.file);
		sourceFolderWrapper = event.insideLocation;
		sourceFolderLocation = event.insideLocation.file;

		updateToSettings();
	}

	private function getLabelFor(file:Dynamic):String {
		var tmpFL:FileLocation = ((Std.is(file, FileLocation))) ? AS3.as(file, FileLocation) : new FileLocation(AS3.string(Reflect.field(file, 'nativePath')));
		var lbl:String = Std.string(setting.project.folderLocation.fileBridge.getRelativePath(tmpFL, true));

		return lbl;
	}

	private function onBrowseSourceFile():Void {
		if (newProjectFilePathPopup == null) {
			newProjectFilePathPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), NewProjectFilePathPopup, true), NewProjectFilePathPopup);
			newProjectFilePathPopup.addEventListener(CloseEvent.CLOSE, handleSourceFilePopupClose);
			newProjectFilePathPopup.addEventListener(NewFileEvent.EVENT_FILE_SELECTED, onSourceFileSelected);

			newProjectFilePathPopup.folderWrapper = sourceFolderWrapper;
			PopUpManager.centerPopUp(newProjectFilePathPopup);
		}
	}

	private function handleSourceFilePopupClose(event:CloseEvent):Void {
		newProjectFilePathPopup.removeEventListener(CloseEvent.CLOSE, handleSourceFilePopupClose);
		newProjectFilePathPopup.removeEventListener(NewFileEvent.EVENT_FILE_SELECTED, onSourceFileSelected);
		newProjectFilePathPopup = null;
	}

	private function onSourceFileSelected(event:NewFileEvent):Void {
		pathFile.text = event.filePath.split(Std.string(sourceFolderLocation.fileBridge.separator)).pop();
		sourceFileLocation = new FileLocation(event.filePath);

		updateToSettings();
	}

	private function updateToSettings():Void {
		if (!setting.project.isLibraryProject && sourceFolderLocation != null && sourceFileLocation != null) {
			setting.stringValue = sourceFolderLocation.fileBridge.nativePath + ',' + sourceFileLocation.fileBridge.nativePath;
		} else if (setting.project.isLibraryProject && sourceFolderLocation != null) {
			setting.stringValue = Std.string(sourceFolderLocation.fileBridge.nativePath);
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _NewProjectSourcePathListSettingRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.id = '_NewProjectSourcePathListSettingRenderer_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_NewProjectSourcePathListSettingRenderer_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_NewProjectSourcePathListSettingRenderer_Label1', _NewProjectSourcePathListSettingRenderer_Label1);
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.paddingLeft = 15;
		temp.paddingBottom = 10;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_NewProjectSourcePathListSettingRenderer_TextInput1_i(), _NewProjectSourcePathListSettingRenderer_Spacer1_c(), _NewProjectSourcePathListSettingRenderer_Button1_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'uiTextSettingsValue';
		temp.percentHeight = 100.0;
		temp.buttonMode = true;
		temp.editable = false;
		temp.mouseChildren = false;
		temp.setStyle('borderVisible', false);
		temp.setStyle('contentBackgroundAlpha', 0);
		temp.setStyle('focusAlpha', 0);
		temp.id = 'pathFolder';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		pathFolder = temp;
		mx.binding.BindingManager.executeBindings(this, 'pathFolder', pathFolder);
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.width = 10;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Browse dir';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', ___NewProjectSourcePathListSettingRenderer_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___NewProjectSourcePathListSettingRenderer_Button1_click(event:flash.events.MouseEvent):Void {
		onBrowseSourceDir();
	}

	private function _NewProjectSourcePathListSettingRenderer_Rect1_c():spark.primitives.Rect {
		var temp:spark.primitives.Rect = new spark.primitives.Rect();
		temp.percentWidth = 100.0;
		temp.alpha = 1;
		temp.stroke = _NewProjectSourcePathListSettingRenderer_SolidColorStroke1_c();
		temp.initialized(this, null);
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_SolidColorStroke1_c():mx.graphics.SolidColorStroke {
		var temp:mx.graphics.SolidColorStroke = new mx.graphics.SolidColorStroke();
		temp.weight = 1;
		temp.color = 14342874;
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_Label2_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Main application file';
		temp.styleName = 'uiTextSettingsLabel';
		temp.setStyle('paddingTop', 19);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_HGroup2_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.paddingLeft = 15;
		temp.paddingBottom = 4;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_NewProjectSourcePathListSettingRenderer_TextInput2_i(), _NewProjectSourcePathListSettingRenderer_Spacer2_c(), _NewProjectSourcePathListSettingRenderer_Button2_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_TextInput2_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'uiTextSettingsValue';
		temp.percentHeight = 100.0;
		temp.buttonMode = true;
		temp.editable = false;
		temp.mouseChildren = false;
		temp.setStyle('borderVisible', false);
		temp.setStyle('contentBackgroundAlpha', 0);
		temp.setStyle('focusAlpha', 0);
		temp.id = 'pathFile';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		pathFile = temp;
		mx.binding.BindingManager.executeBindings(this, 'pathFile', pathFile);
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_Spacer2_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.width = 10;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewProjectSourcePathListSettingRenderer_Button2_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Browse file';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', ___NewProjectSourcePathListSettingRenderer_Button2_click);
		temp.id = '_NewProjectSourcePathListSettingRenderer_Button2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_NewProjectSourcePathListSettingRenderer_Button2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_NewProjectSourcePathListSettingRenderer_Button2', _NewProjectSourcePathListSettingRenderer_Button2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___NewProjectSourcePathListSettingRenderer_Button2_click(event:flash.events.MouseEvent):Void {
		onBrowseSourceFile();
	}

	//  binding mgmt
	private function _NewProjectSourcePathListSettingRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_NewProjectSourcePathListSettingRenderer_Label1.text');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (!setting.project.isLibraryProject);
				},
				null,
				'pathFile.enabled');

		result[2] = new mx.binding.Binding(this,
				function():Bool {
					return (!setting.project.isLibraryProject);
				},
				null,
				'_NewProjectSourcePathListSettingRenderer_Button2.enabled');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(NewProjectSourcePathListSettingRenderer)._watcherSetupUtil = watcherSetupUtil;
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