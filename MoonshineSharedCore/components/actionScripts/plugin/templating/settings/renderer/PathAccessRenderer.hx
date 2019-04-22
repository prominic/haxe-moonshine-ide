/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.templating.settings.renderer
 *  Class:      PathAccessRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/templating/settings/renderer/PathAccessRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package actionScripts.plugin.templating.settings.renderer;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.ResizeEvent;
import mx.events.ToolTipEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.templating.settings.PathAccessSetting;
import actionScripts.utils.UtilsCore;

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
import mx.events.FlexEvent;

import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.HGroup;
import spark.components.Image;
import spark.components.Label;
import spark.components.VGroup;

//  begin class def
class PathAccessRenderer extends spark.components.VGroup implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var imgError:spark.components.Image;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtPath:spark.components.Label;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _PathAccessRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_templating_settings_renderer_PathAccessRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(PathAccessRenderer, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.paddingLeft = 15;
		this.paddingTop = 5;
		this.paddingRight = 15;
		this.paddingBottom = 5;
		this.visible = true;
		this.mxmlContent = [_PathAccessRenderer_HGroup1_c()];

		// events
		this.addEventListener('creationComplete', ___PathAccessRenderer_VGroup1_creationComplete);
		this.addEventListener('resize', ___PathAccessRenderer_VGroup1_resize);

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
	//  <Script>, line 35 - 161

	public static inline var EVENT_REFRESH:String = 'refresh';

	@:meta(Bindable())public var setting:PathAccessSetting;

	private var path:String = '';
	private var model:IDEModel = IDEModel.getInstance();

	private function init():Void {
		imgError.addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
		imgError.addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);

		tripPathValue();
	}

	private function tripPathValue():Void {
		// we shall show relative paths for those who exists.
		// setting.project will only be true if the path is exist.
		// therefore we'll compare the path with setting.project
		if (AS3.as(setting.originalPath.fileBridge.exists, Bool)) {
			path = Std.string(setting.project.folderLocation.fileBridge.getRelativePath(setting.originalPath, true));
		} else {
			path = Std.string(setting.originalPath.fileBridge.nativePath);
		}

		// even if the path comes blank, in case of project.getRelativePath(project)
		if (path == '') {
			path = Std.string(setting.originalPath.fileBridge.nativePath);
		}

		onResizeEvent(null);
	}

	private function onAddPermission(event:MouseEvent):Void {
		function onTypeSelected(event:CloseEvent):Void {
			Alert.yesLabel = 'Yes';
			Alert.cancelLabel = 'Cancel';

			if (event.detail == Alert.CANCEL) {
				model.fileCore.browseForDirectory('Select Directory', openNewAccess, newAccessCancelled, tmpStartLocation.fileBridge.nativePath);
			} else {
				model.fileCore.browseForOpen('Select File', openNewAccess, newAccessCancelled, null, tmpStartLocation.fileBridge.nativePath);
			}
		};
		var tmpStartLocation:FileLocation = setting.originalPath;
		if (setting.isLocalePath) {
			var tmpPathArr:Array<Dynamic> = setting.originalPath.fileBridge.nativePath.split(setting.originalPath.fileBridge.separator);
			tmpPathArr.splice(tmpPathArr.length - 1, 1);
			var tmpLocaleLocation:FileLocation = new FileLocation(tmpPathArr.join(Std.string(setting.originalPath.fileBridge.separator)));
			if (AS3.as(tmpLocaleLocation.fileBridge.exists, Bool)) {
				tmpStartLocation = tmpLocaleLocation;
			}
		}

		/* AS3HX WARNING namespace modifier CONFIG::OSX */{
			model.fileCore.browseForDirectory('Select Directory', openNewAccess, newAccessCancelled, tmpStartLocation.fileBridge.nativePath);
			return;
		} /*
		 *@local
		 */

		// in @development cases
		if (!AS3.as(tmpStartLocation.fileBridge.exists, Bool)) {
			Alert.yesLabel = 'File';
			Alert.cancelLabel = 'Folder';
			Alert.show('Please choose selection type', 'Type Selection', Alert.YES | Alert.CANCEL, null, onTypeSelected, null, 0);
		} else if (AS3.as(tmpStartLocation.fileBridge.isDirectory, Bool) || setting.isLocalePath) {
			model.fileCore.browseForDirectory('Select Directory', openNewAccess, newAccessCancelled, tmpStartLocation.fileBridge.nativePath);
		} else {
			model.fileCore.browseForOpen('Select File', openNewAccess, newAccessCancelled, null, tmpStartLocation.fileBridge.nativePath);
		}
	}

	private function openNewAccess(fileDir:Dynamic):Void {
		// jhar khachhe at FlashBuilderExporter.export in defineFolderAccess.mxml - jokon file path has /{locale}
		// same thing chk korar somoy with non-{locale}, file chooser khulche file selection mode e - eta hochhe jokon file.exists = false, ebong
		// file.isdirectory always coming false at that time, in onAddPermission() method above

		var finalPath:String = AS3.string(Reflect.field(fileDir, 'nativePath'));
		if (setting.isLocalePath) {
			finalPath += setting.originalPath.fileBridge.separator + '{locale}';
		}

		setting.originalPath.fileBridge.nativePath = finalPath;
		dispatchEvent(new Event(EVENT_REFRESH));
	}

	private function newAccessCancelled():Void {}

	private function onResizeEvent(event:ResizeEvent):Void {
		function updatePathWithValue(value:String):Void {
			txtPath.callLater(function():Void {
						txtPath.text = value;
					});
		};
		var thisWidthChar:Int = Math.floor(width / 8);
		var availableWidthByChar:Int = thisWidthChar - 13; /*
		 * @local
		 */ // 100/8
		if (path.length > availableWidthByChar) {
			var lastPart:String = Std.string(path.substring(path.length - (availableWidthByChar - 4)));
			updatePathWithValue('....' + lastPart);
		} else {
			updatePathWithValue(path);
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _PathAccessRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_PathAccessRenderer_Label1_i(), _PathAccessRenderer_Image1_i(), _PathAccessRenderer_Button1_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _PathAccessRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsValue';
		temp.percentWidth = 100.0;
		temp.setStyle('paddingRight', 20);
		temp.id = 'txtPath';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtPath = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtPath', txtPath);
		return temp;
	}

	private function _PathAccessRenderer_Image1_i():spark.components.Image {
		var temp:spark.components.Image = new spark.components.Image();
		temp.source = _embed_mxml__elements_images_iconExclamationRed_png_1685577265;
		temp.id = 'imgError';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		imgError = temp;
		mx.binding.BindingManager.executeBindings(this, 'imgError', imgError);
		return temp;
	}

	private function _PathAccessRenderer_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Add';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', ___PathAccessRenderer_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___PathAccessRenderer_Button1_click(event:flash.events.MouseEvent):Void {
		onAddPermission(event);
	}

	/**
	 * @private
	 **/
	public function ___PathAccessRenderer_VGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		init();
	}

	/**
	 * @private
	 **/
	public function ___PathAccessRenderer_VGroup1_resize(event:mx.events.ResizeEvent):Void {
		onResizeEvent(event);
	}

	//  binding mgmt
	private function _PathAccessRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.errorType);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'imgError.toolTip');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(PathAccessRenderer)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	@:meta(Embed(source = '/elements/images/iconExclamationRed.png'))
	private var _embed_mxml__elements_images_iconExclamationRed_png_1685577265:Class<Dynamic>;

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