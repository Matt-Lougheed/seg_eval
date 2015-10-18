cmake_minimum_required(VERSION 2.8)

project(ComputeDiceCoefficient)

set(ITK_LEGACY_SILENT "ON")

find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(ComputeDiceCoefficient compute_dice_coefficient.cxx)

target_link_libraries(ComputeDiceCoefficient ${ITK_LIBRARIES})
