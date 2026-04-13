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

package otlib.items
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    /**
     * Writes items.xml file from ServerItemList.
     * Uses forgottenserver format with tab indentation.
     * Supports dynamic tag attributes from config (placement="tag").
     * Supports range optimization (fromid/toid) for consecutive items with identical attributes.
     */
    public class ItemsXmlWriter
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        /** Ordered list of attribute keys that go on the <item> tag (from config placement="tag") */
        private var _tagAttributeKeys:Array;

        /** XML encoding for items.xml (from config itemsXmlEncoding) */
        private var _encoding:String;

        /** Whether to use fromid/toid range optimization (from config supportsFromToId) */
        private var _supportsFromToId:Boolean;

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ItemsXmlWriter()
        {
            // Default tag attributes (forgottenserver order)
            _tagAttributeKeys = ["article", "name", "plural", "editorsuffix"];
            // Default encoding
            _encoding = "iso-8859-1";

            // Default to true as per standard
            _supportsFromToId = true;
        }

        // --------------------------------------------------------------------------
        // PUBLIC METHODS
        // --------------------------------------------------------------------------

        /**
         * Sets the ordered list of attribute keys that should be written on the <item> tag.
         * Order is preserved - attributes are written in the order they appear in this array.
         * @param keys Array of attribute key strings from config (placement="tag")
         */
        public function setTagAttributeKeys(keys:Array):void
        {
            if (keys && keys.length > 0)
                _tagAttributeKeys = keys;
        }

        /**
         * Sets the encoding for items.xml output.
         * @param encoding Encoding string (e.g. "iso-8859-1", "UTF-8")
         */
        public function setEncoding(encoding:String):void
        {
            if (encoding && encoding.length > 0)
                _encoding = encoding;
        }

        /**
         * Sets whether to use fromid/toid range optimization.
         * @param value Boolean true/false
         */
        public function setSupportsFromToId(supported:Boolean):void
        {
            _supportsFromToId = supported;
        }

        /**
         * Writes ServerItemList to items.xml using forgottenserver format
         * Writes directly to file stream to optimize memory usage.
         *
         * @param filePath Path to items.xml file
         * @param items ServerItemList to write
         * @return true on success, false on failure
         */
        public function write(filePath:String, items:ServerItemList):Boolean
        {
            if (!filePath || !items)
                return false;

            var targetFile:File = new File(filePath);
            var tempFile:File = new File(filePath + ".tmp");
            var stream:FileStream = new FileStream();

            try
            {
                stream.open(tempFile, FileMode.WRITE);

                var header:String = '<?xml version="1.0" encoding="' + _encoding + '"?>\n';
                header += '<items>\n';
                writeString(stream, header);

                // Precompute tag attributes lookup once
                var tagAttrsLookup:Object = {};
                for each (var tk:String in _tagAttributeKeys)
                    tagAttrsLookup[tk] = true;

                var itemsArray:Array = items.toArray();
                var i:int = 0;
                var len:int = itemsArray.length;

                while (i < len)
                {
                    var item:ServerItem = itemsArray[i] as ServerItem;

                    // Skip items without any XML data
                    if (!hasXmlData(item))
                    {
                        i++;
                        continue;
                    }

                    // Find consecutive items with identical attributes
                    // Only if fromid/toid is supported (optimized)
                    var rangeEnd:int = _supportsFromToId ? findRangeEnd(itemsArray, i, len) : i;

                    if (rangeEnd > i)
                    {
                        // Write as range (fromid/toid)
                        writeItemInternal(stream, item, itemsArray[rangeEnd] as ServerItem, tagAttrsLookup);
                        i = rangeEnd + 1;
                    }
                    else
                    {
                        // Write single item
                        writeItemInternal(stream, item, null, tagAttrsLookup);
                        i++;
                    }
                }

                writeString(stream, '</items>\n');
                stream.close();

                // If original exists, delete it
                if (targetFile.exists)
                {
                    targetFile.deleteFile();
                }

                // Move temp to target
                tempFile.moveTo(targetFile);

                return true;
            }
            catch (error:Error)
            {
                trace("ItemsXmlWriter error:", error.message);
                try
                {
                    stream.close();
                }
                catch (e:Error)
                {
                }
                try
                {
                    if (tempFile.exists)
                        tempFile.deleteFile();
                }
                catch (e:Error)
                {
                }
                return false;
            }

            return false;
        }

        private function writeString(stream:FileStream, str:String):void
        {
            if (_encoding == "UTF-8")
                stream.writeUTFBytes(str);
            else
                stream.writeMultiByte(str, _encoding);
        }

        // --------------------------------------------------------------------------
        // PRIVATE METHODS
        // --------------------------------------------------------------------------

        /**
         * Internal method to write item or item range directly to stream.
         * Uses _tagAttributeKeys for tag attributes.
         */
        private function writeItemInternal(stream:FileStream, item:ServerItem, endItem:ServerItem, tagAttrsLookup:Object):void
        {
            var hasChildren:Boolean = hasNestedAttributes(item, tagAttrsLookup);
            var isRange:Boolean = (endItem != null && endItem.id != item.id);

            var xml:String = '\t<item';

            // 1. ID or range (always first)
            if (isRange)
            {
                xml += ' fromid="' + item.id + '" toid="' + endItem.id + '"';
            }
            else
            {
                xml += ' id="' + item.id + '"';
            }

            // 2. Tag attributes from config (in order)
            var attrs:Dictionary = item.getXmlAttributes();
            for each (var tagKey:String in _tagAttributeKeys)
            {
                var tagValue:String = getAttributeValue(item, tagKey, attrs);
                if (tagValue != null)
                    tagValue = tagValue.replace(/^\s+|\s+$/g, "");
                if (tagValue !== null && (tagValue.length > 0 || tagKey == "name"))
                {
                    xml += ' ' + tagKey + '="' + escapeXml(tagValue) + '"';
                }
            }

            // 3. Nested attributes
            if (hasChildren)
            {
                xml += '>\n';
                writeString(stream, xml); // Write tag opening

                if (attrs)
                {
                    writeAttributesRecursive(stream, attrs, 2, tagAttrsLookup);
                }

                writeString(stream, '\t</item>\n');
            }
            else
            {
                xml += ' />\n';
                writeString(stream, xml);
            }
        }

        /**
         * Gets attribute value from item, checking both dedicated properties and xmlAttributes.
         */
        private function getAttributeValue(item:ServerItem, key:String, attrs:Dictionary):String
        {
            // Check dedicated ServerItem properties first
            switch (key)
            {
                case "name":
                    return item.nameXml;
                case "article":
                    return item.article;
                case "plural":
                    return item.plural;
            }

            // Check xmlAttributes
            if (attrs && attrs[key] !== undefined && attrs[key] !== null)
                return String(attrs[key]);

            return null;
        }

        /** Map of attribute key -> priority (int). Lower values come first. */
        private var _attributePriority:Object;

        public function setAttributePriority(map:Object):void
        {
            _attributePriority = map;
        }

        /**
         * Recursively writes attributes to stream.
         * Skips tag attributes (from tagAttrsLookup) which are on the item tag.
         * Uses _attributePriority for sorting if available, otherwise alphabetical.
         */
        private function writeAttributesRecursive(stream:FileStream, attrs:Dictionary, indentLevel:int, tagAttrsLookup:Object):void
        {
            // Collect keys (excluding tag attrs and internal keys)
            var keys:Array = [];
            for (var k:String in attrs)
            {
                if (k != "_parentValue" && !tagAttrsLookup[k])
                    keys.push(k);
            }

            // Deterministic base order: sort alphabetically first
            keys.sort(Array.CASEINSENSITIVE);

            // Stable sort by priority using RETURNINDEXEDARRAY
            if (_attributePriority)
            {
                var indexed:Array = keys.sort(function(a:String, b:String):int
                    {
                        var pA:int = (_attributePriority[a] !== undefined) ? _attributePriority[a] : int.MAX_VALUE;
                        var pB:int = (_attributePriority[b] !== undefined) ? _attributePriority[b] : int.MAX_VALUE;
                        if (pA != pB) return pA - pB;
                        // Stable fallback: preserve alphabetical order for equal priorities
                        var aLow:String = a.toLowerCase();
                        var bLow:String = b.toLowerCase();
                        if (aLow < bLow) return -1;
                        if (aLow > bLow) return 1;
                        return 0;
                    }, Array.RETURNINDEXEDARRAY);

                var sorted:Array = [];
                for (var j:int = 0; j < indexed.length; j++)
                    sorted.push(keys[indexed[j]]);
                keys = sorted;
            }

            var indent:String = "";
            for (var i:int = 0; i < indentLevel; i++)
                indent += "\t";

            for each (var key:String in keys)
            {
                var value:Object = attrs[key];
                var xml:String = "";

                if (value is Dictionary)
                {
                    // Nested attribute - write parent and recurse
                    var nestedDict:Dictionary = value as Dictionary;

                    var valueStr:String = "";
                    if (nestedDict["_parentValue"])
                    {
                        var pv:String = String(nestedDict["_parentValue"]).replace(/^\s+|\s+$/g, "");
                        valueStr = ' value="' + escapeXml(pv) + '"';
                    }

                    xml = indent + '<attribute key="' + key + '"' + valueStr + '>\n';
                    writeString(stream, xml);

                    writeAttributesRecursive(stream, nestedDict, indentLevel + 1, tagAttrsLookup);

                    writeString(stream, indent + '</attribute>\n');
                }
                else
                {
                    // Simple attribute
                    var sv:String = String(value).replace(/^\s+|\s+$/g, "");
                    xml = indent + '<attribute key="' + key + '" value="' + escapeXml(sv) + '" />\n';
                    writeString(stream, xml);
                }
            }
        }

        /**
         * Finds the end index of a range of consecutive items with identical attributes
         */
        private function findRangeEnd(itemsArray:Array, startIndex:int, len:int):int
        {
            var startItem:ServerItem = itemsArray[startIndex] as ServerItem;

            if (!hasXmlData(startItem))
                return startIndex;

            var endIndex:int = startIndex;

            for (var i:int = startIndex + 1; i < len; i++)
            {
                var nextItem:ServerItem = itemsArray[i] as ServerItem;

                if (!nextItem)
                    break;

                // Check if IDs are consecutive
                if (nextItem.id != (itemsArray[i - 1] as ServerItem).id + 1)
                    break;

                // Check if attributes are identical
                if (!areAttributesEqual(startItem, nextItem))
                    break;

                endIndex = i;
            }

            return endIndex;
        }

        /**
         * Checks if two items have identical XML attributes
         */
        private function areAttributesEqual(a:ServerItem, b:ServerItem):Boolean
        {
            // Compare basic properties
            if (a.nameXml != b.nameXml)
                return false;
            if (a.article != b.article)
                return false;
            if (a.plural != b.plural)
                return false;

            // Compare dynamic attributes using deep comparison
            var attrsA:Dictionary = a.getXmlAttributes();
            var attrsB:Dictionary = b.getXmlAttributes();

            return deepCompareDictionaries(attrsA, attrsB);
        }

        /**
         * Deep comparison of two Dictionary objects, including nested Dictionaries.
         */
        private function deepCompareDictionaries(a:Dictionary, b:Dictionary):Boolean
        {
            // Both null or empty - equal
            var hasA:Boolean = a && countKeys(a) > 0;
            var hasB:Boolean = b && countKeys(b) > 0;

            if (!hasA && !hasB)
                return true;
            if (hasA != hasB)
                return false;

            // Compare key/value pairs with recursive handling for nested Dictionaries
            var countA:int = 0;
            for (var key:String in a)
            {
                // Key doesn't exist in b
                if (!b.hasOwnProperty(key))
                    return false;

                var valA:Object = a[key];
                var valB:Object = b[key];

                // Both are Dictionaries - recurse
                if (valA is Dictionary && valB is Dictionary)
                {
                    if (!deepCompareDictionaries(valA as Dictionary, valB as Dictionary))
                        return false;
                }
                // One is Dictionary, other is not - not equal
                else if ((valA is Dictionary) != (valB is Dictionary))
                {
                    return false;
                }
                // Compare primitive values
                else if (valA != valB)
                {
                    return false;
                }
                countA++;
            }

            // Make sure B doesn't have extra keys
            return countKeys(b) == countA;
        }

        private function countKeys(dict:Dictionary):int
        {
            var count:int = 0;
            for (var key:* in dict)
                count++;
            return count;
        }

        private function hasXmlData(item:ServerItem):Boolean
        {
            if (item.nameXml && item.nameXml.length > 0)
                return true;
            if (item.article && item.article.length > 0)
                return true;
            if (item.plural && item.plural.length > 0)
                return true;
            var attrs:Dictionary = item.getXmlAttributes();
            if (attrs && countKeys(attrs) > 0)
                return true;
            return false;
        }

        private function hasNestedAttributes(item:ServerItem, tagAttrsLookup:Object):Boolean
        {
            var attrs:Dictionary = item.getXmlAttributes();
            if (!attrs)
                return false;

            // Check if there are any non-tag attributes
            for (var key:String in attrs)
            {
                if (!tagAttrsLookup[key] && key != "_parentValue")
                    return true;
            }
            return false;
        }

        private function escapeXml(str:String):String
        {
            if (!str)
                return "";

            return str.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;");
        }
    }
}
