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

package
{
    import com.mignari.workers.IWorkerCommunicator;
    import com.mignari.workers.WorkerCommand;
    import com.mignari.workers.WorkerCommunicator;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.system.System;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import mx.resources.ResourceManager;

    import nail.errors.NullArgumentError;
    import nail.errors.NullOrEmptyArgumentError;
    import nail.image.ImageCodec;
    import nail.image.ImageFormat;
    import nail.logging.Log;
    import nail.utils.FileUtil;
    import nail.utils.SaveHelper;
    import nail.utils.StringUtil;
    import nail.utils.VectorUtils;
    import nail.utils.isNullOrEmpty;

    import flash.utils.setTimeout;

    import nail.utils.FileQueueHelper;

    import ob.commands.FindResultCommand;
    import ob.commands.HideProgressBarCommand;
    import ob.commands.LoadVersionsCommand;
    import ob.commands.LoadSpriteDimensionsCommand;
    import ob.commands.NeedToReloadCommand;
    import ob.commands.ProgressBarID;
    import ob.commands.ProgressCommand;
    import ob.commands.SetClientInfoCommand;
    import ob.commands.SettingsCommand;
    import ob.commands.files.CompileAsCommand;
    import ob.commands.files.CompileCommand;
    import ob.commands.files.CreateNewFilesCommand;
    import ob.commands.files.LoadFilesCommand;
    import ob.commands.files.MergeFilesCommand;
    import ob.commands.files.UnloadFilesCommand;
    import ob.commands.sprites.ExportSpritesCommand;
    import ob.commands.sprites.FindSpritesCommand;
    import ob.commands.sprites.GetSpriteListCommand;
    import ob.commands.sprites.ImportSpritesCommand;
    import ob.commands.sprites.ImportSpritesFromFileCommand;
    import ob.commands.sprites.NewSpriteCommand;
    import ob.commands.sprites.OptimizeSpritesCommand;
    import ob.commands.sprites.OptimizeSpritesResultCommand;
    import ob.commands.sprites.RemoveSpritesCommand;
    import ob.commands.sprites.ReplaceSpritesCommand;
    import ob.commands.sprites.ReplaceSpritesFromFilesCommand;
    import ob.commands.sprites.SetSpriteListCommand;
    import ob.commands.things.DuplicateThingCommand;
    import ob.commands.things.ExportThingCommand;
    import ob.commands.things.FindThingCommand;
    import ob.commands.things.GetThingCommand;
    import ob.commands.things.GetThingListCommand;
    import ob.commands.things.ImportThingsCommand;
    import ob.commands.things.ImportThingsFromFilesCommand;
    import ob.commands.things.NewThingCommand;
    import ob.commands.things.RemoveThingCommand;
    import ob.commands.things.ReplaceThingsCommand;
    import ob.commands.things.ReplaceThingsFromFilesCommand;
    import ob.commands.things.SetThingDataCommand;
    import ob.commands.things.SetThingListCommand;
    import ob.commands.things.UpdateThingCommand;
    import ob.commands.things.BulkUpdateThingsCommand;
    import ob.commands.things.BulkReplaceCommand;
    import ob.commands.things.PasteThingDataCommand;
    import ob.commands.things.UpdateThingPropertiesCommand;
    import ob.commands.things.OptimizeFrameDurationsCommand;
    import ob.commands.things.OptimizeFrameDurationsResultCommand;
    import ob.commands.things.CreateMissingItemsCommand;
    import ob.commands.things.ReloadItemAttributesCommand;
    import ob.settings.ObjectBuilderSettings;
    import ob.utils.SpritesFinder;

    import otlib.items.ServerItemStorage;
    import otlib.items.ServerItem;
    import otlib.items.ServerItemType;
    import otlib.items.TileStackOrder;
    import otlib.items.OtbSync;
    import otlib.events.ThingListEvent;
    import otlib.utils.OtlibUtils;

    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.core.Version;
    import otlib.core.VersionStorage;
    import otlib.core.ClientFeatures;
    import otlib.events.ProgressEvent;
    import otlib.loaders.PathHelper;
    import otlib.loaders.SpriteDataLoader;
    import otlib.loaders.ThingDataLoader;
    import otlib.obd.OBDEncoder;
    import otlib.obd.OBDVersions;
    import otlib.resources.Resources;
    import otlib.sprites.SpriteData;
    import otlib.sprites.SpriteStorage;
    import otlib.storages.events.StorageEvent;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingCategory;
    import otlib.things.ThingData;
    import otlib.things.ThingProperty;
    import otlib.things.ThingType;
    import otlib.things.ThingTypeStorage;
    import otlib.utils.ChangeResult;
    import otlib.utils.ClientInfo;
    import otlib.utils.ClientMerger;
    import otlib.utils.OTFI;
    import otlib.utils.OTFormat;
    import otlib.utils.SpritesOptimizer;
    import otlib.utils.ThingListItem;
    import otlib.utils.FrameDurationsOptimizer;
    import otlib.utils.FrameGroupsConverter;
    import otlib.core.SpriteDimensionStorage;
    import otlib.utils.SpriteExtent;
    import ob.commands.SetSpriteDimensionCommand;
    import ob.commands.things.ConvertFrameGroupsCommand;
    import ob.commands.things.ConvertFrameGroupsResultCommand;
    import otlib.utils.ThingUtils;
    import otlib.items.ItemAttributeStorage;

    [ResourceBundle("strings")]

    public class ObjectBuilderWorker extends flash.display.Sprite
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        private var _communicator:IWorkerCommunicator;
        private var _things:ThingTypeStorage;
        private var _sprites:SpriteStorage;
        private var _datFile:File;
        private var _sprFile:File;
        private var _version:Version;
        private var _features:ClientFeatures;
        private var _errorMessage:String;
        private var _compiled:Boolean;
        private var _isTemporary:Boolean;
        private var _thingListAmount:uint;
        private var _spriteListAmount:uint;
        private var _settings:ObjectBuilderSettings;

        // OTB support
        private var _items:ServerItemStorage;
        private var _attributeRegistry:ItemAttributeStorage;

        private var _batchSize:uint = 50;

        // Reusable render buffer to avoid BitmapData allocation churn
        private static var _renderBuffer:BitmapData;
        private static var _renderBufferSize:uint = 0;

        // --------------------------------------
        // Getters / Setters
        // --------------------------------------

        public function get clientChanged():Boolean
        {
            return ((_things && _things.changed) || (_sprites && _sprites.changed) || (_items && _items.changed));
        }

        public function get clientIsTemporary():Boolean
        {
            return (_things && _things.isTemporary && _sprites && _sprites.isTemporary);
        }

        public function get clientLoaded():Boolean
        {
            return (_things && _things.loaded && _sprites && _sprites.loaded);
        }

        public function get otbLoaded():Boolean
        {
            return (_items && _items.loaded);
        }

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ObjectBuilderWorker()
        {
            super();

            Resources.manager = ResourceManager.getInstance();

            _communicator = new WorkerCommunicator();

            Log.commnunicator = _communicator;

            _thingListAmount = 100;
            _spriteListAmount = 100;

            // Initialize ItemAttributeStorage in the worker thread
            try
            {
                var attrPath:String = File.applicationDirectory.resolvePath("config/attributes").nativePath;
                _attributeRegistry = ItemAttributeStorage.getInstance();
                _attributeRegistry.initialize(attrPath);
            }
            catch (e:Error)
            {
                Log.error("Failed to initialize ItemAttributeStorage in worker: " + e.message);
            }

            register();
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        // --------------------------------------
        // Public
        // --------------------------------------

        public function getThingCallback(id:uint, category:String):void
        {
            sendThingData(id, category);
        }

        public function compileCallback():void
        {
            if (!_datFile)
            {
                Log.warn("Cannot compile in SPR-only mode. Use Compile As instead.");
                return;
            }

            var serverItemsPath:String = null;
            var serverItemsFormat:String = OTFormat.XML;
            var serverItemsBinaryPeer:String = null;

            if (_items && _items.loaded && _items.file)
            {
                serverItemsPath = _items.file.nativePath;

                // Determine format from loaded definition format (e.g. XML or TOML)
                if (_items.definitionFormat)
                {
                    serverItemsFormat = _items.definitionFormat;
                }

                // Determine binary peer from binaryFormat or file extension
                if (_items.binaryFormat)
                {
                    serverItemsBinaryPeer = _items.binaryFormat;
                }
                else if (_items.file.extension && _items.file.extension.toLowerCase() == "otb")
                {
                    serverItemsBinaryPeer = OTFormat.OTB;
                }
            }

            compileAsCallback(_datFile.nativePath,
                    _sprFile.nativePath,
                    serverItemsPath,
                    serverItemsFormat,
                    serverItemsBinaryPeer,
                    _version,
                    _features);
        }

        public function setSelectedThingIds(value:Vector.<uint>, category:String, forceUpdate:Boolean = false):void
        {
            if (value && value.length > 0)
            {
                if (value.length > 1)
                {
                    value.sort(Array.NUMERIC | Array.DESCENDING);
                }

                var max:uint = _things.getMaxId(category);
                if (value[0] > max)
                {
                    value = Vector.<uint>([max]);
                }

                sendThingList(value, category, forceUpdate);
            }
        }

        public function setSelectedSpriteIds(value:Vector.<uint>, forceUpdate:Boolean = false):void
        {
            if (value && value.length > 0)
            {
                if (value.length > 1)
                {
                    value.sort(Array.NUMERIC | Array.DESCENDING);
                }

                if (value[0] > _sprites.spritesCount)
                {
                    value = Vector.<uint>([_sprites.spritesCount]);
                }
                sendSpriteList(value, forceUpdate);
            }
        }

        public function sendCommand(command:WorkerCommand):void
        {
            _communicator.sendCommand(command);
        }

        // --------------------------------------
        // Override Protected
        // --------------------------------------

        public function register():void
        {
            // Register classes.
            _communicator.registerClass(ByteArray);
            _communicator.registerClass(ClientInfo);
            _communicator.registerClass(FrameDuration);
            _communicator.registerClass(FrameGroup);
            _communicator.registerClass(ObjectBuilderSettings);
            _communicator.registerClass(PathHelper);
            _communicator.registerClass(SpriteData);
            _communicator.registerClass(ThingData);
            _communicator.registerClass(ThingListItem);
            _communicator.registerClass(ThingProperty);
            _communicator.registerClass(ThingType);
            _communicator.registerClass(Version);
            _communicator.registerClass(ClientFeatures);

            _communicator.registerCallback(SettingsCommand, settingsCallback);

            _communicator.registerCallback(LoadVersionsCommand, loadClientVersionsCallback);
            _communicator.registerCallback(LoadSpriteDimensionsCommand, loadSpriteDimensionsCallback);
            _communicator.registerCallback(SetSpriteDimensionCommand, setSpriteDimensionCallback);

            // File commands
            _communicator.registerCallback(CreateNewFilesCommand, createNewFilesCallback);
            _communicator.registerCallback(LoadFilesCommand, loadFilesCallback);
            _communicator.registerCallback(MergeFilesCommand, mergeFilesCallback);
            _communicator.registerCallback(CompileCommand, compileCallback);
            _communicator.registerCallback(CompileAsCommand, compileAsCallback);
            _communicator.registerCallback(UnloadFilesCommand, unloadFilesCallback);

            // Thing commands
            _communicator.registerCallback(NewThingCommand, newThingCallback);
            _communicator.registerCallback(UpdateThingCommand, updateThingCallback);
            _communicator.registerCallback(ImportThingsCommand, importThingsCallback);
            _communicator.registerCallback(ImportThingsFromFilesCommand, importThingsFromFilesCallback);
            _communicator.registerCallback(ExportThingCommand, exportThingCallback);
            _communicator.registerCallback(ReplaceThingsCommand, replaceThingsCallback);
            _communicator.registerCallback(ReplaceThingsFromFilesCommand, replaceThingsFromFilesCallback);
            _communicator.registerCallback(DuplicateThingCommand, duplicateThingCallback);
            _communicator.registerCallback(BulkUpdateThingsCommand, bulkUpdateThingsCallback);
            _communicator.registerCallback(BulkReplaceCommand, bulkReplaceCallback);
            _communicator.registerCallback(RemoveThingCommand, removeThingsCallback);
            _communicator.registerCallback(GetThingCommand, getThingCallback);
            _communicator.registerCallback(GetThingListCommand, getThingListCallback);
            _communicator.registerCallback(FindThingCommand, findThingCallback);
            _communicator.registerCallback(OptimizeFrameDurationsCommand, optimizeFrameDurationsCallback);
            _communicator.registerCallback(ConvertFrameGroupsCommand, convertFrameGroupsCallback);
            _communicator.registerCallback(PasteThingDataCommand, pasteThingDataCallback);
            _communicator.registerCallback(CreateMissingItemsCommand, createMissingItemsCallback);
            _communicator.registerCallback(ReloadItemAttributesCommand, reloadItemAttributesCallback);

            // Sprite commands
            _communicator.registerCallback(NewSpriteCommand, newSpriteCallback);
            _communicator.registerCallback(ImportSpritesCommand, addSpritesCallback);
            _communicator.registerCallback(ImportSpritesFromFileCommand, importSpritesFromFilesCallback);
            _communicator.registerCallback(ExportSpritesCommand, exportSpritesCallback);
            _communicator.registerCallback(ReplaceSpritesCommand, replaceSpritesCallback);
            _communicator.registerCallback(ReplaceSpritesFromFilesCommand, replaceSpritesFromFilesCallback);
            _communicator.registerCallback(RemoveSpritesCommand, removeSpritesCallback);
            _communicator.registerCallback(GetSpriteListCommand, getSpriteListCallback);
            _communicator.registerCallback(FindSpritesCommand, findSpritesCallback);
            _communicator.registerCallback(OptimizeSpritesCommand, optimizeSpritesCallback);

            // General commands
            _communicator.registerCallback(NeedToReloadCommand, needToReloadCallback);

            _communicator.start();
        }

        // --------------------------------------
        // Private
        // --------------------------------------

        private function loadClientVersionsCallback(path:String):void
        {
            if (isNullOrEmpty(path))
                throw new NullOrEmptyArgumentError("path");

            VersionStorage.getInstance().load(new File(path));
        }

        private function loadSpriteDimensionsCallback(path:String):void
        {
            if (isNullOrEmpty(path))
                throw new NullOrEmptyArgumentError("path");

            SpriteDimensionStorage.getInstance().load(new File(path));
        }

        private function setSpriteDimensionCallback(value:String, size:uint, dataSize:uint):void
        {
            if (isNullOrEmpty(value))
                throw new NullOrEmptyArgumentError("value");

            if (isNullOrEmpty(size))
                throw new NullOrEmptyArgumentError("size");

            if (isNullOrEmpty(dataSize))
                throw new NullOrEmptyArgumentError("dataSize");

            SpriteExtent.DEFAULT_VALUE = value;
            SpriteExtent.DEFAULT_SIZE = size;
            SpriteExtent.DEFAULT_DATA_SIZE = dataSize;
        }

        private function settingsCallback(settings:ObjectBuilderSettings):void
        {
            if (isNullOrEmpty(settings))
                throw new NullOrEmptyArgumentError("settings");

            Resources.locale = settings.getLanguage()[0];
            _thingListAmount = settings.objectsListAmount;
            _spriteListAmount = settings.spritesListAmount;
            _batchSize = settings.exportBatchSize > 0 ? settings.exportBatchSize : 50;

            _settings = settings;
        }

        private function createNewFilesCallback(datSignature:uint,
                sprSignature:uint,
                features:ClientFeatures):void
        {
            unloadFilesCallback();

            _version = VersionStorage.getInstance().getBySignatures(datSignature, sprSignature);
            _features = features.clone();
            _features.applyVersionDefaults(_version.value);

            // Update attribute server in registry
            if (_features.attributeServer)
            {
                _attributeRegistry.loadServer(_features.attributeServer);
            }

            createStorage();

            // Create things.
            _things.createNew(_version, _features);

            // Create sprites.
            _sprites.createNew(_version, _features);

            // Update preview.
            var thing:ThingType = _things.getItemType(ThingTypeStorage.MIN_ITEM_ID);
            getThingCallback(thing.id, thing.category);

            // Send sprites.
            sendSpriteList(Vector.<uint>([1]));

            Log.info(Resources.getString("logCreatedNewFiles", _version.toString()));
        }

        private function createStorage():void
        {
            _things = new ThingTypeStorage(_settings);
            _things.addEventListener(StorageEvent.LOAD, storageLoadHandler);
            _things.addEventListener(StorageEvent.CHANGE, storageChangeHandler);
            _things.addEventListener(ProgressEvent.PROGRESS, thingsProgressHandler);
            _things.addEventListener(ErrorEvent.ERROR, thingsErrorHandler);

            _sprites = new SpriteStorage();
            _sprites.addEventListener(StorageEvent.LOAD, storageLoadHandler);
            _sprites.addEventListener(StorageEvent.CHANGE, storageChangeHandler);
            _sprites.addEventListener(ProgressEvent.PROGRESS, spritesProgressHandler);
            _sprites.addEventListener(ErrorEvent.ERROR, spritesErrorHandler);
        }

        private function loadFilesCallback(datPath:String,
                sprPath:String,
                version:Version,
                serverItemsPath:String,
                features:ClientFeatures,
                knownAttributes:Array = null):void
        {
            if (isNullOrEmpty(sprPath))
                throw new NullOrEmptyArgumentError("sprPath");

            if (!version)
                throw new NullArgumentError("version");

            unloadFilesCallback();

            _datFile = isNullOrEmpty(datPath) ? null : new File(datPath);
            _sprFile = new File(sprPath);
            _version = version;
            _features = features.clone();
            _features.applyVersionDefaults(_version.value);

            // Update attribute server in registry
            if (_features.attributeServer)
            {
                _attributeRegistry.loadServer(_features.attributeServer);
            }

            createStorage();

            // 1/3 Loading DAT (or creating empty if SPR-only)
            sendCommand(new ProgressCommand(ProgressBarID.METADATA, 0, 3, "Loading DAT"));
            if (_datFile)
            {
                _things.load(_datFile, _version, _features);
            }
            else
            {
                _things.createNew(_version, _features);
            }

            // 2/3 Loading Server Items (if path was provided)
            if (!isNullOrEmpty(serverItemsPath))
            {
                sendCommand(new ProgressCommand(ProgressBarID.METADATA, 1, 3, "Loading Server Items"));
                loadServerItemsCallback(serverItemsPath, null, knownAttributes);
            }

            // 3/3 Loading SPR
            sendCommand(new ProgressCommand(ProgressBarID.METADATA, 2, 3, "Loading SPR"));
            _sprites.load(_sprFile, _version, _features);
        }

        private function mergeFilesCallback(datPath:String,
                sprPath:String,
                version:Version,
                features:ClientFeatures):void
        {
            if (isNullOrEmpty(datPath))
                throw new NullOrEmptyArgumentError("datPath");

            if (isNullOrEmpty(sprPath))
                throw new NullOrEmptyArgumentError("sprPath");

            if (!version)
                throw new NullArgumentError("version");

            var datFile:File = new File(datPath);
            var sprFile:File = new File(sprPath);
            var mergeFeatures:ClientFeatures = features.clone();
            mergeFeatures.applyVersionDefaults(version.value);

            var merger:ClientMerger = new ClientMerger(_things, _sprites, _settings);
            merger.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            merger.addEventListener(Event.COMPLETE, completeHandler);
            merger.start(datFile, sprFile, version, mergeFeatures);

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, event.loaded, event.total, event.label));
            }

            function completeHandler(event:Event):void
            {
                if (!_things || !_sprites)
                {
                    sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                    return;
                }

                var category:String;
                var id:uint;

                if (merger.itemsCount != 0)
                    category = ThingCategory.ITEM;
                else if (merger.outfitsCount != 0)
                    category = ThingCategory.OUTFIT;
                else if (merger.effectsCount != 0)
                    category = ThingCategory.EFFECT;
                else if (merger.missilesCount != 0)
                    category = ThingCategory.MISSILE;

                if (category != null || merger.spritesCount != 0)
                {
                    sendClientInfo();

                    if (merger.spritesCount != 0)
                    {
                        id = _sprites.spritesCount;
                        sendSpriteList(Vector.<uint>([id]));
                    }

                    if (category != null)
                    {
                        id = _things.getMaxId(category);
                        setSelectedThingIds(Vector.<uint>([id]), category);
                    }
                }

                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                // Log merge results
                var parts:Array = [];
                if (merger.itemsCount > 0)
                    parts.push(merger.itemsCount + " items");
                if (merger.outfitsCount > 0)
                    parts.push(merger.outfitsCount + " outfits");
                if (merger.effectsCount > 0)
                    parts.push(merger.effectsCount + " effects");
                if (merger.missilesCount > 0)
                    parts.push(merger.missilesCount + " missiles");
                if (merger.spritesCount > 0)
                    parts.push(merger.spritesCount + " sprites");
                if (parts.length > 0)
                {
                    Log.info(Resources.getString("logMerged", parts.join(", ")));
                }
            }
        }

        private function compileAsCallback(datPath:String,
                sprPath:String,
                serverItemsPath:String,
                serverItemsFormat:String,
                serverItemsBinaryPeer:String,
                version:Version,
                features:ClientFeatures):void
        {
            // ... skipped
            if (isNullOrEmpty(datPath))
                throw new NullOrEmptyArgumentError("datPath");

            if (isNullOrEmpty(sprPath))
                throw new NullOrEmptyArgumentError("sprPath");

            if (!version)
                throw new NullArgumentError("version");

            if (!_things || !_things.loaded)
                throw new Error(Resources.getString("metadataNotLoaded"));

            if (!_sprites || !_sprites.loaded)
                throw new Error(Resources.getString("spritesNotLoaded"));

            var dat:File = new File(datPath);
            var spr:File = new File(sprPath);
            var structureChanged:Boolean = _features.differs(features);

            // Update attribute server in registry using the features passed to compile
            if (features.attributeServer)
            {
                _attributeRegistry.loadServer(features.attributeServer);
            }

            // 1/3 Saving DAT
            sendCommand(new ProgressCommand(ProgressBarID.METADATA, 0, 3, "Saving DAT"));
            if (!_things.compile(dat, version, features))
            {
                return;
            }

            // 2/3 Saving SPR
            sendCommand(new ProgressCommand(ProgressBarID.METADATA, 1, 3, "Saving SPR"));
            if (!_sprites.compile(spr, version, features))
            {
                return;
            }

            // 3/3 Exporting Server Items (if requested)
            if (!isNullOrEmpty(serverItemsPath))
            {
                sendCommand(new ProgressCommand(ProgressBarID.METADATA, 2, 3, "Exporting Server Items"));

                var itemsFile:File = new File(serverItemsPath);
                var itemsDir:File = itemsFile.parent;
                var baseName:String = itemsFile.name;
                var dotIndex:int = baseName.lastIndexOf(".");
                if (dotIndex != -1)
                    baseName = baseName.substring(0, dotIndex);

                // 1. Export Definitions (XML/TOML)
                var defFile:File = itemsDir.resolvePath(baseName + "." + (serverItemsFormat == OTFormat.TOML ? "toml" : "xml"));
                if (!_items.saveDefinitions(defFile, serverItemsFormat))
                {
                    Log.error("Failed to save server items to " + defFile.nativePath);
                }

                // 2. Export Binary Peer (OTB/DAT/ASSETS)
                if (serverItemsBinaryPeer != null)
                {
                    var peerExtension:String = "otb";
                    if (serverItemsBinaryPeer == OTFormat.DAT)
                        peerExtension = "dat";
                    else if (serverItemsBinaryPeer == OTFormat.ASSETS)
                        peerExtension = "dat";

                    var peerFile:File = itemsDir.resolvePath(baseName + "." + peerExtension);

                    if (!_items.save(peerFile, serverItemsBinaryPeer, dat))
                    {
                        Log.error("Failed to save/export binary peer: " + peerFile.nativePath);
                    }
                }
            }

            // Save .otfi file
            var dir:File = FileUtil.getDirectory(dat);
            var otfiFile:File = dir.resolvePath(FileUtil.getName(dat) + ".otfi");
            var otfi:OTFI = new OTFI(features, dat.name, spr.name, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_DATA_SIZE);
            otfi.save(otfiFile);

            // Complete
            sendCommand(new ProgressCommand(ProgressBarID.METADATA, 3, 3, "Saving complete"));

            clientCompileComplete();

            if (!_datFile || !_sprFile)
            {
                _datFile = dat;
                _sprFile = spr;
            }

            if (structureChanged)
                sendCommand(new NeedToReloadCommand(features));
            else
                sendClientInfo();
        }

        private function unloadFilesCallback():void
        {
            if (_things)
            {
                _things.unload();
                _things.removeEventListener(StorageEvent.LOAD, storageLoadHandler);
                _things.removeEventListener(StorageEvent.CHANGE, storageChangeHandler);
                _things.removeEventListener(ProgressEvent.PROGRESS, thingsProgressHandler);
                _things.removeEventListener(ErrorEvent.ERROR, thingsErrorHandler);
                _things = null;
            }

            if (_sprites)
            {
                _sprites.unload();
                _sprites.removeEventListener(StorageEvent.LOAD, storageLoadHandler);
                _sprites.removeEventListener(StorageEvent.CHANGE, storageChangeHandler);
                _sprites.removeEventListener(ProgressEvent.PROGRESS, spritesProgressHandler);
                _sprites.removeEventListener(ErrorEvent.ERROR, spritesErrorHandler);
                _sprites = null;
            }

            _datFile = null;
            _sprFile = null;
            _version = null;
            _features = null;
            _errorMessage = null;
            if (_items)
            {
                _items.unload();
                _items.removeEventListener(ProgressEvent.PROGRESS, itemsProgressHandler);
                _items = null;
            }
        }

        /**
         * Load Server Items (OTB/XML) using ServerItemStorage
         */
        private function loadServerItemsCallback(serverItemsPath:String, itemsXmlPath:String = null, knownAttributes:Array = null):void
        {
            if (isNullOrEmpty(serverItemsPath))
            {
                Log.error(Resources.getString("otbPathEmpty")); // Keep resource key for now unless invalid
                return;
            }

            var otbFile:File = new File(serverItemsPath);
            if (!_items)
            {
                _items = new ServerItemStorage();
                _items.addEventListener(ProgressEvent.PROGRESS, itemsProgressHandler);
            }

            // Set known attributes (injected from main thread)
            if (knownAttributes)
            {
                _items.knownAttributeKeys = knownAttributes;
            }

            if (_items.load(otbFile))
            {
                // Update client info with otbLoaded state
                sendClientInfo();

                // Refresh the thing list to show server IDs
                if (clientLoaded)
                {
                    sendThingList(Vector.<uint>([ThingTypeStorage.MIN_ITEM_ID]), ThingCategory.ITEM);
                }

                Log.info(Resources.getString("logOtbLoaded", _items.items.count));
            }
        }

        /**
         * Creates missing OTB items for client IDs not in OTB
         */
        private function createMissingItemsCallback(selectedId:uint):void
        {
            if (!_items || !_items.loaded)
            {
                Log.error(Resources.getString("noOtbLoaded", "create missing items"));
                return;
            }

            if (!_things || !_things.loaded)
            {
                Log.error(Resources.getString("noDatLoaded", "create missing items"));
                return;
            }

            // itemsCount returns the MAX item ID, not the count
            var maxClientId:uint = _things.itemsCount;
            var otbMaxClientId:uint = _items.items.getMaxClientId();
            Log.info(Resources.getString("logCreateMissingItems", maxClientId, otbMaxClientId, _items.items.count));

            var created:uint = _items.createMissingItems(maxClientId);
            Log.info(Resources.getString("logCreatedOtbItems", created));

            if (created > 0)
            {
                // Determine missing items to sync
                var itemsToSync:Array = [];
                for (var cid:uint = otbMaxClientId + 1; cid <= maxClientId; cid++)
                {
                    var serverItem:ServerItem = _items.getItemByClientId(cid);
                    if (serverItem)
                    {
                        itemsToSync.push(serverItem);
                    }
                }

                if (itemsToSync.length > 0)
                {
                    syncOtbItems(itemsToSync, true, true, "Syncing new items...");
                }

                // Mark OTB as changed to enable Compile
                _items.invalidate();

                // Update client info to reflect new OTB items count
                sendClientInfo();

                // Refresh the thing list preserving selection
                var targetId:uint = selectedId > 0 ? selectedId : ThingTypeStorage.MIN_ITEM_ID;
                sendThingList(Vector.<uint>([targetId]), ThingCategory.ITEM);
            }
        }

        /**
         * Reloads item attributes from DAT for all OTB items.
         * Syncs all items unconditionally (like item-editor).
         */
        private function reloadItemAttributesCallback(selectedId:uint, recalculateHashes:Boolean = false):void
        {
            if (!_items || !_items.loaded)
            {
                Log.error(Resources.getString("noOtbLoaded", "reload item attributes"));
                return;
            }

            if (!_things || !_things.loaded)
            {
                Log.error(Resources.getString("noDatLoaded", "reload item attributes"));
                return;
            }

            var items:Array = _items.items.toArray();
            var progressLabel:String = recalculateHashes ? Resources.getString("reloadingWithHashes") : Resources.getString("reloadingItemAttributes");

            var reloaded:uint = syncOtbItems(items, false, recalculateHashes, progressLabel);

            Log.info(Resources.getString("logReloadedItems", reloaded));

            // Mark OTB as changed to enable Compile
            if (reloaded > 0)
            {
                _items.invalidate();
                sendClientInfo();
            }

            // Refresh the thing list preserving selection
            var targetId:uint = selectedId > 0 ? selectedId : ThingTypeStorage.MIN_ITEM_ID;
            sendThingList(Vector.<uint>([targetId]), ThingCategory.ITEM);
        }

        private function syncOtbItems(items:Array, syncType:Boolean, recalculateHashes:Boolean = false, progressLabel:String = null):uint
        {
            if (!items || items.length == 0)
                return 0;

            var total:uint = items.length;
            var processed:uint = 0;
            var spriteStorageForHash:SpriteStorage = recalculateHashes ? _sprites : null;

            if (!progressLabel)
                progressLabel = Resources.getString("reloadingItemAttributes");
            sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, 0, total, progressLabel));

            for each (var serverItem:ServerItem in items)
            {
                var thing:ThingType = _things.getItemType(serverItem.clientId);
                if (thing)
                {
                    OtbSync.syncFromThingType(serverItem, thing, syncType, _version.value, spriteStorageForHash);
                    processed++;
                }

                if (processed % 500 == 0)
                {
                    sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, processed, total, progressLabel));
                }
            }
            sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, total, total, Resources.getString("done")));
            return processed;
        }

        /**
         * Syncs an item with OTB if it exists, or creates it if missing and setting is enabled.
         */
        private function syncOrCreateItem(thingId:uint, category:String):void
        {
            if (!otbLoaded || category != ThingCategory.ITEM)
                return;

            var thing:ThingType = _things.getThingType(thingId, category);
            if (!thing)
                return;

            var synced:Boolean = _items.updateItemsFromThing(thing, _version.value, _sprites);
            if (!synced && _settings.syncOtbOnAdd)
            {
                createMissingItemsCallback(thingId);
            }
        }

        private function newThingCallback(category:String):void
        {
            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            // ============================================================================
            // Add thing
            var thing:ThingType = ThingType.create(0, category, _features.frameGroups, _settings.getDefaultDuration(category));
            var result:ChangeResult = _things.addThing(thing, category);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Sync with OTB
            syncOrCreateItem(thing.id, category);

            // ============================================================================
            // Send changes
            sendClientInfo();

            // Send thing to preview.
            getThingCallback(thing.id, category);
            setSelectedThingIds(Vector.<uint>([thing.id]), category);

            // Send message to log.
            var message:String = Resources.getString(
                    "logAdded",
                    toLocale(category),
                    thing.id);

            Log.info(message);
        }

        private function updateThingCallback(thingData:ThingData, replaceSprites:Boolean):void
        {
            if (!thingData)
            {
                throw new NullArgumentError("thingData");
            }

            var result:ChangeResult;
            var thing:ThingType = thingData.thing;

            if (!_things.hasThingType(thing.category, thing.id))
            {
                throw new Error(Resources.getString(
                            "thingNotFound",
                            toLocale(thing.category),
                            thing.id));
            }

            // ============================================================================
            // Update sprites

            var spritesIds:Vector.<uint> = new Vector.<uint>();
            var addedSpriteList:Array = [];
            var spriteRefsChanged:Boolean = false;
            var currentThing:ThingType = _things.getThingType(thing.id, thing.category);

            var sprites:Dictionary = new Dictionary();
            sprites = thingData.sprites;

            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (!frameGroup)
                    continue;

                var currentFrameGroup:FrameGroup = currentThing.getFrameGroup(groupType);
                if (!currentFrameGroup)
                    continue;

                var length:uint = sprites[groupType].length;
                for (var i:uint = 0; i < length; i++)
                {
                    var spriteData:SpriteData = sprites[groupType][i];
                    var id:uint = frameGroup.spriteIndex[i];

                    if (id == uint.MAX_VALUE)
                    {
                        if (spriteData.isEmpty())
                        {
                            frameGroup.spriteIndex[i] = 0;
                        }
                        else
                        {

                            if (replaceSprites && i < currentFrameGroup.spriteIndex.length && currentFrameGroup.spriteIndex[i] != 0)
                            {
                                result = _sprites.replaceSprite(currentFrameGroup.spriteIndex[i], spriteData.pixels);
                            }
                            else
                            {
                                result = _sprites.addSprite(spriteData.pixels);
                            }

                            if (!result.done)
                            {
                                Log.error(result.message);
                                return;
                            }

                            spriteData = result.list[0];
                            frameGroup.spriteIndex[i] = spriteData.id;
                            spritesIds[spritesIds.length] = spriteData.id;
                            addedSpriteList[addedSpriteList.length] = spriteData;
                        }
                    }
                    else
                    {
                        if (!_sprites.hasSpriteId(id))
                        {
                            Log.error(Resources.getString("spriteNotFound", id));
                            return;
                        }
                        // Check if sprite reference changed from current
                        if (i < currentFrameGroup.spriteIndex.length && currentFrameGroup.spriteIndex[i] != id)
                        {
                            spriteRefsChanged = true;
                        }
                    }
                }
            }

            // ============================================================================
            // Update thing

            result = _things.replaceThing(thing, thing.category, thing.id);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Send changes

            var message:String;

            // Sprites change message
            if (spritesIds.length > 0)
            {
                message = Resources.getString(
                        replaceSprites ? "logReplaced" : "logAdded",
                        toLocale("sprite", spritesIds.length > 1),
                        spritesIds);

                Log.info(message);

                setSelectedSpriteIds(spritesIds);
            }

            // Sync with Server Item
            syncOrCreateItem(thing.id, thingData.category);

            // Sync XML attributes to ServerItem (from Attributes tab edits)
            if (otbLoaded && thingData.category == ThingCategory.ITEM && thingData.xmlAttributes)
            {
                var serverItem:ServerItem = _items.getItemByClientId(thing.id);
                if (serverItem)
                {
                    serverItem.setXmlAttributesFromObject(thingData.xmlAttributes);
                    _items.invalidate();
                }
            }

            // Refresh thing data (preview) when sprites changed
            if (replaceSprites || spritesIds.length > 0 || spriteRefsChanged)
            {
                getThingCallback(thingData.id, thingData.category);
            }
            else
            {
                sendCommand(new UpdateThingPropertiesCommand(thing.clone()));
            }

            sendThingList(Vector.<uint>([thingData.id]), thingData.category, true);

            message = Resources.getString(
                    "logChanged",
                    toLocale(thing.category),
                    thing.id);

            Log.info(message);
        }

        private function exportThingCallback(list:Vector.<PathHelper>,
                category:String,
                obdVersion:uint,
                clientVersion:Version,
                spriteSheetFlag:uint,
                transparentBackground:Boolean,
                jpegQuality:uint):void
        {
            if (!list)
                throw new NullArgumentError("list");

            if (!ThingCategory.getCategory(category))
                throw new ArgumentError(Resources.getString("invalidCategory"));

            if (!clientVersion)
                throw new NullArgumentError("version");

            var length:uint = list.length;
            if (length == 0)
                return;

            // For large exports, use batched processing
            if (length > _batchSize)
            {
                exportThingsBatched(list, category, obdVersion, clientVersion, spriteSheetFlag, transparentBackground, jpegQuality);
            }
            else
            {
                exportThingsDirect(list, category, obdVersion, clientVersion, spriteSheetFlag, transparentBackground, jpegQuality);
            }
        }

        private function exportThingsDirect(list:Vector.<PathHelper>,
                category:String,
                obdVersion:uint,
                clientVersion:Version,
                spriteSheetFlag:uint,
                transparentBackground:Boolean,
                jpegQuality:uint):void
        {
            var length:uint = list.length;
            var label:String = Resources.getString("exportingObjects");
            var encoder:OBDEncoder = new OBDEncoder(_settings);
            var helper:SaveHelper = new SaveHelper();
            var backgoundColor:uint = (_features.transparency || transparentBackground) ? 0x00FF00FF : 0xFFFF00FF;
            for (var i:uint = 0; i < length; i++)
            {
                addFileToSaveHelper(helper, encoder, list[i], category, obdVersion, clientVersion, spriteSheetFlag, backgoundColor, jpegQuality);
            }
            helper.addEventListener(flash.events.ProgressEvent.PROGRESS, progressHandler);
            helper.addEventListener(Event.COMPLETE, completeHandler);
            helper.save();

            function progressHandler(event:flash.events.ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, event.bytesLoaded, event.bytesTotal, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                var ids:Vector.<uint> = new Vector.<uint>(length, true);
                for (var j:uint = 0; j < length; j++)
                {
                    ids[j] = list[j].id;
                }
                var message:String = Resources.getString(
                        "logExported",
                        toLocale(category, length > 1),
                        ids);
                Log.info(message);
            }
        }

        private function exportThingsBatched(list:Vector.<PathHelper>,
                category:String,
                obdVersion:uint,
                clientVersion:Version,
                spriteSheetFlag:uint,
                transparentBackground:Boolean,
                jpegQuality:uint):void
        {
            var length:uint = list.length;
            var totalBatches:uint = Math.ceil(length / _batchSize);
            var currentBatch:uint = 0;
            var allExportedIds:Vector.<uint> = new Vector.<uint>();

            var label:String = Resources.getString("exportingObjects");
            sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, 0, length, label));

            processNextBatch();

            function processNextBatch():void
            {
                var startIdx:uint = currentBatch * _batchSize;
                var endIdx:uint = Math.min(startIdx + _batchSize, length);

                var encoder:OBDEncoder = new OBDEncoder(_settings);
                var helper:SaveHelper = new SaveHelper();
                var backgoundColor:uint = (_features.transparency || transparentBackground) ? 0x00FF00FF : 0xFFFF00FF;

                for (var i:uint = startIdx; i < endIdx; i++)
                {
                    var pathHelper:PathHelper = list[i];
                    addFileToSaveHelper(helper, encoder, pathHelper, category, obdVersion, clientVersion, spriteSheetFlag, backgoundColor, jpegQuality);
                    allExportedIds.push(pathHelper.id);
                }

                helper.addEventListener(Event.COMPLETE, batchCompleteHandler);
                helper.save();

                function batchCompleteHandler(event:Event):void
                {
                    sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, endIdx, length, label));

                    currentBatch++;

                    if (currentBatch < totalBatches)
                    {
                        System.gc();
                        setTimeout(processNextBatch, 50);
                    }
                    else
                    {
                        finalizeBatchedExport();
                    }
                }
            }

            function finalizeBatchedExport():void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                var message:String = Resources.getString(
                        "logExported",
                        toLocale(category, allExportedIds.length > 1),
                        allExportedIds);
                Log.info(message);
            }
        }

        private function replaceThingsCallback(list:Vector.<ThingData>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            var denyIds:Dictionary = new Dictionary();
            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Add sprites

            var result:ChangeResult;
            var spritesIds:Vector.<uint> = new Vector.<uint>();

            result = processThingDataDataList(list, spritesIds);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Replace things

            var thingsToReplace:Vector.<ThingType> = new Vector.<ThingType>();
            var thingsIds:Vector.<uint> = new Vector.<uint>();
            for (var i:uint = 0; i < length; i++)
            {
                if (!denyIds[i])
                {
                    thingsToReplace[thingsToReplace.length] = list[i].thing;
                    thingsIds[thingsIds.length] = list[i].id;
                }
            }

            if (thingsToReplace.length == 0)
                return;

            result = _things.replaceThings(thingsToReplace);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Send changes

            var message:String;

            // Added sprites message
            if (spritesIds.length > 0)
            {
                sendSpriteList(Vector.<uint>([_sprites.spritesCount]));

                message = Resources.getString(
                        "logAdded",
                        toLocale("sprite", spritesIds.length > 1),
                        spritesIds);

                Log.info(message);
            }

            var category:String = list[0].thing.category;

            // Sync with OTB first (before sending list to UI)
            syncItemsHelper(thingsIds, category);

            // Now send updated list to UI
            sendClientInfo();
            getThingCallback(thingsIds[0], category);
            sendThingList(thingsIds, category, true);

            message = Resources.getString(
                    "logReplaced",
                    toLocale(category, thingsIds.length > 1),
                    thingsIds);

            Log.info(message);
        }

        private function replaceThingsFromFilesCallback(list:Vector.<PathHelper>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Load things

            var loader:ThingDataLoader = new ThingDataLoader(_settings);
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.addEventListener(ErrorEvent.ERROR, errorHandler);
            loader.loadFiles(list);

            var label:String = Resources.getString("loading");

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(event.id, event.loaded, event.total, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                replaceThingsCallback(loader.thingDataList);
            }

            function errorHandler(event:ErrorEvent):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                Log.error(event.text);
            }
        }

        private function importThingsCallback(list:Vector.<ThingData>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // For large imports, use batched processing to prevent memory crashes
            if (length > _batchSize)
            {
                importThingsBatched(list);
            }
            else
            {
                importThingsDirect(list);
            }
        }

        private function importThingsBatched(list:Vector.<ThingData>):void
        {
            var length:uint = list.length;
            var category:String = list[0].thing.category;
            var totalBatches:uint = Math.ceil(length / _batchSize);
            var currentBatch:uint = 0;
            var allAddedThingIds:Vector.<uint> = new Vector.<uint>();
            var allSpritesIds:Vector.<uint> = new Vector.<uint>();

            // Show progress
            var label:String = Resources.getString("importingObjects");
            sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, 0, length, label));

            processNextBatch();

            function processNextBatch():void
            {
                var startIdx:uint = currentBatch * _batchSize;
                var endIdx:uint = Math.min(startIdx + _batchSize, length);

                // Process sprites for this batch
                var result:ChangeResult;

                var batchList:Vector.<ThingData> = list.slice(startIdx, endIdx);
                result = processThingDataDataList(batchList, allSpritesIds);
                if (!result.done)
                {
                    Log.error(result.message);
                    sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                    return;
                }

                // Add things for this batch
                var thingsToAdd:Vector.<ThingType> = new Vector.<ThingType>();
                for (var i:uint = startIdx; i < endIdx; i++)
                {
                    thingsToAdd[thingsToAdd.length] = list[i].thing;
                }

                if (thingsToAdd.length > 0)
                {
                    result = _things.addThings(thingsToAdd);
                    if (!result.done)
                    {
                        Log.error(result.message);
                        sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                        return;
                    }

                    var addedThings:Array = result.list;
                    for (var j:uint = 0; j < addedThings.length; j++)
                    {
                        allAddedThingIds[allAddedThingIds.length] = addedThings[j].id;
                    }
                }

                // Update progress
                sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, endIdx, length, label));

                currentBatch++;

                if (currentBatch < totalBatches)
                {
                    System.gc();
                    setTimeout(processNextBatch, 50);
                }
                else
                {
                    finalizeBatchedImport();
                }
            }

            function finalizeBatchedImport():void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                var message:String;

                if (allSpritesIds.length > 0)
                {
                    sendSpriteList(Vector.<uint>([_sprites.spritesCount]));

                    message = Resources.getString(
                            "logAdded",
                            toLocale("sprite", allSpritesIds.length > 1),
                            allSpritesIds);

                    Log.info(message);
                }

                // Create OTB entries for imported items
                if (otbLoaded && category == ThingCategory.ITEM && allAddedThingIds.length > 0 && _settings.syncOtbOnAdd)
                {
                    for each (var addedId:uint in allAddedThingIds)
                    {
                        syncOrCreateItem(addedId, category);
                    }
                }

                setSelectedThingIds(allAddedThingIds, category);

                message = Resources.getString(
                        "logAdded",
                        toLocale(category, allAddedThingIds.length > 1),
                        allAddedThingIds);

                Log.info(message);
            }
        }

        private function importThingsDirect(list:Vector.<ThingData>):void
        {
            var denyIds:Dictionary = new Dictionary();
            var length:uint = list.length;

            // ============================================================================
            // Add sprites

            var result:ChangeResult;
            var spritesIds:Vector.<uint> = new Vector.<uint>();

            result = processThingDataDataList(list, spritesIds);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Add things

            var thingsToAdd:Vector.<ThingType> = new Vector.<ThingType>();
            for (var i:uint = 0; i < length; i++)
            {
                if (!denyIds[i])
                    thingsToAdd[thingsToAdd.length] = list[i].thing;
            }

            if (thingsToAdd.length == 0)
                return;

            result = _things.addThings(thingsToAdd);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            var addedThings:Array = result.list;

            // ============================================================================
            // Send changes

            var message:String;

            if (spritesIds.length > 0)
            {
                sendSpriteList(Vector.<uint>([_sprites.spritesCount]));

                message = Resources.getString(
                        "logAdded",
                        toLocale("sprite", spritesIds.length > 1),
                        spritesIds);

                Log.info(message);
            }

            var thingsIds:Vector.<uint> = new Vector.<uint>(length, true);
            for (i = 0; i < length; i++)
            {
                thingsIds[i] = addedThings[i].id;
            }

            var category:String = list[0].thing.category;

            // Sync with OTB first (before sending list to UI)
            syncItemsHelper(thingsIds, category);

            // Now send updated list to UI
            sendClientInfo();
            setSelectedThingIds(thingsIds, category);

            message = Resources.getString(
                    "logAdded",
                    toLocale(category, thingsIds.length > 1),
                    thingsIds);

            Log.info(message);
        }

        private function importThingsFromFilesCallback(list:Vector.<PathHelper>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Load things

            var loader:ThingDataLoader = new ThingDataLoader(_settings);
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.addEventListener(ErrorEvent.ERROR, errorHandler);
            loader.loadFiles(list);

            var label:String = Resources.getString("loading");

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(event.id, event.loaded, event.total, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                importThingsCallback(loader.thingDataList);
            }

            function errorHandler(event:ErrorEvent):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                Log.error(event.text);
            }
        }

        private function duplicateThingCallback(list:Vector.<uint>, category:String):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Duplicate things

            list.sort(Array.NUMERIC);

            var thingsCopyList:Vector.<ThingType> = new Vector.<ThingType>();

            for (var i:uint = 0; i < length; i++)
            {
                var thing:ThingType = _things.getThingType(list[i], category);
                if (!thing)
                {
                    throw new Error(Resources.getString(
                                "thingNotFound",
                                Resources.getString(category),
                                list[i]));
                }
                thingsCopyList[i] = thing.clone();
            }

            var result:ChangeResult = _things.addThings(thingsCopyList);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            var addedThings:Array = result.list;

            // ============================================================================
            // Send changes

            length = addedThings.length;
            var thingIds:Vector.<uint> = new Vector.<uint>(length, true);
            for (i = 0; i < length; i++)
            {
                thingIds[i] = addedThings[i].id;
            }

            thingIds.sort(Array.NUMERIC);

            // Sync with OTB first (before sending list to UI)
            syncItemsHelper(thingIds, category);

            // Now send updated list to UI
            sendClientInfo();
            setSelectedThingIds(thingIds, category);

            var message:String = StringUtil.format(Resources.getString(
                        "logDuplicated"),
                    toLocale(category, thingIds.length > 1),
                    list);

            Log.info(message);
        }

        private function bulkUpdateThingsCallback(ids:Vector.<uint>, category:String, properties:Array):void
        {
            if (!ids)
            {
                throw new NullArgumentError("ids");
            }

            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var length:uint = ids.length;
            if (length == 0 || !properties || properties.length == 0)
                return;

            // ============================================================================
            // Bulk update things

            var updatedCount:uint = 0;
            for (var i:uint = 0; i < length; i++)
            {
                var thing:ThingType = _things.getThingType(ids[i], category);
                if (!thing)
                    continue;

                // Apply each property change
                for each (var propChange:Object in properties)
                {
                    var propName:String = propChange.property;
                    var propValue:* = propChange.value;

                    switch (propName)
                    {
                        case "_bulkDuration":
                            var min:uint = propChange.minDuration;
                            var max:uint = propChange.maxDuration;
                            var groupTarget:int = propChange.hasOwnProperty("frameGroupTarget") ? propChange.frameGroupTarget : -1;
                            applyBulkDuration(thing, min, max, groupTarget);
                            break;

                        case "_bulkAnimationMode":
                            applyBulkAnimationMode(thing, propChange.animationMode);
                            break;

                        case "_bulkFrameStrategy":
                            var loopCount:int = (propChange.frameStrategy == 0) ? 0 : -1;
                            applyBulkFrameStrategy(thing, loopCount);
                            break;

                        case "_bulkClearAttributes":
                            if (category == ThingCategory.ITEM)
                            {
                                applyBulkClearAttributes(thing.id, propValue === true);
                            }
                            break;

                        case "_bulkAttributes":
                            if (category == ThingCategory.ITEM)
                            {
                                applyBulkAttributes(thing.id, propValue as Object);
                            }
                            break;

                        default:
                            if (thing.hasOwnProperty(propName))
                            {
                                thing[propName] = propValue;
                            }
                            break;
                    }
                }

                // Replace the thing with updated properties
                var result:ChangeResult = _things.replaceThing(thing, category, thing.id);
                if (result.done)
                {
                    updatedCount++;
                    // Sync ThingType flags to ServerItem (OTB)
                    syncOrCreateItem(ids[i], category);
                }
            }

            // ============================================================================
            // Send changes

            if (updatedCount > 0)
            {
                // Fallback: ensure OTB storage is marked changed if category is ITEM
                if (category == ThingCategory.ITEM && otbLoaded)
                {
                    _items.invalidate();
                }

                sendClientInfo();
                setSelectedThingIds(ids, category, true);

                var message:String = Resources.getString(
                        "logChanged",
                        toLocale(category, updatedCount > 1),
                        ids);

                Log.info(message);
            }
        }

        private function bulkReplaceCallback(sourceDatPath:String,
                                               sourceSprPath:String,
                                               thingIds:Array,
                                               category:String,
                                               sourceExtended:Boolean,
                                               sourceTransparency:Boolean,
                                               sourceImprovedAnimations:Boolean,
                                               sourceFrameGroups:Boolean):void
        {
            if (!sourceDatPath || !sourceSprPath || !thingIds || thingIds.length == 0)
                return;

            if (!ThingCategory.getCategory(category))
                return;

            var total:uint = thingIds.length;
            sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, 0, total, "Preparing bulk replace..."));

            var sourceDatFile:File = new File(sourceDatPath);
            var sourceSprFile:File = new File(sourceSprPath);

            if (!sourceDatFile.exists || !sourceSprFile.exists)
            {
                Log.error("Source files not found: " + sourceDatPath);
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                return;
            }

            // Read signatures from source file headers to determine version
            var datStream:FileStream = new FileStream();
            datStream.open(sourceDatFile, FileMode.READ);
            var datSignature:uint = datStream.readUnsignedInt();
            datStream.close();

            var sprStream:FileStream = new FileStream();
            sprStream.open(sourceSprFile, FileMode.READ);
            var sprSignature:uint = sprStream.readUnsignedInt();
            sprStream.close();

            var sourceVersion:Version = VersionStorage.getInstance().getBySignatures(datSignature, sprSignature);
            if (!sourceVersion)
            {
                Log.error("Unknown source client version (DAT sig: " + datSignature + ", SPR sig: " + sprSignature + ")");
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                return;
            }

            var sourceFeatures:ClientFeatures = new ClientFeatures(
                sourceExtended, sourceTransparency,
                sourceImprovedAnimations, sourceFrameGroups);

            // Open source files
            var sourceThings:ThingTypeStorage = new ThingTypeStorage(_settings);
            var sourceSprites:SpriteStorage = new SpriteStorage();

            try
            {
                sourceThings.load(sourceDatFile, sourceVersion, sourceFeatures);
                sourceSprites.load(sourceSprFile, sourceVersion, sourceFeatures);
            }
            catch (error:Error)
            {
                Log.error("Failed to load source files: " + error.message);
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                return;
            }

            if (!sourceThings.loaded || !sourceSprites.loaded)
            {
                Log.error("Source files could not be loaded.");
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                return;
            }

            var replacedCount:uint = 0;

            for (var i:uint = 0; i < total; i++)
            {
                var id:uint = uint(thingIds[i]);
                sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, i, total, "Replacing " + id + "..."));

                // Get source thing
                var sourceThing:ThingType = sourceThings.getThingType(id, category);
                if (!sourceThing)
                    continue;

                // Collect sprite IDs from source thing and import them
                var spriteMap:Object = {};
                for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
                {
                    var fg:FrameGroup = sourceThing.getFrameGroup(groupType);
                    if (!fg || !fg.spriteIndex)
                        continue;

                    for (var s:uint = 0; s < fg.spriteIndex.length; s++)
                    {
                        var srcSpriteId:uint = fg.spriteIndex[s];
                        if (srcSpriteId == 0 || spriteMap.hasOwnProperty(srcSpriteId.toString()))
                            continue;

                        var srcPixels:ByteArray = sourceSprites.getPixels(srcSpriteId);
                        if (srcPixels)
                        {
                            var addResult:ChangeResult = _sprites.addSprite(srcPixels);
                            if (addResult.done && addResult.list && addResult.list.length > 0)
                            {
                                spriteMap[srcSpriteId.toString()] = addResult.list[0].id;
                            }
                        }
                    }
                }

                // Clone the thing and remap sprite indices
                var clonedThing:ThingType = sourceThing.clone();
                clonedThing.id = id;

                for (groupType = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
                {
                    fg = clonedThing.getFrameGroup(groupType);
                    if (!fg || !fg.spriteIndex)
                        continue;

                    for (s = 0; s < fg.spriteIndex.length; s++)
                    {
                        var oldId:uint = fg.spriteIndex[s];
                        if (oldId != 0 && spriteMap.hasOwnProperty(oldId.toString()))
                        {
                            fg.spriteIndex[s] = spriteMap[oldId.toString()];
                        }
                    }
                }

                // Replace in current storage
                var result:ChangeResult = _things.replaceThing(clonedThing, category, id);
                if (result.done)
                {
                    replacedCount++;
                    syncOrCreateItem(id, category);
                }
            }

            // Unload source storage
            sourceSprites.unload();
            sourceThings.unload();

            // Force GC hint
            System.gc();

            if (replacedCount > 0)
            {
                if (category == ThingCategory.ITEM && otbLoaded)
                {
                    _items.invalidate();
                }

                sendClientInfo();

                var ids:Vector.<uint> = new Vector.<uint>();
                for (i = 0; i < thingIds.length; i++)
                    ids.push(uint(thingIds[i]));

                setSelectedThingIds(ids, category, true);
                Log.info("Bulk replaced " + replacedCount + " objects from external source.");
            }

            sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
        }

        private function applyBulkDuration(thing:ThingType, min:uint, max:uint, targetGroup:int):void
        {
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                if (targetGroup >= 0 && groupType != targetGroup)
                    continue;

                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (frameGroup && frameGroup.frames > 1)
                {
                    for (var f:uint = 0; f < frameGroup.frames; f++)
                    {
                        frameGroup.frameDurations[f] = new FrameDuration(min, max);
                    }
                }
            }
        }

        private function applyBulkAnimationMode(thing:ThingType, animationMode:int):void
        {
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (frameGroup && frameGroup.frames > 1)
                {
                    frameGroup.animationMode = animationMode;
                }
            }
        }

        private function applyBulkFrameStrategy(thing:ThingType, loopCount:int):void
        {
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (frameGroup && frameGroup.frames > 1)
                {
                    frameGroup.loopCount = loopCount;
                }
            }
        }

        private function applyBulkClearAttributes(id:uint, preserveNamePlural:Boolean):void
        {
            if (otbLoaded)
            {
                var item:ServerItem = _items.getItemByClientId(id);
                if (item)
                {
                    var savedName:String = null;
                    var savedPlural:String = null;

                    if (preserveNamePlural)
                    {
                        savedName = item.getXmlAttribute("name") as String;
                        savedPlural = item.getXmlAttribute("plural") as String;
                    }

                    item.clearAllXmlAttributes();

                    if (savedName)
                        item.setXmlAttribute("name", savedName);
                    if (savedPlural)
                        item.setXmlAttribute("plural", savedPlural);
                }
            }
        }

        private function applyBulkAttributes(id:uint, attributes:Object):void
        {
            if (otbLoaded && attributes)
            {
                var item:ServerItem = _items.getItemByClientId(id);
                if (item)
                {
                    for (var key:String in attributes)
                    {
                        item.setXmlAttribute(key, attributes[key]);
                    }
                }
            }
        }

        private function processThingDataDataList(list:Vector.<ThingData>, spritesIds:Vector.<uint>):ChangeResult
        {
            var result:ChangeResult;
            var length:uint = list.length;
            for (var i:uint = 0; i < length; i++)
            {
                var thingData:ThingData = list[i];
                processThingDataConversion(thingData);

                result = processThingDataSprites(thingData, spritesIds);
                if (!result.done)
                {
                    return result;
                }
            }
            return new ChangeResult(null, true);
        }

        private function syncItemsHelper(ids:Vector.<uint>, category:String):void
        {
            if (otbLoaded && category == ThingCategory.ITEM && ids.length > 0)
            {
                for each (var id:uint in ids)
                {
                    syncOrCreateItem(id, category);
                }
            }
        }

        private function checkThingMatch(thing:ThingType,
                propertiesWithoutName:Vector.<ThingProperty>,
                nameSearchTerm:String,
                searchNoName:Boolean,
                searchAttribute:String):Boolean
        {
            // Check other properties first
            for each (var otherProp:ThingProperty in propertiesWithoutName)
            {
                if (otherProp.property != null)
                {
                    if (otherProp.property == "groups")
                    {
                        if (otherProp.value != thing.frameGroups.length)
                        {
                            return false;
                        }
                    }
                    else if (thing.hasOwnProperty(otherProp.property))
                    {
                        if (otherProp.value != thing[otherProp.property])
                        {
                            return false;
                        }
                    }
                    else
                    {
                        var matchesProperty:Boolean = false;
                        var frameGroup:FrameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);
                        if (frameGroup && frameGroup.hasOwnProperty(otherProp.property))
                        {
                            if (otherProp.value == frameGroup[otherProp.property])
                            {
                                matchesProperty = true;
                            }
                        }

                        if (!matchesProperty)
                        {
                            frameGroup = thing.getFrameGroup(FrameGroupType.WALKING);
                            if (frameGroup && frameGroup.hasOwnProperty(otherProp.property))
                            {
                                if (otherProp.value == frameGroup[otherProp.property])
                                {
                                    matchesProperty = true;
                                }
                            }
                        }

                        if (!matchesProperty)
                        {
                            return false;
                        }
                    }
                }
            }

            // Get server item for name and attribute checks
            var serverItem:ServerItem = null;
            if (_items && _items.loaded)
            {
                serverItem = _items.getItemByClientId(thing.id);
            }

            // Check noName filter - find items with no name at all
            if (searchNoName)
            {
                var hasAnyName:Boolean = false;

                // Check DAT marketName
                if (thing.marketName != null && thing.marketName.length > 0)
                    hasAnyName = true;

                // Check server item name
                if (!hasAnyName && serverItem != null && serverItem.nameXml != null && serverItem.nameXml.length > 0)
                    hasAnyName = true;

                if (hasAnyName)
                    return false; // Skip items that have a name
            }

            // Check hasAttribute filter - find items that have a specific XML attribute
            if (searchAttribute != null && searchAttribute.length > 0)
            {
                if (!serverItem || !serverItem.hasXmlAttribute(searchAttribute))
                    return false; // Skip items without the attribute
            }

            // Check name search term if provided
            if (nameSearchTerm != null)
            {
                var nameMatched:Boolean = false;

                // Check DAT marketName
                if (thing.marketName != null)
                {
                    var datName:String = StringUtil.toKeyString(thing.marketName);
                    if (datName.indexOf(nameSearchTerm) != -1)
                    {
                        nameMatched = true;
                    }
                }

                // Check server item name if not matched by DAT name
                if (!nameMatched && serverItem != null && serverItem.nameXml != null)
                {
                    var serverName:String = StringUtil.toKeyString(serverItem.nameXml);
                    if (serverName.indexOf(nameSearchTerm) != -1)
                    {
                        nameMatched = true;
                    }
                }

                if (!nameMatched)
                    return false; // Skip items that don't match name search
            }

            return true;
        }

        /**
         * Unified callback for pasting thing data (properties, patterns, or attributes).
         * @param targetId The target thing ID.
         * @param category The thing category.
         * @param sourceThingType The source ThingType to copy from.
         * @param pasteType PasteDataType enum (PROPERTIES, PATTERNS, or ATTRIBUTES).
         */
        private function pasteThingDataCallback(targetId:uint, category:String, sourceThingType:ThingType, pasteType:String):void
        {
            if (!sourceThingType)
            {
                throw new NullArgumentError("sourceThingType");
            }

            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var targetThing:ThingType = _things.getThingType(targetId, category);
            if (!targetThing)
                return;

            switch (pasteType)
            {
                case ThingListEvent.PASTE_PROPERTIES:
                    // Copy only properties (flags), NOT frameGroups/patterns/animation
                    targetThing.copyPropertiesFrom(sourceThingType);
                    break;
                case ThingListEvent.PASTE_PATTERNS:
                    // Copy only patterns/animation (frameGroups), NOT properties
                    targetThing.copyPatternsFrom(sourceThingType);
                    break;
                case ThingListEvent.PASTE_ATTRIBUTES:
                    // TODO: Implement attributes paste when needed
                    Log.info(Resources.getString("notImplemented", "Paste Attributes"));
                    return;
            }

            // Mark as changed
            _things.invalidate();

            // Sync with OTB first (before sending list to UI)
            syncOrCreateItem(targetId, category);

            // Notify UI
            sendClientInfo();
            getThingCallback(targetId, category);
            sendThingList(Vector.<uint>([targetId]), category, true);

            var message:String = Resources.getString(
                    "logChanged",
                    toLocale(category),
                    targetId);

            Log.info(message);
        }

        private function removeThingsCallback(list:Vector.<uint>, category:String, removeSprites:Boolean):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            if (!ThingCategory.getCategory(category))
            {
                throw new ArgumentError(Resources.getString("invalidCategory"));
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Remove things

            var result:ChangeResult = _things.removeThings(list, category);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            var removedThingList:Array = result.list;

            // Remove from OTB items list (if category is 'item')
            if (otbLoaded && category == ThingCategory.ITEM)
            {
                for (var j:uint = 0; j < removedThingList.length; j++)
                {
                    var clientId:uint = removedThingList[j].id;
                    var serverItems:Array = _items.getItemsByClientId(clientId);
                    if (serverItems && serverItems.length > 0)
                    {
                        // Create copy of array since we're modifying during iteration
                        var itemsToRemove:Array = serverItems.slice();
                        for each (var serverItem:ServerItem in itemsToRemove)
                        {
                            _items.removeItem(serverItem.id);
                        }
                    }
                }
                _items.invalidate();
            }

            // Remove sprites
            var removedSpriteList:Array;

            if (removeSprites)
            {
                var sprites:Object = {};
                var id:uint;

                length = removedThingList.length;
                for (var i:uint = 0; i < length; i++)
                {
                    var spriteIndex:Vector.<uint> = removedThingList[i].spriteIndex;
                    var len:uint = spriteIndex.length;
                    for (var k:uint = 0; k < len; k++)
                    {
                        id = spriteIndex[k];
                        if (id != 0)
                        {
                            sprites[id] = id;
                        }
                    }
                }

                var spriteIds:Vector.<uint> = new Vector.<uint>();
                for each (id in sprites)
                {
                    spriteIds[spriteIds.length] = id;
                }

                result = _sprites.removeSprites(spriteIds);
                if (!result.done)
                {
                    Log.error(result.message);
                    return;
                }

                removedSpriteList = result.list;
            }

            // ============================================================================
            // Send changes

            var message:String;

            length = removedThingList.length;
            var thingIds:Vector.<uint> = new Vector.<uint>(length, true);
            for (i = 0; i < length; i++)
            {
                thingIds[i] = removedThingList[i].id;
            }

            // Select the previous item (min removed ID - 1) instead of removed items
            thingIds.sort(Array.NUMERIC);
            var minRemovedId:uint = thingIds[0];
            var maxRemovedId:uint = thingIds[thingIds.length - 1];

            // Get the max ID in the list for this category
            var maxIdInList:uint = _things.getMaxId(category);

            // If we deleted the last item(s), select the previous one
            // Otherwise, select the same position (which will be the next item after deletion)
            var selectId:uint;
            if (maxRemovedId >= maxIdInList)
            {
                // Deleted the last item(s) - select previous
                selectId = minRemovedId > 1 ? minRemovedId - 1 : 1;
            }
            else
            {
                // Not the last - select the same position (next item will be there)
                selectId = minRemovedId;
            }
            setSelectedThingIds(Vector.<uint>([selectId]), category);

            thingIds.sort(Array.NUMERIC);
            message = Resources.getString(
                    "logRemoved",
                    toLocale(category, thingIds.length > 1),
                    thingIds);

            Log.info(message);

            // Sprites changes
            if (removeSprites && spriteIds.length != 0)
            {
                spriteIds.sort(Array.NUMERIC);
                var minRemovedSprite:uint = spriteIds[0];
                var maxRemovedSprite:uint = spriteIds[spriteIds.length - 1];

                // Get the max sprite ID
                var maxSpriteInList:uint = _sprites.spritesCount;

                // If we deleted the last sprite(s), select the previous one
                // Otherwise, select the same position
                var selectSpriteId:uint;
                if (maxRemovedSprite >= maxSpriteInList)
                {
                    selectSpriteId = minRemovedSprite > 1 ? minRemovedSprite - 1 : 1;
                }
                else
                {
                    selectSpriteId = minRemovedSprite;
                }
                sendSpriteList(Vector.<uint>([selectSpriteId]));

                message = Resources.getString(
                        "logRemoved",
                        toLocale("sprite", spriteIds.length > 1),
                        spriteIds);

                Log.info(message);
            }
        }

        private function getThingListCallback(targetId:uint, category:String):void
        {
            if (isNullOrEmpty(category))
                throw new NullOrEmptyArgumentError("category");

            sendThingList(Vector.<uint>([targetId]), category);
        }

        private function findThingCallback(category:String, properties:Vector.<ThingProperty>):void
        {
            if (!ThingCategory.getCategory(category))
            {
                throw new ArgumentError(Resources.getString("invalidCategory"));
            }

            if (!properties)
            {
                throw new NullArgumentError("properties");
            }

            // Extract special search properties
            var nameSearchTerm:String = null;
            var searchNoName:Boolean = false;
            var searchAttribute:String = null;
            var propertiesWithoutName:Vector.<ThingProperty> = new Vector.<ThingProperty>();
            for each (var prop:ThingProperty in properties)
            {
                if (prop.property == "searchName" && prop.value != null)
                {
                    nameSearchTerm = StringUtil.toKeyString(String(prop.value));
                }
                else if (prop.property == "noName" && prop.value == true)
                {
                    searchNoName = true;
                }
                else if (prop.property == "hasAttribute" && prop.value != null)
                {
                    searchAttribute = String(prop.value);
                }
                else
                {
                    propertiesWithoutName.push(prop);
                }
            }

            var list:Array = [];
            var things:Array;

            // If we need custom search (noName, hasAttribute, or name search), do it
            if (category == ThingCategory.ITEM && (nameSearchTerm != null || searchNoName || searchAttribute != null))
            {
                // Search through all items and match by either marketName or serverItem name
                things = [];
                var minId:uint = _things.getMinId(category);
                var maxId:uint = _things.getMaxId(category);
                var total:uint = maxId - minId;

                for (var id:uint = minId; id <= maxId; id++)
                {
                    var thing:ThingType = _things.getThingType(id, category);
                    if (!thing)
                        continue;

                    if (checkThingMatch(thing, propertiesWithoutName, nameSearchTerm, searchNoName, searchAttribute))
                    {
                        things.push(thing);
                    }

                    // Throttle progress events to every 100 items to prevent UI freeze
                    if (id % 100 == 0)
                    {
                        sendCommand(new ProgressCommand(ProgressBarID.FIND, id - minId, total, "Searching"));
                    }
                }
            }
            else
            {
                // Use standard search (with marketName if present)
                things = _things.findThingTypeByProperties(category, properties);
            }

            var length:uint = things.length;

            for (var i:uint = 0; i < length; i++)
            {
                var listItem:ThingListItem = new ThingListItem();
                listItem.thing = things[i];
                listItem.frameGroup = things[i].getFrameGroup(FrameGroupType.DEFAULT);
                listItem.pixels = getBitmapPixels(listItem.thing);

                // Add Server ID and name from OTB if loaded
                if (otbLoaded && category == ThingCategory.ITEM)
                {
                    var findServerItem:ServerItem = _items.getItemByClientId(things[i].id);
                    if (findServerItem)
                    {
                        listItem.serverId = findServerItem.id;
                        things[i].name = findServerItem.getDisplayName();
                    }
                }

                list[i] = listItem;
            }
            sendCommand(new FindResultCommand(FindResultCommand.THINGS, list));
        }

        private function replaceSpritesCallback(sprites:Vector.<SpriteData>):void
        {
            if (!sprites)
            {
                throw new NullArgumentError("sprites");
            }

            var length:uint = sprites.length;
            if (length == 0)
                return;

            // ============================================================================
            // Replace sprites

            var result:ChangeResult = _sprites.replaceSprites(sprites);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Send changes

            var spriteIds:Vector.<uint> = new Vector.<uint>(length, true);
            for (var i:uint = 0; i < length; i++)
            {
                spriteIds[i] = sprites[i].id;
            }

            setSelectedSpriteIds(spriteIds, true);

            var message:String = Resources.getString(
                    "logReplaced",
                    toLocale("sprite", sprites.length > 1),
                    spriteIds);

            Log.info(message);
        }

        private function replaceSpritesFromFilesCallback(list:Vector.<PathHelper>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            if (list.length == 0)
                return;

            // ============================================================================
            // Load sprites

            var loader:SpriteDataLoader = new SpriteDataLoader();
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            loader.loadFiles(list);

            var label:String = Resources.getString("loading");

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(event.id, event.loaded, event.total, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                replaceSpritesCallback(loader.spriteDataList);
            }
        }

        private function addSpritesCallback(sprites:Vector.<ByteArray>):void
        {
            if (!sprites)
            {
                throw new NullArgumentError("sprites");
            }

            if (sprites.length == 0)
                return;

            // ============================================================================
            // Add sprites

            var result:ChangeResult = _sprites.addSprites(sprites);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            var spriteAddedList:Array = result.list;

            // ============================================================================
            // Send changes to application

            var ids:Array = [];
            var length:uint = spriteAddedList.length;
            for (var i:uint = 0; i < length; i++)
            {
                ids[i] = spriteAddedList[i].id;
            }

            sendSpriteList(Vector.<uint>([ids[0]]));

            ids.sort(Array.NUMERIC);
            var message:String = Resources.getString(
                    "logAdded",
                    toLocale("sprite", ids.length > 1),
                    ids);

            Log.info(message);
        }

        private function importSpritesFromFilesCallback(list:Vector.<PathHelper>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            if (list.length == 0)
                return;

            // ============================================================================
            // Load sprites

            var loader:SpriteDataLoader = new SpriteDataLoader();
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.addEventListener(ErrorEvent.ERROR, errorHandler);
            loader.loadFiles(list);

            var label:String = Resources.getString("loading");

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(event.id, event.loaded, event.total, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                var spriteDataList:Vector.<SpriteData> = loader.spriteDataList;
                var length:uint = spriteDataList.length;
                var sprites:Vector.<ByteArray> = new Vector.<ByteArray>(length, true);

                VectorUtils.sortOn(spriteDataList, "id", Array.NUMERIC | Array.DESCENDING);

                for (var i:uint = 0; i < length; i++)
                {
                    sprites[i] = spriteDataList[i].pixels;
                }

                addSpritesCallback(sprites);
            }

            function errorHandler(event:ErrorEvent):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
                Log.error(event.text);
            }
        }

        private function exportSpritesCallback(list:Vector.<PathHelper>,
                transparentBackground:Boolean,
                jpegQuality:uint):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            var length:uint = list.length;
            if (length == 0)
                return;

            // ============================================================================
            // Save sprites

            var label:String = Resources.getString("exportingSprites");
            var helper:SaveHelper = new SaveHelper();

            for (var i:uint = 0; i < length; i++)
            {
                var pathHelper:PathHelper = list[i];
                var file:File = new File(pathHelper.nativePath);
                var name:String = FileUtil.getName(file);
                var format:String = file.extension;

                if (ImageFormat.hasImageFormat(format) && pathHelper.id != 0)
                {
                    var bitmap:BitmapData = _sprites.getBitmap(pathHelper.id, transparentBackground);
                    if (bitmap)
                    {
                        var bytes:ByteArray = ImageCodec.encode(bitmap, format, jpegQuality);
                        helper.addFile(bytes, name, format, file);
                    }
                }
            }
            helper.addEventListener(flash.events.ProgressEvent.PROGRESS, progressHandler);
            helper.addEventListener(Event.COMPLETE, completeHandler);
            helper.save();

            function progressHandler(event:flash.events.ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.DEFAULT, event.bytesLoaded, event.bytesTotal, label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));

                var ids:Vector.<uint> = new Vector.<uint>(length, true);
                for (var j:uint = 0; j < length; j++)
                {
                    ids[j] = list[j].id;
                }
                var message:String = Resources.getString(
                        "logExported",
                        toLocale("sprite", length > 1),
                        ids);
                Log.info(message);
            }
        }

        private function newSpriteCallback():void
        {
            if (_sprites.isFull)
            {
                Log.error(Resources.getString("spritesLimitReached"));
                return;
            }

            // ============================================================================
            // Add sprite

            var rect:Rectangle = new Rectangle(0, 0, SpriteExtent.DEFAULT_SIZE, SpriteExtent.DEFAULT_SIZE);
            var tempBitmap:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
            var pixels:ByteArray = tempBitmap.getPixels(rect);
            tempBitmap.dispose();
            var result:ChangeResult = _sprites.addSprite(pixels);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Send changes

            sendSpriteList(Vector.<uint>([_sprites.spritesCount]));

            var message:String = Resources.getString(
                    "logAdded",
                    Resources.getString("sprite"),
                    _sprites.spritesCount);
            Log.info(message);
        }

        private function removeSpritesCallback(list:Vector.<uint>):void
        {
            if (!list)
            {
                throw new NullArgumentError("list");
            }

            // ============================================================================
            // Removes sprites

            var result:ChangeResult = _sprites.removeSprites(list);
            if (!result.done)
            {
                Log.error(result.message);
                return;
            }

            // ============================================================================
            // Send changes

            // Select sprites
            setSelectedSpriteIds(list);

            // Send message to log
            var message:String = Resources.getString(
                    "logRemoved",
                    toLocale("sprite", list.length > 1),
                    list);

            Log.info(message);
        }

        private function getSpriteListCallback(targetId:uint):void
        {
            sendSpriteList(Vector.<uint>([targetId]));
        }

        private function needToReloadCallback(features:ClientFeatures):void
        {
            var currentOtbPath:String = _items && _items.file ? _items.file.nativePath : null;
            loadFilesCallback(_datFile ? _datFile.nativePath : null,
                    _sprFile.nativePath,
                    _version,
                    currentOtbPath,
                    features);
        }

        private function findSpritesCallback(unusedSprites:Boolean, emptySprites:Boolean):void
        {
            var finder:SpritesFinder = new SpritesFinder(_things, _sprites);
            finder.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            finder.addEventListener(Event.COMPLETE, completeHandler);
            finder.start(unusedSprites, emptySprites);

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.FIND, event.loaded, event.total));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new FindResultCommand(FindResultCommand.SPRITES, finder.foundList));
            }
        }

        private function optimizeSpritesCallback():void
        {
            var optimizer:SpritesOptimizer = new SpritesOptimizer(_things, _sprites);
            optimizer.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            optimizer.addEventListener(Event.COMPLETE, completeHandler);
            optimizer.start();

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.OPTIMIZE, event.loaded, event.total, event.label));
            }

            function completeHandler(event:Event):void
            {
                // Remove listeners to allow GC of optimizer
                optimizer.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
                optimizer.removeEventListener(Event.COMPLETE, completeHandler);

                if (optimizer.removedCount > 0)
                {
                    // Sprite IDs changed - need to recalculate OTB hashes
                    if (otbLoaded)
                    {
                        reloadItemAttributesCallback(0, true);
                    }

                    sendClientInfo();
                    sendSpriteList(Vector.<uint>([0]));
                    sendThingList(Vector.<uint>([ThingTypeStorage.MIN_ITEM_ID]), ThingCategory.ITEM);
                }

                sendCommand(new OptimizeSpritesResultCommand(optimizer.removedCount, optimizer.oldCount, optimizer.newCount));

                if (optimizer.removedCount > 0)
                {
                    Log.info(Resources.getString("logOptimizedSprites", optimizer.removedCount, optimizer.oldCount, optimizer.newCount));
                }
            }
        }

        private function optimizeFrameDurationsCallback(items:Boolean, itemsMinimumDuration:uint, itemsMaximumDuration:uint,
                outfits:Boolean, outfitsMinimumDuration:uint, outfitsMaximumDuration:uint,
                effects:Boolean, effectsMinimumDuration:uint, effectsMaximumDuration:uint):void
        {
            var optimizer:FrameDurationsOptimizer = new FrameDurationsOptimizer(_things, items, itemsMinimumDuration, itemsMaximumDuration,
                    outfits, outfitsMinimumDuration, outfitsMaximumDuration,
                    effects, effectsMinimumDuration, effectsMaximumDuration);
            optimizer.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            optimizer.addEventListener(Event.COMPLETE, completeHandler);
            optimizer.start();

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.OPTIMIZE, event.loaded, event.total, event.label));
            }

            function completeHandler(event:Event):void
            {
                sendCommand(new OptimizeFrameDurationsResultCommand());
                Log.info(Resources.getString("logFrameDurationsComplete"));
            }
        }

        private function convertFrameGroupsCallback(frameGroups:Boolean, mounts:Boolean):void
        {
            var optimizer:FrameGroupsConverter = new FrameGroupsConverter(_things, _sprites, frameGroups, mounts, _version.value, _features.improvedAnimations, _settings.getDefaultDuration(ThingCategory.OUTFIT));
            optimizer.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            optimizer.addEventListener(Event.COMPLETE, completeHandler);
            optimizer.start();

            function progressHandler(event:ProgressEvent):void
            {
                sendCommand(new ProgressCommand(ProgressBarID.OPTIMIZE, event.loaded, event.total, event.label));
            }

            function completeHandler(event:Event):void
            {
                _features.frameGroups = frameGroups;
                sendCommand(new ConvertFrameGroupsResultCommand());
                Log.info(Resources.getString("logFrameGroupsComplete"));
            }
        }

        private function clientLoadComplete():void
        {
            sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
            sendClientInfo();
            sendThingList(Vector.<uint>([ThingTypeStorage.MIN_ITEM_ID]), ThingCategory.ITEM);
            sendThingData(ThingTypeStorage.MIN_ITEM_ID, ThingCategory.ITEM);
            sendSpriteList(Vector.<uint>([0]));
            Log.info(Resources.getString("loadComplete"));
        }

        private function clientCompileComplete():void
        {
            sendClientInfo();
            sendCommand(new HideProgressBarCommand(ProgressBarID.DEFAULT));
            Log.info(Resources.getString("compileComplete"));
        }

        public function sendClientInfo():void
        {
            var info:ClientInfo = new ClientInfo();
            info.loaded = clientLoaded;

            if (info.loaded)
            {
                info.clientVersion = _version.value;
                info.clientVersionStr = _version.valueStr;
                info.datSignature = _things.signature;
                info.minItemId = ThingTypeStorage.MIN_ITEM_ID;
                info.maxItemId = _things.itemsCount;
                info.minOutfitId = ThingTypeStorage.MIN_OUTFIT_ID;
                info.maxOutfitId = _things.outfitsCount;
                info.minEffectId = ThingTypeStorage.MIN_EFFECT_ID;
                info.maxEffectId = _things.effectsCount;
                info.minMissileId = ThingTypeStorage.MIN_MISSILE_ID;
                info.maxMissileId = _things.missilesCount;
                info.sprSignature = _sprites.signature;
                info.minSpriteId = 0;
                info.maxSpriteId = _sprites.spritesCount;
                info.features = _features;
                info.changed = clientChanged;
                info.isTemporary = clientIsTemporary;
                info.otbLoaded = otbLoaded;

                // Add OTB version info if loaded
                if (info.otbLoaded && _items.items)
                {
                    info.otbMajorVersion = _items.items.majorVersion;
                    info.otbMinorVersion = _items.items.minorVersion;
                    info.otbItemsCount = _items.items.count;
                }

                if (_datFile)
                {
                    info.loadedFileName = _datFile.name;
                }
            }

            sendCommand(new SetClientInfoCommand(info));
        }

        private function sendThingList(selectedIds:Vector.<uint>, category:String, forceUpdate:Boolean = false):void
        {
            if (!_things || !_things.loaded)
            {
                throw new Error(Resources.getString("metadataNotLoaded"));
            }

            var first:uint = _things.getMinId(category);
            var last:uint = _things.getMaxId(category);
            var length:uint = selectedIds.length;

            if (length > 1)
            {
                selectedIds.sort(Array.NUMERIC | Array.DESCENDING);
                if (selectedIds[length - 1] > last)
                {
                    selectedIds = Vector.<uint>([last]);
                }
            }

            var target:uint = length == 0 ? first : selectedIds[0];

            // Check if we should hide empty objects
            var hideEmpty:Boolean = _settings && _settings.hideEmptyObjects;
            var itemsNeeded:uint = _thingListAmount > 0 ? _thingListAmount : 100;
            // Prepare pagination IDs
            var prevPageId:int = -1;
            var nextPageId:int = -1;

            var list:Vector.<ThingListItem> = new Vector.<ThingListItem>();

            if (hideEmpty)
            {
                // Robust approach: Scan all items to build a filtered list of IDs
                var filteredIds:Vector.<uint> = new Vector.<uint>();

                // Collect ALL non-empty IDs in this category
                // Optimization: Just iterating IDs is fast providing we don't do heavy work
                for (var j:uint = first; j <= last; j++)
                {
                    var t:ThingType = _things.getThingType(j, category);
                    if (t && !t.isEmpty())
                    {
                        filteredIds.push(j);
                    }
                }

                var len:uint = filteredIds.length;

                // Find index roughly corresponding to target
                var targetIndex:int = -1;

                // If target is beyond the cached ids, we clamp
                if (len > 0)
                {
                    if (target <= filteredIds[0])
                        targetIndex = 0;
                    else if (target >= filteredIds[len - 1])
                        targetIndex = len - 1;
                    else
                    {
                        // Linear search for exact or next closest
                        for (var idx:int = 0; idx < len; idx++)
                        {
                            if (filteredIds[idx] >= target)
                            {
                                targetIndex = idx;
                                break;
                            }
                        }
                        if (targetIndex == -1)
                            targetIndex = len - 1;
                    }
                }

                // PAGE ALIGNMENT
                // Snap the index to the beginning of the page
                if (targetIndex != -1)
                {
                    targetIndex = Math.floor(targetIndex / itemsNeeded) * itemsNeeded;
                }
                else
                {
                    targetIndex = 0; // Fallback
                }

                // Calculate Prev/Next IDs based on Virtual List
                if (targetIndex - itemsNeeded >= 0)
                {
                    prevPageId = filteredIds[targetIndex - itemsNeeded];
                }
                else if (targetIndex > 0)
                {
                    // If we are at index > 0 but < itemsNeeded (shouldn't happen with alignment 0),
                    // snap to 0. But alignment ensures we are at 0, 100, 200.
                    // If we are at 0, prev is -1.
                    prevPageId = -1;
                }

                if (targetIndex + itemsNeeded < len)
                {
                    nextPageId = filteredIds[targetIndex + itemsNeeded];
                }

                // Slice the needed items from the aligned start
                var count:uint = 0;
                for (var k:int = targetIndex; k < len && count < itemsNeeded; k++)
                {
                    var thingId:uint = filteredIds[k];
                    var thing:ThingType = _things.getThingType(thingId, category);
                    if (!thing)
                        continue;

                    var listItem:ThingListItem = new ThingListItem();
                    listItem.thing = thing;
                    listItem.frameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);
                    listItem.pixels = getBitmapPixels(thing);

                    if (otbLoaded && category == ThingCategory.ITEM)
                    {
                        var serverItem:ServerItem = _items.getItemByClientId(thing.id);
                        if (serverItem)
                        {
                            listItem.serverId = serverItem.id;
                            thing.name = serverItem.getDisplayName();
                        }
                    }
                    list.push(listItem);
                    count++;
                }

                // If user requested minimum (First button) or target is before first filtered item, select first item
                if (list.length > 0 && target <= filteredIds[0])
                {
                    selectedIds = Vector.<uint>([list[0].thing.id]);
                }
                // If user requested the maximum (Last button), select the actual last item
                else if (target >= last && list.length > 0)
                {
                    selectedIds = Vector.<uint>([list[list.length - 1].thing.id]);
                }
            }
            else
            {
                // Unfiltered logic (Standard)
                // Calculate page start based on offset from first ID
                // For first=1: pages are 1-100, 101-200, 201-300
                // For first=100: pages are 100-199, 200-299
                var min:uint = first + Math.floor((target - first) / itemsNeeded) * itemsNeeded;

                // Calculate prev/next
                if (min > first)
                {
                    prevPageId = min - itemsNeeded;
                    if (prevPageId < first)
                        prevPageId = first;
                    // If min was already first, we wouldn't be here.
                    // If min=101, needed=100. prev=1. Correct.
                }

                if (min + itemsNeeded <= last)
                {
                    nextPageId = min + itemsNeeded;
                }

                for (var i:uint = min; i <= last && list.length < itemsNeeded; i++)
                {
                    var thingUnfiltered:ThingType = _things.getThingType(i, category);
                    if (!thingUnfiltered)
                    {
                        continue;
                    }

                    var listItemUnfiltered:ThingListItem = new ThingListItem();
                    listItemUnfiltered.thing = thingUnfiltered;
                    listItemUnfiltered.frameGroup = thingUnfiltered.getFrameGroup(FrameGroupType.DEFAULT);
                    listItemUnfiltered.pixels = getBitmapPixels(thingUnfiltered);

                    if (otbLoaded && category == ThingCategory.ITEM)
                    {
                        var serverItem2:ServerItem = _items.getItemByClientId(thingUnfiltered.id);
                        if (serverItem2)
                        {
                            listItemUnfiltered.serverId = serverItem2.id;
                            thingUnfiltered.name = serverItem2.getDisplayName();
                        }
                    }

                    list.push(listItemUnfiltered);
                }

                // If user requested the maximum (Last button), select the actual last item
                if (target >= last && list.length > 0)
                {
                    selectedIds = Vector.<uint>([list[list.length - 1].thing.id]);
                }
            }

            sendCommand(new SetThingListCommand(selectedIds, list, forceUpdate, prevPageId, nextPageId));
        }

        private function sendThingData(id:uint, category:String):void
        {
            var thingData:ThingData = getThingData(id, category, OBDVersions.OBD_VERSION_3, _version.value);
            if (thingData)
                sendCommand(new SetThingDataCommand(thingData));
        }

        private function sendSpriteList(selectedIds:Vector.<uint>, forceUpdate:Boolean = false):void
        {
            if (!selectedIds)
            {
                throw new NullArgumentError("selectedIds");
            }

            if (!_sprites || !_sprites.loaded)
            {
                throw new Error(Resources.getString("spritesNotLoaded"));
            }

            var length:uint = selectedIds.length;
            if (length > 1)
            {
                selectedIds.sort(Array.NUMERIC | Array.DESCENDING);
                if (selectedIds[length - 1] > _sprites.spritesCount)
                {
                    selectedIds = Vector.<uint>([_sprites.spritesCount]);
                }
            }

            var target:uint = length == 0 ? 0 : selectedIds[0];
            var first:uint = 0;
            var last:uint = _sprites.spritesCount;
            var min:uint = Math.max(first, OtlibUtils.hundredFloor(target));
            var max:uint = Math.min(min + (_spriteListAmount - 1), last);
            var list:Vector.<SpriteData> = new Vector.<SpriteData>();

            for (var i:uint = min; i <= max; i++)
            {
                var pixels:ByteArray = _sprites.getPixels(i);
                if (!pixels)
                {
                    throw new Error(Resources.getString("spriteNotFound", i));
                }

                var spriteData:SpriteData = new SpriteData();
                spriteData.id = i;
                spriteData.pixels = pixels;
                list.push(spriteData);
            }

            sendCommand(new SetSpriteListCommand(selectedIds, list, forceUpdate));
        }

        private function getBitmapPixels(thing:ThingType):ByteArray
        {
            var size:uint = SpriteExtent.DEFAULT_SIZE;
            var frameGroup:FrameGroup = thing.getFrameGroup(FrameGroupType.DEFAULT);

            var width:uint = frameGroup.width;
            var height:uint = frameGroup.height;
            var layers:uint = frameGroup.layers;
            var bitmapWidth:uint = width * size;
            var bitmapHeight:uint = height * size;
            var requiredSize:uint = Math.max(bitmapWidth, bitmapHeight);
            var x:uint;

            // Reuse static buffer if possible, otherwise create/resize
            if (_renderBuffer == null || _renderBufferSize < requiredSize)
            {
                if (_renderBuffer)
                {
                    _renderBuffer.dispose();
                }
                _renderBufferSize = Math.max(requiredSize, 96); // Min 96 to cover most cases
                _renderBuffer = new BitmapData(_renderBufferSize, _renderBufferSize, true, 0xFF636363);
            }

            // Clear only the region we need
            var renderRect:Rectangle = new Rectangle(0, 0, bitmapWidth, bitmapHeight);
            _renderBuffer.fillRect(renderRect, 0xFF636363);

            if (thing.category == ThingCategory.OUTFIT)
            {
                layers = 1;
                x = frameGroup.patternX > 1 ? 2 : 0;
            }

            for (var l:uint = 0; l < layers; l++)
            {
                for (var w:uint = 0; w < width; w++)
                {
                    for (var h:uint = 0; h < height; h++)
                    {
                        var index:uint = frameGroup.getSpriteIndex(w, h, l, x, 0, 0, 0);
                        var px:int = (width - w - 1) * size;
                        var py:int = (height - h - 1) * size;
                        _sprites.copyPixels(frameGroup.spriteIndex[index], _renderBuffer, px, py);
                    }
                }
            }
            return _renderBuffer.getPixels(renderRect);
        }

        private function getThingData(id:uint, category:String, obdVersion:uint, clientVersion:uint):ThingData
        {
            if (!ThingCategory.getCategory(category))
            {
                throw new Error(Resources.getString("invalidCategory"));
            }

            var thing:ThingType = _things.getThingType(id, category);
            if (!thing)
            {
                throw new Error(Resources.getString(
                            "thingNotFound",
                            Resources.getString(category),
                            id));
            }

            var sprites:Dictionary = new Dictionary();
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (!frameGroup)
                    continue;

                sprites[groupType] = new Vector.<SpriteData>();

                var spriteIndex:Vector.<uint> = frameGroup.spriteIndex;
                var length:uint = spriteIndex.length;

                for (var i:uint = 0; i < length; i++)
                {
                    var spriteId:uint = spriteIndex[i];
                    var pixels:ByteArray = _sprites.getPixels(spriteId);
                    if (!pixels)
                    {
                        Log.error(Resources.getString("spriteNotFound", spriteId));
                        pixels = _sprites.alertSprite.getPixels();
                    }

                    var spriteData:SpriteData = new SpriteData();
                    spriteData.id = spriteId;
                    spriteData.pixels = pixels;
                    sprites[groupType][i] = spriteData;
                }
            }

            var thingData:ThingData = ThingData.create(obdVersion, clientVersion, thing, sprites);

            // Add xmlAttributes from ServerItem if this is an item and OTB is loaded
            if (category == ThingCategory.ITEM && otbLoaded)
            {
                var serverItem:ServerItem = _items.getItemByClientId(id);
                if (serverItem)
                {
                    var xmlAttrs:flash.utils.Dictionary = serverItem.getXmlAttributes();
                    if (xmlAttrs)
                    {
                        var attrsObj:Object = {};
                        for (var key:String in xmlAttrs)
                        {
                            attrsObj[key] = xmlAttrs[key];
                        }
                        thingData.xmlAttributes = attrsObj;
                    }
                }
            }

            return thingData;
        }

        private function toLocale(bundle:String, plural:Boolean = false):String
        {
            return Resources.getString(bundle + (plural ? "s" : "")).toLowerCase();
        }

        // --------------------------------------
        // Event Handlers
        // --------------------------------------

        protected function storageLoadHandler(event:StorageEvent):void
        {
            if (event.target == _things)
            {
                // Log DAT loaded with details
                Log.info("DAT loaded. Signature: 0x" + _things.signature.toString(16).toUpperCase() +
                        ". Items: " + _things.itemsCount +
                        ", Outfits: " + _things.outfitsCount +
                        ", Effects: " + _things.effectsCount +
                        ", Missiles: " + _things.missilesCount);
            }

            if (event.target == _sprites)
            {
                // Log SPR loaded with details
                Log.info("SPR loaded. Signature: 0x" + _sprites.signature.toString(16).toUpperCase() +
                        ". Sprites: " + _sprites.spritesCount);
            }

            if (event.target == _things || event.target == _sprites)
            {
                if (_things.loaded && _sprites.loaded)
                    clientLoadComplete();
            }
        }

        protected function storageChangeHandler(event:StorageEvent):void
        {
            sendClientInfo();
        }

        protected function thingsProgressHandler(event:ProgressEvent):void
        {
            sendCommand(new ProgressCommand(event.id, event.loaded, event.total, event.label ? event.label : "Loading DAT"));
        }

        protected function thingsErrorHandler(event:ErrorEvent):void
        {
            // Try load as extended.
            if (!_things.loaded && (_features == null || !_features.extended))
            {
                _errorMessage = event.text;
                var retryFeatures:ClientFeatures = _features ? _features.clone() : new ClientFeatures();
                retryFeatures.extended = true;
                var currentOtbPath2:String = _items && _items.file ? _items.file.nativePath : null;
                loadFilesCallback(_datFile ? _datFile.nativePath : null,
                        _sprFile.nativePath,
                        _version,
                        currentOtbPath2,
                        retryFeatures);
            }
            else
            {
                if (_errorMessage)
                {
                    Log.error(_errorMessage);
                    _errorMessage = null;
                }
                else
                    Log.error(event.text);
            }
        }

        protected function spritesProgressHandler(event:ProgressEvent):void
        {
            sendCommand(new ProgressCommand(event.id, event.loaded, event.total, event.label ? event.label : "Loading SPR"));
        }

        protected function itemsProgressHandler(event:ProgressEvent):void
        {
            sendCommand(new ProgressCommand(event.id, event.loaded, event.total, event.label ? event.label : "Loading OTB"));
        }

        protected function spritesErrorHandler(event:ErrorEvent):void
        {
            Log.error(event.text, "", event.errorID);
        }

        private function processThingDataConversion(thingData:ThingData):void
        {
            if (_features.frameGroups && thingData.obdVersion < OBDVersions.OBD_VERSION_3)
                ThingUtils.convertFrameGroups(thingData, ThingUtils.ADD_FRAME_GROUPS, _features.improvedAnimations, _settings.getDefaultDuration(thingData.category), _version.value < 870);
            else if (!_features.frameGroups && thingData.obdVersion >= OBDVersions.OBD_VERSION_3)
                ThingUtils.convertFrameGroups(thingData, ThingUtils.REMOVE_FRAME_GROUPS, _features.improvedAnimations, _settings.getDefaultDuration(thingData.category), _version.value < 870);
        }

        private function processThingDataSprites(thingData:ThingData, spritesIds:Vector.<uint> = null):ChangeResult
        {
            var result:ChangeResult;
            var thing:ThingType = thingData.thing;
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
                var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
                if (!frameGroup)
                    continue;

                var sprites:Vector.<SpriteData> = thingData.sprites[groupType];
                var len:uint = sprites.length;

                for (var k:uint = 0; k < len; k++)
                {
                    var spriteData:SpriteData = sprites[k];
                    var id:uint = spriteData.id;
                    if (spriteData.isEmpty())
                    {
                        id = 0;
                    }
                    else if (!_sprites.hasSpriteId(id) || !_sprites.compare(id, spriteData.pixels))
                    {
                        result = _sprites.addSprite(spriteData.pixels);
                        if (!result.done)
                        {
                            return result;
                        }
                        id = _sprites.spritesCount;
                        if (spritesIds)
                            spritesIds.push(id);
                    }
                    frameGroup.spriteIndex[k] = id;
                }
            }
            return new ChangeResult(null, true);
        }
        private function addFileToSaveHelper(helper:SaveHelper,
                encoder:OBDEncoder,
                pathHelper:PathHelper,
                category:String,
                obdVersion:uint,
                clientVersion:Version,
                spriteSheetFlag:uint,
                backgoundColor:uint,
                jpegQuality:uint):void
        {
            var thingData:ThingData = getThingData(pathHelper.id, category, obdVersion, clientVersion.value);
            var file:File = new File(pathHelper.nativePath);
            var name:String = FileUtil.getName(file);
            var format:String = file.extension;
            var bytes:ByteArray;
            var bitmap:BitmapData;

            if (ImageFormat.hasImageFormat(format))
            {
                bitmap = thingData.getTotalSpriteSheet(null, backgoundColor);
                bytes = ImageCodec.encode(bitmap, format, jpegQuality);
                if (spriteSheetFlag != 0)
                    helper.addFile(OtlibUtils.getPatternsString(thingData.thing, spriteSheetFlag), name, "txt", file);
            }
            else if (format == OTFormat.OBD)
            {
                bytes = encoder.encode(thingData);
            }
            helper.addFile(bytes, name, format, file);
        }
    }
}
