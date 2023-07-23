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

package otlib.assets
{
    import nail.errors.AbstractClassError;

    public final class Assets
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function Assets()
        {
            throw new AbstractClassError(Assets);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        [Embed(source="/../assets/icons/export.png", mimeType="image/png")]
        public static const EXPORT:Class;

        [Embed(source="/../assets/icons/import.png", mimeType="image/png")]
        public static const IMPORT:Class;

        [Embed(source="/../assets/icons/duplicate.png", mimeType="image/png")]
        public static const DUPLICATE:Class;

        [Embed(source="/../assets/icons/new.png", mimeType="image/png")]
        public static const NEW:Class;

        [Embed(source="/../assets/icons/delete.png", mimeType="image/png")]
        public static const DELETE:Class;

        [Embed(source="/../assets/icons/edit_icon.png", mimeType="image/png")]
        public static const EDIT:Class;

        [Embed(source="/../assets/icons/replace_icon.png", mimeType="image/png")]
        public static const REPLACE:Class;

        [Embed(source="/../assets/icons/open.png", mimeType="image/png")]
        public static const OPEN:Class;

        [Embed(source="/../assets/icons/save.png", mimeType="image/png")]
        public static const SAVE:Class;

        [Embed(source="/../assets/icons/save_as.png", mimeType="image/png")]
        public static const SAVE_AS:Class;

        [Embed(source="/../assets/icons/info.png", mimeType="image/png")]
        public static const INFO:Class;

        [Embed(source="/../assets/icons/log.png", mimeType="image/png")]
        public static const LOG:Class;

        [Embed(source="/../assets/icons/new_files.png", mimeType="image/png")]
        public static const NEW_FILE:Class;

        [Embed(source="/../assets/icons/paste.png", mimeType="image/png")]
        public static const PASTE:Class;

        [Embed(source="/../assets/icons/mini_copy.png", mimeType="image/png")]
        public static const MINI_COPY:Class;

        [Embed(source="/../assets/icons/mini_paste.png", mimeType="image/png")]
        public static const MINI_PASTE:Class;

        [Embed(source="/../assets/icons/binoculars.png", mimeType="image/png")]
        public static const BINOCULARS:Class;

        [Embed(source="/../assets/icons/viewer_icon.png", mimeType="image/png")]
        public static const VIEWER:Class;

        [Embed(source="/../assets/icons/slicer.png", mimeType="image/png")]
        public static const SLICER:Class;

        [Embed(source="/../assets/icons/animation.png", mimeType="image/png")]
        public static const ANIMATION:Class;

        [Embed(source="/../assets/icons/store.png", mimeType="image/png")]
        public static const ASSET_STORE:Class;

        [Embed(source="/../assets/icons/outfit.png", mimeType="image/png")]
        public static const OUTFIT:Class;

        [Embed(source="/../assets/icons/show_list_icon.png", mimeType="image/png")]
        public static const SHOW_LIST_ICON:Class;

        [Embed(source="/../assets/icons/first.png", mimeType="image/png")]
        public static const FIRST:Class;

        [Embed(source="/../assets/icons/previous.png", mimeType="image/png")]
        public static const PREVIOUS:Class;

        [Embed(source="/../assets/icons/back.png", mimeType="image/png")]
        public static const BACK:Class;

        [Embed(source="/../assets/icons/play.png", mimeType="image/png")]
        public static const PLAY:Class;

        [Embed(source="/../assets/icons/pause.png", mimeType="image/png")]
        public static const PAUSE:Class;

        [Embed(source="/../assets/icons/next.png", mimeType="image/png")]
        public static const NEXT:Class;

        [Embed(source="/../assets/icons/last.png", mimeType="image/png")]
        public static const LAST:Class;

        [Embed(source="/../assets/icons/error.png", mimeType="image/png")]
        public static const ERROR:Class;

        [Embed(source="/../assets/icons/alert_sprite32.png", mimeType="image/png")]
        public static const ALERT_IMAGE32:Class;

        [Embed(source="/../assets/icons/alert_sprite64.png", mimeType="image/png")]
        public static const ALERT_IMAGE64:Class;

        [Embed(source="/../assets/icons/alert_sprite128.png", mimeType="image/png")]
        public static const ALERT_IMAGE128:Class;

        [Embed(source="/../assets/icons/alert_sprite256.png", mimeType="image/png")]
        public static const ALERT_IMAGE256:Class;

        [Embed(source="/../assets/icons/rotate_right_90.png", mimeType="image/png")]
        public static const ROTATE_RIGHT_90:Class;

        [Embed(source="/../assets/icons/rotate_left_90.png", mimeType="image/png")]
        public static const ROTATE_LEFT_90:Class;

        [Embed(source="/../assets/icons/flip_vertical.png", mimeType="image/png")]
        public static const FLIP_VERTICAL:Class;

        [Embed(source="/../assets/icons/flip_horizontal.png", mimeType="image/png")]
        public static const FLIP_HORIZONTAL:Class;
    }
}
