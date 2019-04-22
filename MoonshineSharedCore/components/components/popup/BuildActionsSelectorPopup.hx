/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      BuildActionsSelectorPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/BuildActionsSelectorPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package components.popup;

import actionScripts.plugin.build.vo.BuildActionVO;

import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.renderers.GeneralListRenderer;
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
import mx.collections.ArrayList;
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
import spark.components.DataGrid;
import spark.components.gridClasses.GridColumn;

@:meta(Event(name = 'actionSelected', type = 'flash.events.Event'))
//  begin class def
class BuildActionsSelectorPopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _BuildActionsSelectorPopup_Button2:spark.components.Button;

	/**
	 * @private
	 **/
	public var _BuildActionsSelectorPopup_Button3:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var dgActions:spark.components.DataGrid;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _BuildActionsSelectorPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_BuildActionsSelectorPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(BuildActionsSelectorPopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 600;
		this.height = 240;
		this.minWidth = 300;
		this.minHeight = 150;
		this.title = 'Select SDK';
		this.controlBarContent = [_BuildActionsSelectorPopup_Button1_c(), _BuildActionsSelectorPopup_Button2_i(), _BuildActionsSelectorPopup_Spacer1_c(), _BuildActionsSelectorPopup_Button3_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_BuildActionsSelectorPopup_Array2_c);

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
	//  <Script>, line 32 - 60

	@:meta(Bindable())
	public var actions:ArrayList;
	@:meta(Bindable())
	public var selectedItem:Dynamic;

	private function onDgActionsDoubleClick(event:MouseEvent):Void {
		dispatchEvent(new Event('actionSelected'));
		super.closeThis();
	}

	private function onBtnActionAddClick(event:MouseEvent):Void {
		var action:BuildActionVO = new BuildActionVO('Build', '');
		this.actions.addItem(action);
	}

	private function onBtnActionRemoveClick(event:MouseEvent):Void {
		if (dgActions.selectedIndex > -1) {
			this.actions.removeItemAt(dgActions.selectedIndex);
			selectedItem = null;
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _BuildActionsSelectorPopup_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = '+';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___BuildActionsSelectorPopup_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___BuildActionsSelectorPopup_Button1_click(event:flash.events.MouseEvent):Void {
		onBtnActionAddClick(event);
	}

	private function _BuildActionsSelectorPopup_Button2_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = '-';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___BuildActionsSelectorPopup_Button2_click);
		temp.id = '_BuildActionsSelectorPopup_Button2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_BuildActionsSelectorPopup_Button2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_BuildActionsSelectorPopup_Button2', _BuildActionsSelectorPopup_Button2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___BuildActionsSelectorPopup_Button2_click(event:flash.events.MouseEvent):Void {
		onBtnActionRemoveClick(event);
	}

	private function _BuildActionsSelectorPopup_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _BuildActionsSelectorPopup_Button3_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Select';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___BuildActionsSelectorPopup_Button3_click);
		temp.id = '_BuildActionsSelectorPopup_Button3';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_BuildActionsSelectorPopup_Button3 = temp;
		mx.binding.BindingManager.executeBindings(this, '_BuildActionsSelectorPopup_Button3', _BuildActionsSelectorPopup_Button3);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___BuildActionsSelectorPopup_Button3_click(event:flash.events.MouseEvent):Void {
		onDgActionsDoubleClick(event);
	}

	private function _BuildActionsSelectorPopup_Array2_c():Array<Dynamic> {
		var temp:Array<DataGrid> = [_BuildActionsSelectorPopup_DataGrid1_i()];
		return cast temp;
	}

	private function _BuildActionsSelectorPopup_DataGrid1_i():spark.components.DataGrid {
		var temp:spark.components.DataGrid = new spark.components.DataGrid();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.itemRenderer = _BuildActionsSelectorPopup_ClassFactory1_c();
		temp.sortableColumns = false;
		temp.editable = true;
		temp.rowHeight = 28;
		temp.columns = _BuildActionsSelectorPopup_ArrayList1_c();
		temp.setStyle('borderVisible', false);
		temp.setStyle('contentBackgroundColor', 14737632);
		temp.setStyle('selectionColor', 16185078);
		temp.setStyle('horizontalScrollPolicy', 'off');
		temp.id = 'dgActions';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		dgActions = temp;
		mx.binding.BindingManager.executeBindings(this, 'dgActions', dgActions);
		return temp;
	}

	private function _BuildActionsSelectorPopup_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = components.renderers.GeneralListRenderer;
		return temp;
	}

	private function _BuildActionsSelectorPopup_ArrayList1_c():mx.collections.ArrayList {
		var temp:mx.collections.ArrayList = new mx.collections.ArrayList();
		temp.source = [_BuildActionsSelectorPopup_GridColumn1_c(), _BuildActionsSelectorPopup_GridColumn2_c()];
		return temp;
	}

	private function _BuildActionsSelectorPopup_GridColumn1_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.headerText = 'Action name';
		temp.dataField = 'actionName';
		temp.width = 200;
		temp.minWidth = 200;
		temp.editable = true;
		return temp;
	}

	private function _BuildActionsSelectorPopup_GridColumn2_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.headerText = 'Action';
		temp.dataField = 'action';
		temp.editable = true;
		return temp;
	}

	//  binding mgmt
	private function _BuildActionsSelectorPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(dgActions.selectedItem, Bool));
				},
				null,
				'_BuildActionsSelectorPopup_Button2.enabled');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(dgActions.selectedItem, Bool));
				},
				null,
				'_BuildActionsSelectorPopup_Button3.enabled');

		result[2] = new mx.binding.Binding(this,
				null,
				null,
				'dgActions.dataProvider', 'actions');

		result[3] = new mx.binding.Binding(this,
				null,
				null,
				'dgActions.selectedItem', 'selectedItem');

		result[4] = new mx.binding.Binding(this,
				function():Dynamic {
					return dgActions.selectedItem;
				},
				function(_sourceFunctionReturnValue:Dynamic):Void {
					selectedItem = _sourceFunctionReturnValue;
				},
				'selectedItem');

		Reflect.setField(result[4], 'twoWayCounterpart', result[3]);

		Reflect.setField(result[3], 'isTwoWayPrimary', true);
		Reflect.setField(result[3], 'twoWayCounterpart', result[4]);

		return result;
	}

	private function _BuildActionsSelectorPopup_bindingExprs():Void {
		selectedItem = dgActions.selectedItem;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(BuildActionsSelectorPopup)._watcherSetupUtil = watcherSetupUtil;
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