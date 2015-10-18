cmake_minimum_required(VERSION 2.8)

project(MHA_To_PNG)

set(ITK_LEGACY_SILENT "ON")

find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

find_package(Boost COMPONENTS filesystem system REQUIRED)
include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIR})
add_executable(MhaToPng mha_to_png.cxx)

target_link_libraries(MhaToPng ${ITK_LIBRARIES} ${Boost_LIBRARIES})
