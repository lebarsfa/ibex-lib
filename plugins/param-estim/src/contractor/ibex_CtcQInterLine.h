//============================================================================

//                                  I B E X                                   
// File        : Q-intersection contractor specialized for plane detection 
// Author      : Bertrand Neveu
// Copyright   : Ecole des Mines de Nantes (France)
// License     : See the LICENSE file
// Created     : Feb 4, 2015
// Last Update : Feb 4, 2015
//============================================================================

#ifndef __IBEX_CTC_Q_INTERLINE_H__
#define __IBEX_CTC_Q_INTERLINE_H__

#include "ibex_CtcQInterAff.h"
#include "ibex_System.h"

//#include "ibex_CtcPolytopeHull.h" include
//#"ibex_LinearRelaxXTaylor.h"
namespace ibex {

class CtcQInterLine : virtual public CtcQInter {
public:
	/**
	 * \brief q-intersection on a list of contractors.
	 *
	 * The list itself is not kept by reference.
	 */

  CtcQInterLine(int n,  const Array<Ctc>& ctc_list,double*** linfun, 
		   double epseq, int q,  qintermethod QINTERPROJ);
  CtcQInterLine(int n, int nb_obs, const Array<Ctc>& ctc_list,double*** linfun, int ** index, IntervalMatrix * boxes,
		   double epseq, int q,  qintermethod QINTERPROJ);
  //  int ctc_contract(IntervalVector& box);
  double compute_err_iter (Vector & mid, int iter);
  void point_contract(IntervalVector& box,int iter); 
  void point_contract_exact(IntervalVector& box,int iter); 
  double *** linfun;
  IntervalMatrix* boxesini;
  int** index;
  double epseq;
  Interval eps;
  //  int points_count(IntervalVector& box);        
  //  int activepoints_count(IntervalVector& box);        
  //  int activepoints_contract_count(IntervalVector& box);        

  IntervalVector validpoint( IntervalVector & box);
  void contract_pairs (IntervalVector & box);
  int nb_obs;
  vector<int> initial_observations (int i)  ;
 protected :

	void init();
        void fwd(IntervalVector & box, int iter);
        Interval eval_ctc(IntervalVector & box, int iter, int k);
	Interval eval_dist(IntervalVector & box, int iter, int k);
	double eval_dist_mid(Vector & vec, int iter, int k);
	IntervalVector boxintersection( IntervalVector& box, int iter1, int iter2);
	IntervalVector boxintersection( IntervalVector& box, int* iter);
	//	IntervalVector boxintersection( int* iter);
	IntervalVector pointintersection( int iter1, int iter2);
	//	Vector pointintersection( int* iter);
	IntervalVector pointintersection(IntervalVector& box, int* iter);
	void ctc_contract_all(IntervalVector& box);
	bool contract_with_outliers (IntervalVector& box, int gap);

	//	IntervalVector randomvalidpoint( IntervalVector & box);
};

 class CtcQInterAffLine :
   virtual public CtcQInter, 
   public CtcQInterLine, public CtcQInterAff {

   public :

   CtcQInterAffLine(int n, const Array<Ctc>& ctc_list,double*** linfun, 
		     double epseq, int q,  qintermethod QINTERPROJ);
   CtcQInterAffLine(int n, int nb_obs, const Array<Ctc>& ctc_list,double*** linfun, int** index,IntervalMatrix* boxes,
		     double epseq, int q,  qintermethod QINTERPROJ);
 protected :

   double valmean_compute(int iter, int i, const IntervalVector& box, Affine2& af);
   double slope_compute(int iter, int j, int i , const IntervalVector& box ,Affine2& af);
   double err_compute( int iter, int k,const IntervalVector& box ,Affine2& af);
   void compute_affine_evaluation( int i, int iter,  Affine2& af , Interval& af2);
   //   void bwd1(IntervalVector & box, int iter);
};

} // end namespace ibex
#endif // __IBEX_CTC_Q_INTERLINE_H__