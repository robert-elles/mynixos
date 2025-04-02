{
  programs.plasma = {
    enable = true;
    shortcuts = {
      "ksmserver"."Lock Session" = "Meta+X";
      "ksmserver"."Log Out Without Confirmation" = "Meta+Shift+X";
      "kwin"."Grid View" = ["Meta+G" "Meta+Shift+W"];
      "kwin"."Overview" = "Meta+W";
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 10" = "Meta+0";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "kwin"."Switch to Desktop 5" = "Meta+5";
      "kwin"."Switch to Desktop 6" = "Meta+6";
      "kwin"."Switch to Desktop 7" = "Meta+7";
      "kwin"."Switch to Desktop 8" = "Meta+8";
      "kwin"."Switch to Desktop 9" = "Meta+9";
      "kwin"."Walk Through Windows Alternative" = "Meta+K";
      "kwin"."Walk Through Windows Alternative (Reverse)" = "Meta+J";
      "kwin"."Window Close" = ["Meta+Shift+Q" "Alt+F4\\,Alt+F4\\,Close Window"];
      "kwin"."Window Fullscreen" = "Meta+Shift+F";
      "kwin"."Window Maximize" = "Meta+F";
      "kwin"."Window Operations Menu" = "Alt+`";
      "kwin"."Window to Desktop 1" = "Meta+!";
      "kwin"."Window to Desktop 10" = "Meta+)";
      "kwin"."Window to Desktop 2" = "Meta+@";
      "kwin"."Window to Desktop 3" = "Meta+#";
      "kwin"."Window to Desktop 4" = "Meta+$";
      "kwin"."Window to Desktop 5" = "Meta+%";
      "kwin"."Window to Desktop 6" = "Meta+^";
      "kwin"."Window to Desktop 7" = "Meta+&";
      "kwin"."Window to Desktop 8" = "Meta+*";
      "kwin"."Window to Desktop 9" = "Meta+(";
      "plasma-manager-commands.desktop"."kitty" = "Meta+Enter";
      "plasmashell"."activate application launcher" = "Meta";
      "plasmashell"."activate task manager entry 1" = "Alt+1";
      "plasmashell"."activate task manager entry 10" = "Alt+0";
      "plasmashell"."activate task manager entry 2" = "Alt+2";
      "plasmashell"."activate task manager entry 3" = "Alt+3";
      "plasmashell"."activate task manager entry 4" = "Alt+4";
      "plasmashell"."activate task manager entry 5" = "Alt+5";
      "plasmashell"."activate task manager entry 6" = "Alt+6";
      "plasmashell"."activate task manager entry 7" = "Alt+7";
      "plasmashell"."activate task manager entry 8" = "Alt+8";
      "plasmashell"."activate task manager entry 9" = "Alt+9";
      "plasmashell"."next activity" = "Meta+z";
      "plasmashell"."previous activity" = ["Meta+Shift+z" "Meta+Shift+Z" "Meta+Z"];
      "plasmashell"."switch to next activity" = "Meta+a";
      "plasmashell"."switch to previous activity" = ["Meta+Shift+a" "Meta+Shift+A" "Meta+A"];
      "services/chromium-browser.desktop"."_launch" = "Meta+Shift+B";
      "services/firefox.desktop"."_launch" = "Meta+B";
      "services/kitty.desktop"."_launch" = "Meta+Return";
      "services/org.kde.krunner.desktop"."_launch" = "Alt+Space";
      "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = ["Meta+Shift+P" "Meta+Shift+Print"];
      "services/org.kde.spectacle.desktop"."_launch" = "Print";
      "services/org.pulseaudio.pavucontrol.desktop"."_launch" = "Meta+H";
      "services/playerctl-2.desktop"."_launch" = "Ctrl+Shift+Left";
      "services/playerctl-4.desktop"."_launch" = "Ctrl+Shift+Space";
      "services/playerctl.desktop"."_launch" = "Ctrl+Shift+Right";
      "services/systemsettings.desktop"."_launch" = "Meta+Shift+S";
    };
    configFile = {
      "kactivitymanagerdrc"."activities"."4a162aea-a0f9-4acb-a72d-2c48d7816b0b" = "Main";
      "kcminputrc"."Libinput/2/10/TPPS\\/2 Elan TrackPoint"."PointerAcceleration" = 0.0;
      "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."PointerAcceleration" = 0.8;
      "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."ScrollFactor" = 2;
      "kcminputrc"."Libinput/2362/597/UNIW0001:00 093A:0255 Touchpad"."PointerAcceleration" = 0.8;
      "kdeglobals"."Sounds"."Enable" = false;
      "krunnerrc"."General"."ActivateWhenTypingOnDesktop" = true;
      "krunnerrc"."General"."FreeFloating" = true;
      "krunnerrc"."General"."historyBehavior" = "CompletionSuggestion";
      "kwinrc"."Desktops"."Id_1" = "Desktop_1";
      "kwinrc"."Desktops"."Id_10" = "Desktop_10";
      "kwinrc"."Desktops"."Id_2" = "Desktop_2";
      "kwinrc"."Desktops"."Id_3" = "Desktop_3";
      "kwinrc"."Desktops"."Id_4" = "Desktop_4";
      "kwinrc"."Desktops"."Id_5" = "Desktop_5";
      "kwinrc"."Desktops"."Id_6" = "Desktop_6";
      "kwinrc"."Desktops"."Id_7" = "Desktop_7";
      "kwinrc"."Desktops"."Id_8" = "Desktop_8";
      "kwinrc"."Desktops"."Id_9" = "Desktop_9";
      "kwinrc"."Desktops"."Name_1" = 1;
      "kwinrc"."Desktops"."Name_10" = 10;
      "kwinrc"."Desktops"."Name_2" = 2;
      "kwinrc"."Desktops"."Name_3" = 3;
      "kwinrc"."Desktops"."Name_4" = 4;
      "kwinrc"."Desktops"."Name_5" = 5;
      "kwinrc"."Desktops"."Name_6" = 6;
      "kwinrc"."Desktops"."Name_7" = 7;
      "kwinrc"."Desktops"."Name_8" = 8;
      "kwinrc"."Desktops"."Name_9" = 9;
      "kwinrc"."Desktops"."Number" = 10;
      "kwinrc"."Desktops"."Rows" = 3;
      "kwinrc"."Effect-translucency"."IndividualMenuConfig" = true;
      "kwinrc"."MouseBindings"."CommandAllWheel" = "Change Opacity";
      "kwinrc"."NightColor"."Active" = false;
      "kwinrc"."NightColor"."DayTemperature" = 5000;
      "kwinrc"."NightColor"."EveningBeginFixed" = 1830;
      "kwinrc"."NightColor"."Mode" = "Times";
      "kwinrc"."NightColor"."MorningBeginFixed" = 0630;
      "kwinrc"."NightColor"."NightTemperature" = 3000;
      "kwinrc"."NightColor"."TransitionTime" = 90;
      "kwinrc"."Plugins"."fadedesktopEnabled" = true;
      "kwinrc"."Plugins"."slideEnabled" = false;
      "kwinrc"."Plugins"."translucencyEnabled" = true;
      "kwinrc"."TabBoxAlternative"."ActivitiesMode" = 0;
      "kwinrc"."TabBoxAlternative"."DesktopMode" = 0;
      "kwinrc"."TabBoxAlternative"."HighlightWindows" = false;
      "kwinrc"."TabBoxAlternative"."LayoutName" = "compact";
      "kwinrulesrc"."1"."Description" = "No window borders";
      "kwinrulesrc"."1"."noborder" = true;
      "kwinrulesrc"."1"."noborderrule" = 2;
      "kwinrulesrc"."1"."types" = 1;
      "kwinrulesrc"."2"."Description" = "Joplin";
      "kwinrulesrc"."2"."activities" = "All";
      "kwinrulesrc"."2"."activitiesrule" = 3;
      "kwinrulesrc"."2"."desktops" = "Desktop_8";
      "kwinrulesrc"."2"."desktopsrule" = 3;
      "kwinrulesrc"."2"."maximizehoriz" = true;
      "kwinrulesrc"."2"."maximizehorizrule" = 3;
      "kwinrulesrc"."2"."wmclass" = "joplin Joplin";
      "kwinrulesrc"."2"."wmclasscomplete" = true;
      "kwinrulesrc"."2"."wmclassmatch" = 1;
      "kwinrulesrc"."3"."Description" = "Spotify";
      "kwinrulesrc"."3"."activities" = "All";
      "kwinrulesrc"."3"."activitiesrule" = 3;
      "kwinrulesrc"."3"."desktops" = "Desktop_5";
      "kwinrulesrc"."3"."desktopsrule" = 3;
      "kwinrulesrc"."3"."maximizehoriz" = true;
      "kwinrulesrc"."3"."maximizehorizrule" = 3;
      "kwinrulesrc"."3"."wmclass" = "spotify Spotify";
      "kwinrulesrc"."3"."wmclasscomplete" = true;
      "kwinrulesrc"."3"."wmclassmatch" = 1;
      "kwinrulesrc"."4"."Description" = "Super Productivity";
      "kwinrulesrc"."4"."activities" = "All";
      "kwinrulesrc"."4"."activitiesrule" = 3;
      "kwinrulesrc"."4"."desktops" = "Desktop_7";
      "kwinrulesrc"."4"."desktopsrule" = 3;
      "kwinrulesrc"."4"."maximizehoriz" = true;
      "kwinrulesrc"."4"."maximizehorizrule" = 3;
      "kwinrulesrc"."4"."wmclass" = "superproductivity superProductivity";
      "kwinrulesrc"."4"."wmclasscomplete" = true;
      "kwinrulesrc"."4"."wmclassmatch" = 1;
      "kwinrulesrc"."5"."Description" = "Ferdium";
      "kwinrulesrc"."5"."activities" = "All";
      "kwinrulesrc"."5"."activitiesrule" = 3;
      "kwinrulesrc"."5"."desktops" = "Desktop_9";
      "kwinrulesrc"."5"."desktopsrule" = 3;
      "kwinrulesrc"."5"."wmclass" = "ferdium Ferdium";
      "kwinrulesrc"."5"."wmclasscomplete" = true;
      "kwinrulesrc"."5"."wmclassmatch" = 1;
      "kwinrulesrc"."6"."Description" = "Visual Studio Code";
      "kwinrulesrc"."6"."maximizehoriz" = true;
      "kwinrulesrc"."6"."maximizehorizrule" = 3;
      "kwinrulesrc"."6"."maximizevert" = true;
      "kwinrulesrc"."6"."maximizevertrule" = 3;
      "kwinrulesrc"."6"."wmclass" = "code code-url-handler";
      "kwinrulesrc"."6"."wmclasscomplete" = true;
      "kwinrulesrc"."6"."wmclassmatch" = 1;
      "kwinrulesrc"."General"."count" = 6;
      "kwinrulesrc"."General"."rules" = "1,2,3,4,5,6";
      "kxkbrc"."Layout"."DisplayNames" = "";
      "kxkbrc"."Layout"."LayoutList" = "us";
      "kxkbrc"."Layout"."Use" = true;
      "kxkbrc"."Layout"."VariantList" = "altgr-intl";
      "plasma-localerc"."Formats"."LC_TIME" = "en_DE.UTF-8";
      "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowBadges" = false;
      "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowInHistory" = false;
      "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowPopups" = false;
      "plasmaparc"."General"."GlobalMute" = true;
      "plasmaparc"."General"."GlobalMuteDevices" = "easyeffects_sink.4294967295";
      "spectaclerc"."ImageSave"."lastImageSaveLocation" = "file:///home/robert/Bilder/Screenshots/Screenshot_20250331_214521.png";
      "spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Screenshots";
      "spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Screencasts";
    };
    dataFile = {
      "kate/anonymous.katesession"."Document 0"."URL" = "file:///home/robert/mynixos/machines/leopard/flake.nix";
      "kate/anonymous.katesession"."Document 1"."URL" = "file:///home/robert/mynixos/machines/leopard/hardware.nix";
      "kate/anonymous.katesession"."Document 2"."URL" = "file:///home/robert/mynixos/machines/leopard/configuration.nix";
      "kate/anonymous.katesession"."Document 3"."URL" = "file:///home/robert/mynixos/machines/leopard/hardware-configuration.nix";
      "kate/anonymous.katesession"."Kate Plugins"."cmaketoolsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."compilerexplorer" = false;
      "kate/anonymous.katesession"."Kate Plugins"."eslintplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."externaltoolsplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."formatplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katebacktracebrowserplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katebuildplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katecloseexceptplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katecolorpickerplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katectagsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katefilebrowserplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katefiletreeplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."kategdbplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."kategitblameplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katekonsoleplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."kateprojectplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."katereplicodeplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesearchplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."katesnippetsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesqlplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesymbolviewerplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katexmlcheckplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katexmltoolsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."keyboardmacrosplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."ktexteditorpreviewplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."latexcompletionplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."lspclientplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."openlinkplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."rainbowparens" = false;
      "kate/anonymous.katesession"."Kate Plugins"."rbqlplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."tabswitcherplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."textfilterplugin" = true;
      "kate/anonymous.katesession"."MainWindow0"."Active ViewSpace" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-H-Splitter" = "200,1802,0";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-Bar-0-TvList" = "kate_private_plugin_katefiletreeplugin,kateproject,kateprojectgit,lspclient_symbol_outline";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-Splitter" = 971;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-Bar-0-TvList" = "";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-Splitter" = 971;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-Bar-0-TvList" = "";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-Splitter" = 1802;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-Bar-0-TvList" = "output,diagnostics,kate_plugin_katesearch,kateprojectinfo,kate_private_plugin_katekonsoleplugin";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-Splitter" = 1665;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-Style" = 2;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-Visible" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Visible" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-V-Splitter" = "0,971,0";
      "kate/anonymous.katesession"."MainWindow0"."ToolBarsMovable" = "Disabled";
      "kate/anonymous.katesession"."MainWindow0 Settings"."ToolBarsMovable" = "Disabled";
      "kate/anonymous.katesession"."MainWindow0 Settings"."WindowState" = 10;
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Children" = "MainWindow0-ViewSpace 0";
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Orientation" = 1;
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Sizes" = 1802;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Active View" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Count" = 4;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Documents" = "3,2,1,0";
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."View 0" = 3;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."View 1" = 2;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."View 2" = 1;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."View 3" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 0"."CursorColumn" = 6;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 0"."CursorLine" = 33;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 1"."CursorColumn" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 1"."CursorLine" = 16;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 2"."CursorColumn" = 19;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 2"."CursorLine" = 133;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 3"."CursorColumn" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 3"."CursorLine" = 9;
      "kate/anonymous.katesession"."Open Documents"."Count" = 4;
      "kate/anonymous.katesession"."Open MainWindows"."Count" = 1;
      "kate/anonymous.katesession"."Plugin:kateprojectplugin:"."projects" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."BinaryFiles" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."CurrentExcludeFilter" = "-1";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."CurrentFilter" = "-1";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."ExcludeFilters" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."ExpandSearchResults" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Filters" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."FollowSymLink" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."HiddenFiles" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."MatchCase" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Place" = 1;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Recursive" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Replaces" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Search" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeAllProjects" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeCurrentFile" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeFolder" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeOpenFiles" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeProject" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchDiskFiles" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchDiskFiless" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SizeLimit" = 128;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."UseRegExp" = false;
    };
  };
}
