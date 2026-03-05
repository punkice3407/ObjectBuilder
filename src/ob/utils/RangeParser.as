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

package ob.utils
{
    /**
     * Static utility class for parsing ID ranges like "555-666;777;2000-2300".
     * Uses Vector.<uint> for type safety and performance.
     */
    public class RangeParser
    {
        // --------------------------------------------------------------------------
        // STATIC
        // --------------------------------------------------------------------------

        /**
         * Parses a range string into a sorted, deduplicated Vector of IDs.
         * Format: "555-666;777;2000-2300" (semicolons or commas as separators)
         */
        public static function parseRange(rangeString:String):Vector.<uint>
        {
            var result:Vector.<uint> = new Vector.<uint>();
            if (!rangeString)
                return result;

            rangeString = rangeString.replace(/\s+/g, "");
            if (rangeString.length == 0)
                return result;

            var parts:Array = rangeString.split(/[;,]/);
            var seen:Object = {};

            for (var i:uint = 0; i < parts.length; i++)
            {
                var part:String = parts[i];
                if (part.length == 0)
                    continue;

                var dashIndex:int = part.indexOf("-");
                if (dashIndex > 0)
                {
                    var startStr:String = part.substring(0, dashIndex);
                    var endStr:String = part.substring(dashIndex + 1);
                    var start:uint = uint(startStr);
                    var end:uint = uint(endStr);

                    if (start > end)
                    {
                        var tmp:uint = start;
                        start = end;
                        end = tmp;
                    }

                    for (var id:uint = start; id <= end; id++)
                    {
                        if (!seen[id])
                        {
                            seen[id] = true;
                            result.push(id);
                        }
                    }
                }
                else
                {
                    var singleId:uint = uint(part);
                    if (!seen[singleId])
                    {
                        seen[singleId] = true;
                        result.push(singleId);
                    }
                }
            }

            result.sort(sortUint);
            return result;
        }

        /**
         * Parses a range string with min/max bounds clamping.
         */
        public static function parseRangeWithBounds(rangeString:String, minId:uint, maxId:uint):Vector.<uint>
        {
            var all:Vector.<uint> = parseRange(rangeString);
            var result:Vector.<uint> = new Vector.<uint>();

            for (var i:uint = 0; i < all.length; i++)
            {
                if (all[i] >= minId && all[i] <= maxId)
                    result.push(all[i]);
            }

            return result;
        }

        /**
         * Validates that a range string is well-formed.
         */
        public static function validateRange(rangeString:String):Boolean
        {
            if (!rangeString)
                return false;

            rangeString = rangeString.replace(/\s+/g, "");
            if (rangeString.length == 0)
                return false;

            var pattern:RegExp = /^(\d+(-\d+)?)([\s]*[;,][\s]*(\d+(-\d+)?))*$/;
            return pattern.test(rangeString);
        }

        /**
         * Returns a human-readable summary of the range.
         */
        public static function getRangeSummary(rangeString:String):String
        {
            var ids:Vector.<uint> = parseRange(rangeString);
            if (ids.length == 0)
                return "No IDs";

            if (ids.length == 1)
                return "1 ID: " + ids[0];

            return ids.length + " IDs: " + ids[0] + " - " + ids[ids.length - 1];
        }

        // --------------------------------------------------------------------------
        // PRIVATE
        // --------------------------------------------------------------------------

        private static function sortUint(a:uint, b:uint):int
        {
            if (a < b) return -1;
            if (a > b) return 1;
            return 0;
        }
    }
}
