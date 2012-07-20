//============================================================================
//                                  I B E X                                   
// File        : Ibex.cpp
// Author      : Gilles Chabert
// Copyright   : Ecole des Mines de Nantes (France)
// License     : See the LICENSE file
// Created     : Jul 18, 2012
// Last Update : Jul 18, 2012
//============================================================================

#include "ibex_Java.h_"
#include "ibex_CtcCompo.h"
#include "ibex_CtcHC4.h"
#include "ibex_CtcNewton.h"
#include "ibex_CtcProj.h"
#include "ibex_System.h"
#include <stdio.h>
#include <vector>

using namespace std;
using namespace ibex;

static vector<System*> sys;
static vector<Ctc*> ctc;
static vector<int> options; // which contractor is used for the ith constraint?

enum { COMPO=0, HC4=1, HC4_NEWTON=2 };

enum { FAIL=0, ENTAILED=1, CONTRACT=2, NOTHING=3 };

enum { FALSE_=0, TRUE_=1, FALSE_OR_TRUE=2 };

static const double EPS_CONTRACT=0.01;

JNIEXPORT void JNICALL Java_Ibex_add_1ctr__ILjava_lang_String_2(JNIEnv *env, jobject o, jint nb_var, jstring syntax) {
	Java_Ibex_add_1ctr__ILjava_lang_String_2I(env,o,nb_var,syntax,COMPO);
}

JNIEXPORT void JNICALL Java_Ibex_add_1ctr__ILjava_lang_String_2I(JNIEnv *env, jobject, jint nb_var, jstring syntax, jint option) {
	const char* _syntax = env->GetStringUTFChars(syntax,0);

	System* s=new System(nb_var,_syntax);
	sys.push_back(s);
	options.push_back(option);

	if (s->nb_ctr==1) {
		ctc.push_back(new CtcProj(s->ctrs[0]));
	} else {
		Ctc* c;
		switch (option) {
		case COMPO:      {
			Array<Ctc> array(s->nb_ctr);
			for (int i=0; i<s->nb_ctr; i++)
				array.set_ref(i,*new CtcProj(s->ctrs[i]));
			c=new CtcCompo(array);
			break;
		}
		case HC4:
			c=new CtcHC4(s->ctrs);
			break;
		case HC4_NEWTON:
			c=new CtcCompo(*new CtcHC4(s->ctrs), *new CtcNewton(s->f));
			break;
		default:
			not_implemented("unimplemented option");
		}
		ctc.push_back(c);
	}
}

JNIEXPORT jint JNICALL Java_Ibex_contract__I_3D(JNIEnv *env, jobject o, jint n, jdoubleArray domains) {
	return Java_Ibex_contract__I_3DI(env,o,n,domains,1);
}

JNIEXPORT jint JNICALL Java_Ibex_contract__I_3DI(JNIEnv *env, jobject, jint n, jdoubleArray domains, jint reif) {

	jdouble* d =
	           env -> GetDoubleArrayElements(domains, 0);
	jint size = env -> GetArrayLength(domains);
	jint result;

	assert(size%2==0);

	int nb_var=size/2;

	assert(nb_var==ctc[n]->nb_var);

	IntervalVector& box=sys[n]->box;

	for (int i=0; i<nb_var; i++) {
		box[i]=Interval(d[2*i],d[2*i+1]);
	}

	IntervalVector savebox(box);

	if (reif==TRUE_ || reif==FALSE_OR_TRUE) {
		try {
			ctc[n]->contract(box);

			if (reif==TRUE_ && savebox.rel_distance(box) >= EPS_CONTRACT) {
				result=CONTRACT;
			} else {
				result=NOTHING;
			}
		} catch(EmptyBoxException&) {
			result=FAIL;
		}
	}

	if (reif==FALSE_ || reif==FALSE_OR_TRUE) {
		not_implemented("Inner contraction from CHOCO");
	}

	if (result==CONTRACT) {
		for (int i=0; i<nb_var; i++) {
			d[2*i]=box[i].lb();
			d[2*i+1]=box[i].ub();
		}
	}

	env->ReleaseDoubleArrayElements(domains, d, 0);

	return result;
}

JNIEXPORT void JNICALL Java_Ibex_release(JNIEnv *, jobject) {
	for (unsigned int i=0; i<sys.size(); i++) {
		// free the contractors
		if (sys[i]->nb_ctr>1) {
			switch(options[i]) {
			case COMPO:
			case HC4_NEWTON:
			{
				CtcCompo& compo=*((CtcCompo*) ctc[i]);
				for (int j=0; j<compo.list.size(); j++)
					delete &compo.list[j];
				break;
			}
			default:
				break;
			}
		}

		delete ctc[i];

		// free the system
		delete sys[i];
	}
}
