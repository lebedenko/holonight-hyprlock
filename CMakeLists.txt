cmake_minimum_required(VERSION 3.20)
project(holonight-hyprlock VERSION 0.1.0 LANGUAGES NONE)

include(CTest)
include(GNUInstallDirs)

install(FILES LICENSE ASSET_PROVENANCE.md LICENSES/GPL-3.0-or-later.txt
  DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/${PROJECT_NAME}")

set(HOLONIGHT_HYPRLOCK_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/holonight-hyprlock"
    CACHE PATH "Absolute runtime asset directory")
set(HOLONIGHT_HYPRLOCK_HELPER "${CMAKE_INSTALL_PREFIX}/libexec/holonight-hyprlock/status"
    CACHE FILEPATH "Absolute runtime status helper")
configure_file(config/hyprlock.conf.in hyprlock.conf @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/hyprlock.conf" DESTINATION "/etc/xdg/hypr")
install(FILES
    assets/wallpaper.png
    assets/no-avatar.png
    DESTINATION "share/holonight-hyprlock")
install(PROGRAMS scripts/status DESTINATION "libexec/holonight-hyprlock")
install(FILES README.md LICENSE DESTINATION "share/doc/holonight-hyprlock")

if(BUILD_TESTING)
    add_test(NAME status-helper COMMAND sh "${CMAKE_CURRENT_SOURCE_DIR}/tests/test-status.sh")
    add_test(NAME package-layout COMMAND sh "${CMAKE_CURRENT_SOURCE_DIR}/tests/test-package.sh"
        "${CMAKE_COMMAND}" "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
