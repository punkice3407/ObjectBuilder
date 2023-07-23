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

package ob.core
{
    import flash.filesystem.File;

    import mx.core.IUIComponent;
    import mx.core.IWindow;

    import ob.settings.ObjectBuilderSettings;

    import otlib.core.IVersionStorage;
    import otlib.core.Version;
    import otlib.utils.ClientInfo;

    public interface IObjectBuilder extends IUIComponent, IWindow
    {
        function get locked():Boolean;

        function get settings():ObjectBuilderSettings;
        function get versionStorage():IVersionStorage;
        function get version():Version;

        function get showPreviewPanel():Boolean;
        function set showPreviewPanel(value:Boolean):void;
        function get showThingsPanel():Boolean;
        function set showThingsPanel(value:Boolean):void;
        function get showSpritesPanel():Boolean;
        function set showSpritesPanel(value:Boolean):void;

        function get clientInfo():ClientInfo;
        function get clientExtendedEnabled():Boolean;
        function get clientTransparencyEnabled():Boolean;
        function get clientChanged():Boolean;
        function get clientIsTemporary():Boolean;
        function get clientLoaded():Boolean;

        function createNewProject():void;
        function openProject(directory:File = null):void;
        function compileProject():void;
        function compileProjectAs():void;
        function unloadProject():void;

        function openPreferencesWindow():void;

        function openFinder():void;
        function closeFinder():void;

        function openObjectViewer(file:File = null):void;
        function closeObjectViewer():void;

        function openSlicer(file:File = null):void;
        function closeSlicer():void;

        function openAnimationEditor():void;
        function closeAnimationEditor():void;

        function openAssetStore():void;
        function closeAssetStore():void;

        function openSpritesOptimizer():void;

        function openLogWindow():void;
        function closeLogWindow():void;
    }
}
