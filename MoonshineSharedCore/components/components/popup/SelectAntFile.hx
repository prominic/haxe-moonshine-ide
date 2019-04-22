/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SelectAntFile
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/SelectAntFile.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.popup;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Image;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.popup.SelectAntFileInnerClass0;
import components.skins.ResizableTitleWindowSkin;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.Event;
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
import spark.components.List;
import spark.components.VGroup;

//  begin class def
class SelectAntFile extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btn_select:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lst_Ant:spark.components.List;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var vgProjects:spark.components.VGroup;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SelectAntFile_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SelectAntFileWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SelectAntFile, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 500;
		this.height = 230;
		this.controlBarContent = [_SelectAntFile_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SelectAntFile_Array2_c);

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
	//  <Script>, line 29 - 80

	public static inline var ANTFILE_SELECTED:String = 'ANTFILE_SELECTED';
	public static inline var ANTFILE_SELECTION_CANCELLED:String = 'ANTFILE_SELECTION_CANCELLED';

	public var selectedAntFile:FileLocation;

	@:meta(Bindable())private var _antFiles:ArrayCollection = new ArrayCollection();

	private var model:IDEModel = IDEModel.getInstance();
	private var loaderIcon:Image;

	override private function closeByCrossSign(event:Event):Void {
		dispatchEvent(new Event(ANTFILE_SELECTION_CANCELLED));
		super.closeByCrossSign(event);
	}

	@:meta(Bindable())
	public var antFiles(get, set):ArrayCollection;
	private function set_antFiles(value:ArrayCollection):ArrayCollection {
		_antFiles = value;
		return value;
	}

	private function get_antFiles():ArrayCollection {
		return _antFiles;
	}

	private function onAntBuildRequest(event:MouseEvent):Void {
		if (!AS3.as(lst_Ant.selectedItem, Bool)) {
			Alert.show('Please, selet a Ant File to Build.', 'Error!');
		} else {
			selectedAntFile = AS3.as(lst_Ant.selectedItem, FileLocation);
			dispatchEvent(new Event(ANTFILE_SELECTED));
			closeThis();
		}
	}

	private function lst_AntLableFun(item:Dynamic):String {
		return AS3.string(Reflect.field(Reflect.field(item, 'fileBridge'), 'name'));
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _SelectAntFile_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = ' Select & Continue';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', __btn_select_click);
		temp.id = 'btn_select';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btn_select = temp;
		mx.binding.BindingManager.executeBindings(this, 'btn_select', btn_select);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btn_select_click(event:flash.events.MouseEvent):Void {
		onAntBuildRequest(event);
	}

	private function _SelectAntFile_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_SelectAntFile_VGroup1_i()];
		return cast temp;
	}

	private function _SelectAntFile_VGroup1_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 10;
		temp.paddingLeft = 12;
		temp.paddingBottom = 13;
		temp.paddingTop = 9;
		temp.paddingRight = 13;
		temp.horizontalAlign = 'center';
		temp.mxmlContent = [_SelectAntFile_List1_i()];
		temp.addEventListener('addedToStage', __vgProjects_addedToStage);
		temp.id = 'vgProjects';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		vgProjects = temp;
		mx.binding.BindingManager.executeBindings(this, 'vgProjects', vgProjects);
		return temp;
	}

	private function _SelectAntFile_List1_i():spark.components.List {
		var temp:spark.components.List = new spark.components.List();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.doubleClickEnabled = true;
		temp.labelFunction = lst_AntLableFun;
		temp.itemRenderer = _SelectAntFile_ClassFactory1_c();
		temp.setStyle('color', 15658734);
		temp.setStyle('contentBackgroundColor', 0);
		temp.setStyle('rollOverColor', 3750201);
		temp.setStyle('selectionColor', 12674488);
		temp.setStyle('alternatingItemColors', [4473924, 5065804]);
		temp.setStyle('borderVisible', false);
		temp.addEventListener('doubleClick', __lst_Ant_doubleClick);
		temp.id = 'lst_Ant';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lst_Ant = temp;
		mx.binding.BindingManager.executeBindings(this, 'lst_Ant', lst_Ant);
		return temp;
	}

	private function _SelectAntFile_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = components.popup.SelectAntFileInnerClass0;
		temp.properties = {
					'outerDocument': this
				};
		return temp;
	}

	/**
	 * @private
	 **/
	public function __lst_Ant_doubleClick(event:flash.events.MouseEvent):Void {
		onAntBuildRequest(event);
	}

	/**
	 * @private
	 **/
	public function __vgProjects_addedToStage(event:flash.events.Event):Void {
		title = 'Select Ant File to Build';
	}

	//  binding mgmt
	private function _SelectAntFile_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'lst_Ant.dataProvider', 'antFiles');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SelectAntFile)._watcherSetupUtil = watcherSetupUtil;
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