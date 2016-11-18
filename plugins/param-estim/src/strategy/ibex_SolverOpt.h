//============================================================================
//                                  I B E X                                   
// File        : ibex_SolverOpt.h
// Author      : Gilles Chabert
// Copyright   : Ecole des Mines de Nantes (France)
// License     : See the LICENSE file
// Created     : May 13, 2012
// Last Update : August 21, 2013
//============================================================================

#ifndef __IBEX_SOLVEROPT_H__
#define __IBEX_SOLVEROPT_H__

#include "ibex_Ctc.h"
#include "ibex_Pdc.h"
#include "ibex_Bsc.h"
#include "ibex_Cell.h"
#include "ibex_CellBuffer.h"
#include "ibex_CtcQInter.h"
#include "ibex_SubPaving.h"
#include "ibex_Timer.h"
#include "ibex_Exception.h"


#include <vector>
#include <set>
#include <algorithm>
#include <utility>

using namespace std;

namespace ibex {

/**
 * \ingroup strategy
 *
 * \brief  SolverOpt.
 *
 * This class implements a branch and prune algorithm that finds all the solutions of a well constrained systems of equations (the system may contain additional inequalities).
 */


class CellOptLimitException : public Exception {} ;

class SolverOpt {
public:
	/**
	 * \brief Build a solver.
	 *
	 * \param ctc  -  the contractor (for contracting each node of the search tree) 
	 * \param bsc  -  the bisector   (for branching). Contains the stop criterion.
	 * \param buffer - the cell buffer (a CellStack in a depth first search strategy)
	 */
        SolverOpt(Ctc& ctc, Bsc& bsc, CellBuffer& buffer);

	/**
	 * \brief Solve the system (non-interactive mode).
	 *
	 * \param init_box - the initial box (the search space)
	 * 
	 * Return :the vector of solutions (small boxes with the required precision) found by the solver.
	 */
	std::vector<IntervalVector> solve(const IntervalVector& init_box);

	/**
	 * \brief Start solving (interactive mode).
	 *
	 * Can also be used to restart a new search.
	 */
	void start(const IntervalVector& init_box);

	/**
	 * \brief Continue solving (interactive mode).
	 *
	 * Look for the next solution and push it into the vector.
	 * \return false if the search is over (true otherwise).
	 */
	bool next(std::vector<IntervalVector>& sols);


	/**
	 * \brief  The contractor 
	 *
	 * contractor used by the solver for contracting the current box at each node : 
	 * generally, a sequence (with or without fixpoint) of different contractors (hc4 , acid, Newton , a linear relaxation )
	 *
	 */ 
	Ctc& ctc;

	/** Bisector (tests also precision of boxes). */
	Bsc& bsc;

	/** Cell buffer. */
	CellBuffer& buffer;

	/** Maximum cpu time used by the solver.
	 * This parameter allows to bound time complexity.
	 * The value can be fixed by the user. By default, it is -1 (no limit). */

	double time_limit;


	/** Maximal number of cells created by the solver.
	 * This parameter allows to bound the number of nodes in the search tree.
	 * The value can be fixed by the user. By default, it is -1 (no limit). */
	long cell_limit;

	/**
	 * \brief Trace level
	 *
	 *  the trace level. 
	 *  0  : no trace  (default value)
	 *  1   the solutions are printed each time a new solution is found
	 *  2   the solutions are printed each time a new solution is found and the current box is printed at each node of the branch and prune algorithm 
	 */
	int trace;

	/** Number of nodes  in the search tree */
	int nb_cells;


	/** Remember running time of the last exploration */
	double time;


protected :

        std::pair<Cell*,Cell*> 	bisect(Cell& c, IntervalVector& box1, IntervalVector& box2);
	virtual Cell* root_cell(const IntervalVector& box);
        virtual int validate_value(Cell & cell);

	virtual void precontract(Cell& c){;};
	virtual void postcontract(Cell& c){;};
        virtual void validate (Cell& c){;};
        virtual void small_box (Cell& c){;};
	virtual void other_checks(Cell& c){;};
	void time_limit_check();
	virtual void handle_small_box(Cell& c) {;};

	virtual void report_time_limit();
	virtual void init_buffer_info(Cell& c) {};
	virtual void update_buffer_info(Cell & c) {};
	virtual void push_cells(Cell&c1, Cell& c2);
	virtual Cell* pop_cell();
	virtual Cell* top_cell();
	virtual bool empty_buffer();
	BitSet impact;
        void handle_cell(Cell & cell);
};


} // end namespace ibex
#endif // __IBEX_SOLVEROPT_H__
