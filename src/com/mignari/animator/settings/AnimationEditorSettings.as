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

package com.mignari.animator.settings
{
    import com.mignari.settings.Settings;

    import flash.filesystem.File;

    import nail.image.ImageFormat;
    import nail.utils.FileUtil;
    import nail.utils.isNullOrEmpty;

    import otlib.core.Version;
    import otlib.core.VersionStorage;
    import otlib.utils.OTFormat;

    public class AnimationEditorSettings extends Settings
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        public var maximized:Boolean;
        public var lastDirectoryPath:String;
        public var exportFormat:String;
        public var datSignature:int;
        public var sprSignature:int;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function AnimationEditorSettings()
        {
            super();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function getLastDirectory():File
        {
            if (!isNullOrEmpty(lastDirectoryPath))
            {
                try
                {
                    var directory:File = new File(lastDirectoryPath);
                    if (directory.exists)
                        return directory;
                }
                catch(error:Error)
                {
                    //trace(error.message);
                }
            }

            return File.userDirectory;
        }

        public function setLastDirectory(directory:File):void
        {
            if (directory && directory.exists)
                lastDirectoryPath = FileUtil.getDirectory(directory).nativePath;
            else
                lastDirectoryPath = "";
        }

        public function getLastExportFormat():String
        {
            if (!isNullOrEmpty(exportFormat))
            {
                if (ImageFormat.hasImageFormat(exportFormat) || exportFormat == OTFormat.OBD)
                    return exportFormat;
            }

            return null;
        }

        public function setLastExportFormat(format:String):void
        {
            format = format != null ? format.toLowerCase() : "";
            this.exportFormat = format;
        }

        public function getLastExportVersion():Version
        {
            return VersionStorage.getInstance().getBySignatures(datSignature, sprSignature);
        }

        public function setLastExportVersion(version:Version):void
        {
            this.datSignature = version ? version.datSignature : 0;
            this.sprSignature = version ? version.sprSignature : 0;
        }
    }
}
