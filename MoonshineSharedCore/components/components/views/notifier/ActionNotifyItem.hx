/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.views.notifier
 *  Class:      ActionNotifyItem
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/views/notifier/ActionNotifyItem.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.views.notifier;

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filters.*;
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
import mx.containers.Canvas;
import mx.controls.Text;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponentDescriptor;
import mx.core.Mx_internal;
import mx.effects.Fade;
import mx.styles.*;

//  begin class def
class ActionNotifyItem extends mx.containers.Canvas implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _ActionNotifyItem_Text1:mx.controls.Text;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var createEffect:mx.effects.Fade;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var removeEffect:mx.effects.Fade;

	//  type-import dummies

	//  Container document descriptor
	private var _documentDescriptor_:mx.core.UIComponentDescriptor;

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		this._documentDescriptor_ =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.Canvas,
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': mx.controls.Text,
								'id': '_ActionNotifyItem_Text1',
								'stylesFactory': function():Void {
									this.color = 16777215;
									this.paddingRight = 4;
									this.paddingLeft = 5;
									this.paddingTop = 5;
									this.paddingBottom = 5;
								},
								'propertiesFactory': function():Dynamic {
									return {
										'selectable': false
									};
								}
							})
				]
						};
					}
				});
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _ActionNotifyItem_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_views_notifier_ActionNotifyItemWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(ActionNotifyItem, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.mouseChildren = false;
		this.mouseEnabled = false;
		this.verticalCenter = 0;
		this.horizontalCenter = 0;
		this.alpha = 0;
		_ActionNotifyItem_Fade1_i();
		_ActionNotifyItem_Fade2_i();

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
					this.cornerRadius = 2;
					this.borderStyle = 'solid';
					this.backgroundAlpha = 0.4;
					this.backgroundColor = 0;
				};
		return factory;
	}

	//  initialize()
	/**
	 * @private
	 **/
	override public function initialize():Void {
		// mx_internal::setDocumentDescriptor(_documentDescriptor_);

		super.initialize();
	}

	//  scripts
	//  <Script>, line 34 - 38

	@:meta(Bindable())
	public var notifyText:String;

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _ActionNotifyItem_Fade1_i():mx.effects.Fade {
		var temp:mx.effects.Fade = new mx.effects.Fade();
		temp.alphaFrom = 0;
		temp.alphaTo = 1;
		temp.duration = 100;
		createEffect = temp;
		mx.binding.BindingManager.executeBindings(this, 'createEffect', createEffect);
		return temp;
	}

	private function _ActionNotifyItem_Fade2_i():mx.effects.Fade {
		var temp:mx.effects.Fade = new mx.effects.Fade();
		temp.alphaFrom = 1;
		temp.alphaTo = 0;
		temp.duration = 100;
		removeEffect = temp;
		mx.binding.BindingManager.executeBindings(this, 'removeEffect', removeEffect);
		return temp;
	}

	//  binding mgmt
	private function _ActionNotifyItem_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				null,
				function(_sourceFunctionReturnValue:Dynamic):Void {
					this.setStyle('creationCompleteEffect', _sourceFunctionReturnValue);
				},
				'this.creationCompleteEffect', 'createEffect');

		result[1] = new mx.binding.Binding(this,
				null,
				null,
				'_ActionNotifyItem_Text1.text', 'notifyText');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(ActionNotifyItem)._watcherSetupUtil = watcherSetupUtil;
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