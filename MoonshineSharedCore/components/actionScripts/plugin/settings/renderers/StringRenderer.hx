/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    actionScripts.plugin.settings.renderers
 *  Class:      StringRenderer
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/actionScripts/plugin/settings/renderers/StringRenderer.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package actionScripts.plugin.settings.renderers;

import mx.events.FlexEvent;
import spark.components.TextSelectionHighlighting;
import spark.events.TextOperationEvent;
import actionScripts.plugin.settings.vo.AbstractSetting;
import actionScripts.plugin.settings.vo.StringSetting;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.FocusEvent;
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
import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.VGroup;

//  begin class def
class StringRenderer extends spark.components.VGroup implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lbl:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lblMessage:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var text:spark.components.TextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _StringRenderer_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_actionScripts_plugin_settings_renderers_StringRendererWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(StringRenderer, propertyName);
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
		this.mxmlContent = [_StringRenderer_HGroup1_c(), _StringRenderer_Label2_i()];

		// events
		this.addEventListener('creationComplete', ___StringRenderer_VGroup1_creationComplete);

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
	//  <Script>, line 28 - 95

	@:meta(Bindable())
	public var setting:StringSetting;

	public function setMessage(value:String, type:String):Void {
		if (lblMessage == null || value == null) {
			return;
		}

		lblMessage.includeInLayout = lblMessage.visible = true;
		switch (type) {
			case AbstractSetting.MESSAGE_CRITICAL:
				lblMessage.setStyle('color', 0xff0000);
			case AbstractSetting.MESSAGE_IMPORTANT:
				lblMessage.setStyle('color', 0x0099ff);
			case _:
				lblMessage.setStyle('color', 0x666666);
		}

		lblMessage.text = value;
	}

	private function onStringRendererCreationComplete(event:FlexEvent):Void {
		text.selectRange(0, text.text.length);

		updatePrompt();

		text.setFocus();
	}

	private function focusIn():Void {
		/*text.visible = true;
		text.includeInLayout = true;*/

		callLater(text.setFocus);
	}

	private function updatePrompt():Void {
		//to show project Name highlighted while creating new Project
		if (setting.name == 'projectName') {
			text.selectionHighlighting = TextSelectionHighlighting.ALWAYS;
		}
	}

	private function onTextChange(event:TextOperationEvent):Void {
		setting.dispatchEvent(new Event(StringSetting.VALUE_UPDATED));
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _StringRenderer_HGroup1_c():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.gap = 0;
		temp.mxmlContent = [_StringRenderer_Label1_i(), _StringRenderer_TextInput1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _StringRenderer_Label1_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.setStyle('paddingTop', 15);
		temp.setStyle('paddingBottom', 15);
		temp.setStyle('paddingRight', 50);
		temp.setStyle('paddingLeft', 15);
		temp.addEventListener('mouseDown', __lbl_mouseDown);
		temp.id = 'lbl';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lbl = temp;
		mx.binding.BindingManager.executeBindings(this, 'lbl', lbl);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __lbl_mouseDown(event:flash.events.MouseEvent):Void {
		focusIn();
	}

	private function _StringRenderer_TextInput1_i():spark.components.TextInput {
		var temp:spark.components.TextInput = new spark.components.TextInput();
		temp.styleName = 'uiTextSettingsValue';
		temp.percentHeight = 100.0;
		temp.percentWidth = 100.0;
		temp.prompt = 'No value';
		temp.setStyle('textAlign', 'right');
		temp.setStyle('borderVisible', false);
		temp.setStyle('focusAlpha', 0);
		temp.setStyle('contentBackgroundColor', 16777215);
		temp.addEventListener('change', __text_change);
		temp.addEventListener('focusOut', __text_focusOut);
		temp.id = 'text';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		text = temp;
		mx.binding.BindingManager.executeBindings(this, 'text', text);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __text_change(event:spark.events.TextOperationEvent):Void {
		onTextChange(event);
	}

	/**
	 * @private
	 **/
	public function __text_focusOut(event:flash.events.FocusEvent):Void {
		updatePrompt();
	}

	private function _StringRenderer_Label2_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'uiTextSettingsLabel';
		temp.percentWidth = 100.0;
		temp.maxDisplayedLines = 3;
		temp.includeInLayout = false;
		temp.visible = false;
		temp.setStyle('color', 6710886);
		temp.setStyle('fontSize', 12);
		temp.setStyle('paddingLeft', 15);
		temp.id = 'lblMessage';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lblMessage = temp;
		mx.binding.BindingManager.executeBindings(this, 'lblMessage', lblMessage);
		return temp;
	}

	/**
	 * @private
	 **/
	public function ___StringRenderer_VGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		onStringRendererCreationComplete(event);
	}

	//  binding mgmt
	private function _StringRenderer_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (setting.label);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'lbl.text');

		result[1] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = setting.stringValue;
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'text.text');

		result[2] = new mx.binding.Binding(this,
				function():Dynamic {
					return text.text;
				},
				function(_sourceFunctionReturnValue:Dynamic):Void {
					setting.stringValue = Std.string(_sourceFunctionReturnValue);
				},
				'setting.stringValue');

		Reflect.setField(result[2], 'twoWayCounterpart', result[1]);

		Reflect.setField(result[1], 'isTwoWayPrimary', true);
		Reflect.setField(result[1], 'twoWayCounterpart', result[2]);

		return result;
	}

	private function _StringRenderer_bindingExprs():Void {
		setting.stringValue = Std.string(text.text);
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(StringRenderer)._watcherSetupUtil = watcherSetupUtil;
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