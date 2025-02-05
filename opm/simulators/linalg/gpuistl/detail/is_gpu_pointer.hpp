/*
  Copyright 2025 Equinor ASA
  This file is part of the Open Porous Media project (OPM).
  OPM is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  OPM is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  You should have received a copy of the GNU General Public License
  along with OPM.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef OPM_SIMULATORS_LINALG_GPUISTL_DETAIL_IS_GPU_POINTER_HPP
#define OPM_SIMULATORS_LINALG_GPUISTL_DETAIL_IS_GPU_POINTER_HPP

#include <cuda.h>
#include <cuda_runtime.h>
#include <memory>
#include <opm/simulators/linalg/gpuistl/detail/gpu_safe_call.hpp>

namespace Opm::gpuistl::detail
{

/**
 * @brief Checks whether the given pointer is associated with GPU device memory.
 *
 * This function retrieves CUDA pointer attributes for the provided pointer and
 * determines whether it references device memory. It returns true if the pointer
 * corresponds to GPU memory; otherwise, it returns false.
 *
 * @tparam T Type of elements pointed to by the input pointer.
 * @param ptr Pointer to the memory that needs to be checked.
 * @return True if the pointer represents GPU memory, false otherwise.
 */
template <class T>
inline bool
isGPUPointer(const T* ptr)
{
    if (ptr == nullptr) {
        return false;
    }
    cudaPointerAttributes attributes;
    OPM_GPU_SAFE_CALL(cudaPointerGetAttributes(&attributes, ptr));
    return attributes.type == cudaMemoryTypeDevice;
}


/**
 * @brief Checks if the given smart pointer refers to GPU memory.
 *
 * This overload of isGPUPointer checks the pointer by forwarding the call
 * to its raw pointer form, thereby determining if the underlying pointer
 * addresses GPU memory.
 *
 * @tparam SmartPtr A template class for the pointer type.
 * @tparam T   The type stored within the pointer.
 * @tparam Args Additional template arguments for the smart pointer (typically the custom deleter for unique pointers).
 * @param ptr  The smart pointer object to inspect.
 * @return true if the smart pointer addresses GPU memory; otherwise false.
 */
template <template <class, class...> class SmartPtr, class T, class... Args>
inline bool
isGPUPointer(const SmartPtr<T, Args...>& ptr)
{
    return isGPUPointer(ptr.get());
}
} // namespace Opm::gpuistl::detail
#endif
