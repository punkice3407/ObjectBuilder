/*
*  Copyright (c) 2014-2023 Object Builder <https://github.com/ottools/ObjectBuilder>
*
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:
*
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.
*/

package ob.menu
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.controls.FlexNativeMenu;
    import mx.core.FlexGlobals;
    import mx.events.FlexEvent;
    import mx.events.FlexNativeMenuEvent;

    import nail.events.MenuEvent;
    import nail.menu.MenuItem;
    import nail.utils.CapabilitiesUtil;
    import nail.utils.Descriptor;

    import ob.core.IObjectBuilder;

    import otlib.resources.Resources;

    [Event(name="selected", type="nail.events.MenuEvent")]

    [ExcludeClass]
    public class Menu extends FlexNativeMenu
    {
        //--------------------------------------
        // Private
        //--------------------------------------

        private var m_application:IObjectBuilder;
        private var m_isMac:Boolean;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Menu()
        {
            m_application = FlexGlobals.topLevelApplication as IObjectBuilder;
            m_application.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
            m_isMac = CapabilitiesUtil.isMac;

            super();

            this.labelField = "@label";
            this.keyEquivalentField = "@keyEquivalent";
            this.showRoot = false;

            this.addEventListener(FlexNativeMenuEvent.ITEM_CLICK, itemClickHandler);
            this.addEventListener(FlexNativeMenuEvent.MENU_SHOW, showMenuItem);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Private
        //--------------------------------------

        private function create():void
        {
            // Root menu
            var menu:MenuItem = new MenuItem();

            // Separator
            var separator:MenuItem = new MenuItem();

            if (m_isMac)
            {
                var objectBuilderMenu:MenuItem = new MenuItem();
                objectBuilderMenu.label = Descriptor.getName();
                menu.addMenuItem(objectBuilderMenu);
            }

            // File
            var fileMenu:MenuItem = new MenuItem();
            fileMenu.label = Resources.getString("menu.file");
            menu.addMenuItem(fileMenu);

            // File > New
            var fileNewMenu:MenuItem = new MenuItem();
            fileNewMenu.label = Resources.getString("menu.new");
            fileNewMenu.data = FILE_NEW;
            fileNewMenu.keyEquivalent = "N";
            fileNewMenu.controlKey = true;
            fileMenu.addMenuItem(fileNewMenu);

            // File > Open
            var fileOpenMenu:MenuItem = new MenuItem();
            fileOpenMenu.label = Resources.getString("menu.open");
            fileOpenMenu.data = FILE_OPEN;
            fileOpenMenu.keyEquivalent = "O";
            fileOpenMenu.controlKey = true;
            fileMenu.addMenuItem(fileOpenMenu);

            // File > Compile
            var fileCompileMenu:MenuItem = new MenuItem();
            fileCompileMenu.label = Resources.getString("menu.compile");
            fileCompileMenu.data = FILE_COMPILE;
            fileCompileMenu.keyEquivalent = "S";
            fileCompileMenu.controlKey = true;
            fileMenu.addMenuItem(fileCompileMenu);

            // File > Compile As
            var fileCompileAsMenu:MenuItem = new MenuItem();
            fileCompileAsMenu.label = Resources.getString("menu.compileAs");
            fileCompileAsMenu.data = FILE_COMPILE_AS;
            fileCompileAsMenu.keyEquivalent = "S";
            fileCompileAsMenu.controlKey = true;
            fileCompileAsMenu.shiftKey = true;
            fileMenu.addMenuItem(fileCompileAsMenu);

            // Separator
            fileMenu.addMenuItem(separator);

            // File > Close
            var fileCloseMenu:MenuItem = new MenuItem();
            fileCloseMenu.label = Resources.getString("menu.close");
            fileCloseMenu.data = FILE_CLOSE;
            fileCloseMenu.keyEquivalent = "W";
            fileCloseMenu.controlKey = true;
            fileMenu.addMenuItem(fileCloseMenu);

            // Separator
            fileMenu.addMenuItem(separator);

            // File > Merge
            var fileMergeMenu:MenuItem = new MenuItem();
            fileMergeMenu.label = Resources.getString("menu.merge");
            fileMergeMenu.data = FILE_MERGE;
            fileMergeMenu.keyEquivalent = "M";
            fileMergeMenu.controlKey = true;
            fileMenu.addMenuItem(fileMergeMenu);

            // Separator
            if (!m_isMac)
                fileMenu.addMenuItem(separator);

            // File > Preferences
            var filePreferencesMenu:MenuItem = new MenuItem();
            filePreferencesMenu.label = Resources.getString("menu.preferences");
            filePreferencesMenu.data = FILE_PREFERENCES;
            filePreferencesMenu.keyEquivalent = "P";
            filePreferencesMenu.controlKey = true;

            // File > Exit
            var fileExitMenu:MenuItem = new MenuItem();
            fileExitMenu.label = Resources.getString("menu.exit");
            fileExitMenu.data = FILE_EXIT;
            fileExitMenu.keyEquivalent = "Q";
            fileExitMenu.controlKey = true;

            // View
            var viewMenu:MenuItem = new MenuItem();
            viewMenu.label = Resources.getString("menu.view");
            menu.addMenuItem(viewMenu);

            // View > Show Preview Panel
            var viewShowPreviewMenu:MenuItem = new MenuItem();
            viewShowPreviewMenu.label = Resources.getString("menu.showPreviewPanel");
            viewShowPreviewMenu.data = VIEW_SHOW_PREVIEW;
            viewShowPreviewMenu.keyEquivalent = "F2";
            viewShowPreviewMenu.toggled = m_application.showPreviewPanel;
            viewMenu.addMenuItem(viewShowPreviewMenu);

            // View > Show Objects Panel
            var viewShowObjectsMenu:MenuItem = new MenuItem();
            viewShowObjectsMenu.label = Resources.getString("menu.showObjectsPanel");
            viewShowObjectsMenu.data = VIEW_SHOW_OBJECTS;
            viewShowObjectsMenu.keyEquivalent = "F3";
            viewShowObjectsMenu.toggled = m_application.showThingsPanel;
            viewMenu.addMenuItem(viewShowObjectsMenu);

            // View > Show Sprites Panel
            var viewShowSpritesMenu:MenuItem = new MenuItem();
            viewShowSpritesMenu.label = Resources.getString("menu.showSpritesPanel");
            viewShowSpritesMenu.data = VIEW_SHOW_SPRITES;
            viewShowSpritesMenu.keyEquivalent = "F4";
            viewShowSpritesMenu.toggled = m_application.showSpritesPanel;
            viewMenu.addMenuItem(viewShowSpritesMenu);

            // Tools
            var toolsMenu:MenuItem = new MenuItem();
            toolsMenu.label = Resources.getString("menu.tools");
            menu.addMenuItem(toolsMenu);

            // Tools > Find
            var toolsFind:MenuItem = new MenuItem();
            toolsFind.label = Resources.getString("find");
            toolsFind.data = TOOLS_FIND;
            toolsFind.keyEquivalent = "F";
            toolsFind.controlKey = true;
            toolsMenu.addMenuItem(toolsFind);

            // Tools > LookType Generator
            var toolsLookGenerator:MenuItem = new MenuItem();
            toolsLookGenerator.label = Resources.getString("menu.toolsLookTypeGenerator");
            toolsLookGenerator.data = TOOLS_LOOK_TYPE_GENERATOR;
            toolsMenu.addMenuItem(toolsLookGenerator);

            // Tools > Object Viewer
            var toolsObjectViewer:MenuItem = new MenuItem();
            toolsObjectViewer.label = Resources.getString("objectViewer");
            toolsObjectViewer.data = TOOLS_OBJECT_VIEWER;
            toolsMenu.addMenuItem(toolsObjectViewer);

            // Tools > Slicer
            var toolsSlicer:MenuItem = new MenuItem();
            toolsSlicer.label = "Slicer";
            toolsSlicer.data = TOOLS_SLICER;
            toolsMenu.addMenuItem(toolsSlicer);

            // Tools > Animation Editor
            var toolsAnimationEditor:MenuItem = new MenuItem();
            toolsAnimationEditor.label = Resources.getString("animationEditor");
            toolsAnimationEditor.data = TOOLS_ANIMATION_EDITOR;
            toolsMenu.addMenuItem(toolsAnimationEditor);

            // Tools > Sprites Optimizer
            var toolsSpritesOptimizer:MenuItem = new MenuItem();
            toolsSpritesOptimizer.label = Resources.getString("spritesOptimizer");
            toolsSpritesOptimizer.data = TOOLS_SPRITES_OPTIMIZER;
            toolsMenu.addMenuItem(toolsSpritesOptimizer);

            // Tools > Frame Durations Optimizer
            var toolsFrameDurationsOptimizer:MenuItem = new MenuItem();
            toolsFrameDurationsOptimizer.label = Resources.getString("frameDurationsOptimizer");
            toolsFrameDurationsOptimizer.data = TOOLS_FRAME_DURATIONS_OPTIMIZER;
            toolsMenu.addMenuItem(toolsFrameDurationsOptimizer);

            // Tools > Frame Groups Converter
            var toolsFrameGroupsConverter:MenuItem = new MenuItem();
            toolsFrameGroupsConverter.label = Resources.getString("frameGroupsConverter");
            toolsFrameGroupsConverter.data = TOOLS_FRAME_GROUPS_CONVERTER;
            toolsMenu.addMenuItem(toolsFrameGroupsConverter);

            // Window
            var windowMenu:MenuItem = new MenuItem();
            windowMenu.label = Resources.getString("menu.window");
            menu.addMenuItem(windowMenu);

            // Window > Log Window
            var windowLogWindowMenu:MenuItem = new MenuItem();
            windowLogWindowMenu.label = Resources.getString("menu.logWindow");
            windowLogWindowMenu.data = WINDOW_LOG;
            windowLogWindowMenu.keyEquivalent = "L";
            windowLogWindowMenu.controlKey = true;
            windowMenu.addMenuItem(windowLogWindowMenu);

            // Window > Versions
            var windowVersionsMenu:MenuItem = new MenuItem();
            windowVersionsMenu.label = Resources.getString("menu.versions");
            windowVersionsMenu.data = WINDOW_VERSIONS;
            windowMenu.addMenuItem(windowVersionsMenu);

            // Help
            var helpMenu:MenuItem = new MenuItem();
            helpMenu.label = Resources.getString("menu.help");
            menu.addMenuItem(helpMenu);

            // Help > Help Contents
            var helpContentsMenu:MenuItem = new MenuItem();
            helpContentsMenu.label = Resources.getString("menu.helpContents");
            helpContentsMenu.data = HELP_CONTENTS;
            helpContentsMenu.keyEquivalent = "F1";
            helpContentsMenu.enabled = false;
            helpMenu.addMenuItem(helpContentsMenu);

            // Separator
            helpMenu.addMenuItem(separator);

            // Help > Help Contents
            var helpCheckForUpdatesMenu:MenuItem = new MenuItem();
            helpCheckForUpdatesMenu.label = Resources.getString("menu.checkForUpdate");
            helpCheckForUpdatesMenu.data = HELP_CHECK_FOR_UPDATES;
            helpMenu.addMenuItem(helpCheckForUpdatesMenu);

            // About
            var aboutMenu:MenuItem = new MenuItem();
            aboutMenu.label = Resources.getString("menu.about") + " " + Descriptor.getName();
            aboutMenu.data = HELP_ABOUT;

            if (m_isMac)
            {
                objectBuilderMenu.addMenuItem(aboutMenu);
                objectBuilderMenu.addMenuItem(separator);
                objectBuilderMenu.addMenuItem(filePreferencesMenu);
                objectBuilderMenu.addMenuItem(separator);
                objectBuilderMenu.addMenuItem(fileExitMenu);
            }
            else
            {
                fileMenu.addMenuItem(filePreferencesMenu);
                fileMenu.addMenuItem(separator);
                fileMenu.addMenuItem(fileExitMenu);

                helpMenu.addMenuItem(separator);
                helpMenu.addMenuItem(aboutMenu);
            }

            this.dataProvider = menu.serialize();
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function applicationCompleteHandler(event:FlexEvent):void
        {
            m_application.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
            m_application.systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            create();
        }

        protected function itemClickHandler(event:FlexNativeMenuEvent):void
        {
            event.stopImmediatePropagation();

            var data:String = String(event.item.@data);
            dispatchEvent(new MenuEvent(MenuEvent.SELECTED, data));
        }

        protected function showMenuItem(event:FlexNativeMenuEvent):void
        {
            if (m_isMac)
            {
                // menu File > Compile
                nativeMenu.items[1].submenu.items[2].enabled = (m_application.clientChanged && !m_application.clientIsTemporary);

                // menu File > Compile As
                nativeMenu.items[1].submenu.items[3].enabled = m_application.clientLoaded;

                // menu File > Close
                nativeMenu.items[1].submenu.items[5].enabled = m_application.clientLoaded;

                // menu File > Merge
                nativeMenu.items[1].submenu.items[7].enabled = m_application.clientLoaded;

                // menu View > Show Preview Panel
                nativeMenu.items[2].submenu.items[0].checked = m_application.showPreviewPanel;

                // menu View > Show Things Panel
                nativeMenu.items[2].submenu.items[1].checked = m_application.showThingsPanel;

                // menu View > Show Sprites Panel
                nativeMenu.items[2].submenu.items[2].checked = m_application.showSpritesPanel;

                // menu Tools > Find
                nativeMenu.items[3].submenu.items[0].enabled = m_application.clientLoaded;
            }
            else
            {
                // menu File > Compile
                nativeMenu.items[0].submenu.items[2].enabled = (m_application.clientChanged && !m_application.clientIsTemporary);

                // menu File > Compile As
                nativeMenu.items[0].submenu.items[3].enabled = m_application.clientLoaded;

                // menu File > Close
                nativeMenu.items[0].submenu.items[5].enabled = m_application.clientLoaded;

                // menu File > Merge
                nativeMenu.items[0].submenu.items[7].enabled = m_application.clientLoaded;

                // menu View > Show Preview Panel
                nativeMenu.items[1].submenu.items[0].checked = m_application.showPreviewPanel;

                // menu View > Show Things Panel
                nativeMenu.items[1].submenu.items[1].checked = m_application.showThingsPanel;

                // menu View > Show Sprites Panel
                nativeMenu.items[1].submenu.items[2].checked = m_application.showSpritesPanel;

                // menu Tools > Find
                nativeMenu.items[2].submenu.items[0].enabled = m_application.clientLoaded;
            }
        }

        protected function keyDownHandler(event:KeyboardEvent):void
        {
            var ev:MenuEvent;
            var code:uint = event.keyCode;

            if (m_isMac)
            {
                if (event.ctrlKey && !event.shiftKey)
                {
                    switch (code)
                    {
                        case Keyboard.N:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_NEW);
                            break;

                        case Keyboard.O:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_OPEN);
                            break;

                        case Keyboard.S:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_COMPILE);
                            break;

                        case Keyboard.M:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_MERGE);
                            break;

                        case Keyboard.P:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_PREFERENCES);
                            break;

                        case Keyboard.F:
                            ev = new MenuEvent(MenuEvent.SELECTED, TOOLS_FIND);
                            break;

                        case Keyboard.Q:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_EXIT);
                            break;

                        case Keyboard.L:
                            ev = new MenuEvent(MenuEvent.SELECTED, WINDOW_LOG);
                            break;
                    }
                }
                else if (event.ctrlKey && event.shiftKey)
                {
                    switch (code)
                    {
                        case Keyboard.S:
                            ev = new MenuEvent(MenuEvent.SELECTED, FILE_COMPILE_AS);
                            break;
                    }
                }
            }
            else if (!event.ctrlKey && !event.shiftKey)
            {
                switch (code)
                {
                    case Keyboard.F1:
                        ev = new MenuEvent(MenuEvent.SELECTED, HELP_CONTENTS);
                        break;

                    case Keyboard.F2:
                        ev = new MenuEvent(MenuEvent.SELECTED, VIEW_SHOW_PREVIEW);
                        break;

                    case Keyboard.F3:
                        ev = new MenuEvent(MenuEvent.SELECTED, VIEW_SHOW_OBJECTS);
                        break;

                    case Keyboard.F4:
                        ev = new MenuEvent(MenuEvent.SELECTED, VIEW_SHOW_SPRITES);
                        break;
                }
            }

            if (ev)
                dispatchEvent(ev);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static const FILE_NEW:String = "fileNew";
        public static const FILE_OPEN:String = "fileOpen";
        public static const FILE_COMPILE:String = "fileCompile";
        public static const FILE_COMPILE_AS:String = "fileCompileAs";
        public static const FILE_CLOSE:String = "fileClose";
        public static const FILE_MERGE:String = "fileMerge";
        public static const FILE_PREFERENCES:String = "filePreferences";
        public static const FILE_EXIT:String = "fileExit";
        public static const VIEW_SHOW_PREVIEW:String = "viewShowPreview";
        public static const VIEW_SHOW_OBJECTS:String = "viewShowObjects";
        public static const VIEW_SHOW_SPRITES:String = "viewShowSprites";
        public static const TOOLS_FIND:String = "toolsFind";
        public static const TOOLS_LOOK_TYPE_GENERATOR:String = "toolsLookTypeGenerator";
        public static const TOOLS_OBJECT_VIEWER:String = "toolsObjectViewer";
        public static const TOOLS_SLICER:String = "toolsSlicer";
        public static const TOOLS_ANIMATION_EDITOR:String = "toolsAnimationEditor";
        public static const TOOLS_SPRITES_OPTIMIZER:String = "toolsSpritesOptimizer";
        public static const TOOLS_FRAME_DURATIONS_OPTIMIZER:String = "toolsFrameDurationsOptimizer";
        public static const TOOLS_FRAME_GROUPS_CONVERTER:String = "toolsFrameGroupsConverter";
        public static const WINDOW_LOG:String = "windowLog";
        public static const WINDOW_VERSIONS:String = "windowVersions";
        public static const HELP_CONTENTS:String = "helpContents";
        public static const HELP_CHECK_FOR_UPDATES:String = "helpCheckForUpdates";
        public static const HELP_ABOUT:String = "helpAbount";
    }
}
