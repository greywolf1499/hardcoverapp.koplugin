local http = require("socket.http")
local json = require("json")
local ltn12 = require("ltn12")
local T = require("ffi/util").template
local socket = require("socket")

local VERSION = require("hardcover_version")

local RELEASE_API = "https://api.github.com/repos/billiam/hardcoverapp.koplugin/releases?per_page=1"

local Github = {}

function Github:newestRelease()
  local responseBody = {}
  local request = {
    url = RELEASE_API,
    sink = ltn12.sink.table(responseBody),
    headers = {
      ["User-Agent"] = T("hardcoverapp.koplugin/%1 (https://github.com/billiam/hardcoverapp.koplugin)",
        table.concat(VERSION, "."))
    }
  }

  local code, resp_headers, status = socket.skip(1, http.request(request))

  if code == 200 or code == 304 then
    local data = json.decode(table.concat(responseBody), json.decode.simple)
    if data and #data > 0 then
      local tag = data[1].tag_name
      local index = 1
      for str in string.gmatch(tag, "([^.]+)") do
        local part = tonumber(str)

        if part < VERSION[index] then
          return nil
        elseif part > VERSION[index] then
          return tag
        end
        index = index + 1
      end
    end
  end
end

return Github
