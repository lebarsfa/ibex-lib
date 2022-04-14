################################################################################
################################################################################
################################################################################
# subdir_list (RESULTVAR [ WDIR wdir] [ RELATIVE ])
# return the list of directories of wdir
# If not given wdir = CMAKE_CURRENT_SOURCE_DIR
# By default, RELATIVE is not set and absolute path are returned. If RELATIVE
# is given, only the names of the directories are returned.
function (SUBDIR_LIST resultvar)
  set (opt RELATIVE)
  set (oneArgs WDIR)
  set (multiArgs "")

  cmake_parse_arguments(SL "${opt}" "${oneArgs}" "${multiArgs}" ${ARGN})

  if(SL_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Unknown keywords given to subdir_list(): \"${SL_UNPARSED_ARGUMENTS}\"")
  endif()

  if (SL_WDIR)
    set (wdir ${SL_WDIR})
  else ()
    set (wdir ${CMAKE_CURRENT_SOURCE_DIR})
  endif ()

  #
  file (GLOB children RELATIVE ${wdir} ${wdir}/*)
  set (dirlist "")
  foreach (child ${children})
    if (IS_DIRECTORY ${wdir}/${child})
      if (SL_RELATIVE)
        list (APPEND dirlist ${child})
      else()
        list (APPEND dirlist ${wdir}/${child})
      endif()
    endif()
  endforeach()
  set (${resultvar} ${dirlist} PARENT_SCOPE)
endfunction()

################################################################################
################################################################################
################################################################################
# filter the input list(s) and return only elements matching regex
function (LIST_FILTER resultvar regex)
  foreach (filelist ${ARGN})
    foreach (file ${filelist})
      if (file MATCHES "${regex}")
        list (APPEND _list ${file})
      endif ()
    endforeach()
  endforeach()
  set (${resultvar} ${_list} PARENT_SCOPE)
endfunction ()

function (LIST_FILTER_HEADER resultvar)
  list_filter (${resultvar} "\\.(h|hpp)$" ${ARGN})
  set (${resultvar} ${${resultvar}} PARENT_SCOPE)
endfunction ()

################################################################################
################################################################################
################################################################################
function (GENERATE_MAIN_HEADER outputname)
  set (opt "")
  set (oneArgs WITH_GUARD)
  set (multiArgs "")
  
  cmake_parse_arguments(GMH "${opt}" "${oneArgs}" "${multiArgs}" ${ARGN})

  file (WRITE ${outputname} "/* This file in generated by CMake */\n\n")
  if (GMH_WITH_GUARD)
    file (APPEND ${outputname} "#ifndef ${GMH_WITH_GUARD}\n")
    file (APPEND ${outputname} "#define ${GMH_WITH_GUARD}\n\n")
  endif ()

  foreach (filelist ${GMH_UNPARSED_ARGUMENTS})
    foreach (file ${filelist})
      GET_FILENAME_COMPONENT (header_name ${file} NAME)
      file (APPEND ${outputname} "#include <${header_name}>\n")
    endforeach()
  endforeach()

  if (GMH_WITH_GUARD)
    file (APPEND ${outputname} "\n#endif /* ${GMH_WITH_GUARD} */\n")
  endif ()
endfunction ()

################################################################################
################################################################################
################################################################################
function (LIB_GET_ABSPATH_FROM_NAME var libdir libname)
  if (BUILD_SHARED_LIBS)
    set (_pre ${CMAKE_SHARED_LIBRARY_PREFIX})
    set (_suf ${CMAKE_SHARED_LIBRARY_SUFFIX})
  else ()
    set (_pre ${CMAKE_STATIC_LIBRARY_PREFIX})
    set (_suf ${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif ()
  set (${var} "${libdir}/${_pre}${libname}${_suf}" PARENT_SCOPE)
endfunction ()

################################################################################
################################################################################
################################################################################
function (EXECUTE_PROCESS_CHECK)
  set (opt "")
  set (oneArgs WORKING_DIRECTORY MSG LOGBASENAME STATUS_PREFIX)
  set (multiArgs COMMAND)

  cmake_parse_arguments(EPC "${opt}" "${oneArgs}" "${multiArgs}" ${ARGN})

  if(EPC_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Unknown keywords given to execute_process_check(): \"${EPC_UNPARSED_ARGUMENTS}\"")
  endif()

  # Check mandatory arguments
  foreach (arg "COMMAND" "MSG" "LOGBASENAME")
    if (NOT EPC_${arg})
      message (FATAL_ERROR "Missing mandatory argument ${arg} in execute_process_check")
    endif ()
  endforeach ()

  # use working dir if given
  if (EPC_WORKING_DIRECTORY)
    set (_workingdir WORKING_DIRECTORY ${EPC_WORKING_DIRECTORY})
  endif ()

  message (STATUS "${EPC_STATUS_PREFIX}${EPC_MSG}")
  execute_process (COMMAND ${EPC_COMMAND} ${_workingdir}
                   RESULT_VARIABLE ret
                   OUTPUT_FILE "${EPC_LOGBASENAME}-out.log"
                   ERROR_FILE "${EPC_LOGBASENAME}-err.log"
                   )

  if (ret)
    message (FATAL_ERROR "An error occurs while ${EPC_MSG}\n"
                          "See also\n${EPC_LOGBASENAME}-*.log\n")
  endif ()
endfunction ()

################################################################################
################################################################################
################################################################################
# Note: we need this one to be a macro, not a function, as we need to execute
# the following command in the same scope as the main CMakeLists.txt file
macro (ADD_MAKE_TARGET_FOR_CTEST tgtname)
  include (CTest)

  if (ARGN)
    set (_depends DEPENDS ${ARGN})
  else ()
    set (_depends "")
  endif ()

  if ("${CMAKE_GENERATOR}" STREQUAL "Unix Makefiles")
    set (_cmd ${CMAKE_CTEST_COMMAND} --output-on-failure $(ARGS))
  else ()
    set (_cmd ${CMAKE_CTEST_COMMAND} --output-on-failure)
  endif ()

  if (BUILD_TESTING)
    add_custom_target (${tgtname} COMMAND ${_cmd} ${_depends}
                                  COMMENT "Running the tests")
    add_subdirectory (tests EXCLUDE_FROM_ALL)
  endif ()
endmacro ()

################################################################################
################################################################################
################################################################################
function (GENERATORS_EXPRESSION_REPLACE_FOR_BUILD resultvar input_str)
  set (opt "")
  set (oneArgs INCLUDEDIR LIBDIR PREFIX)
  set (multiArgs "")
  
  cmake_parse_arguments(GERFB "${opt}" "${oneArgs}" "${multiArgs}" ${ARGN})

  if(GERFB_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Unknown keywords given to generators_expression_replace_for_build(): \"${GERFB_UNPARSED_ARGUMENTS}\"")
  endif()

  if (NOT GERFB_PREFIX)
    set (GERFB_PREFIX "${CMAKE_INSTALL_PREFIX}")
  endif ()
  if (NOT GERFB_INCLUDEDIR)
    set (GERFB_INCLUDEDIR "${GERFB_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")
  endif ()
  if (NOT GERFB_LIBDIR)
    set (GERFB_LIBDIR "${GERFB_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
  endif ()

  string(REPLACE "$<BUILD_INTERFACE:" "$<0:" input_str "${input_str}")
  string(REPLACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}" "$<1:${GERFB_INCLUDEDIR}" input_str "${input_str}")
  string(REPLACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_LIBDIR}" "$<1:${GERFB_LIBDIR}" input_str "${input_str}")
  string(REPLACE "$<INSTALL_INTERFACE:" "$<1:" input_str "${input_str}")

  string(REPLACE "$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}" "${GERFB_INCLUDEDIR}" input_str "${input_str}")
  string(REPLACE "$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR}" "${GERFB_LIBDIR}" input_str "${input_str}")
  string(REPLACE "$<INSTALL_PREFIX>" "${GERFB_PREFIX}" input_str "${input_str}")

  set(${resultvar} ${input_str} PARENT_SCOPE)
endfunction ()

################################################################################
################################################################################
################################################################################
function (GET_TARGET_INCDIRS outvarname target)
  set (incdirs)

  get_target_property (_propvalue ${target} INTERFACE_INCLUDE_DIRECTORIES)
  if (_propvalue)
    list (APPEND incdirs ${_propvalue})
  endif ()

  get_target_property (_libs ${target} INTERFACE_LINK_LIBRARIES)
  foreach (lib ${_libs})
    if (TARGET ${lib})
      get_target_incdirs (_propvalue ${lib})
      if (_propvalue)
        list (APPEND incdirs ${_propvalue})
      endif ()
    endif ()
  endforeach ()

  set (${outvarname} ${incdirs} PARENT_SCOPE)
endfunction ()

################################################################################
################################################################################
################################################################################
function (GET_TARGET_LIBS outvarname target)
  set (Libs)

  if (TARGET ${target})
    get_target_property (is_imported ${target} IMPORTED)
    get_target_property (target_type ${target} TYPE)
    if (is_imported)
      if (NOT "${target_type}" STREQUAL "INTERFACE_LIBRARY")
        get_target_property (_propvalue ${target} IMPORTED_PKG_LIBS)
        if (_propvalue)
          list (APPEND Libs ${_propvalue})
        endif ()
      endif ()
    else ()
      get_target_property (_propvalue ${target} NAME)
      list (APPEND Libs "-L\${libdir};-l${_propvalue}")
    endif ()

    get_target_property (_libs ${target} INTERFACE_LINK_LIBRARIES)
    if (_libs)
      foreach (lib ${_libs})
        get_target_libs (_propvalue ${lib})
        if (_propvalue)
          list (APPEND Libs ${_propvalue})
        endif ()
      endforeach ()
    endif ()
  else ()
    list (APPEND Libs ${target})
  endif ()

  set (${outvarname} ${Libs} PARENT_SCOPE)
endfunction ()

################################################################################
################################################################################
################################################################################
define_property (TARGET PROPERTY IMPORTED_PKG_LIBS
                  BRIEF_DOCS "Libs for pkg-config file"
                  FULL_DOCS "String to add to 'Libs:' in pkg-config file")

function (CREATE_TARGET_IMPORT_AND_EXPORT libname libabspath cfgfilename_var)
  set (opt NO_EXPORT INSTALL)
  set (oneArgs NAMESPACE TARGET_NAME COMPONENT)
  set (multiArgs INCLUDE_DIRECTORIES LINK_LIBRARIES COMPILE_OPTIONS DEPENDS)
  
  cmake_parse_arguments(CTIE "${opt}" "${oneArgs}" "${multiArgs}" ${ARGN})

  if(CTIE_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Unknown keywords given to create_target_import_and_export(): \"${CTIE_UNPARSED_ARGUMENTS}\"")
  endif()

  ##############################################################################
  # Default values for some arguments
  ##############################################################################
  if (CTIE_TARGET_NAME)
    set (target ${CTIE_NAMESPACE}${CTIE_TARGET_NAME})
  else ()
    set (target ${CTIE_NAMESPACE}${libname})
  endif ()

  ##############################################################################
  # Get type of library (SHARED|STATIC|MODULE|UNKNOWN)
  ##############################################################################
  if (libabspath MATCHES "${CMAKE_SHARED_LIBRARY_PREFIX}${libname}${CMAKE_SHARED_LIBRARY_SUFFIX}$")
    set (libtype "SHARED")
  elseif (libabspath MATCHES "${CMAKE_STATIC_LIBRARY_PREFIX}${libname}${CMAKE_STATIC_LIBRARY_SUFFIX}$")
    set (libtype "STATIC")
  elseif (libabspath MATCHES "${CMAKE_SHARED_MODULE_PREFIX}${libname}${CMAKE_SHARED_MODULE_SUFFIX}$")
    set (libtype "MODULE")
  elseif (NOT libabspath) # not absolute path => treat it as an interface
    set (libtype "INTERFACE")
  else ()
    set (libtype "UNKNOWN")
  endif ()

  ##############################################################################
  # Add the target and set IMPORTED_LOCATION + extra properties
  ##############################################################################
  # FIXME do we really need global ?
  add_library (${target} ${libtype} IMPORTED GLOBAL)
  if (libabspath)
    set_target_properties (${target} PROPERTIES IMPORTED_LOCATION ${libabspath})
  endif ()
  if (CTIE_INCLUDE_DIRECTORIES)
    set_target_properties (${target} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CTIE_INCLUDE_DIRECTORIES}")
  endif ()
  if (CTIE_LINK_LIBRARIES)
    set_target_properties (${target} PROPERTIES INTERFACE_LINK_LIBRARIES "${CTIE_LINK_LIBRARIES}")
  endif ()
  if (CTIE_COMPILE_OPTIONS)
    set_target_properties (${target} PROPERTIES INTERFACE_COMPILE_OPTIONS "${CTIE_COMPILE_OPTIONS}")
  endif ()
  if (CTIE_DEPENDS)
    add_dependencies (${target} ${CTIE_DEPENDS})
  endif ()

  ##############################################################################
  # install the library
  ##############################################################################
  if (CTIE_INSTALL)
    get_filename_component (libfilename "${libabspath}" NAME)
    set (installpath "$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR_3RD}/${libfilename}") 
    if (CTIE_COMPONENT)
      set (_cn COMPONENT ${CTIE_COMPONENT})
    endif ()
    install (FILES ${libabspath} DESTINATION ${CMAKE_INSTALL_LIBDIR_3RD} ${_cn})
    set_target_properties (${target} PROPERTIES IMPORTED_PKG_LIBS "-L\${prefix}/${CMAKE_INSTALL_LIBDIR_3RD};-l${libname}")
  else ()
    set (installpath ${libabspath})
    if (libabspath)
      get_filename_component (libdir "${libabspath}" DIRECTORY)
      set_target_properties (${target} PROPERTIES IMPORTED_PKG_LIBS "-L${libdir};-l${libname}")
    endif ()
  endif ()

  ##############################################################################
  # export the target
  ##############################################################################
  if (NOT CTIE_NO_EXPORT)
    set (CFG_FILENAME ${CMAKE_CURRENT_BINARY_DIR}/ibex-config-${libname}.cmake)
    # FIXME do we really need global ?
    set (CFG_CONTENT "add_library (${target} ${libtype} IMPORTED GLOBAL)")
    if (libabspath)
      generators_expression_replace_for_build (_path "${installpath}")
      set (CFG_CONTENT "${CFG_CONTENT}
set_target_properties (${target} PROPERTIES IMPORTED_LOCATION ${_path})")
    endif ()
    if (CTIE_INCLUDE_DIRECTORIES)
      generators_expression_replace_for_build (_prop "${CTIE_INCLUDE_DIRECTORIES}")
      set (CFG_CONTENT "${CFG_CONTENT}
set_target_properties (${target} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES \"${_prop}\")")
    endif ()
    if (CTIE_LINK_LIBRARIES)
      generators_expression_replace_for_build (_prop "${CTIE_LINK_LIBRARIES}")
      set (CFG_CONTENT "${CFG_CONTENT}
set_target_properties (${target} PROPERTIES INTERFACE_LINK_LIBRARIES \"${_prop}\")")
    endif ()
    if (CTIE_COMPILE_OPTIONS)
      generators_expression_replace_for_build (_prop "${CTIE_COMPILE_OPTIONS}")
      set (CFG_CONTENT "${CFG_CONTENT}
set_target_properties (${target} PROPERTIES INTERFACE_COMPILE_OPTIONS \"${_prop}\")")
    endif ()

    file (GENERATE OUTPUT ${CFG_FILENAME} CONTENT "${CFG_CONTENT}
")
    #
    set (${cfgfilename_var} "${CFG_FILENAME}" PARENT_SCOPE)
  endif ()
endfunction ()

################################################################################
################################################################################
################################################################################
function (ADD_UNINSTALL_COMMAND UNINSTALL_SCRIPT)
  file (GENERATE OUTPUT ${UNINSTALL_SCRIPT} CONTENT "\
if(NOT EXISTS \"${CMAKE_CURRENT_BINARY_DIR}/install_manifest.txt\")\n\
  message(FATAL_ERROR \"Cannot find install manifest: \\\"${CMAKE_CURRENT_BINARY_DIR}/install_manifest.txt\\\"\")\n\
endif()\n\
\n\
file(READ \"${CMAKE_CURRENT_BINARY_DIR}/install_manifest.txt\" files)\n\
string(REPLACE \"\\n\" \";\" files \"\${files}\")\n\
foreach(file \${files})\n\
  message(STATUS \"Uninstalling \\\"\$ENV{DESTDIR}\${file}\\\"\")\n\
  if(EXISTS \"\$ENV{DESTDIR}\${file}\")\n\
    exec_program(\n\
      \"${CMAKE_COMMAND}\" ARGS \"-E remove -f \\\"\$ENV{DESTDIR}\${file}\\\"\"\n\
      OUTPUT_VARIABLE rm_out\n\
      RETURN_VALUE rm_retval\n\
      )\n\
    if(\"\${rm_retval}\" STREQUAL 0)\n\
    else()\n\
      message(FATAL_ERROR \"Problem when removing \\\"\$ENV{DESTDIR}\${file}\\\": \${rm_out}\")\n\
    endif()\n\
  else()\n\
    message(STATUS \"File \\\"\$ENV{DESTDIR}\${file}\\\" does not exist.\")\n\
  endif()\n\
endforeach()\n\
")
  add_custom_target(uninstall "${CMAKE_COMMAND}" -P "${UNINSTALL_SCRIPT}")
endfunction ()

################################################################################
################################################################################
################################################################################
function (IBEX_INIT_COMMON)
  ##############################################################################
  # Options for install directory
  ##############################################################################
  set (CMAKE_INSTALL_INCLUDEDIR "include" CACHE PATH "C++ header files (include)")
  set (CMAKE_INSTALL_LIBDIR "lib" CACHE PATH "object code libraries (lib)")
  set (CMAKE_INSTALL_BINDIR "bin" CACHE PATH "user executables (bin)")
  set (CMAKE_INSTALL_PKGCONFIG "share/pkgconfig" CACHE PATH "pkg files (share/pkgconfig)")

  set (CMAKE_INSTALL_INCLUDEDIR_3RD ${CMAKE_INSTALL_INCLUDEDIR}/ibex/3rd PARENT_SCOPE)
  set (CMAKE_INSTALL_LIBDIR_3RD ${CMAKE_INSTALL_LIBDIR}/ibex/3rd PARENT_SCOPE)
  set (CMAKE_INSTALL_CONFIGCMAKE "share/ibex/cmake" PARENT_SCOPE)

  ##############################################################################
  # Print information (to ease debugging)
  ##############################################################################
  message (STATUS "Running on system ${CMAKE_HOST_SYSTEM} with processor ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  if (NOT ${CMAKE_HOST_SYSTEM} STREQUAL ${CMAKE_SYSTEM} OR
      NOT ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_SYSTEM_PROCESSOR})
    message (STATUS "Targeting system ${CMAKE_SYSTEM} with processor ${CMAKE_SYSTEM_PROCESSOR}")
  endif ()
  message (STATUS "Using CMake ${CMAKE_VERSION}")
  message (STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")

  ##############################################################################
  # Options for shared or static library
  ##############################################################################
  option (BUILD_SHARED_LIBS "Set to ON to build shared libraries" OFF)
  if (BUILD_SHARED_LIBS)
    message (STATUS "Will build shared libraries")
  else ()
    message (STATUS "Will build static libraries")
  endif ()

  ##############################################################################
  # Ibex and its plugins need c++11
  ##############################################################################
  # we do not override (nor check!) the value if a choice was already made
  if (NOT CMAKE_CXX_STANDARD)
    set (CMAKE_CXX_STANDARD 11 PARENT_SCOPE)
    set (CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE)
  endif ()

  ##############################################################################
  # Set flags and build type (release or debug)
  ##############################################################################
  include(CheckCXXCompilerFlag)
  if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message (STATUS "Setting build type to 'Release' as none was specified.")
    set (CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose type of build" FORCE)
    set_property (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")
  endif ()

  if(MSVC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_SECURE_NO_WARNINGS" PARENT_SCOPE)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D _CRT_SECURE_NO_WARNINGS" PARENT_SCOPE)
  set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D DEBUG" PARENT_SCOPE)
  else()
  set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -pg -Wall -DDEBUG" PARENT_SCOPE)
  endif()

  ##############################################################################
  # add uninstall command
  ##############################################################################
  add_uninstall_command ("${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")
endfunction ()

################################################################################
################################################################################
################################################################################
# To be used by plugin, target Ibex::ibex should exist
# return 1 if an Linear Programming library was used when Ibex was compiled
# else return 0
function (IBEX_CHECK_HAVE_LP_LIB resultvar)
  include (CheckCXXSymbolExists)
  set (_bak ${CMAKE_REQUIRED_INCLUDES}) # backup
  get_target_property (_incs Ibex::ibex INTERFACE_INCLUDE_DIRECTORIES)
  set (CMAKE_REQUIRED_INCLUDES "${_incs}")
  set (symbol "__IBEX_NO_LP_SOLVER__")
  set (header "ibex_LPLibWrapper.h")
  CHECK_CXX_SYMBOL_EXISTS (${symbol} ${header} HAVE_NO_LP_LIB)
  if (HAVE_NO_LP_LIB)
    set (${resultvar} 0 PARENT_SCOPE)
  else ()
    set (${resultvar} 1 PARENT_SCOPE)
  endif ()
  set (CMAKE_REQUIRED_INCLUDES "${_bak}") # restore backup
endfunction ()
