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

package otlib.settings
{
    import com.mignari.utils.FileUtil;
    import com.mignari.utils.StringUtil;

    import flash.filesystem.File;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.system.System;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    import nail.errors.NullArgumentError;
    import nail.utils.Descriptor;

    import otlib.otml.OTMLDocument;
    import otlib.otml.OTMLNode;

    public class Settings implements ISettings
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_application:String;
        private var m_version:String;
        private var m_type:String;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get settingsApplicationName():String { return m_application; }
        public function get settingsApplicationVersion():String { return m_version; }
        public function get settingsClassType():String { return m_type; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Settings()
        {
            m_type = describeType(this).@name;

            var index:int = m_type.indexOf("::");
            if (index != -1)
                m_type = m_type.substr(index + 2);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function serialize():OTMLDocument
        {
            var describe:XML = describeType(this);
            var doc:OTMLDocument = OTMLDocument.create();
            var node:OTMLNode = new OTMLNode();
            node.tag = m_type + " < Settings";
            node.writeAt("__application", getName());
            node.writeAt("__version", getVersionNumber());
            node.writeAt("__type", String(describe.@name));

            var file:String = getQualifiedClassName(File);
            var point:String = getQualifiedClassName(Point);
            var rectangle:String = getQualifiedClassName(Rectangle);

            var properties:XMLList = describe.variable;
            for each (var property:XML in properties)
            {
                var name:String = property.@name;
                var type:String = property.@type;

                switch (type)
                {
                    case "int":
                    case "uint":
                    case "Number":
                    case "Boolean":
                    case "String":
                    case file:
                    case point:
                    case rectangle:
                        node.writeAt(name, this[name]);
                        break;
                }
            }

            doc.addChild(node);
            System.disposeXML(describe);
            return doc;
        }

        public function unserialize(doc:OTMLDocument):Boolean
        {
            if (!doc)
                throw new NullArgumentError("doc");

            if (doc.length == 0) return false;

            var node:OTMLNode = doc.getChildAt(0);
            if (!node.hasChild("__type") || node.getValueAt("__type") != getQualifiedClassName(this))
                return false;

            m_application = node.getValueAt("__application");
            m_version = node.getValueAt("__version");

            var describe:XML = describeType(this);
            var properties:XMLList = describe.variable;

            for each (var property:XML in properties)
            {
                var name:String = property.@name;
                var type:String = property.@type;

                if (node.hasChild(name))
                    this[name] = getValue(node.valueAt(name, ''), getDefinitionByName(type) as Class);
            }

            System.disposeXML(describe);
            return true;
        }

        //--------------------------------------
        // Protected
        //--------------------------------------

        protected function getName():String
        {
            return Descriptor.getName();
        }

        protected function getVersionNumber():String
        {
            return Descriptor.getVersionNumber();
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function getValue(value:String, type:Class):*
        {
            var values:Array;

            switch (type)
            {
                case int:
                    return int(value);

                case uint:
                    return uint(value);

                case Number:
                    return Number(value);

                case String:
                    return value;

                case Boolean:
                    return value == "true" ? true : false;

                case File:
                    return FileUtil.pathToFile(value);

                case Point:
                    values = StringUtil.trim(value).split(' ');
                    if (values.length == 2) {
                        return new Point(parseFloat(values[0]),
                                         parseFloat(values[1]));
                    }
                    break;

                case Rectangle:
                    values = StringUtil.trim(value).split(' ');
                    if (values.length == 4) {
                        return new Rectangle(parseFloat(values[0]),
                                             parseFloat(values[1]),
                                             parseFloat(values[2]),
                                             parseFloat(values[3]));
                    }
                    break;

                default:
                    throw new ArgumentError("Settings.getValue: Unsupported type: " + type);
            }

            return null;
        }
    }
}
