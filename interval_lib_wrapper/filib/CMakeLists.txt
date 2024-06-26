################################################################################
# Options
################################################################################
set (FILIB_DIR "" CACHE PATH "Path to the Filib lib and include directories")

################################################################################
# May be needed to install missing dependencies
################################################################################
include (ExternalProject)
include (IbexUtils)

# Looking for interval/interval.hpp, result is written in FILIB_INCDIR
find_header_custom (FILIB "interval/interval.hpp" PATHS "${FILIB_DIR}")
# Looking for prim library, result is written in FILIB_LIB
find_library_custom (FILIB "prim" PATHS "${FILIB_DIR}")

# See also flags in ibex-config-utils.cmake...

if (FILIB_INCDIR AND FILIB_LIB)
  create_target_import_and_export (prim ${FILIB_LIB} FILIB_EXPORTFILE
                                        ${filib_compile_option}
                                        NAMESPACE Ibex::
                                        TARGET_NAME filib
                                        INCLUDE_DIRECTORIES ${FILIB_INCDIR})
else ()
  message (STATUS "Will install and use library Filib from 3rd/ subdirectory")

  set (filib_basename "filibsrc-3.0.2.2")
  set (filib_archive_name "${filib_basename}.tar.gz")
  set (filib_archive "${CMAKE_CURRENT_SOURCE_DIR}/3rd/${filib_archive_name}")
  set (wdir "${CMAKE_CURRENT_BINARY_DIR}/${filib_basename}")
  set (logdir "${CMAKE_CURRENT_BINARY_DIR}/log")
  set (_prefix "Filib: ")

  file (MAKE_DIRECTORY "${logdir}")

  # extract
  execute_process_check (COMMAND ${CMAKE_COMMAND} -E tar xzf ${filib_archive}
                         WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                         MSG "extracting ${filib_archive_name}"
                         LOGBASENAME "${logdir}/extract"
                         STATUS_PREFIX "${_prefix}")

  # apply patch
  set (FILIB_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/3rd/filibsrc-3.0.2.2.all.all.patch")
  execute_process_check (COMMAND patch -p1 -i ${FILIB_PATCH}
                         WORKING_DIRECTORY ${wdir}
                         MSG "patching ${filib_archive_name}"
                         LOGBASENAME "${logdir}/patch"
                         STATUS_PREFIX "${_prefix}")

  # copy files
  foreach (file "CMakeLists.txt" "config.h.in" "rounding_control/rounding_control_config.hpp.in")
    set (infile ${CMAKE_CURRENT_SOURCE_DIR}/3rd/${filib_basename}/${file})
    set (outfile ${wdir}/${file})
    string (REPLACE "/" "_" logbase "${file}")
    execute_process_check (COMMAND ${CMAKE_COMMAND} -E copy ${infile} ${outfile}
                           MSG "copying ${file}"
                           LOGBASENAME "${logdir}/copy-${logbase}"
                           STATUS_PREFIX "${_prefix}")
  endforeach ()

  # configure
  message (STATUS "${_prefix}configure")
  # Original values will be restored at the end of this file
  set (CMAKE_INSTALL_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR_3RD})
  set (CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR_3RD})
  add_subdirectory (${wdir} ${wdir}-build)
  message (STATUS "${_prefix}configure - done")

  add_library (Ibex::filib ALIAS prim)
endif ()

list (APPEND EXPORTFILES "${FILIB_EXPORTFILE}")
set (EXPORTFILES "${EXPORTFILES}" PARENT_SCOPE)
