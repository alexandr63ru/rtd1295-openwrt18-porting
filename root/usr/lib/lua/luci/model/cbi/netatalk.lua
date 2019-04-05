-- Copyright 2012 Gabor Juhos <juhosg@openwrt.org>
-- Licensed to the public under the Apache License 2.0.
require("nixio.fs")
local m, s, o
m = Map("afpd", "TimeMachine",
	translate("AFP (netatalk) for Apple TimeMachine."))

s = m:section(TypedSection, "netatalk", translate("Settings"))
s.anonymous = true

o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

servername = s:option(Value, "hostname", translate("Server Name"))
servername.rmempty = true
function servername.cfgvalue(self, section)
	local name = Value.cfgvalue(self, section)
	if name == nil then
	  for Line in io.lines("/etc/afp.conf") do
	    if Line:find("hostname") and not Line:find(";")  then
	  	  start,p_end = string.find(Line, "\"")
	  	  name = string.sub(Line,start+1,string.len(Line)-1)
	    end
	  end
	  if name == "" then
	  	local f = io.popen("/usr/bin/hostname")
	  	local hostname = f:read("*a") or ""
	  	f:close()
	  	hostname = string.gsub(hostname, "\n$", "")
	  	name = hostname.." - TimeMachine"
	  end
	end
	return name
end
function servername.write(self, section, value)
	return Flag.write(self, section, value)
end


path = s:option(Value, "path", translate("Shared Folder"))
path.rmempty = true
function path.cfgvalue(self, section)
	local path = Value.cfgvalue(self, section)
	if path == nil then 
	  for Line in io.lines("/etc/afp.conf") do
	    if Line:find("path") and Line:find("\"") and not Line:find(";")  then
	  	  start,p_end = string.find(Line, "/")
	        path=string.sub(Line,start,string.len(Line)-1)
	    end
	  end
	end
	return path
end
function path.write(self, section, value)
	return Flag.write(self, section, value)
end

return m
