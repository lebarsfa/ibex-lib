/* ============================================================================
 * I B E X - No bisectable variable
 * ============================================================================
 * Copyright   : Ecole des Mines de Nantes (FRANCE)
 * License     : This program can be distributed under the terms of the GNU LGPL.
 *               See the file COPYING.LESSER.
 *
 * Author(s)   : Bertrand Neveu
 * Created     : Feb 28, 2015
 * ---------------------------------------------------------------------------- */

#ifndef __AFFINE_PROJECTION_EXCEPTION_H__
#define __AFFINE_PROJECTION_EXCEPTION_H__


#include "ibex_Exception.h"

namespace ibex {

/**
 * \ingroup level2
 * \brief Thrown when no bisesction is posible.
 */
class AffineProjectionException : public Exception {

};

} // namespace ibex
#endif // __AFFINE_PROJECTION_EXCEPTION_H__
