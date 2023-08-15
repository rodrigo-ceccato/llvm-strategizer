##===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
##===----------------------------------------------------------------------===##
#
# Build offloading library libomptarget.so.
#
##===----------------------------------------------------------------------===##

libomptarget_say("Building offloading runtime library libomptarget.")
message("Looking for header in...... ${CMAKE_CURRENT_SOURCE_DIR}/../DeviceRTL/include")

add_llvm_library(omptarget
  SHARED

  api.cpp
  device.cpp # we must link against DeviceRTL to use KMPC interface
  interface.cpp
  interop.cpp
  omptarget.cpp
  ompt_callback.cpp
  rtl.cpp
  LegacyAPI.cpp
  autoStrategizer.cpp

  ADDITIONAL_HEADER_DIRS

  LINK_COMPONENTS
  Support
  Object

  LINK_LIBS
  PRIVATE
  omp
  "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/exports"
  NO_INSTALL_RPATH
)

# add -lnuma to compilation
target_link_libraries(omptarget PRIVATE numa)

target_include_directories(omptarget PRIVATE ${LIBOMPTARGET_INCLUDE_DIR} 
# include DeviceRTL headers
${CMAKE_CURRENT_SOURCE_DIR}/../DeviceRTL/include

)

# libomptarget.so needs to be aware of where the plugins live as they
# are now separated in the build directory.
set_target_properties(omptarget PROPERTIES INSTALL_RPATH "$ORIGIN" BUILD_RPATH "$ORIGIN:${CMAKE_CURRENT_BINARY_DIR}/..")
install(TARGETS omptarget LIBRARY COMPONENT omptarget DESTINATION "${OPENMP_INSTALL_LIBDIR}")
