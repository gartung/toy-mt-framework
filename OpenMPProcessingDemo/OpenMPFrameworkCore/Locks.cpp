#include "Locks.h"

#if defined(PARALLEL_MODULES)
std::shared_ptr<demo::OMPLock> demo::s_thread_unsafe_lock{ new OMPLock{}};
#else
std::shared_ptr<demo::OMPLock> demo::s_thread_unsafe_lock{ new OMPLock{}};
#endif
