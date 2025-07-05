hs.hotkey.bind({"cmd"}, "e", function()
  hs.execute("open ~/")
end)
hs.hotkey.bind({"cmd"}, "b", function()
  hs.execute("open -n -a Firefox")
end)
hs.hotkey.bind({"cmd"}, "return", function()
  hs.applescript.applescript([[
    tell application "Terminal"
      do script ""
      activate
    end tell
  ]])
end)