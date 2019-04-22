/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugins.vscodeDebug.view
 *  Class:      VSCodeDebugProtocolView
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineDESKTOPevolved/src/actionScripts/plugins/vscodeDebug/view/VSCodeDebugProtocolView.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:13:59 MSK
 */

package actionScripts.plugins.vscodeDebug.view;

import mx.collections.ICollectionView;
import mx.collections.IHierarchicalData;
import mx.events.AdvancedDataGridEvent;
import mx.events.ListEvent;
import actionScripts.plugins.vscodeDebug.events.LoadVariablesEvent;
import actionScripts.plugins.vscodeDebug.events.StackFrameEvent;
import actionScripts.plugins.vscodeDebug.vo.BaseVariablesReference;
import actionScripts.plugins.vscodeDebug.vo.StackFrame;
import actionScripts.plugins.vscodeDebug.vo.Variable;

import haxe.Constraints.Function;
import actionScripts.interfaces.IViewWithTitle;
import flash.accessibility.*;
import flash.data.*;
import flash.debugger.*;
import flash.desktop.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filesystem.*;
import flash.filters.*;
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
import mx.containers.HBox;
import mx.controls.AdvancedDataGrid;
import mx.controls.DataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponent;
import mx.core.UIComponentDescriptor;
import mx.core.Mx_internal;

import mx.skins.ProgrammaticSkin;
import mx.styles.*;
import spark.components.Button;
import spark.components.VGroup;
import spark.containers.HDividerGroup;

@:meta(Event(name = 'loadVariables', type = 'actionScripts.plugins.vscodeDebug.events.LoadVariablesEvent'))
class VSCodeDebugProtocolView extends mx.containers.HBox implements actionScripts.interfaces.IViewWithTitle implements mx.binding.IBindingClient {

	/**
	 * @private
	 **/
	public var _VSCodeDebugProtocolView_AdvancedDataGridColumn2:mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

	/**
	 * @private
	 **/
	public var _VSCodeDebugProtocolView_DataGridColumn1:mx.controls.dataGridClasses.DataGridColumn;

	/**
	 * @private
	 **/
	public var _VSCodeDebugProtocolView_DataGridColumn2:mx.controls.dataGridClasses.DataGridColumn;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var callStackList:mx.controls.DataGrid;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var pauseButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var playButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var stepIntoButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var stepOutButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var stepOverButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var stopButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var variablesTree:mx.controls.AdvancedDataGrid;

	private var _documentDescriptor_:mx.core.UIComponentDescriptor;

	/**
	 * @private
	 **/
	public function new() {
		this._documentDescriptor_ =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.HBox,
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': spark.components.VGroup,
								'propertiesFactory': function():Dynamic {
									return {
										'gap': 4,
										'horizontalAlign': 'center',
										'verticalAlign': 'top',
										'percentHeight': 100,
										'width': 35,
										'paddingTop': 4,
										'mxmlContent': [this._VSCodeDebugProtocolView_Button1_i(), this._VSCodeDebugProtocolView_Button2_i(), this._VSCodeDebugProtocolView_Button3_i(), this._VSCodeDebugProtocolView_Button4_i(), this._VSCodeDebugProtocolView_Button5_i(), this._VSCodeDebugProtocolView_Button6_i()]
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': spark.containers.HDividerGroup,
								'propertiesFactory': function():Dynamic {
									return {
										'gap': 1,
										'percentWidth': 100,
										'percentHeight': 100,
										'children': [this._VSCodeDebugProtocolView_AdvancedDataGrid1_i(), this._VSCodeDebugProtocolView_DataGrid1_i()]
									};
								}
							})
				]
						};
					}
				});
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _VSCodeDebugProtocolView_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugins_vscodeDebug_view_VSCodeDebugProtocolViewWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(VSCodeDebugProtocolView, propertyName);
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
					this.horizontalGap = 2;
					this.backgroundColor = 4473924;
				};
		// ambient styles
		// mx_internal::_VSCodeDebugProtocolView_StylesInit();

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
	public var stackFrames:ICollectionView;

	@:meta(Bindable())
	public var scopesAndVars:IHierarchicalData;

	public var title(get, never):String;
	private function get_title():String {
		return 'Debug';
	}

	private function variablesValueLabelFunction(item:Dynamic, column:AdvancedDataGridColumn = null):String {
		if (Std.is(item, Variable)) {
			return Std.string(Variable(item).value);
		}
		return '';
	}

	private function lineLabelFunction(item:StackFrame, column:DataGridColumn = null):String {
		if (item.source != null) {
			return Std.string(Std.string(item.line));
		}
		return '';
	}

	private function nameDataTipFunction(item:StackFrame):String {
		var result:String = item.name;
		if (item.source != null) {
			result += ' (' + item.line + ',' + item.column + ')';
			result += '\n' + item.source.path;
		}
		return result;
	}

	private function variablesTree_itemOpenHandler(event:AdvancedDataGridEvent):Void {
		var item:BaseVariablesReference = BaseVariablesReference(event.item);
		if (this.scopesAndVars.hasChildren(item)) {
			this.dispatchEvent(new LoadVariablesEvent(LoadVariablesEvent.LOAD_VARIABLES, item));
		}
	}

	private function callStackList_itemClickHandler(event:ListEvent):Void {
		var stackFrame:StackFrame = StackFrame(event.itemRenderer.data);
		this.dispatchEvent(new StackFrameEvent(StackFrameEvent.GOTO_STACK_FRAME, stackFrame));
	}

	//  supporting function definitions for properties, events, styles, effects
	private function _VSCodeDebugProtocolView_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugPlayButton';
		temp.toolTip = 'Play';
		temp.enabled = false;
		temp.id = 'playButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		playButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'playButton', playButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_Button2_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugPauseButton';
		temp.toolTip = 'Pause';
		temp.enabled = false;
		temp.id = 'pauseButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		pauseButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'pauseButton', pauseButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_Button3_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugStepOverButton';
		temp.toolTip = 'Step Over';
		temp.enabled = false;
		temp.id = 'stepOverButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		stepOverButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'stepOverButton', stepOverButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_Button4_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugStepIntoButton';
		temp.toolTip = 'Step Into';
		temp.enabled = false;
		temp.id = 'stepIntoButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		stepIntoButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'stepIntoButton', stepIntoButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_Button5_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugStepOutButton';
		temp.toolTip = 'Step Out';
		temp.enabled = false;
		temp.id = 'stepOutButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		stepOutButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'stepOutButton', stepOutButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_Button6_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.styleName = 'debugStopButton';
		temp.toolTip = 'Stop';
		temp.enabled = false;
		temp.id = 'stopButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		stopButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'stopButton', stopButton);
		return temp;
	}

	private function _VSCodeDebugProtocolView_AdvancedDataGrid1_i():mx.controls.AdvancedDataGrid {
		var temp:mx.controls.AdvancedDataGrid = new mx.controls.AdvancedDataGrid();
		temp.percentWidth = 50;
		temp.percentHeight = 100;
		temp.draggableColumns = false;
		temp.sortableColumns = false;
		temp.sortExpertMode = true;
		temp.sortItemRenderer = _VSCodeDebugProtocolView_ClassFactory1_c();
		temp.columns = cast [_VSCodeDebugProtocolView_AdvancedDataGridColumn1_c(), _VSCodeDebugProtocolView_AdvancedDataGridColumn2_i()];
		temp.setStyle('color', 14737632);
		temp.setStyle('fontSize', 11);
		temp.setStyle('verticalScrollBarStyleName', 'black');
		temp.setStyle('contentBackgroundColor', 0);
		temp.setStyle('textRollOverColor', 16777215);
		temp.setStyle('rollOverColor', 3750201);
		temp.setStyle('selectionColor', 3750201);
		temp.setStyle('alternatingItemColors', [4473924, 5065804]);
		temp.setStyle('textSelectedColor', 14737632);
		temp.setStyle('borderVisible', false);
		temp.setStyle('useRollOver', true);
		temp.setStyle('headerColors', [6974058, 3158064]);
		temp.setStyle('headerStyleName', 'variablesTreeHeaderStyles');
		temp.setStyle('headerSortSeparatorSkin', mx.skins.ProgrammaticSkin);
		temp.setStyle('chromeColor', 3750201);
		temp.addEventListener('itemOpen', __variablesTree_itemOpen);
		temp.id = 'variablesTree';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		variablesTree = temp;
		mx.binding.BindingManager.executeBindings(this, 'variablesTree', variablesTree);
		return temp;
	}

	private function _VSCodeDebugProtocolView_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = mx.core.UIComponent;
		return temp;
	}

	private function _VSCodeDebugProtocolView_AdvancedDataGridColumn1_c():mx.controls.advancedDataGridClasses.AdvancedDataGridColumn {
		var temp:mx.controls.advancedDataGridClasses.AdvancedDataGridColumn = new mx.controls.advancedDataGridClasses.AdvancedDataGridColumn();
		temp.headerText = 'Variables';
		temp.dataField = 'name';
		temp.headerWordWrap = '';
		temp.showDataTips = true;
		temp.dataTipField = 'type';
		return temp;
	}

	private function _VSCodeDebugProtocolView_AdvancedDataGridColumn2_i():mx.controls.advancedDataGridClasses.AdvancedDataGridColumn {
		var temp:mx.controls.advancedDataGridClasses.AdvancedDataGridColumn = new mx.controls.advancedDataGridClasses.AdvancedDataGridColumn();
		temp.headerText = 'Values';
		temp.showDataTips = true;
		_VSCodeDebugProtocolView_AdvancedDataGridColumn2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_VSCodeDebugProtocolView_AdvancedDataGridColumn2', _VSCodeDebugProtocolView_AdvancedDataGridColumn2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __variablesTree_itemOpen(event:mx.events.AdvancedDataGridEvent):Void {
		variablesTree_itemOpenHandler(event);
	}

	private function _VSCodeDebugProtocolView_DataGrid1_i():mx.controls.DataGrid {
		var temp:mx.controls.DataGrid = new mx.controls.DataGrid();
		temp.percentWidth = 50;
		temp.percentHeight = 100;
		temp.draggableColumns = false;
		temp.sortableColumns = false;
		temp.columns = [_VSCodeDebugProtocolView_DataGridColumn1_i(), _VSCodeDebugProtocolView_DataGridColumn2_i()];
		temp.setStyle('color', 14737632);
		temp.setStyle('fontSize', 11);
		temp.setStyle('contentBackgroundColor', 0);
		temp.setStyle('textRollOverColor', 16777215);
		temp.setStyle('rollOverColor', 3750201);
		temp.setStyle('selectionColor', 3750201);
		temp.setStyle('alternatingItemColors', [4473924, 5065804]);
		temp.setStyle('textSelectedColor', 14737632);
		temp.setStyle('borderVisible', false);
		temp.setStyle('useRollOver', true);
		temp.setStyle('chromeColor', 3750201);
		temp.setStyle('verticalScrollBarStyleName', 'black');
		temp.addEventListener('itemClick', __callStackList_itemClick);
		temp.id = 'callStackList';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		callStackList = temp;
		mx.binding.BindingManager.executeBindings(this, 'callStackList', callStackList);
		return temp;
	}

	private function _VSCodeDebugProtocolView_DataGridColumn1_i():mx.controls.dataGridClasses.DataGridColumn {
		var temp:mx.controls.dataGridClasses.DataGridColumn = new mx.controls.dataGridClasses.DataGridColumn();
		temp.headerText = 'Frames';
		temp.dataField = 'name';
		temp.dataTipField = 'source';
		temp.showDataTips = true;
		_VSCodeDebugProtocolView_DataGridColumn1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_VSCodeDebugProtocolView_DataGridColumn1', _VSCodeDebugProtocolView_DataGridColumn1);
		return temp;
	}

	private function _VSCodeDebugProtocolView_DataGridColumn2_i():mx.controls.dataGridClasses.DataGridColumn {
		var temp:mx.controls.dataGridClasses.DataGridColumn = new mx.controls.dataGridClasses.DataGridColumn();
		temp.headerText = 'Line';
		temp.width = 50;
		_VSCodeDebugProtocolView_DataGridColumn2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_VSCodeDebugProtocolView_DataGridColumn2', _VSCodeDebugProtocolView_DataGridColumn2);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __callStackList_itemClick(event:mx.events.ListEvent):Void {
		callStackList_itemClickHandler(event);
	}

	//  binding mgmt
	private function _VSCodeDebugProtocolView_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'variablesTree.dataProvider', 'scopesAndVars');

		result[1] = new mx.binding.Binding(this,
				function():Function {
					return (variablesValueLabelFunction);
				},
				null,
				'_VSCodeDebugProtocolView_AdvancedDataGridColumn2.labelFunction');

		result[2] = new mx.binding.Binding(this,
				function():Function {
					return (variablesValueLabelFunction);
				},
				null,
				'_VSCodeDebugProtocolView_AdvancedDataGridColumn2.dataTipFunction');

		result[3] = new mx.binding.Binding(this,
				null,
				null,
				'callStackList.dataProvider', 'stackFrames');

		result[4] = new mx.binding.Binding(this,
				function():Function {
					return (nameDataTipFunction);
				},
				null,
				'_VSCodeDebugProtocolView_DataGridColumn1.dataTipFunction');

		result[5] = new mx.binding.Binding(this,
				function():Function {
					return (lineLabelFunction);
				},
				null,
				'_VSCodeDebugProtocolView_DataGridColumn2.labelFunction');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(VSCodeDebugProtocolView)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	@:ns('mx_internal') private var _VSCodeDebugProtocolView_StylesInit_done:Bool = false;

	@:ns('mx_internal') private function _VSCodeDebugProtocolView_StylesInit():Void {
		//  only add our style defs to the style manager once
		if ( //  mx_internal::_VSCodeDebugProtocolView_StylesInit_done) {
			return;
		} else {
			// mx_internal::_VSCodeDebugProtocolView_StylesInit_done = true;
		}

		var style:CSSStyleDeclaration;
		var effects:Array<Dynamic>;

		var conditions:Array<Dynamic>;
		var condition:CSSCondition;
		var selector:CSSSelector;
		selector = null;
		conditions = null;
		conditions = [];
		condition = new CSSCondition('class', 'variablesTreeHeaderStyles');
		conditions.push(condition);
		selector = new CSSSelector('', conditions, selector);
		// .variablesTreeHeaderStyles
		style = styleManager.getStyleDeclaration('.variablesTreeHeaderStyles');
		if (style == null) {
			style = new CSSStyleDeclaration(selector, styleManager);
		}

		if (style.factory == null) {
			style.factory = function():Void {
						this.horizontalGap = 0;
						this.color = 0xe0e0e0;
						this.horizontalAlign = 'left';
					};
		}

	}

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