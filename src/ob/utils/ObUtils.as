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
    import flash.filesystem.File;
    import flash.net.FileFilter;
    import flash.utils.describeType;

    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    import nail.errors.AbstractClassError;
    import nail.utils.FileUtil;
    import nail.utils.StringUtil;

    import otlib.resources.Resources;
    import otlib.things.BindableThingType;
    import otlib.things.ThingCategory;
    import otlib.things.ThingType;
	import otlib.things.FrameGroupType;

    [ResourceBundle("strings")]

    public final class ObUtils
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ObUtils()
        {
            throw new AbstractClassError(ObUtils);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        public static function toLocale(category:String):String
        {
            var result:String = "";

            if (ThingCategory.getCategory(category)) {
                switch(category) {
                    case ThingCategory.ITEM:
                        result = Resources.getString("item");
                        break;
                    case ThingCategory.OUTFIT:
                        result = Resources.getString("outfit");
                        break;
                    case ThingCategory.EFFECT:
                        result = Resources.getString("effect");
                        break;
                    case ThingCategory.MISSILE:
                        result = Resources.getString("missile");
                        break;
                }
            }
            return result;
        }

        public static function hundredFloor(value:uint):uint
        {
            return (Math.floor(value / 100) * 100);
        }

        public static function getPatternsString(thing:ThingType, saveValue:Number):String
        {
            var text:String = "";

            if (saveValue == 2) {
                var list:Array = [];
                var description:XMLList = describeType(thing)..variable;
                for each (var property:XML in description) {
                    var name:String = property.@name;
                    var type:String = property.@type;
                    if (name != "id" && (type == "Boolean" || type == "uint")) {
                        list.push(BindableThingType.toLabel(name) + " = " + thing[name] + File.lineEnding);
                    }
                }

                list.sort(Array.CASEINSENSITIVE);
                var length:uint = list.length;
                for (var i:uint = 0; i < length; i++) {
                    text += list[i];
                }
                return text;
            }

            var resource:IResourceManager = ResourceManager.getInstance();
            text = resource.getString("strings", "width") + " = {0}" + File.lineEnding +
                resource.getString("strings", "height") + " = {1}" + File.lineEnding +
                resource.getString("strings", "cropSize") + " = {2}" + File.lineEnding +
                resource.getString("strings", "layers") + " = {3}" + File.lineEnding +
                resource.getString("strings", "patternX") + " = {4}" + File.lineEnding +
                resource.getString("strings", "patternY") + " = {5}" + File.lineEnding +
                resource.getString("strings", "patternZ") + " = {6}" + File.lineEnding +
                resource.getString("strings", "animations") + " = {7}" + File.lineEnding;

            return StringUtil.format(text,
                                     thing.frameGroups[FrameGroupType.DEFAULT].width,
                                     thing.frameGroups[FrameGroupType.DEFAULT].height,
                                     thing.frameGroups[FrameGroupType.DEFAULT].exactSize,
                                     thing.frameGroups[FrameGroupType.DEFAULT].layers,
                                     thing.frameGroups[FrameGroupType.DEFAULT].patternX,
                                     thing.frameGroups[FrameGroupType.DEFAULT].patternY,
                                     thing.frameGroups[FrameGroupType.DEFAULT].patternZ,
                                     thing.frameGroups[FrameGroupType.DEFAULT].frames);
        }

        public static function sortFiles(list:*, flags:uint):*
        {
            if (!list || flags == 0) return list;

            var array:Array = [];
            var length:uint = list.length;
            for (var i:uint = 0; i < length; i++)
            {
                var id:uint = 0;
                var file : File = list[i];
                var name:String = FileUtil.getName(file);

                var parts:Array = name.split("_");
                if (parts.length > 1) {
                    id = parseInt(parts[1])
                } else {
                    var extensionIndex:int = name.indexOf(".");
                    if (extensionIndex != -1) {
                        id = parseInt(name.substring(0, extensionIndex))
                    } else {
                        id = parseInt(name)
                    }
                }

                array[i] = {id:id, file:file};
            }

            array.sortOn("id", flags);
            for (i = 0; i < length; i++)
            {
                list[i] = array[i].file;
            }
            return list;
        }

        public static function createImagesFileFilter():Array
        {
            return [ new FileFilter(Resources.getString("allFormats"), "*.png;*.bmp;*.jpg;*.gif;"),
                new FileFilter("PNG (*.PNG)", "*.png"),
                new FileFilter("BMP (*.BMP)", "*.bmp"),
                new FileFilter("JPEG (*.JPG)", "*.jpg"),
                new FileFilter("CompuServe (*.GIF)", "*.gif")];
        }
    }
}
