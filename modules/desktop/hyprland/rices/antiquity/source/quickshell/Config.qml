pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Quickshell's runtime state (settings/favorites/widgets JSON) must live in a
    // WRITABLE location. The QML code itself is a read-only Nix store symlink
    // (~/.config/quickshell -> store), so writing state files there fails with
    // "Read-only file system" and the theme/favorites menus can't persist.
    // Point state at XDG_STATE_HOME/quickshell (or ~/.local/state/quickshell).
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") !== "" ? Quickshell.env("XDG_STATE_HOME") : Quickshell.env("HOME") + "/.local/state") + "/quickshell"

    // Wallpapers are exposed under ~/.local/share/wallpapers (linked by the rice
    // module). hyprpaper does NOT expand ~, so build absolute paths via $HOME.
    function wp(name) {
        return Quickshell.env("HOME") + "/.local/share/wallpapers/" + name;
    }

    // Apply a wallpaper to all known monitors via hyprpaper IPC. Empty/invalid
    // paths are ignored. Called on startup, theme switch, and selector override.
    function applyWallpaper(path) {
        if (path === "" || path === null || path === undefined) return;
        // Only target monitors that are ACTUALLY connected. Setting wallpaper on
        // a disconnected output makes hyprpaper error/flash for no reason. The
        // image itself is preloaded via hyprpaper.conf, so the swap reuses the
        // buffered texture and does not reparse (no bright flash on change).
        wpSetter.command = ["bash", "-c", "for m in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do hyprctl hyprpaper wallpaper \"$m," + path + "\"; done"];
        wpSetter.running = true;
    }

    // Effective wallpaper = user-selected override (if set), else the active
    // theme's default. Switching theme resets the override to the theme default.
    function effectiveWallpaper() {
        if (root.selectedWallpaper !== "" && root.selectedWallpaper !== null)
            return root.selectedWallpaper;
        var t = themes[settings.currentTheme] != null ? settings.currentTheme : "helios";
        return themes[t].defaultWallpaperPath;
    }

    // Wallpaper setter process (hyprpaper IPC). Started on demand by applyWallpaper().
    Process {
        id: wpSetter
        running: false
    }

    // User-selected wallpaper override (persisted to state dir by the selector).
    // Empty = use the active theme's default. Populated from the override file via
    // an async process read (FileView.onLoaded does not expose `file` in this
    // quickshell build, so we shell out to cat instead).
    property string selectedWallpaper: ""

    Process {
        id: selWpReader
        running: false
        stdout: SplitParser { onRead: (line) => {
            root.selectedWallpaper = line.trim();
            applyWallpaper(effectiveWallpaper());
        } }
        command: ["bash", "-c", "cat \"$HOME/.local/state/quickshell/selectedWallpaper\" 2>/dev/null || true"]
    }

    // Watch the override file for changes with inotifywait (if available); the
    // selector writes it on every change. Falls back to one read at startup.
    Process {
        id: selWpWatch
        running: false
        stdout: SplitParser { onRead: (line) => {
            root.selectedWallpaper = line.trim();
            applyWallpaper(effectiveWallpaper());
        } }
        command: ["bash", "-c", "while true; do inotifywait -q -e modify -e attrib \"$HOME/.local/state/quickshell/selectedWallpaper\" 2>/dev/null; cat \"$HOME/.local/state/quickshell/selectedWallpaper\" 2>/dev/null || true; done"]
    }

    // Writable handle used to clear the override file on theme switch. We shell out
    // (bash echo) because FileView has no settable `text` property; this matches how
    // the `launcher wallpaper` selector writes the override file.
    function clearSelectedWallpaper() {
        clearWpProc.command = ["bash", "-c", "mkdir -p \"$HOME/.local/state/quickshell\"; : > \"$HOME/.local/state/quickshell/selectedWallpaper\""];
        clearWpProc.running = true;
    }

    Process {
        id: clearWpProc
        running: false
    }

    // OpenWeatherMap API key is read from a RUNTIME SECRET in a .env file, never
    // from the repo. The QML ships via a read-only Nix store symlink, and we must
    // not commit credentials. Put `OWM_API_KEY=<key>` in
    // ~/.local/state/quickshell/.env (chmod 600). Falls back to the legacy
    // ~/.local/state/quickshell/owm_key file if .env is absent, then to the
    // (placeholder) settings.openWeatherMap.apiKey.
    property string owmApiKey: settings.openWeatherMap.apiKey

    // Read the runtime secret from ~/.local/state/quickshell/.env (OWM_API_KEY=...),
    // falling back to the legacy owm_key file. FileView.onLoaded does not expose
    // `file` in this quickshell build, so we shell out.
    Process {
        id: owmKeyReader
        running: false
        stdout: SplitParser { onRead: (line) => {
            if (line.trim() !== "") root.owmApiKey = line.trim();
        } }
        command: ["bash", "-c", "f=\"$HOME/.local/state/quickshell/.env\"; if [ -f \"$f\" ]; then grep -E '^OWM_API_KEY=' \"$f\" | head -1 | cut -d= -f2-; elif [ -s \"$HOME/.local/state/quickshell/owm_key\" ]; then cat \"$HOME/.local/state/quickshell/owm_key\"; fi 2>/dev/null || true"]
    }

    Component.onCompleted: {
        // Kick off the async readers once the singleton is constructed.
        selWpReader.running = true;
        selWpWatch.running = true;
        owmKeyReader.running = true;
        // Apply the active theme's default wallpaper immediately (quickshell side);
        // the hyprpaper service's ExecStartPost also applies it once the display is up.
        applyWallpaper(effectiveWallpaper());
    }

    //*=======================================================================*/
    // READ THIS NOTE:
    // Simply add to this list in order to create your
    // own color schemes, they will automatically show up in the theme picker.
    property var colors: themes[themes[settings.currentTheme] == null ? 'helios' : settings.currentTheme]
    property var themes: {
        "helios": {
            "base": "#181818",
            "shadow": "#121212",
            "highlight": "#333333",
            "urgent": "#ff723e",
            "accent": "#fccf8a",
            "accentDark": "#87704f",
            "text": "#121212",
            "textLight": "#d0daed",
            "outline": "#121212",
            "outlineGradientFade": "#161616",
            "defaultWallpaperPath": wp("georges_riom_collage.png"),
            "danger": "#fc5870",
            "warning": "#fcd37b",
            "cbodyBackground": "#fccf8a",
            "cbodyBackgroundShadow": "#d1a67b",
            "cbodyMoonBackground": "#484a5e",
            "cbodyMoonBackgroundShadow": "#5e5e5e",
            "cbodyStroke": "#000000",
            "cbodyPowerMenu": "#fccf8a",
            "cbodyThemingMenu": "#a0675d",
            "cbodyFavoriteApps": "#5e5e5e",
            "cbodyMainMenu": "#666c93",
            "glassTintColor": "#fce2ab",
            "appLauncherBackground": "#252525",
            "patternLineColor": "#87704f",
            "humorWet": "#425682",
            "humorDry": "#c4a78f",
            "humorCold": "#92bbcc",
            "humorHot": "#c44444",
            "elementAir": "#ccdde2",
            "elementWater": "#6f8ebc",
            "elementEarth": "#473e39",
            "elementFire": "#c15555"
        },
        "eris": {
            "base": "#1b1c1e",
            "shadow": "#121212",
            "defaultWallpaperPath": wp("carnation_collage.png"),
            "highlight": "#2f2f33",
            "urgent": "#ff723e",
            "accent": "#c7cfe5",
            "accentDark": "#989daa",
            "text": "#121212",
            "textLight": "#b6aae2",
            "outline": "#121212",
            "danger": "#fc5870",
            "warning": "#fcd37b",
            "cbodyBackground": "#d2dddc",
            "cbodyBackgroundShadow": "#97a09f",
            "cbodyMoonBackground": "#484a5e",
            "cbodyMoonBackgroundShadow": "#5e5e5e",
            "cbodyStroke": "#000000",
            "cbodyPowerMenu": "#d2dddc",
            "cbodyThemingMenu": "#767d7f",
            "cbodyFavoriteApps": "#536868",
            "cbodyMainMenu": "#68877f",
            "glassTintColor": "#b9c5c9",
            "appLauncherBackground": "#252525",
            "patternLineColor": "#505160",
            "humorWet": "#425682",
            "humorDry": "#c4a78f",
            "humorCold": "#92bbcc",
            "humorHot": "#c44444",
            "elementAir": "#ccdde2",
            "elementWater": "#6f8ebc",
            "elementEarth": "#473e39",
            "elementFire": "#c15555"
        },
        "priapus": {
            "base": "#1f211e",
            "shadow": "#121410",
            "defaultWallpaperPath": wp("oc_the_blackboard.png"),
            "highlight": "#393d2d",
            "urgent": "#ff723e",
            "accent": "#a7b777",
            "accentDark": "#747c5c",
            "text": "#121212",
            "textLight": "#d0daed",
            "outline": "#141612",
            "danger": "#fc5870",
            "warning": "#fcd37b",
            "cbodyBackground": "#f2efb3",
            "cbodyBackgroundShadow": "#aaa87c",
            "cbodyMoonBackground": "#484a5e",
            "cbodyMoonBackgroundShadow": "#5e5e5e",
            "cbodyStroke": "#000000",
            "cbodyPowerMenu": "#f2d793",
            "cbodyThemingMenu": "#666c75",
            "cbodyFavoriteApps": "#5b5050",
            "cbodyMainMenu": "#5b6b54",
            "glassTintColor": "#a6bf85",
            "appLauncherBackground": "#252525",
            "patternLineColor": "#4a5437",
            "humorWet": "#425682",
            "humorDry": "#cdce8c",
            "humorCold": "#bcd8d6",
            "humorHot": "#c44444",
            "elementAir": "#c7e0ca",
            "elementWater": "#6f8ebc",
            "elementEarth": "#3e3f2f",
            "elementFire": "#c15555"
        },
        "eros": {
            "base": "#15101c",
            "shadow": "#110c16",
            "defaultWallpaperPath": wp("ALCHEMY-dark.png"),
            "highlight": "#2c243d",
            "urgent": "#ff723e",
            "accent": "#fccb7b",
            "accentDark": "#87704f",
            "text": "#121212",
            "textLight": "#d0daed",
            "outline": "#0c0b0c",
            "danger": "#eda1a6",
            "warning": "#fcd37b",
            "cbodyBackground": "#f9997f",
            "cbodyBackgroundShadow": "#b78487",
            "cbodyMoonBackground": "#484a5e",
            "cbodyMoonBackgroundShadow": "#5e5e5e",
            "cbodyStroke": "#000000",
            "cbodyPowerMenu": "#f9997f",
            "cbodyThemingMenu": "#705a7a",
            "cbodyFavoriteApps": "#ad7082",
            "cbodyMainMenu": "#53475e",
            "glassTintColor": "#3c2d66",
            "appLauncherBackground": "#252525",
            "patternLineColor": "#725c3b",
            "humorWet": "#425682",
            "humorDry": "#c4a78f",
            "humorCold": "#92bbcc",
            "humorHot": "#c44444",
            "elementAir": "#ccdde2",
            "elementWater": "#6f8ebc",
            "elementEarth": "#473e39",
            "elementFire": "#c15555"
        },
        "hades": {
            "base": "#181818",
            "shadow": "#121212",
            "highlight": "#333333",
            "urgent": "#ff723e",
            "accent": "#d1ceca",
            "accentDark": "#969593",
            "defaultWallpaperPath": wp("HIRAETH.png"),
            "text": "#eaeaea",
            "textLight": "#f7f8f9",
            "outline": "#e3e7e8",
            "danger": "#aa3a3a",
            "warning": "#c6c479",
            "cbodyBackground": "#181818",
            "cbodyBackgroundShadow": "#121212",
            "cbodyMoonBackground": "#484a5e",
            "cbodyMoonBackgroundShadow": "#5e5e5e",
            "cbodyStroke": "#eaeaea",
            "cbodyPowerMenu": "#181818",
            "cbodyThemingMenu": "#181818",
            "cbodyFavoriteApps": "#181818",
            "cbodyMainMenu": "#181818",
            "glassTintColor": "#d7dddb",
            "appLauncherBackground": "#252525",
            "patternLineColor": "#7f7f7f",
            "humorWet": "#425682",
            "humorDry": "#c6c479",
            "humorCold": "#8da5c9",
            "humorHot": "#c44444",
            "elementAir": "#cccccc",
            "elementWater": "#66929e",
            "elementEarth": "#423f3d",
            "elementFire": "#c15555"
        }
    }

    enum SystemPopup {
        Startmenu,
        ThemePicker,
        AppLauncher,
        None
    }
    enum SidebarPopup {
        PowerMenu,
        FavoriteAppsMenu,
        ThemingMenu,
        MainMenu,
        None
    }
    // TODO: Finish adding all the other widgets
    readonly property var widgetTypes: ["Weather", "Clock"]
    readonly property var widgetPaths: {
        "Weather": "WeatherWidget.qml",
        "Clock": "ClockWidget.qml"
        //"CPUTemp": "CPUTemperatureWidget.qml",
        //"GPUTemp": "GPUTemperatureWidget.qml",
        //"RAM": "RAMWidget.qml",
        //"TheDate": "DateWidget.qml"
    }

    // Weather stuff
    property var weatherData: undefined
    function fetchWeatherData() {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            if (xmlhttp.status == 200) {
                try {
                    weatherData = JSON.parse(xmlhttp.responseText);
                } catch (e) {
                    console.warn("Weather: got an unparsable response from openweathermap: " + e);
                }
            } else {
                // Most likely a wrong API key/city name, or no network. Keep the old
                // data around if we had any, a stale reading beats an empty widget.
                console.warn("Weather: request failed with status " + xmlhttp.status + " - check your API key and city name in settings.");
            }
        };

        // encodeURIComponent so city names with spaces or special characters work (e.g. "São Paulo").
        // API key is resolved from the runtime secret (~/.local/state/quickshell/owm_key) with a
        // fallback to the placeholder in settings; the real key is never stored in the repo.
        const url = `https://api.openweathermap.org/data/2.5/weather` + `?q=${encodeURIComponent(settings.openWeatherMap.city)}` + `&appid=${root.owmApiKey}` + `&units=metric` + `&lang=en`;

        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }
    Timer {
        interval: 10 * 60 * 1000
        running: Config.settings.openWeatherMap.enableWeather
        repeat: Config.settings.openWeatherMap.enableWeather
        triggeredOnStart: Config.settings.openWeatherMap.enableWeather
        onTriggered: Config.fetchWeatherData()
    }

    function toggleFavoriteApp(appName: string, exec: list<string>, iconPath: string) {
        let updated = Object.assign({}, favoriteApps);
        if (favoriteApps[appName] != null) {
            delete favoriteApps[appName];
            return;
        }
        if (!favoriteApps[appName]) {
            updated[appName] = {};
            favoriteApps = updated;
        }
        updated[appName] = {
            "name": appName,
            "execCommand": exec,
            "icon": iconPath
        };
        favoriteApps = updated;
    }
    property alias favoriteApps: favoriteAppsAdapter.apps
    FileView {
        path: root.stateDir + "/favoriteapps.json"
        // when changes are made on disk, reload the file's content
        watchChanges: true
        onFileChanged: reload()
        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }
        JsonAdapter {
            id: favoriteAppsAdapter

            // IGNORE WARNING, do not wrap in ()
            property var apps: ({})
        }
    }
    //Widgets
    function addWidget(monitorName: string, widgetType: int, widgetName: string, x: int, y: int, enableBackground: bool) {
        let updated = Object.assign({}, widgets);
        if (!widgets[monitorName]) {
            updated[monitorName] = {};
            widgets = updated;
        }
        updated[monitorName] = Object.assign({}, updated[monitorName]);
        updated[monitorName][Object.keys(updated[monitorName]).length] = {
            "widgetName": widgetName,
            "widgetType": widgetType,
            "x": x,
            "y": y,
            "enableBackground": enableBackground,
            "monitorName": monitorName,
            "widgetId": Object.keys(updated[monitorName]).length.toString()
        };
        widgets = updated;
    }
    function updateWidget(monitorName: string, widgetId: int, widgetName: string, x: int, y: int, enableBackground: bool, widgetType: int) {
        let updated = Object.assign({}, widgets);
        if (!widgets[monitorName]) {
            console.error("Monitor not found!");
            return;
        }
        updated[monitorName] = Object.assign({}, updated[monitorName]);
        updated[monitorName][widgetId] = {
            "widgetName": widgetName,
            "widgetType": widgetType,
            "x": x,
            "y": y,
            "enableBackground": enableBackground,
            "monitorName": monitorName,
            "widgetId": widgetId
        };
        widgets = updated;
    }
    function removeWidget(monitorName: string, widgetId: string) {
        let updated = Object.assign({}, widgets);
        delete updated[monitorName][widgetId];
        widgets = updated;
    }
    property alias widgets: widgetsAdapter.monitors
    FileView {
        path: root.stateDir + "/widgets.json"
        // when changes are made on disk, reload the file's content
        watchChanges: true
        onFileChanged: reload()
        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }
        JsonAdapter {
            id: widgetsAdapter

            // IGNORE WARNING, do not wrap in ()
            property var monitors: ({})
        }
    }

    property bool openSettingsWindow: false
    property alias settings: settingsJsonAdapter.settings
    FileView {
        path: root.stateDir + "/settings.json"
        // when changes are made on disk, reload the file's content
        watchChanges: true
        onFileChanged: reload()
        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        JsonAdapter {
            id: settingsJsonAdapter
            property JsonObject settings: JsonObject {
                property string version: "0.1"
                property bool militaryTimeClockFormat: true
                property string currentTheme: "helios"
                property int defaultWindowRadius: 12
                property bool appLauncherBackground: true
                property JsonObject openWeatherMap: JsonObject {
                    property string apiKey: "***SET_VIA_RUNTIME_SECRET***" // real key lives in ~/.local/state/quickshell/owm_key
                    property string city: "Phnom Penh" // Cambodia
                    property string unit: "metric" //standard = kelvin, metric = c, imperial = F
                    property bool enableWeather: true
                }
                property JsonObject execCommands: JsonObject {
                    property string terminal: "kitty"
                    property string files: "nemo"
                }
                property JsonObject bar: JsonObject {
                    property int fontSize: 12
                    property double workspacePadding: 0.032
                    property int trayIconSize: 12
                    property bool monochromeTrayIcons: true
                }
                onCurrentThemeChanged: {
                    console.info("Updated theme to: " + currentTheme);
                    // Switching theme resets any user-selected wallpaper override
                    // back to this theme's default (per design: override only lasts
                    // until the next theme switch).
                    root.selectedWallpaper = "";
                    // Clear the persisted override file so a reboot also resets.
                    clearSelectedWallpaper();
                    applyWallpaper(effectiveWallpaper());
                }
            }
        }
    }
}
