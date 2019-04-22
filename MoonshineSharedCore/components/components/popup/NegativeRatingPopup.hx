/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      NegativeRatingPopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/NegativeRatingPopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.popup;

import mx.events.FlexEvent;

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
import spark.components.Label;
import spark.components.TextArea;
import spark.components.VGroup;

//  begin class def
class NegativeRatingPopup extends actionScripts.ui.resizableTitleWindow.ResizableTitleWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnReport:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtProblem:spark.components.TextArea;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _NegativeRatingPopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_NegativeRatingPopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(NegativeRatingPopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.minWidth = 400;
		this.minHeight = 200;
		this.autoLayout = true;
		this.title = 'How can we help you?';
		this.controlBarContent = [_NegativeRatingPopup_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_NegativeRatingPopup_Array2_c);

		// events
		this.addEventListener('creationComplete', ___NegativeRatingPopup_ResizableTitleWindow1_creationComplete);

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
	//  <Script>, line 9 - 56

	public var errorDetails:String;

	private function onBtnReportClick(event:MouseEvent):Void {
		var issueGithubRequest:URLRequest = new URLRequest('https://github.com/prominic/Moonshine-IDE/issues/new');
		var urlVariables:URLVariables = new URLVariables();
		urlVariables.body = txtProblem.text;

		issueGithubRequest.data = urlVariables;
		flash.Lib.getURL(issueGithubRequest, '_blank');

		closeThis();
	}

	private function onCreationCompletes(event:FlexEvent):Void {
		var messageBody:String = '<!-- Requirements: please go through this checklist before opening a new issue -->\n\n' +
		'- [ ] Review the documentation: https://github.com/prominic/Moonshine-IDE\n' +
		'- [ ] Search for existing issues: https://github.com/prominic/Moonshine-IDE/issues\n' +
		'- [ ] Use the latest stable version at: http://moonshine-ide.com\n' +
		'- [ ] Let us know how to reproduce the issue. Include a code sample, or share a project that reproduces the issue\n\n' +
		'## Environment\n' +
		'<!-- Required. -->\n\n' +
		'## Description\n' +
		'<!-- Describe your issue in detail. -->\n\n' +
		'## Steps to Reproduce\n' +
		'<!-- Required. -->\n\n' +
		'## Expected Behavior\n' +
		'<!-- Write what you thought would happen. -->\n\n' +
		'## Actual Behavior/Errors\n';

		if (errorDetails != null) {
			messageBody += '\n### Errors\n' +
			errorDetails + '\n\n';
		}

		messageBody += '<!-- Write what happened. Include screenshots if needed. If this is a regression, let us know. -->\n';

		txtProblem.text = messageBody;
		txtProblem.setFocus();
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _NegativeRatingPopup_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Report Issue';
		temp.styleName = 'darkButton';
		temp.addEventListener('click', __btnReport_click);
		temp.id = 'btnReport';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnReport = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnReport', btnReport);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnReport_click(event:flash.events.MouseEvent):Void {
		onBtnReportClick(event);
	}

	private function _NegativeRatingPopup_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_NegativeRatingPopup_VGroup1_c()];
		return cast temp;
	}

	private function _NegativeRatingPopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.paddingLeft = 12;
		temp.paddingBottom = 12;
		temp.paddingTop = 9;
		temp.paddingRight = 12;
		temp.mxmlContent = [_NegativeRatingPopup_Label1_c(), _NegativeRatingPopup_TextArea1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NegativeRatingPopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'I want to report an issue:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NegativeRatingPopup_TextArea1_i():spark.components.TextArea {
		var temp:spark.components.TextArea = new spark.components.TextArea();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.prompt = 'Describe your problem here..';
		temp.id = 'txtProblem';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtProblem = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtProblem', txtProblem);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___NegativeRatingPopup_ResizableTitleWindow1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreationCompletes(event);
	}

	//  binding mgmt
	private function _NegativeRatingPopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Bool {
					return (StringTools.trim(txtProblem.text).length != 0);
				},
				null,
				'btnReport.enabled');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(NegativeRatingPopup)._watcherSetupUtil = watcherSetupUtil;
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