cmake_minimum_required(VERSION 3.1)

# Package Info

project(multitail
    VERSION 6.5.0
    LANGUAGES C
)

include(GNUInstallDirs)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# CMake Options

set(CONFIG_FILE ${CMAKE_INSTALL_FULL_SYSCONFDIR}/multitail.conf CACHE STRING "Path to configuration file")
set(CONFIG_DIR ${CMAKE_INSTALL_FULL_SYSCONFDIR}/multitail CACHE STRING "Path to configuration directory")

option(UTF8_SUPPORT "Support UTF-8 terminals" ON)

# Dependencies

# Must be called before find_package(Curses ...)
set(CURSES_NEED_NCURSES TRUE)
if (UTF8_SUPPORT)
    set(CURSES_NEED_WIDE TRUE)
endif()

find_package(Curses REQUIRED)
find_package(Panel REQUIRED)

# Executables

list(APPEND multitail_sources
    clipboard.c
    cmdline.c
    color.c
    config.c
    cv.c
    diff.c
    error.c
    exec.c
    globals.c
    help.c
    history.c
    mem.c
    misc.c
    mt.c
    my_pty.c
    scrollback.c
    selbox.c
    stripstring.c
    term.c
    ui.c
    utils.c
)
add_executable(multitail ${multitail_sources})

# Compiler Definitions

target_compile_definitions(multitail PRIVATE
    -DVERSION="${CMAKE_PROJECT_VERSION}"
    -DCONFIG_DIR="${CONFIG_DIR}"
    -DCONFIG_FILE="${CONFIG_FILE}"
)

if (UTF8_SUPPORT)
    target_compile_definitions(multitail PRIVATE -DUTF8_SUPPORT)
endif()

if (NOT MSVC)
    target_compile_options(multitail PRIVATE
        -Wall -Wno-unused-parameter -funsigned-char
    )
endif()

# Debugging Support

if ($<CONFIG:Debug>)
    # I.e. CMAKE_BUILD_TYPE=Debug
    target_compile_definitions(multitail PRIVATE
        # TODO Replace debugging sections to check NDEBUG instead.
        -D_DEBUG
    )
    if (MSVC)
        # Warning level 4
        target_compile_options(multitail PRIVATE
            /W4
        )
    else()
        # Enable additional warnings
        target_compile_options(multitail PRIVATE
            -Wextra -Wpedantic
        )
    endif()
endif()

# Add Dependencies to Compiler / Linker Flags

target_include_directories(multitail PRIVATE ${CURSES_INCLUDE_DIRS})
target_compile_definitions(multitail PRIVATE ${CURSES_CFLAGS})
target_link_libraries(multitail PRIVATE ${CURSES_LIBRARIES})

target_include_directories(multitail PRIVATE ${PANEL_INCLUDE_DIRS})
target_compile_definitions(multitail PRIVATE ${PANEL_CFLAGS})
target_link_libraries(multitail PRIVATE ${PANEL_LIBRARIES})

target_link_libraries(multitail PRIVATE m)

install(TARGETS multitail DESTINATION ${CMAKE_INSTALL_BINDIR})

# Man Pages

install(FILES
    multitail.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

# Documentation

file(GLOB html_manuals "manual*.html")
install(FILES
    AUTHORS
    INSTALL
    README.md
    ${html_manuals}
    DESTINATION ${CMAKE_INSTALL_DOCDIR}
)

# Configuration Files

install(FILES
    multitail.conf
    DESTINATION ${CONFIG_FILE}
    RENAME multitail.conf.new
)

# Custom Targets

# XXX Included for deference to 'make thanks' in the legacy code. But do we
# really want to send emails during the build?
add_custom_target(thanks
    COMMAND echo Automatic thank you e-mail for multitail $(VERSION) on a `uname -a` | mail -s "multitail $(VERSION)" folkert@vanheusden.com
    COMMAND echo Is your company using MultiTail and you would like to be
    COMMAND echo mentioned on http://www.vanheusden.com/multitail/usedby.html ?
    COMMAND echo Then please send me a logo -not too big- and a link and I will
    COMMAND echo add it to that page.
    COMMAND echo
    COMMAND echo Oh, blatant plug: http://keetweej.vanheusden.com/wishlist.html
)
