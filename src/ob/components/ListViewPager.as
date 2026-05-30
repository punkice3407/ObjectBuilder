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

package ob.components
{
    import otlib.components.ListBase;

    /**
     *  Controller that keeps a paginated pair of list/grid views (both derive
     *  from ListBase) in sync and centralizes id-based navigation. Sprites and
     *  objects both drive their list+grid through this, so the worker-page sync
     *  is identical for both and cannot diverge per view.
     */
    public class ListViewPager
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        private var _listView:ListBase;       // list view (ViewStack index 0)
        private var _gridView:ListBase;       // grid view (ViewStack index 1)
        private var _activeResolver:Function; // ():ListBase — the currently visible view

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ListViewPager(listView:ListBase, gridView:ListBase, activeResolver:Function)
        {
            _listView = listView;
            _gridView = gridView;
            _activeResolver = activeResolver;
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        // --------------------------------------
        // Public
        // --------------------------------------

        /**
         *  Canonical page sync: BOTH views receive identical data, selection and
         *  scroll restoration. Replaces the divergent blocks that used to live in
         *  setSpriteListCallback / setThingListCallback.
         */
        public function applyPage(selectedIds:Vector.<uint>, items:*, forceUpdate:Boolean = false):void
        {
            applyToView(_listView, selectedIds, items, forceUpdate);
            applyToView(_gridView, selectedIds, items, forceUpdate);
        }

        /**
         *  Corrected navigation guard. Returns true when handled locally (already
         *  selected no-op, or selected within the loaded page); returns false when
         *  the caller must request a fresh page from the worker.
         *
         *  Uses getIndexById presence instead of the minId/maxId heuristic so that
         *  the id == 0 case (empty sprite) is no longer swallowed by the inherited
         *  "selectedId == id" / selectedId-returns-0-for-no-selection ambiguity.
         */
        public function trySelect(id:uint):Boolean
        {
            var src:ListBase = active;
            if (!src)
                return false;

            if (src.getIndexById(id) == -1)
                return false; // not on the loaded page — caller must reload

            if (!src.isEmpty && src.selectedId == id)
                return true; // already shown and selected — no-op

            src.ensureIdIsVisible(id);
            src.selectedId = id;
            return true;
        }

        // --------------------------------------
        // Private
        // --------------------------------------

        private function applyToView(view:ListBase, selectedIds:Vector.<uint>, items:*, forceUpdate:Boolean):void
        {
            if (!view)
                return;

            view.rememberScroll();
            if (forceUpdate)
                view.forceNextUpdate();

            view.setListObjects(items);
            view.selectedIds = selectedIds;

            if (selectedIds && selectedIds.length > 0)
                view.ensureIdIsVisible(selectedIds[0]);
        }

        // --------------------------------------
        // Getters / Setters
        // --------------------------------------

        /** The currently visible view, used for navigation/selection reads. */
        public function get active():ListBase
        {
            return (_activeResolver != null) ? (_activeResolver() as ListBase) : _listView;
        }
    }
}
