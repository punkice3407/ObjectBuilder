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

package otlib.components
{
    import mx.collections.ArrayCollection;
    import mx.events.FlexEvent;

    import spark.components.List;

    [Exclude(kind="property", name="dataProvider")]

    public class ListBase extends List
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _ensureIdIsVisible:uint = uint.MAX_VALUE;
        private var _scrollSave:ScrollPosition;
        private var _contextMenuEnabled:Boolean = true;
        private var _minId:uint;
        private var _maxId:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(category="General", defaultValue="0")]
        public function get selectedId():uint
        {
            if (this.selectedItem) {
                return this.selectedItem.id;
            }
            return 0;
        }

        public function set selectedId(value:uint):void
        {
            if (selectedId != value) {
                this.selectedIndex = getIndexById(value);
            }
        }

        public function get firstSelectedId():uint
        {
            if (selectedIndices && selectedIndices.length > 0) {
                return dataProvider.getItemAt(selectedIndices[0]).id;
            }
            return 0;
        }

        public function get lastSelectedId():uint
        {
            if (selectedIndices && selectedIndices.length > 0) {
                return dataProvider.getItemAt(selectedIndices[selectedIndices.length - 1]).id;
            }
            return 0;
        }

        public function get selectedIds():Vector.<uint>
        {
            var result:Vector.<uint> = new Vector.<uint>();

            if (selectedIndices) {
                var length:uint = selectedIndices.length;
                for (var i:uint = 0; i < length; i++) {
                    result[i] = dataProvider.getItemAt(selectedIndices[i]).id;
                }
            }
            return result;
        }

        public function set selectedIds(value:Vector.<uint>):void
        {
            if (value) {
                var indices:Vector.<int> = new Vector.<int>();
                var length:uint = value.length;
                if (length > 1) {
                    for (var i:uint = 0; i < length; i++) {
                        var index:uint = getIndexById(value[i]);
                        if (index != -1) indices[indices.length] = index;
                    }
                    this.selectedIndices = indices;
                } else if (length == 1) {
                    this.selectedIndex = getIndexById(value[0]);
                }
            }
        }

        public function get maxId():uint { return _maxId; }
        public function get minId():uint { return _minId; }
        public function get multipleSelected():Boolean { return (this.selectedIndices.length > 1); }
        public function get isEmpty():Boolean { return (dataProvider.length == 0); }

        [Inspectable(category="General", defaultValue="true")]
        public function get contextMenuEnabled():Boolean { return _contextMenuEnabled; }
        public function set contextMenuEnabled(value:Boolean):void
        {
            if (_contextMenuEnabled != value) {
                _contextMenuEnabled = value;
            }
        }

        public function get length():uint { return dataProvider.length; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ListBase()
        {
            this.dataProvider = new ArrayCollection();
            this.addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function setListObjects(list:*):void
        {
            this.removeAll();

            if (list) {
                _minId = uint.MAX_VALUE;
                _maxId = 0;
                var length:uint = list.length;
                for (var i:uint = 0; i < length; i++) {
                    var object:IListObject = list[i];
                    var id:uint = object.id;
                    _minId = id < _minId ? id : _minId;
                    _maxId = id > _maxId ? id : _maxId;
                    dataProvider.addItem(object);
                }
            }
        }

        public function removeSelectedIndices():void
        {
            var selectedIndices:Vector.<int> = this.selectedIndices;
            if (selectedIndices) {
                selectedIndices.sort(Array.NUMERIC);
                var length:uint = selectedIndices.length;
                for (var i:int = length - 1; i >= 0; i--) {
                    dataProvider.removeItemAt(selectedIndices[i]);
                }
            }
        }

        public function removeAll():void
        {
            _minId = 0;
            _maxId = 0;
            dataProvider.removeAll();
        }

        public function getIndexById(id:uint):int
        {
            var length:uint = dataProvider.length;
            for (var i:uint = 0; i < length; i++) {
                if (dataProvider.getItemAt(i).id == id) {
                    return i;
                }
            }
            return -1;
        }

        public function getIndexOf(object:IListObject):int
        {
            if (object) {
                return this.dataProvider.getItemIndex(object);
            }
            return -1;
        }

        public function getObjectAt(index:int):IListObject
        {
            return this.dataProvider.getItemAt(index) as IListObject;
        }

        public function rememberScroll():void
        {
            if (dataGroup && dataProvider.length != 0) {
                var indicesInView:Vector.<int> = dataGroup.getItemIndicesInView();
                if (indicesInView && indicesInView.length != 0) {
                    var firstVisible:int = indicesInView[0];
                    var lastVisible:int = indicesInView[indicesInView.length - 1];
                    if (firstVisible < dataProvider.length && lastVisible < dataProvider.length) {
                        _scrollSave = new ScrollPosition();
                        _scrollSave.horizontalPosition = dataGroup.horizontalScrollPosition;
                        _scrollSave.verticalPosition = dataGroup.verticalScrollPosition;
                        _scrollSave.firstVisible = dataProvider.getItemAt(firstVisible) as IListObject;
                        _scrollSave.lastVisible = dataProvider.getItemAt(lastVisible) as IListObject;
                    }
                }
            }
        }

        public function ensureIdIsVisible(id:uint):void
        {
            _ensureIdIsVisible = id;
        }

        public function refresh():void
        {
            ArrayCollection(dataProvider).refresh();
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function onEnsureIdIsVisible(id:uint):void
        {
            if (this.isEmpty) return;

            var firstVisible:IListObject;
            var lastVisible:IListObject;

            if (_scrollSave) {
                firstVisible = _scrollSave.firstVisible;
                lastVisible = _scrollSave.lastVisible;
            } else {
                var indicesInView:Vector.<int> = dataGroup.getItemIndicesInView();
                firstVisible = dataProvider.getItemAt(indicesInView[0]) as IListObject;
                lastVisible = dataProvider.getItemAt(indicesInView[indicesInView.length - 1]) as IListObject;
            }

            if ((firstVisible && (id - 1) < firstVisible.id) || (lastVisible && (id + 1) > lastVisible.id)) {
                var index:int = getIndexById(id);
                if (index != -1) ensureIndexIsVisible(index);
            } else if (_scrollSave)  {
                dataGroup.horizontalScrollPosition = _scrollSave.horizontalPosition;
                dataGroup.verticalScrollPosition = _scrollSave.verticalPosition;
            }

            _scrollSave = null;
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        protected function updateCompleteHandler(event:FlexEvent):void
        {
            if (_ensureIdIsVisible != uint.MAX_VALUE) {
                onEnsureIdIsVisible(_ensureIdIsVisible);
                _ensureIdIsVisible = uint.MAX_VALUE;
            }
        }
    }
}
