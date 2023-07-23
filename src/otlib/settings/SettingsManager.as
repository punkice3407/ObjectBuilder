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
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import nail.errors.NullArgumentError;
    import nail.errors.SingletonClassError;

    import otlib.otml.OTMLDocument;

    public final class SettingsManager implements ISettingsManager
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_directory:File;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SettingsManager()
        {
            if (s_instance)
                throw new SingletonClassError(SettingsManager);

            s_instance = this;

            m_directory = File.applicationStorageDirectory.resolvePath("settings");
            m_directory.createDirectory();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function loadSettings(settings:ISettings):Boolean
        {
            if (!settings)
                throw new NullArgumentError("settings");

            var type:String = settings.settingsClassType;

            var file:File = m_directory.resolvePath(type + ".otcfg");
            if (!file.exists) return false;

            var doc:OTMLDocument = OTMLDocument.parse(file);
            return settings.unserialize(doc);
        }

        public function saveSettings(settings:ISettings):Boolean
        {
            if (!settings)
                throw new NullArgumentError("settings");

            var type:String = settings.settingsClassType;
            var doc:OTMLDocument = settings.serialize();
            var file:File = m_directory.resolvePath(type + ".otcfg");
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes( doc.toOTMLString() );
            stream.close();

            return true;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static var s_instance:ISettingsManager;
        public static function getInstance():ISettingsManager
        {
            if (!s_instance)
                new SettingsManager();

            return s_instance;
        }
    }
}
