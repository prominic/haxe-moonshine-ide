/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SelectOpenedFlexProject
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/SelectOpenedFlexProject.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.popup;

import actionScripts.plugin.project.ProjectType;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.FlexEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.ProjectVO;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.popup.SelectOpenedFlexProjectInnerClass0;
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
class SelectOpenedFlexProject extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btn_load:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lst_projects:spark.components.List;

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

		var bindings:Array<Dynamic> = _SelectOpenedFlexProject_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SelectOpenedFlexProjectWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SelectOpenedFlexProject, propertyName);
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
		this.controlBarContent = [_SelectOpenedFlexProject_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SelectOpenedFlexProject_Array2_c);

		// events
		this.addEventListener('creationComplete', ___SelectOpenedFlexProject_ResizableTitleWindow1_creationComplete);

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
	//  <Script>, line 30 - 92

	public static inline var PROJECT_SELECTED:String = 'PROJECT_SELECTED';
	public static inline var PROJECT_SELECTION_CANCELLED:String = 'PROJECT_SELECTION_CANCELLED';

	public var selectedProject:ProjectVO;
	public var projectType:Int = ProjectType.AS3PROJ_AS_AIR;

	@:meta(Bindable())
	private var projects:ArrayCollection;

	private var model:IDEModel = IDEModel.getInstance();

	override private function closeByCrossSign(event:Event):Void {
		dispatchEvent(new Event(PROJECT_SELECTION_CANCELLED));
		super.closeByCrossSign(event);
	}

	private function onProjectBuildRequest(event:MouseEvent):Void {
		if (!AS3.as(lst_projects.selectedItem, Bool)) {
			Alert.show('Please, select a Project to Build.', 'Error!');
		} else {
			selectedProject = AS3.as(lst_projects.selectedItem, ProjectVO);
			dispatchEvent(new Event(PROJECT_SELECTED));
			closeThis();
		}
	}

	private function onSelectOpenedFlexProjectCreationComplete(event:FlexEvent):Void {
		projects = new ArrayCollection(model.projects.source);
		projects.filterFunction = this.filterByProjectType;
		projects.refresh();
	}

	public function filterByProjectType(item:AS3ProjectVO):Bool {
		if (this.projectType == ProjectType.AS3PROJ_AS_AIR && !item.isRoyale) {
			return true;
		} else if (this.projectType == ProjectType.ROYALE && item.isRoyale) {
			return true;
		}

		return false;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _SelectOpenedFlexProject_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = ' Select & Continue';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', __btn_load_click);
		temp.id = 'btn_load';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btn_load = temp;
		mx.binding.BindingManager.executeBindings(this, 'btn_load', btn_load);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btn_load_click(event:flash.events.MouseEvent):Void {
		onProjectBuildRequest(event);
	}

	private function _SelectOpenedFlexProject_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_SelectOpenedFlexProject_VGroup1_i()];
		return cast temp;
	}

	private function _SelectOpenedFlexProject_VGroup1_i():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 10;
		temp.paddingLeft = 12;
		temp.paddingBottom = 13;
		temp.paddingTop = 9;
		temp.paddingRight = 13;
		temp.horizontalAlign = 'center';
		temp.mxmlContent = [_SelectOpenedFlexProject_List1_i()];
		temp.addEventListener('addedToStage', __vgProjects_addedToStage);
		temp.id = 'vgProjects';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		vgProjects = temp;
		mx.binding.BindingManager.executeBindings(this, 'vgProjects', vgProjects);
		return temp;
	}

	private function _SelectOpenedFlexProject_List1_i():spark.components.List {
		var temp:spark.components.List = new spark.components.List();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.doubleClickEnabled = true;
		temp.labelField = 'projectName';
		temp.itemRenderer = _SelectOpenedFlexProject_ClassFactory1_c();
		temp.setStyle('color', 15658734);
		temp.setStyle('contentBackgroundColor', 0);
		temp.setStyle('rollOverColor', 3750201);
		temp.setStyle('selectionColor', 12674488);
		temp.setStyle('alternatingItemColors', [4473924, 5065804]);
		temp.setStyle('borderVisible', false);
		temp.addEventListener('doubleClick', __lst_projects_doubleClick);
		temp.id = 'lst_projects';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lst_projects = temp;
		mx.binding.BindingManager.executeBindings(this, 'lst_projects', lst_projects);
		return temp;
	}

	private function _SelectOpenedFlexProject_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = components.popup.SelectOpenedFlexProjectInnerClass0;
		temp.properties = {
					'outerDocument': this
				};
		return temp;
	}

	/**
	 * @private
	 **/
	public function __lst_projects_doubleClick(event:flash.events.MouseEvent):Void {
		onProjectBuildRequest(event);
	}

	/**
	 * @private
	 **/
	public function __vgProjects_addedToStage(event:flash.events.Event):Void {
		title = 'Select Project to Build';
	}

	/**
	 * @private
	 **/
	public function ___SelectOpenedFlexProject_ResizableTitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onSelectOpenedFlexProjectCreationComplete(event);
	}

	//  binding mgmt
	private function _SelectOpenedFlexProject_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():mx.collections.IList {
					return (projects);
				},
				null,
				'lst_projects.dataProvider');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SelectOpenedFlexProject)._watcherSetupUtil = watcherSetupUtil;
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