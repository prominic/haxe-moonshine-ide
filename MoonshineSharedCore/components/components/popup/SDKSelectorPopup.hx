/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SDKSelectorPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/SDKSelectorPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.popup;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.locator.IDEModel;
import actionScripts.utils.SDKUtils;
import actionScripts.valueObjects.SDKReferenceVO;
import components.renderers.GeneralListRenderer;

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
import mx.events.FlexEvent;
import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.DataGrid;
import spark.components.gridClasses.GridColumn;

//  begin class def
class SDKSelectorPopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _SDKSelectorPopup_Button2:spark.components.Button;

	/**
	 * @private
	 **/
	public var _SDKSelectorPopup_Button3:spark.components.Button;

	/**
	 * @private
	 **/
	public var _SDKSelectorPopup_Button4:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var dgSDKs:spark.components.DataGrid;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SDKSelectorPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SDKSelectorPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SDKSelectorPopup, propertyName);
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
		this.controlBarContent = [_SDKSelectorPopup_Button1_c(), _SDKSelectorPopup_Button2_i(), _SDKSelectorPopup_Button3_i(), _SDKSelectorPopup_Spacer1_c(), _SDKSelectorPopup_Button4_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SDKSelectorPopup_Array2_c);

		// events
		this.addEventListener('creationComplete', ___SDKSelectorPopup_ResizableTitleWindow1_creationComplete);

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
	//  <Script>, line 30 - 118

	@:meta(Bindable())private var model:IDEModel = IDEModel.getInstance();

	private var sdkPathPopup:SDKDefinePopup;

	private function onCreateionCompletes():Void {
		dgSDKs.itemRenderer = new ClassFactory(GeneralListRenderer);
	}

	private function onSDKAddition(event:MouseEvent, isNew:Bool = true):Void {
		if (sdkPathPopup == null) {
			sdkPathPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SDKDefinePopup, true), SDKDefinePopup);
			sdkPathPopup.addEventListener(CloseEvent.CLOSE, onSDKPathPopupClosed);
			sdkPathPopup.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
			if (!isNew) {
				sdkPathPopup.editedSDKPath = AS3.as(dgSDKs.selectedItem, SDKReferenceVO);
			}
			PopUpManager.centerPopUp(sdkPathPopup);
		} else {
			PopUpManager.bringToFront(sdkPathPopup);
		}
	}

	private function onSDKPathPopupClosed(event:CloseEvent):Void {
		sdkPathPopup.removeEventListener(CloseEvent.CLOSE, onSDKPathPopupClosed);
		sdkPathPopup.removeEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
		sdkPathPopup = null;
	}

	private function onFlexSDKUpdated(event:ProjectEvent):Void {
		onSDKPathPopupClosed(null);

		// detects been new or edit situation
		if (Std.is(event.anObject, SDKReferenceVO)) {
			// edit sdk
			model.userSavedSDKs.refresh();
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED));
		} else {
			// add sdk
			// don't add if said sdk already added
			var tmp:SDKReferenceVO = SDKUtils.isSDKAlreadySaved(event.anObject);
			if (tmp != null) {
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED));
				dgSDKs.callLater(function():Void {
							dgSDKs.selectedItem = tmp;
						});
			} else {
				Alert.show('SDK is already added in the list.', 'Note!');
			}
		}
	}

	private function onSDKDeletion(event:MouseEvent):Void {
		model.userSavedSDKs.removeItem(dgSDKs.selectedItem);
		GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED));
	}

	private function onEntryDoubleClicked(event:MouseEvent):Void {
		dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, dgSDKs.selectedItem));
		super.closeThis();
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _SDKSelectorPopup_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = '+';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SDKSelectorPopup_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKSelectorPopup_Button1_click(event:flash.events.MouseEvent):Void {
		onSDKAddition(event, true);
	}

	private function _SDKSelectorPopup_Button2_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = '-';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SDKSelectorPopup_Button2_click);
		temp.id = '_SDKSelectorPopup_Button2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SDKSelectorPopup_Button2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SDKSelectorPopup_Button2', _SDKSelectorPopup_Button2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKSelectorPopup_Button2_click(event:flash.events.MouseEvent):Void {
		onSDKDeletion(event);
	}

	private function _SDKSelectorPopup_Button3_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Edit';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SDKSelectorPopup_Button3_click);
		temp.id = '_SDKSelectorPopup_Button3';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SDKSelectorPopup_Button3 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SDKSelectorPopup_Button3', _SDKSelectorPopup_Button3);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKSelectorPopup_Button3_click(event:flash.events.MouseEvent):Void {
		onSDKAddition(event, false);
	}

	private function _SDKSelectorPopup_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SDKSelectorPopup_Button4_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Select';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SDKSelectorPopup_Button4_click);
		temp.id = '_SDKSelectorPopup_Button4';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SDKSelectorPopup_Button4 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SDKSelectorPopup_Button4', _SDKSelectorPopup_Button4);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SDKSelectorPopup_Button4_click(event:flash.events.MouseEvent):Void {
		onEntryDoubleClicked(event);
	}

	private function _SDKSelectorPopup_Array2_c():Array<Dynamic> {
		var temp:Array<DataGrid> = [_SDKSelectorPopup_DataGrid1_i()];
		return cast temp;
	}

	private function _SDKSelectorPopup_DataGrid1_i():spark.components.DataGrid {
		var temp:spark.components.DataGrid = new spark.components.DataGrid();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.sortableColumns = false;
		temp.doubleClickEnabled = true;
		temp.rowHeight = 28;
		temp.columns = _SDKSelectorPopup_ArrayList1_c();
		temp.setStyle('borderVisible', false);
		temp.setStyle('contentBackgroundColor', 14737632);
		temp.setStyle('selectionColor', 16185078);
		temp.setStyle('horizontalScrollPolicy', 'off');
		temp.addEventListener('doubleClick', __dgSDKs_doubleClick);
		temp.id = 'dgSDKs';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		dgSDKs = temp;
		mx.binding.BindingManager.executeBindings(this, 'dgSDKs', dgSDKs);
		return temp;
	}

	private function _SDKSelectorPopup_ArrayList1_c():mx.collections.ArrayList {
		var temp:mx.collections.ArrayList = new mx.collections.ArrayList();
		temp.source = [_SDKSelectorPopup_GridColumn1_c(), _SDKSelectorPopup_GridColumn2_c(), _SDKSelectorPopup_GridColumn3_c()];
		return temp;
	}

	private function _SDKSelectorPopup_GridColumn1_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.headerText = 'Description';
		temp.dataField = 'name';
		temp.dataTipField = 'name';
		temp.minWidth = 295;
		return temp;
	}

	private function _SDKSelectorPopup_GridColumn2_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.headerText = 'Path';
		temp.dataField = 'path';
		temp.dataTipField = 'path';
		temp.minWidth = 200;
		return temp;
	}

	private function _SDKSelectorPopup_GridColumn3_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.headerText = '';
		temp.dataField = 'status';
		temp.dataTipField = 'status';
		temp.minWidth = 60;
		return temp;
	}

	/**
	 * @private
	 **/
	public function __dgSDKs_doubleClick(event:flash.events.MouseEvent):Void {
		onEntryDoubleClicked(event);
	}

	/**
	 * @private
	 **/
	public function ___SDKSelectorPopup_ResizableTitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreateionCompletes();
	}

	//  binding mgmt
	private function _SDKSelectorPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(dgSDKs.selectedItem, Bool) && dgSDKs.selectedItem.status != SDKUtils.BUNDLED);
				},
				null,
				'_SDKSelectorPopup_Button2.enabled');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(dgSDKs.selectedItem, Bool) && dgSDKs.selectedItem.status != SDKUtils.BUNDLED);
				},
				null,
				'_SDKSelectorPopup_Button3.enabled');

		result[2] = new mx.binding.Binding(this,
				function():Bool {
					return (AS3.as(dgSDKs.selectedItem, Bool));
				},
				null,
				'_SDKSelectorPopup_Button4.enabled');

		result[3] = new mx.binding.Binding(this,
				function():mx.collections.IList {
					return (model.userSavedSDKs);
				},
				null,
				'dgSDKs.dataProvider');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SDKSelectorPopup)._watcherSetupUtil = watcherSetupUtil;
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