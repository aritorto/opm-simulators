# defines that must be present in config.h for our headers
set (opm-simulators_CONFIG_VAR
  HAVE_OPM_GRID
  HAVE_PTHREAD
  HAVE_EWOMS
  HAVE_MPI
  HAVE_PETSC
  HAVE_CUDA
  HAVE_OPENCL
  HAVE_OPENCL_HPP
  HAVE_FPGA
  HAVE_AMGCL
  HAVE_VEXCL
  HAVE_SUITESPARSE_UMFPACK_H
  HAVE_DUNE_ISTL
  DUNE_ISTL_WITH_CHECKING
  DUNE_ISTL_VERSION_MAJOR
  DUNE_ISTL_VERSION_MINOR
  DUNE_ISTL_VERSION_REVISION
  HAVE_SUITESPARSE_UMFPACK
  )

# dependencies
set (opm-simulators_DEPS
  # Compile with C99 support if available
  "C99"
  # Various runtime library enhancements
  "Boost 1.44.0
    COMPONENTS date_time system unit_test_framework REQUIRED"
  # DUNE prerequisites
  "dune-common REQUIRED"
  "dune-istl REQUIRED"
  # matrix library
  "BLAS REQUIRED"
  "LAPACK REQUIRED"
  # Look for MPI support
  "MPI"
  # Tim Davis' SuiteSparse archive
  "SuiteSparse REQUIRED COMPONENTS umfpack"
  # SuperLU direct solver
  "SuperLU"
  # OPM dependency
  "opm-common REQUIRED"
  "opm-material REQUIRED"
  "opm-grid REQUIRED"
  "opm-models REQUIRED"
  )

find_package_deps(opm-simulators)

if(NOT HAVE_ECL_INPUT OR NOT HAVE_ECL_OUTPUT)
  message(FATAL_ERROR "Eclipse input/output support required in opm-common")
endif()
