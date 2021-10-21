local sync={}

sync.server="https://coffer.norns.online"
sync.folder=_path.audio.."pirate-radio"

function sync.init()
  print(util.os_capture("mkdir -p "..sync.folder))
end

function sync:download()
  -- run async
  clock.run(function()
    local files=sync:download_()
    print("sync: have "..#files.." files downloaded")
    if #files>2 then 
      print("sync: refreshing engine")
      engine.refresh(sync.folder)
    end
  end)
end

function sync:download_()
  print("sync: downloading")
  local files=util.os_capture("ls "..sync.folder)
  print("sync: "..files)
  local file_list={}
  for word in files:gmatch("%S+") do
    file_list[word]=true
  end
  local dl=util.os_capture("curl -k "..self.server.."/uploads")
  print("sync: "..dl)

  local server_list={}
  for w in string.gmatch(dl,'"(.-)"') do
    if w~="uploads" then
      table.insert(server_list,w)
    end
  end

  local missing_files={}
  for _,w in ipairs(server_list) do
    if file_list[w]==nil then
      table.insert(missing_files,w)
    end
  end
  for _,w in ipairs(missing_files) do
    print("curl -k -o "..sync.folder.."/"..w.." "..self.server.."/"..w)
    util.os_capture("curl -k -o "..sync.folder.."/"..w.." "..self.server.."/"..w)
  end

  -- return the list of files
  files=util.os_capture("ls "..sync.folder)
  file_list={}
  for word in files:gmatch("%S+") do
    table.insert(file_list,word)
  end
  return file_list
end

function sync:upload(file_name)
  -- curl -F file="@somefile.wav" https://coffer.norns.online/upload
  file_name=os_capture('curl -k -F file="@'..file_name..'" '..self.server..'/upload')
  print(file_name)
end

return sync