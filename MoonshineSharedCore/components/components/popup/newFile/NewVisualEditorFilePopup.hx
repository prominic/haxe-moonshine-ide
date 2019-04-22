/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup.newFile
 *  Class:      NewVisualEditorFilePopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/newFile/NewVisualEditorFilePopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:48 MSK
 */

package components.popup.newFile;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.NewFileEvent;
import actionScripts.extResources.com.validator.ValidatorType;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.utils.SimpleValidator;
import actionScripts.valueObjects.ConstantsCoreVO;

import components.popup.newFile.NewMXMLFilePopup;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
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

//  begin class def
class NewVisualEditorFilePopup extends components.popup.newFile.NewMXMLFilePopup {

	//  instance variables

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		// layer initializers

		// properties
		this.title = 'New Visual Editor File';

		// events

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
	//  <Script>, line 5 - 53

	override private function refreshTemplatesBasedOnDropDownList():Void {
		var currentProject:AS3ProjectVO = AS3.as(wrapperBelongToProject, AS3ProjectVO);
		if (currentProject != null && currentProject.isVisualEditorProject) {
			if (currentProject.isPrimeFacesVisualEditorProject) {
				componentTemplates = ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_PRIMEFACES;
				title = 'New Visual Editor PrimeFaces File';
				extensionLabel.text = '.xhtml';
			} else {
				componentTemplates = ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_FLEX;
				title = 'New Visual Editor Flex File';
				extensionLabel.text = '.mxml';
			}
		}
	}

	override private function onCreateButton(event:MouseEvent):Void {
		// validation check for Enter key
		if (!AS3.as(btnCreate.enabled, Bool)) {
			return;
		}

		// validation 2
		var validateArr:Array<Dynamic> = new Array<Dynamic>();
		if (SimpleValidator.validate(validateArr)) {
			var tmpEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_NEW_VISUAL_EDITOR_FILE, null, new FileLocation(Std.string(ddlType.selectedItem.nativePath)), wrapperOfFolderLocation);
			tmpEvent.ofProject = wrapperBelongToProject;
			tmpEvent.fileName = txtFileName.text;
			GlobalEventDispatcher.getInstance().dispatchEvent(tmpEvent);

			doBeforeExit();
			super.closeThis();
		}
	}

}

//  end package def