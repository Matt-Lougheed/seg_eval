cmake_minimum_required(VERSION 2.8)

project(ComputeHausdorff)

set(ITK_LEGACY_SILENT "ON")

find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(ComputeHausdorff compute_hausdorff.cxx)

target_link_libraries(ComputeHausdorff ${ITK_LIBRARIES})
