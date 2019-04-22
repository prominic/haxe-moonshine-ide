/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.findreplace.view
 *  Class:      GoToLineView
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/findreplace/view/GoToLineView.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package actionScripts.plugin.findreplace.view;

import actionScripts.plugin.findreplace.view.StatusTextInput;
import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
import components.skins.ResizableTitleWindowSkin;
import elements.skins.DarkButtonSkin;
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
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;
import mx.events.FlexEvent;
import mx.filters.*;
import mx.styles.*;
import spark.components.Button;
import spark.components.Label;
import spark.components.RadioButtonGroup;
import spark.components.VGroup;

//  begin class def
class GoToLineView extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _GoToLineView_Label1:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var findButton:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var rbDirection:spark.components.RadioButtonGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtLine:actionScripts.plugin.findreplace.view.StatusTextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _GoToLineView_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_findreplace_view_GoToLineViewWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(GoToLineView, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.width = 400;
		this.autoLayout = true;
		this.minWidth = 300;
		this.minHeight = 130;
		this.title = 'Go To Line';
		this.controlBarContent = [_GoToLineView_Spacer1_c(), _GoToLineView_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_GoToLineView_Array2_c);
		_GoToLineView_RadioButtonGroup1_i();

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
	//  <Script>, line 30 - 44

	@:meta(Bindable())public var totalLinesCount:Int = 0;

	public var lineNumber:Int = -1;

	private function jump():Void {
		if (AS3.int(txtLine.text) > totalLinesCount) {
			return;
		}

		lineNumber = AS3.int(txtLine.text);
		closeThis();
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _GoToLineView_RadioButtonGroup1_i():spark.components.RadioButtonGroup {
		var temp:spark.components.RadioButtonGroup = new spark.components.RadioButtonGroup();
		temp.initialized(this, 'rbDirection');
		rbDirection = temp;
		mx.binding.BindingManager.executeBindings(this, 'rbDirection', rbDirection);
		return temp;
	}

	private function _GoToLineView_Spacer1_c():mx.controls.Spacer {
		var temp:mx.controls.Spacer = new mx.controls.Spacer();
		temp.percentWidth = 100.0;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _GoToLineView_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'OK';
		temp.setStyle('fontFamily', 'DejaVuSans');
		temp.setStyle('fontSize', 12);
		temp.setStyle('skinClass', elements.skins.DarkButtonSkin);
		temp.addEventListener('click', __findButton_click);
		temp.id = 'findButton';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		findButton = temp;
		mx.binding.BindingManager.executeBindings(this, 'findButton', findButton);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __findButton_click(event:flash.events.MouseEvent):Void {
		jump();
	}

	private function _GoToLineView_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_GoToLineView_VGroup1_c()];
		return cast temp;
	}

	private function _GoToLineView_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.paddingLeft = 12;
		temp.paddingBottom = 12;
		temp.paddingTop = 9;
		temp.paddingRight = 12;
		temp.mxmlContent = [_GoToLineView_Label1_i(), _GoToLineView_StatusTextInput1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _GoToLineView_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.id = '_GoToLineView_Label1';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_GoToLineView_Label1 = temp;
		mx.binding.BindingManager.executeBindings(this, '_GoToLineView_Label1', _GoToLineView_Label1);
		return temp;
	}

	private function _GoToLineView_StatusTextInput1_i():actionScripts.plugin.findreplace.view.StatusTextInput {
		var temp:actionScripts.plugin.findreplace.view.StatusTextInput = new actionScripts.plugin.findreplace.view.StatusTextInput();
		temp.prompt = '#';
		temp.restrict = '0-9';
		temp.percentWidth = 100.0;
		temp.styleName = 'textInputStatus';
		temp.tabIndex = 1;
		temp.addEventListener('creationComplete', __txtLine_creationComplete);
		temp.id = 'txtLine';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtLine = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtLine', txtLine);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __txtLine_creationComplete(event:mx.events.FlexEvent):Void {
		txtLine.setFocus();
	}

	//  binding mgmt
	private function _GoToLineView_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				null,
				'this.defaultButton', 'findButton');

		result[1] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = 'Enter line number: 1..' + (totalLinesCount);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_GoToLineView_Label1.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(GoToLineView)._watcherSetupUtil = watcherSetupUtil;
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