cmake_minimum_required(VERSION 3.20)
project(holonight-hyprlock VERSION 0.1.0 LANGUAGES NONE)

include(CTest)

set(HOLONIGHT_HYPRLOCK_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/holonight-hyprlock")
set(HOLONIGHT_HYPRLOCK_HELPER "${CMAKE_INSTALL_PREFIX}/libexec/holonight-hyprlock/status")
configure_file(config/hyprlock.conf.in hyprlock.conf @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/hyprlock.conf" DESTINATION "/etc/xdg/hypr")
install(FILES assets/wallpaper.png assets/no-avatar.png DESTINATION "share/holonight-hyprlock")
install(PROGRAMS scripts/status DESTINATION "libexec/holonight-hyprlock")
install(FILES README.md LICENSE DESTINATION "share/doc/holonight-hyprlock")

if(BUILD_TESTING)
    add_test(NAME status-helper COMMAND sh "${CMAKE_CURRENT_SOURCE_DIR}/tests/test-status.sh")
    add_test(NAME package-layout COMMAND sh "${CMAKE_CURRENT_SOURCE_DIR}/tests/test-package.sh"
        "${CMAKE_COMMAND}" "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
