cmake_minimum_required(VERSION 3.20)

project(DualSenseExpressive
    VERSION 2.0.0
    DESCRIPTION "Modern Material 3 Expressive manager for PlayStation 5 DualSense on Linux"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    QuickControls2
    Widgets
    Svg
)

include_directories(src)

set(SOURCES
    src/main.cpp
    src/core/DualSenseDevice.cpp
    src/core/DualSenseClient.cpp
    src/core/ProfileManager.cpp
    src/SystrayManager.cpp
)

set(HEADERS
    src/core/DualSenseDevice.h
    src/core/DualSenseClient.h
    src/core/ProfileManager.h
    src/SystrayManager.h
)

set(RESOURCES
    resources/qml.qrc
)

add_executable(dualsense-expressive
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
)

target_link_libraries(dualsense-expressive PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::Svg
)

# Install targets
install(TARGETS dualsense-expressive
    DESTINATION bin
)

install(FILES io.github.x_eon_max.dualsense_expressive.desktop
    DESTINATION share/applications
)

install(FILES resources/icons/app-icon.svg
    DESTINATION share/icons/hicolor/scalable/apps
    RENAME io.github.x_eon_max.dualsense_expressive.svg
)
