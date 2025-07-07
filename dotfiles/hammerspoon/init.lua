hs.hotkey.bind({"option"}, "e", function()
  hs.execute("open ~/")
end)
hs.hotkey.bind({"option"}, "b", function()
  hs.execute("/Applications/Firefox.app/Contents/MacOS/firefox --new-window about:blank &")
end)
hs.hotkey.bind({"option"}, "return", function()
  hs.applescript.applescript([[
    tell application "Terminal"
      do script ""
      activate
    end tell
  ]])
end)