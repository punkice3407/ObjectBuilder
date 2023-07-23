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

package otlib.otml
{
    import com.mignari.errors.NullArgumentError;
    import com.mignari.utils.Color;
    import com.mignari.utils.FileUtil;
    import com.mignari.utils.isNullOrEmpty;

    import flash.filesystem.File;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.utils.StringUtil;

    import otlib.core.otlib_internal;
    import otlib.geom.Rect;
    import otlib.geom.Size;

    use namespace otlib_internal;

    public class OTMLNode
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var source:String;
        public var tag:String;
        public var value:String;
        public var isUnique:Boolean;
        public var isNull:Boolean;

        private var m_children:Vector.<OTMLNode>;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get children():Vector.<OTMLNode> { return m_children; }
        public function get hasChildren():Boolean { return (m_children != null); }
        public function get hasTag():Boolean { return (tag != null && tag.length != 0); }
        public function get hasValue():Boolean { return (value != null && value.length != 0); }
        public function get length():uint { return m_children ? m_children.length : 0; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OTMLNode()
        {
           ////
        }

        //--------------------------------------------------------------------------
        //
        // METHODS
        //
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function addChild(newChild:OTMLNode):void
        {
            addChildAt(newChild, this.length);
        }

        public function addChildAt(newChild:OTMLNode, index:int):void
        {
            if (!newChild)
            {
                throw new NullArgumentError("newChild");
            }

            index = Math.max(0, Math.min(this.length, index));

            // replace is needed when the tag is marked as unique
            if(m_children && newChild.hasTag)
            {
                var toRemove:Vector.<uint> = new Vector.<uint>();
                var hasUnique:Boolean = false;
                var length:uint = this.length;
                for (var i:uint = 0; i < length; i++)
                {
                    var child:OTMLNode = m_children[i];
                    if (child.tag == newChild.tag && (child.isUnique || newChild.isUnique))
                    {
                        newChild.isUnique = true;

                        if (child.hasChildren && newChild.hasChildren)
                        {
                            var tmpNode:OTMLNode = child.clone();
                            tmpNode.merge(newChild);
                            newChild.copy(tmpNode);
                        }

                        var idx:int = m_children.indexOf(child);
                        if (idx != -1)
                        {
                            m_children[idx] = newChild;
                        }

                        // find child with the same tag
                        for (var k:int = 0; k < length; k++)
                        {
                            var node:OTMLNode = m_children[k];
                            if(node != newChild && node.tag == newChild.tag)
                            {
                                toRemove[toRemove.length] = k;
                            }
                        }

                        hasUnique = true;
                        break;
                    }
                }

                // remove any other child with the same tag
                length = toRemove.length;
                for (i = 0; i < length; i++)
                {
                    m_children.removeAt(toRemove[i]);
                }

                if (hasUnique)
                {
                    return;
                }
            }

            if (!m_children)
            {
                m_children = new Vector.<OTMLNode>();
            }

            m_children.splice(index, 0, newChild);
        }

        public function removeChild(child:OTMLNode):Boolean
        {
            if (m_children)
            {
                var index:int = m_children.indexOf(child);
                if (index != -1)
                {
                    m_children.removeAt(index);
                    return true;
                }
            }

            return false;
        }

        public function write(value:String):void
        {
            this.value = value;
        }

        public function writeAt(tag:String, value:*, index:int = -1):void
        {
            var stringValue:String;
            if (value is int || value is uint || value is Number || value is Boolean)
            {
                stringValue = value.toString();
            }
            else if (value is String)
            {
                stringValue = isNullOrEmpty(value) ? '~' : String(value);
            }
            else if (value is File)
            {
                stringValue = value == null ? '~' : File(value).nativePath.replace(/\\/g, '/');
            }
            else if (value is Point)
            {
                stringValue = value == null ? '~' : (value.x + ' ' + value.y);
            }
            else if (value is Rectangle)
            {
                stringValue = value == null ? '~' : (value.x + ' ' + value.y + ' ' + value.width + ' ' + value.height);
            }
            else
            {
                stringValue = '~';
            }

            if (index == -1)
            {
                index = this.length;
            }

            var child:OTMLNode = create(tag);
            child.isUnique = true;
            child.write(stringValue);
            addChildAt(child, index);
        }

        public function writeIn(type:Object):void
        {
            var child:OTMLNode = create(tag);
            child.write(value);
            addChild(child);
        }

        public function readAt(childTag:String, type:Class):*
        {
            var node:OTMLNode = getChildByTag(childTag);

            switch (type)
            {
                case int:
                    return node.toInt();

                case uint:
                    return node.toUInt();

                case Number:
                    return node.toNumber();

                case String:
                    return node.value;

                case Boolean:
                    return node.toBoolean();

                case File:
                    return node.toFile();

                case Rectangle:
                    return node.toRectange();

                case Point:
                    return node.toPoint();
            }

            throw new Error("Invalid class type.");
        }

        public function getValueAt(childTag:String):String
        {
            var node:OTMLNode = getChildByTag(childTag);
            return node.value;
        }

        public function valueAt(childTag:String, def:String = null):String
        {
            var node:OTMLNode = getChild(childTag);
            if (node && !node.isNull)
            {
                return node.value;
            }

            return def;
        }

        public function setValue(tag:String, value:Object):void
        {
            var node:OTMLNode = getChild(tag);
            if (node)
            {
                node.value = value.toString();
            }
        }

        public function getChildByTag(tag:String):OTMLNode
        {
            var node:OTMLNode = getChild(tag);
            if (!node || node.isNull)
            {
                throw new OTMLError(this, StringUtil.substitute("child node with tag '{0}' not found", tag));
            }

            return node;
        }

        public function getChild(tag:String):OTMLNode
        {
            var length:uint = this.length;
            for (var i:uint = 0; i < length; i++)
            {
                var node:OTMLNode = m_children[i];
                if (node.tag == tag)
                {
                    return node;
                }
            }

            return null;
        }

        public function getChildAt(index:int):OTMLNode
        {
            if (m_children && index >= 0 && index < m_children.length)
            {
                return m_children[index];
            }

            return null;
        }

        public function getChildrenAt(tag:String):Vector.<OTMLNode>
        {
            var result:Vector.<OTMLNode> = new Vector.<OTMLNode>();

            var length:uint = this.length;
            for (var i:uint = 0; i < length; i++)
            {
                var node:OTMLNode = m_children[i];
                if (node.tag == tag)
                {
                    result[result.length] = node;
                }
            }

            return result;
        }

        public function hasChild(tag:String):Boolean
        {
            var length:uint = this.length;
            for (var i:uint = 0; i < length; i++)
            {
                var node:OTMLNode = m_children[i];
                if (node.tag == tag)
                {
                    return true;
                }
            }

            return false;
        }

        public function toString():String
        {
            return value == "~" ? null : value;
        }

        public function toPoint():Point
        {
            var split:Array = this.value.split(" ");
            if (split.length != 2)
            {
                throw new OTMLError(this, StringUtil.substitute("failed to cast node value '{0}' to type 'Point'", this.value));
            }

            var point:Point = new Point();
            point.x = parseInt(split[0]);
            point.y = parseInt(split[1]);
            return point;
        }

        public function toRectange():Rectangle
        {
            var rect:Rectangle = new Rectangle();

            if (this.tag == "Rectangle")
            {
                rect.x = readAt("x", int);
                rect.y = readAt("y", int);
                rect.width = readAt("width", int);
                rect.height = readAt("height", int);
            }
            else
            {
                var split:Array = this.value.split(" ");
                if (split.length != 4)
                {
                    throw new OTMLError(this, StringUtil.substitute("failed to cast node value '{0}' to type 'Rectangle'", this.value));
                }

                rect.x = parseInt(split[0]);
                rect.y = parseInt(split[1]);
                rect.width = parseInt(split[2]);
                rect.height = parseInt(split[3]);
            }

            return rect;
        }

        public function toRect():Rect
        {
            var rect:Rect = new Rect();

            if (this.tag == "Rect")
            {
                rect.x = readAt("x", int);
                rect.y = readAt("y", int);
                rect.width = readAt("width", int);
                rect.height = readAt("height", int);
            }
            else
            {
                var split:Array = this.value.split(" ");
                if (split.length != 4)
                {
                    throw new OTMLError(this, StringUtil.substitute("failed to cast node value '{0}' to type 'Rect'", this.value));
                }

                rect.x = parseInt(split[0]);
                rect.y = parseInt(split[1]);
                rect.width = parseInt(split[2]);
                rect.height = parseInt(split[3]);
            }

            return rect;
        }

        public function toSize():Size
        {
            var split:Array = this.value.split(" ");
            if (split.length != 2)
            {
                throw new OTMLError(this, StringUtil.substitute("failed to cast node value '{0}' to type 'Size'", this.value));
            }

            var size:Size = new Size();
            size.width = parseInt(split[0]);
            size.height = parseInt(split[1]);
            return size;
        }

        public function toColor():Color
        {
            return Color.toColor(this.value);
        }

        public function toUInt():uint
        {
            return uint(this.value);
        }

        public function toInt():int
        {
            return parseInt(this.value);
        }

        public function toNumber():Number
        {
            return parseFloat(this.value);
        }

        public function toArray():Array
        {
            if (this.value != null && this.value != "~")
            {
                return this.value.split(" ");
            }

            return null;
        }

        public function toBoolean():Boolean
        {
            return this.value == "true" ? true : false;
        }

        public function toFile():File
        {
            if (this.value != null && this.value != "~")
            {
                return FileUtil.pathToFile(this.value);
            }

            return null;
        }

        public function sizeAt(childTag:String, def:Size = null):Size
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toSize();
            }

            return def;
        }

        public function rectangleAt(childTag:String, def:Rectangle = null):Rectangle
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toRectange();
            }

            return def;
        }

        public function intAt(childTag:String, def:int = 0):int
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toInt();
            }

            return def;
        }

        public function uintAt(childTag:String, def:uint = 0):uint
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toUInt();
            }

            return def;
        }

        public function arrayAt(childTag:String, def:Array = null):Array
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toArray();
            }

            return def;
        }

        public function booleanAt(childTag:String, def:Boolean = false):Boolean
        {
            var child:OTMLNode = getChild(childTag);
            if (child && !child.isNull)
            {
                return child.toBoolean();
            }

            return def;
        }

        public function merge(node:OTMLNode):void
        {
            this.tag = node.tag;
            this.source = node.source;

            var length:uint = node.length;
            for (var i:uint = 0; i < length; i++)
            {
                this.addChild(node.children[i]);
            }
        }

        public function clone():OTMLNode
        {
            var newNode:OTMLNode = new OTMLNode();
            newNode.tag = this.tag;
            newNode.value = this.value;
            newNode.isUnique = this.isUnique;
            newNode.isNull = this.isNull;
            newNode.source = this.source;

            var length:uint = m_children.length;
            for (var i:uint = 0; i < length; i++)
            {
                newNode.addChild(m_children[i]);
            }

            return newNode;
        }

        public function copy(node:OTMLNode):void
        {
            this.tag = node.tag;
            this.value = node.value;
            this.isUnique = node.isUnique;
            this.isNull = node.isNull;
            this.source = node.source;

            clear();

            var length:uint = node.length;
            for (var i:uint = 0; i < length; i++)
            {
                this.addChild(node.children[i]);
            }
        }

        /**
         * Sorteia as nós pela ordem alfabetica.
         */
        public function sortChidren():Vector.<OTMLNode>
        {
            if (m_children && m_children.length > 1)
            {
                this.children.sort(function(a:OTMLNode, b:OTMLNode):Number
                {
                    if (a.tag != null && b.tag != null)
                    {
                        if (a.tag < b.tag)
                        {
                            return -1;
                        }
                        else if (a.tag > b.tag)
                        {
                            return 1;
                        }
                    }

                    return 0;
                });
            }

            return m_children;
        }

        public function clear():void
        {
            m_children = null;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        static public function create(tag:String, value:String = null, unique:Boolean = false):OTMLNode
        {
            var node:OTMLNode = new OTMLNode();
            node.tag = tag;
            node.value = value;
            node.isUnique = unique;
            return node;
        }
    }
}
