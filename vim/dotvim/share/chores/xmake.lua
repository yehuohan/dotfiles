set_xmakever("3.0.0")
set_languages("c++20")

-- Print package info: xmake require --info <package>
add_requires("vulkan-headers 1.4.321")


target("libx", function()
	set_kind("static")

	add_files("$(scriptdir)/libx/**.cpp")
	add_files("$(scriptdir)/libx/*.a") -- Static library
	add_files("$(scriptdir)/libx/*.o") -- Object files
	add_includedirs("$(scriptdir)/libx", { public = true })

	add_packages("vulkan-headers", { public = true })
	if is_plat("windows") or is_plat("mingw") then
		add_defines("VK_USE_PLATFORM_WIN32_KHR", { public = true })
	elseif is_plat("linux") then
		add_defines("VK_USE_PLATFORM_XLIB_KHR", { public = true })
	elseif is_plat("android") then
		add_defines("VK_USE_PLATFORM_ANDROID_KHR", { public = true })
	elseif is_plat("macosx") then
		add_defines("VK_USE_PLATFORM_MACOS_MVK", { public = true })
	end

	if is_plat("windows") or is_plat("mingw") then
		add_defines("__API=__declspec(dllexport)", { public = true })
	else
		add_cxflags("-fvisibility=hidden", { public = true })
		add_defines('__API=__attribute__((visibility("default")))', { public = true })
	end

    add_rules("utils.glsl2spv", { bin2c = true })
    add_files("$(scriptdir)/glsl/*.vert") -- #include *.vert.spv.h
    add_files("$(scriptdir)/glsl/*.frag")
    add_files("$(scriptdir)/glsl/*.comp")
end)

target("main", function()
	set_kind("binary")
	add_files("$(scriptdir)/main/**.cpp")
	add_includedirs("$(scriptdir)/main")

	add_packages("libx")
	add_deps("libx")

	on_prepare(function(tar)
        -- 在build之前，用于生成代码等
    end)
end)

target("tags", function()
	set_kind("phony")
	set_default(false)
	on_build(function()
		os.exec("ctags -R $(scriptdir)/src")
	end)
end)
