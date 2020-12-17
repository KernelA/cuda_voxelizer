CMAKE_MINIMUM_REQUIRED(VERSION 3.17 FATAL_ERROR)

PROJECT(CudaVoxelize LANGUAGES CXX CUDA)

FIND_PACKAGE(glm REQUIRED)
FIND_PACKAGE(OpenMP REQUIRED)
FIND_PACKAGE(Boost 1.7 REQUIRED COMPONENTS filesystem program_options log log_setup)
FIND_PACKAGE(CUDAToolkit REQUIRED)
 
SET(CUDA_VOXELIZER_EXECUTABLE cuda_voxelizer)

SET(Trimesh2_INCLUDE_DIR CACHE PATH "Path to Trimesh2 includes")
SET(CUDA_ARCH CACHE STRING "CUDA compute capability. It is prefer to set native value for your video card. Example: 61")

IF(NOT CUDA_ARCH)
	MESSAGE(FATAL_ERROR "You must set CUDA_ARCH variable. For example: 61.")
ENDIF()

IF(NOT Trimesh2_INCLUDE_DIR)
  MESSAGE(FATAL_ERROR "You need to set variable Trimesh2_INCLUDE_DIR")
ENDIF()

FIND_FILE(Trimesh2_TriMesh_h TriMesh.h ${Trimesh2_INCLUDE_DIR})
IF(NOT Trimesh2_TriMesh_h)
	message(FATAL_ERROR "Can't find TriMesh.h in ${Trimesh2_INCLUDE_DIR}")
ENDIF()
MARK_AS_ADVANCED(Trimesh2_TriMesh_h)

SET(Trimesh2_LINK_DIR CACHE PATH "Path to Trimesh2 library dir.")

IF(NOT Trimesh2_LINK_DIR)
  MESSAGE(FATAL_ERROR "You need to set variable Trimesh2_LINK_DIR")
ENDIF()

IF(NOT EXISTS "${Trimesh2_LINK_DIR}")
  MESSAGE(FATAL_ERROR "Trimesh2 library dir does not exist")
ENDIF()

FIND_LIBRARY(Trimesh2_LIBRARY trimesh ${Trimesh2_LINK_DIR})

IF(NOT Trimesh2_LIBRARY)
	message(SEND_ERROR "Can't find libtrimesh.a in ${Trimesh2_LINK_DIR}")
ENDIF()
MARK_AS_ADVANCED(Trimesh2_LIBRARY)

MESSAGE(STATUS "CUDA compute capability set to ${CUDA_ARCH}")
MESSAGE(STATUS "Found Trimesh2 include: ${Trimesh2_TriMesh_h}")
MESSAGE(STATUS "Found Trimesh2 lib: ${Trimesh2_LIBRARY}")


SET(CUDA_VOXELIZER_SRCS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/libs/helper_cuda.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/libs/helper_string.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/cpu_voxelizer.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/cpu_voxelizer.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/morton_LUTs.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/thrust_operations.cuh
  ${CMAKE_CURRENT_SOURCE_DIR}/src/thrust_operations.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/src/timer.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util_cuda.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util_cuda.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util_io.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util_io.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/voxelize.cuh
  ${CMAKE_CURRENT_SOURCE_DIR}/src/voxelize.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/src/prepare_model.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/prepare_model.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/cpu_computing.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/cpu_computing.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/gpu_computing.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/gpu_computing.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/loggers.h
)

ADD_EXECUTABLE(${CUDA_VOXELIZER_EXECUTABLE} ${CUDA_VOXELIZER_SRCS})
TARGET_COMPILE_FEATURES(${CUDA_VOXELIZER_EXECUTABLE} PUBLIC cxx_std_14)
TARGET_INCLUDE_DIRECTORIES(	${CUDA_VOXELIZER_EXECUTABLE} PRIVATE ${Trimesh2_INCLUDE_DIR})
TARGET_LINK_LIBRARIES ( ${CUDA_VOXELIZER_EXECUTABLE} PRIVATE ${Trimesh2_LIBRARY} Boost::log_setup PRIVATE Boost::log PRIVATE Boost::dynamic_linking PRIVATE glm PRIVATE OpenMP::OpenMP_CXX PRIVATE Boost::filesystem PRIVATE Boost::program_options PRIVATE PRIVATE CUDA::cuda_driver PRIVATE CUDA::cudart)
TARGET_COMPILE_OPTIONS(${CUDA_VOXELIZER_EXECUTABLE} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-gencode arch=compute_${CUDA_ARCH},code=sm_${CUDA_ARCH}>)
