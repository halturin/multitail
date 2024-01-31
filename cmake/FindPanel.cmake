#[=======================================================================[.rst:
FindPanel
----------

Find the panel or panelw include file and library.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``PANEL_FOUND``
  True if Panel is found.
``PANEL_INCLUDE_DIRS``
  The include directories needed to use Panel.
``PANEL_LIBRARIES``
  The libraries needed to use Panel.
``PANEL_CFLAGS``
  Parameters which ought be given to C/C++ compilers when using Panel.
#]=======================================================================]

if (CURSES_NEED_WIDE)
    set(PANEL_LIBRARY_NAME "panelw")
else()
    set(PANEL_LIBRARY_NAME "panel")
endif()

find_library(PANEL_LIBRARIES NAMES ${PANEL_LIBRARY_NAME})

find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(PANEL QUIET ${PANEL_LIBRARY_NAME})
    set(PANEL_CFLAGS ${PANEL_CFLAGS_OTHER})
endif()
