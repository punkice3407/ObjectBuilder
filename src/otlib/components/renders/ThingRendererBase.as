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

package otlib.components.renders
{
    import flash.display.NativeMenuItem;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;

    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    import otlib.components.ThingList;
    import otlib.core.otlib_internal;
    import otlib.events.ThingListEvent;
    import otlib.utils.ThingListItem;

    use namespace otlib_internal;

    /**
     * Shared utility class for ThingListRenderer and ThingGridRenderer.
     * Contains common context menu creation and handling logic.
     */
    public class ThingRendererBase
    {
        /**
         * Creates the shared context menu for thing renderers.
         */
        public static function createContextMenu():ContextMenu
        {
            var resource:IResourceManager = ResourceManager.getInstance();

            var replaceMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "replace"));
            replaceMenu.data = ThingListEvent.REPLACE;

            var exportMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "export"));
            exportMenu.data = ThingListEvent.EXPORT;

            var editMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "edit"));
            editMenu.data = ThingListEvent.EDIT;

            var duplicateMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "duplicate"));
            duplicateMenu.data = ThingListEvent.DUPLICATE;

            var bulkEditMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "bulkEdit"));
            bulkEditMenu.data = ThingListEvent.BULK_EDIT;

            var copyObjectMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "copyObject"));
            copyObjectMenu.data = ThingListEvent.COPY_OBJECT;

            var pasteObjectMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "pasteObject"));
            pasteObjectMenu.data = ThingListEvent.PASTE_OBJECT;

            var copyPatternsMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "copyPatterns"));
            copyPatternsMenu.data = ThingListEvent.COPY_PATTERNS;

            var pastePatternsMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "pastePatterns"));
            pastePatternsMenu.data = ThingListEvent.PASTE_PATTERNS;

            var copyPropertiesMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "copyProperties"));
            copyPropertiesMenu.data = ThingListEvent.COPY_PROPERTIES;

            var pastePropertiesMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "pasteProperties"));
            pastePropertiesMenu.data = ThingListEvent.PASTE_PROPERTIES;

            var copyAttributesMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "copyAttributes"));
            copyAttributesMenu.data = ThingListEvent.COPY_ATTRIBUTES;

            var pasteAttributesMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "pasteAttributes"));
            pasteAttributesMenu.data = ThingListEvent.PASTE_ATTRIBUTES;

            var removeMenu:ContextMenuItem = new ContextMenuItem(resource.getString("strings", "remove"));
            removeMenu.data = ThingListEvent.REMOVE;

            var compareMenu:ContextMenuItem = new ContextMenuItem("Compare...", true);
            compareMenu.data = ThingListEvent.COMPARE;

            var copyIdMenu:ContextMenuItem = new ContextMenuItem("Copy Client ID", true);
            copyIdMenu.data = ThingListEvent.COPY_CLIENT_ID;

            var copyServerIdMenu:ContextMenuItem = new ContextMenuItem("Copy Server ID");
            copyServerIdMenu.data = ThingListEvent.COPY_SERVER_ID;

            var menu:ContextMenu = new ContextMenu();
            menu.customItems = [
                    replaceMenu, exportMenu, editMenu, duplicateMenu, bulkEditMenu,
                    copyObjectMenu, pasteObjectMenu,
                    copyPatternsMenu, pastePatternsMenu,
                    copyPropertiesMenu, pastePropertiesMenu,
                    copyAttributesMenu, pasteAttributesMenu,
                    removeMenu, compareMenu, copyIdMenu, copyServerIdMenu
                ];

            return menu;
        }

        /**
         * Updates the Copy Client ID and Copy Server ID menu item labels with actual IDs.
         */
        public static function updateContextMenuLabels(menu:ContextMenu, item:ThingListItem):void
        {
            if (!item || !item.thing)
                return;

            var resource:IResourceManager = ResourceManager.getInstance();
            var menuLength:int = menu.customItems.length;

            // Update Copy Client ID menu item label (second to last)
            var copyClientIdItem:ContextMenuItem = menu.customItems[menuLength - 2] as ContextMenuItem;
            if (copyClientIdItem)
            {
                copyClientIdItem.caption = resource.getString("strings", "copyClientId", [item.thing.id]);
            }

            // Update Copy Server ID menu item label (last)
            var copyServerIdItem:ContextMenuItem = menu.customItems[menuLength - 1] as ContextMenuItem;
            if (copyServerIdItem)
            {
                copyServerIdItem.caption = resource.getString("strings", "copyServerId", [item.serverId > 0 ? item.serverId : "-"]);
            }
        }

        /**
         * Handles context menu selection and forwards to ThingList owner.
         */
        public static function handleContextMenuSelect(owner:Object, itemIndex:int, event:Event):void
        {
            if (owner is ThingList)
            {
                var type:String = NativeMenuItem(event.target).data as String;
                ThingList(owner).onContextMenuSelect(itemIndex, type);
            }
        }

        /**
         * Handles context menu displaying and forwards to ThingList owner.
         */
        public static function handleContextMenuDisplaying(owner:Object, itemIndex:int, menu:ContextMenu, item:ThingListItem):void
        {
            updateContextMenuLabels(menu, item);

            if (owner is ThingList)
            {
                ThingList(owner).onContextMenuDisplaying(itemIndex, menu);
            }
        }
    }
}
