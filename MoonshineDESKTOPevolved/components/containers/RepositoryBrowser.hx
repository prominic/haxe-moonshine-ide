/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.containers
 *  Class:      RepositoryBrowser
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineDESKTOPevolved/src/components/containers/RepositoryBrowser.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:13:58 MSK
 */

package components.containers;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.events.TreeEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.plugins.versionControl.event.VersionControlEvent;
import actionScripts.ui.renderers.RepositoryTreeItemRenderer;
import actionScripts.valueObjects.RepositoryItemVO;

import flash.accessibility.*;
import flash.data.*;
import flash.debugger.*;
import flash.desktop.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filesystem.*;
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
import mx.controls.Tree;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;

import mx.events.ListEvent;

import mx.filters.*;
import mx.styles.*;
import spark.components.Label;
import spark.components.VGroup;

class RepositoryBrowser extends spark.components.VGroup implements mx.binding.IBindingClient {

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var treeRepositories:mx.controls.Tree;

	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _RepositoryBrowser_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_containers_RepositoryBrowserWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(RepositoryBrowser, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.gap = 10;
		this.mxmlContent = [_RepositoryBrowser_Label1_c(), _RepositoryBrowser_Tree1_i()];

		// events
		this.addEventListener('creationComplete', ___RepositoryBrowser_VGroup1_creationComplete);

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

	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	@:meta(Bindable())public var selectedItem:Dynamic;
	@:meta(Bindable())private var repositories:ArrayCollection;

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var remoteReuestedObject:RepositoryItemVO;

	//--------------------------------------------------------------------------
	//
	//  PUBLIC API
	//
	//--------------------------------------------------------------------------

	public function setRepositories(value:Array<Dynamic>):Void {
		repositories = new ArrayCollection(value);
	}

	public function onBackEvent():Void {
		if (remoteReuestedObject != null) {
			remoteReuestedObject.isUpdating = false;
			remoteReuestedObject = null;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE/PROTECTED API
	//
	//--------------------------------------------------------------------------

	private function onCreationCompletes(event:FlexEvent):Void {
		treeRepositories.addEventListener(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, handleContextMenuItemClick, false, 0, true);
	}

	private function handleContextMenuItemClick(event:TreeMenuItemEvent):Void {
		var rendererData:RepositoryItemVO = event.extra;
		if (AS3.as(rendererData.isUpdating, Bool)) {
			return;
		}

		switch (event.menuLabel) {
			case RepositoryTreeItemRenderer.REFRESH:
				// remove any previous items first
				rendererData.children = [];
				requestRemoteSvnList(rendererData);
			case RepositoryTreeItemRenderer.COLLAPSE_ALL:
				collapseAllItems();
		}
	}

	private function repositoryLabelFunction(item:RepositoryItemVO):String {
		if (AS3.as(item.isRoot, Bool)) {
			return Std.string(item.url);
		}
		return Std.string(item.label);
	}

	private function collapseAllItems():Void {
		for (item in repositories) {
			treeRepositories.expandChildrenOf(item, false);
		}
	}

	//--------------------------------------------------------------------------
	//
	//  DATA-FETCH UI API
	//
	//--------------------------------------------------------------------------

	private function onTreeItemOpen(event:TreeEvent):Void {
		if (remoteReuestedObject != null) {
			treeRepositories.expandItem(event.item, false);
			return;
		}

		requestRemoteSvnList(AS3.as(event.item, RepositoryItemVO));
	}

	private function requestRemoteSvnList(repoItem:RepositoryItemVO):Void {
		// condition1:: if no children, request data
		// condition2:: if has children from previous load, do not request
		if (AS3.as(repoItem.children, Bool) && (repoItem.children.length == 0)) {
			remoteReuestedObject = repoItem;
			repoItem.isUpdating = true;
			dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.LOAD_REMOTE_SVN_LIST,
					{
						'repository': repoItem,
						'onCompletion': onCallListingCompleted
					}));
		}
	}

	private function onCallListingCompleted(againstNodeItem:RepositoryItemVO, success:Bool):Void {
		againstNodeItem.isUpdating = false;
		remoteReuestedObject = null;

		// in case of auth cancel situation
		if (!success) {
			treeRepositories.expandItem(againstNodeItem, false);
			return;
		}

		var lastScrollPosition:Float = treeRepositories.verticalScrollPosition;
		var lastSelectedItem:Dynamic = treeRepositories.selectedItem;
		var openItems:Dynamic = treeRepositories.openItems;
		treeRepositories.openItems = openItems;
		treeRepositories.invalidateList();

		treeRepositories.callLater(function():Void {
					treeRepositories.verticalScrollPosition = lastScrollPosition;
					treeRepositories.selectedItem = lastSelectedItem;
					if (!AS3.as(treeRepositories.isItemOpen(againstNodeItem), Bool)) {
						treeRepositories.expandItem(againstNodeItem, true);
					}
				});
	}

	//  supporting function definitions for properties, events, styles, effects
	private function _RepositoryBrowser_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Select any repository to checkout/clone:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _RepositoryBrowser_Tree1_i():mx.controls.Tree {
		var temp:mx.controls.Tree = new mx.controls.Tree();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.labelFunction = repositoryLabelFunction;
		temp.itemRenderer = _RepositoryBrowser_ClassFactory1_c();
		temp.setStyle('rollOverColor', 15000804);
		temp.setStyle('selectionColor', 13421772);
		temp.setStyle('color', 0);
		temp.setStyle('alternatingItemColors', [15658734, 16777215]);
		temp.addEventListener('itemOpen', __treeRepositories_itemOpen);
		temp.addEventListener('itemClick', __treeRepositories_itemClick);
		temp.id = 'treeRepositories';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		treeRepositories = temp;
		mx.binding.BindingManager.executeBindings(this, 'treeRepositories', treeRepositories);
		return temp;
	}

	private function _RepositoryBrowser_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = actionScripts.ui.renderers.RepositoryTreeItemRenderer;
		return temp;
	}

	/**
	 * @private
	 **/
	public function __treeRepositories_itemOpen(event:mx.events.TreeEvent):Void {
		onTreeItemOpen(event);
	}

	/**
	 * @private
	 **/
	public function __treeRepositories_itemClick(event:mx.events.ListEvent):Void {
		selectedItem = treeRepositories.selectedItem;
	}

	/**
	 * @private
	 **/
	public function ___RepositoryBrowser_VGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		onCreationCompletes(event);
	}

	//  binding mgmt
	private function _RepositoryBrowser_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Dynamic {
					return (repositories);
				},
				null,
				'treeRepositories.dataProvider');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(RepositoryBrowser)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

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