//============================================================================
//                                  I B E X
// File        : ibex_LSmear.cpp
// Author      : Ignacio Araya
// License     : See the LICENSE file
// Last update : May, 25 2017
//============================================================================

#include "ibex_LSmear.h"
#include "ibex_ExtendedSystem.h"

using std::pair;

namespace ibex {

LPSolver::Status_Sol LSmear::getdual(IntervalMatrix& J, const IntervalVector& box, Vector& dual) const {
	int goal_ctr=-1, goal_var=rand()%box.size();
	bool minimize=rand()%2;

	if (dynamic_cast<ExtendedSystem*> (&sys)) {
		goal_ctr= dynamic_cast<ExtendedSystem*> (&sys)->goal_ctr();
		goal_var= dynamic_cast<ExtendedSystem*> (&sys)->goal_var();
		minimize=true;
	}

	// The linear system is created
	mylinearsolver->clean_ctrs();
	mylinearsolver->set_bounds(box);
	mylinearsolver->set_bounds_var(goal_var, Interval(-1e10,1e10));


	int nb_lctrs[sys.f_ctrs.image_dim()]; /* number of linear constraints generated by nonlinear constraint*/

	for (int i=0; i<sys.f_ctrs.image_dim(); i++) {
		Vector row1(sys.nb_var);
		Interval ev(0.0);
		for (int j=0; j<sys.nb_var; j++) {
			row1[j] = J[i][j].mid();
			ev -= Interval(row1[j])*box[j].mid();
		}
		ev+= sys.f_ctrs.eval(i,box.mid()).mid();

		nb_lctrs[i]=1;
		if (i!=goal_ctr) {
			if (sys.ops[i] == LEQ || sys.ops[i] == LT)
				mylinearsolver->add_constraint( row1, sys.ops[i], (-ev).ub());
			else if (sys.ops[i] == GEQ || sys.ops[i] == GT)
				mylinearsolver->add_constraint( row1, sys.ops[i], (-ev).lb());
			else { //op=EQ
				mylinearsolver->add_constraint( row1, LT, (-ev).ub());
				mylinearsolver->add_constraint( row1, GT, (-ev).lb());
				nb_lctrs[i]=2;
			}
		} else {
			mylinearsolver->add_constraint( row1, LEQ, (-ev).ub());
		}
	}


	//the linear system is solved
	LPSolver::Status_Sol stat=LPSolver::UNKNOWN;
	try {
		mylinearsolver->set_obj_var(goal_var, (minimize)? 1.0:-1.0);

		stat = mylinearsolver->solve();

		if (stat == LPSolver::OPTIMAL) {
			// the dual solution : used to compute the bound
			dual.resize(mylinearsolver->get_nb_rows());
			mylinearsolver->get_dual_sol(dual);
			int k=0; //number of multipliers != 0
			int ii=0;


			for (int i=0; i<sys.f_ctrs.image_dim(); i++) {
				if (nb_lctrs[i]==2) {
					dual[sys.nb_var+i]=dual[sys.nb_var+ii]+dual[sys.nb_var+ii+1]; ii+=2;
				} else {
					dual[sys.nb_var+i]=dual[sys.nb_var+ii]; ii++;
				}

				if (std::abs(dual[sys.nb_var+i])>1e-10) k++;
			}

			if(k<2) { stat = LPSolver::UNKNOWN; }
		}
	} catch (LPException&) {
		stat = LPSolver::UNKNOWN;
	}

	return stat;
}

int LSmear::var_to_bisect(IntervalMatrix& J, const IntervalVector& box) const {

	//Linearization
	LPSolver::Status_Sol stat = LPSolver::UNKNOWN;

	Vector dual_solution(1);

	if (lsmode==LSMEAR_MG) { //compute the Jacobian in the midpoint
		IntervalMatrix J2(sys.f_ctrs.image_dim(), sys.nb_var);
		IntervalVector box2(IntervalVector(box.mid()).inflate(1e-8));
		box2 &= box;

		sys.f_ctrs.jacobian(box2,J2);
		stat = getdual(J2, box, dual_solution);

	} else if (lsmode==LSMEAR) {
		stat = getdual(J, box, dual_solution);
	}


	int lvar = -1;
	int goal_var=dynamic_cast<ExtendedSystem*> (&sys)->goal_var();

	if (stat == LPSolver::OPTIMAL) {
		double max_Lmagn = 0.0;
		int k=0;

		for (int j=0; j<nbvars; j++) {
			Interval lsmear=Interval(0.0);
			if ((!too_small(box,j)) && (box[j].mag() <1 ||  box[j].diam()/ box[j].mag() >= prec(j))){
				lsmear=dual_solution[j];

				for (int i=0; i<sys.f_ctrs.image_dim(); i++)
					lsmear += dual_solution[sys.nb_var+i] * J[i][j];
			}

			lsmear*=(box[j].diam());

			if (lsmear.mag() > 1e-10  && (j!=goal_var || mylinearsolver->get_obj_value().mid() > box[goal_var].lb() )) {
				k++;
				if (lsmear.mag() > max_Lmagn) {
					max_Lmagn = lsmear.mag();
					lvar = j;
				}
			}
		}

		if (k==1 && lvar==goal_var) { lvar=-1; }
	}

	if (lvar==-1) {
		lvar=SmearSumRelative::var_to_bisect(J, box);
	}

	return lvar;
}


} /* namespace ibex */
