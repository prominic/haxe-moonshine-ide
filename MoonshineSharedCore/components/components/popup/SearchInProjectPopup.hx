/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SearchInProjectPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/SearchInProjectPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package components.popup;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.search.SearchPlugin;

import actionScripts.plugin.findreplace.view.PromptTextInput;
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
import spark.components.CheckBox;
import spark.components.DropDownList;
import spark.components.HGroup;
import spark.components.Label;
import spark.components.RadioButton;
import spark.components.RadioButtonGroup;
import spark.components.VGroup;

//  begin class def
class SearchInProjectPopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _SearchInProjectPopup_RadioButton1:spark.components.RadioButton;

	/**
	 * @private
	 **/
	public var _SearchInProjectPopup_RadioButton2:spark.components.RadioButton;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var cbEnclosingProjects:spark.components.CheckBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var ddlProjects:spark.components.DropDownList;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var optionEscapeChars:spark.components.CheckBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var optionMatchCase:spark.components.CheckBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var optionRegExp:spark.components.CheckBox;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var rbgScope:spark.components.RadioButtonGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtPatterns:actionScripts.plugin.findreplace.view.PromptTextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtSearch:actionScripts.plugin.findreplace.view.PromptTextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SearchInProjectPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SearchInProjectPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SearchInProjectPopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 500;
		this.minWidth = 400;
		this.minHeight = 200;
		this.autoLayout = true;
		this.title = 'Search';
		this.controlBarContent = [_SearchInProjectPopup_Spacer1_c(), _SearchInProjectPopup_Button1_c(), _SearchInProjectPopup_Button2_c()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_SearchInProjectPopup_Array2_c);
		_SearchInProjectPopup_RadioButtonGroup1_i();

		// events
		this.addEventListener('creationComplete', ___SearchInProjectPopup_ResizableTitleWindow1_creationComplete);

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
	//  <Script>, line 31 - 111

	public var isClosedAsSubmit:Bool = false;
	public var isShowReplaceWhenDone:Bool = false;

	@:meta(Bindable())private var model:IDEModel = IDEModel.getInstance();

	private function onSearchRequest(showReplaceWhenDone:Bool = false):Void {
		if (StringTools.trim(txtSearch.text).length != 0) {
			isShowReplaceWhenDone = showReplaceWhenDone;
			isClosedAsSubmit = true;
			closeThis();
		}
	}

	private function onInitialized(event:FlexEvent):Void {
		if (SearchPlugin.LAST_SEARCH != null) {
			txtSearch.text = SearchPlugin.LAST_SEARCH;
			txtSearch.selectRange(0, txtSearch.text.length);
			txtSearch.setFocus();
		}

		var tmpIndex:Int = -1;
		if (SearchPlugin.LAST_SELECTED_PROJECT != null) {
			tmpIndex = AS3.int(model.projects.getItemIndex(SearchPlugin.LAST_SELECTED_PROJECT));
		} else if (model.activeProject != null) {
			tmpIndex = AS3.int(model.projects.getItemIndex(model.activeProject));
		}
		if (tmpIndex != -1) {
			ddlProjects.selectedIndex = tmpIndex;
		}

		rbgScope.selectedIndex = SearchPlugin.LAST_SCOPE_INDEX;
		cbEnclosingProjects.selected = SearchPlugin.LAST_SELECTED_SCOPE_ENCLOSING_PROJECTS;
		updatePatterns(SearchPlugin.LAST_SELECTED_PATTERNS);
	}

	private function onSelectPatterns(event:MouseEvent):Void {
		var patternPopup:SearchPatternsPopup = AS3.as(PopUpManager.createPopUp(AS3.as(FlexGlobals.topLevelApplication, DisplayObject), SearchPatternsPopup, true), SearchPatternsPopup);
		if (SearchPlugin.LAST_SELECTED_PATTERNS != null) {
			patternPopup.patterns = SearchPlugin.LAST_SELECTED_PATTERNS;
			SearchPlugin.LAST_SELECTED_PATTERNS = null;
		}
		patternPopup.addEventListener(CloseEvent.CLOSE, onPatternsPopupClosed);
		PopUpManager.centerPopUp(patternPopup);
	}

	private function onPatternsPopupClosed(event:CloseEvent):Void {
		event.target.removeEventListener(CloseEvent.CLOSE, onPatternsPopupClosed);
		updatePatterns(AS3.as(ObjectUtil.clone(SearchPatternsPopup(event.target).patterns), ArrayCollection));
	}

	private function updatePatterns(collection:ArrayCollection):Void {
		var tmpArr:Array<Dynamic> = [];
		for (i in collection) {
			if (AS3.as(Reflect.field(i, 'isSelected'), Bool)) {
				tmpArr.push(Reflect.field(i, 'label'));
			}
		}

		if (tmpArr.length > 0) {
			txtPatterns.text = tmpArr.join(', ');
			SearchPlugin.LAST_SELECTED_PATTERNS = collection;
		} else {
			txtPatterns.text = '*';
		}
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _SearchInProjectPopup_RadioButtonGroup1_i():spark.components.RadioButtonGroup {
		var temp:spark.components.RadioButtonGroup = new spark.components.RadioButtonGroup();
		temp.initialized(this, 'rbgScope');
		rbgScope = temp;
		mx.binding.BindingManager.executeBindings(this, 'rbgScope', rbgScope);
		return temp;
	}

	private function _SearchInProjectPopup_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_Button1_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Replace';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SearchInProjectPopup_Button1_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SearchInProjectPopup_Button1_click(event:flash.events.MouseEvent):Void {
		onSearchRequest(true);
	}

	private function _SearchInProjectPopup_Button2_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Search';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', ___SearchInProjectPopup_Button2_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SearchInProjectPopup_Button2_click(event:flash.events.MouseEvent):Void {
		onSearchRequest();
	}

	private function _SearchInProjectPopup_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_SearchInProjectPopup_VGroup1_c()];
		return cast temp;
	}

	private function _SearchInProjectPopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.gap = 10;
		temp.paddingLeft = 12;
		temp.paddingBottom = 3;
		temp.paddingTop = 9;
		temp.paddingRight = 13;
		temp.mxmlContent = [_SearchInProjectPopup_PromptTextInput1_i(), _SearchInProjectPopup_HGroup1_c(), _SearchInProjectPopup_VGroup2_c(), _SearchInProjectPopup_VGroup3_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_PromptTextInput1_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.prompt = 'Containing text';
		temp.addEventListener('enter', __txtSearch_enter);
		temp.addEventListener('creationComplete', __txtSearch_creationComplete);
		temp.id = 'txtSearch';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtSearch = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtSearch', txtSearch);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __txtSearch_enter(event:mx.events.FlexEvent):Void {
		onSearchRequest();
	}

	/**
	 * @private
	 **/
	public function __txtSearch_creationComplete(event:mx.events.FlexEvent):Void {
		txtSearch.setFocus();
	}

	private function _SearchInProjectPopup_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_SearchInProjectPopup_CheckBox1_i(), _SearchInProjectPopup_CheckBox2_i(), _SearchInProjectPopup_CheckBox3_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_CheckBox1_i():spark.components.CheckBox {
		var temp:spark.components.CheckBox = new spark.components.CheckBox();
		temp.label = 'Match case';
		temp.id = 'optionMatchCase';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		optionMatchCase = temp;
		mx.binding.BindingManager.executeBindings(this, 'optionMatchCase', optionMatchCase);
		return temp;
	}

	private function _SearchInProjectPopup_CheckBox2_i():spark.components.CheckBox {
		var temp:spark.components.CheckBox = new spark.components.CheckBox();
		temp.label = 'RegExp';
		temp.id = 'optionRegExp';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		optionRegExp = temp;
		mx.binding.BindingManager.executeBindings(this, 'optionRegExp', optionRegExp);
		return temp;
	}

	private function _SearchInProjectPopup_CheckBox3_i():spark.components.CheckBox {
		var temp:spark.components.CheckBox = new spark.components.CheckBox();
		temp.label = 'Escape chars';
		temp.id = 'optionEscapeChars';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		optionEscapeChars = temp;
		mx.binding.BindingManager.executeBindings(this, 'optionEscapeChars', optionEscapeChars);
		return temp;
	}

	private function _SearchInProjectPopup_VGroup2_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_SearchInProjectPopup_Label1_c(), _SearchInProjectPopup_HGroup2_c(), _SearchInProjectPopup_Label2_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'File name patterns:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_HGroup2_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_SearchInProjectPopup_PromptTextInput2_i(), _SearchInProjectPopup_Button3_c()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_PromptTextInput2_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.restrict = '0-9a-zA-Z*\\-_,. ';
		temp.id = 'txtPatterns';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtPatterns = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtPatterns', txtPatterns);
		return temp;
	}

	private function _SearchInProjectPopup_Button3_c():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Select';
		temp.styleName = 'lightButton';
		temp.addEventListener('click', ___SearchInProjectPopup_Button3_click);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SearchInProjectPopup_Button3_click(event:flash.events.MouseEvent):Void {
		onSelectPatterns(event);
	}

	private function _SearchInProjectPopup_Label2_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = '(Separate patterns with comma (,) sign)';
		temp.setStyle('fontSize', 11);
		temp.setStyle('paddingTop', 0);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_VGroup3_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.paddingBottom = 9;
		temp.mxmlContent = [_SearchInProjectPopup_Label3_c(), _SearchInProjectPopup_HGroup3_c(), _SearchInProjectPopup_DropDownList1_i(), _SearchInProjectPopup_CheckBox4_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_Label3_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Scope:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_HGroup3_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_SearchInProjectPopup_RadioButton1_i(), _SearchInProjectPopup_RadioButton2_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SearchInProjectPopup_RadioButton1_i():spark.components.RadioButton {
		var temp:spark.components.RadioButton = new spark.components.RadioButton();
		temp.label = 'Workspace';
		temp.id = '_SearchInProjectPopup_RadioButton1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SearchInProjectPopup_RadioButton1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SearchInProjectPopup_RadioButton1', _SearchInProjectPopup_RadioButton1);
		return temp;
	}

	private function _SearchInProjectPopup_RadioButton2_i():spark.components.RadioButton {
		var temp:spark.components.RadioButton = new spark.components.RadioButton();
		temp.label = 'Selected project';
		temp.id = '_SearchInProjectPopup_RadioButton2';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_SearchInProjectPopup_RadioButton2 = temp;
		mx.binding.BindingManager.executeBindings(this, '_SearchInProjectPopup_RadioButton2', _SearchInProjectPopup_RadioButton2);
		return temp;
	}

	private function _SearchInProjectPopup_DropDownList1_i():spark.components.DropDownList {
		var temp:spark.components.DropDownList = new spark.components.DropDownList();
		temp.percentWidth = 100.0;
		temp.height = 24;
		temp.requireSelection = true;
		temp.labelField = 'name';
		temp.id = 'ddlProjects';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		ddlProjects = temp;
		mx.binding.BindingManager.executeBindings(this, 'ddlProjects', ddlProjects);
		return temp;
	}

	private function _SearchInProjectPopup_CheckBox4_i():spark.components.CheckBox {
		var temp:spark.components.CheckBox = new spark.components.CheckBox();
		temp.label = 'Include external source paths';
		temp.id = 'cbEnclosingProjects';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		cbEnclosingProjects = temp;
		mx.binding.BindingManager.executeBindings(this, 'cbEnclosingProjects', cbEnclosingProjects);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___SearchInProjectPopup_ResizableTitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onInitialized(event);
	}

	//  binding mgmt
	private function _SearchInProjectPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Dynamic {
					return (SearchPlugin.WORKSPACE);
				},
				null,
				'_SearchInProjectPopup_RadioButton1.value');

		result[1] = new mx.binding.Binding(this,
				null,
				null,
				'_SearchInProjectPopup_RadioButton1.group', 'rbgScope');

		result[2] = new mx.binding.Binding(this,
				function():Dynamic {
					return (SearchPlugin.PROJECT);
				},
				null,
				'_SearchInProjectPopup_RadioButton2.value');

		result[3] = new mx.binding.Binding(this,
				null,
				null,
				'_SearchInProjectPopup_RadioButton2.group', 'rbgScope');

		result[4] = new mx.binding.Binding(this,
				function():Bool {
					return (rbgScope.selectedIndex == 1);
				},
				null,
				'ddlProjects.enabled');

		result[5] = new mx.binding.Binding(this,
				function():mx.collections.IList {
					return (model.projects);
				},
				null,
				'ddlProjects.dataProvider');

		result[6] = new mx.binding.Binding(this,
				function():Bool {
					return (rbgScope.selectedIndex == 1);
				},
				null,
				'cbEnclosingProjects.enabled');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SearchInProjectPopup)._watcherSetupUtil = watcherSetupUtil;
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