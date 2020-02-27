#ifndef __IBEX_AVM_H__
#define __IBEX_AVM_H__

#include "ibex_FwdAlgorithm.h"
#include "ibex_Function.h"
#include "ibex_ExprDomain.h"
#include "ibex_ExprDataAVM.h"
#include "ibex_LPSolver.h"
#include "ibex_Eval.h"
#include "ibex_SparseVector.h"

namespace ibex {

class AVM : public FwdAlgorithm {
public:
    AVM(Eval& eval);
    ~AVM();

    struct Result {
        double uplo;
        Vector point;
    };

    void set_cost(const Vector& vec);
    LPSolver::Status minimize(const IntervalVector& box);
    Interval minimum() const;

    void load_node_bounds_in_solver(int y);



    inline void vector_fwd (int* x, int y);
	inline void apply_fwd  (int* x, int y);
	inline void idx_fwd    (int x, int y);
	inline void idx_cp_fwd (int x, int y);
	inline void symbol_fwd (int y);
	inline void cst_fwd    (int y);
	inline void chi_fwd    (int x1, int x2, int x3, int y);
	inline void gen2_fwd   (int x1, int x2, int y);
	inline void add_fwd    (int x1, int x2, int y);
	inline void mul_fwd    (int x1, int x2, int y);
	inline void sub_fwd    (int x1, int x2, int y);
	inline void div_fwd    (int x1, int x2, int y);
	inline void max_fwd    (int x1, int x2, int y);
	inline void min_fwd    (int x1, int x2, int y);
	inline void atan2_fwd  (int x1, int x2, int y);
	inline void gen1_fwd   (int x, int y);
	inline void minus_fwd  (int x, int y);
	inline void minus_V_fwd(int x, int y);
	inline void minus_M_fwd(int x, int y);
	inline void trans_V_fwd(int x, int y);
	inline void trans_M_fwd(int x, int y);
	inline void sign_fwd   (int x, int y);
	inline void abs_fwd    (int x, int y);
	inline void power_fwd  (int x, int y, int p);
	inline void sqr_fwd    (int x, int y);
	inline void sqrt_fwd   (int x, int y);
	inline void exp_fwd    (int x, int y);
	inline void log_fwd    (int x, int y);
	inline void cos_fwd    (int x, int y);
	inline void sin_fwd    (int x, int y);
	inline void tan_fwd    (int x, int y);
	inline void cosh_fwd   (int x, int y);
	inline void sinh_fwd   (int x, int y);
	inline void tanh_fwd   (int x, int y);
	inline void acos_fwd   (int x, int y);
	inline void asin_fwd   (int x, int y);
	inline void atan_fwd   (int x, int y);
	inline void acosh_fwd  (int x, int y);
	inline void asinh_fwd  (int x, int y);
	inline void atanh_fwd  (int x, int y);
	inline void floor_fwd  (int x, int y);
	inline void ceil_fwd   (int x, int y);
	inline void saw_fwd    (int x, int y);
	inline void add_V_fwd  (int x1, int x2, int y);
	inline void add_M_fwd  (int x1, int x2, int y);
	inline void mul_SV_fwd (int x1, int x2, int y);
	inline void mul_SM_fwd (int x1, int x2, int y);
	inline void mul_VV_fwd (int x1, int x2, int y);
	inline void mul_MV_fwd (int x1, int x2, int y);
	inline void mul_VM_fwd (int x1, int x2, int y);
	inline void mul_MM_fwd (int x1, int x2, int y);
	inline void sub_V_fwd  (int x1, int x2, int y);
	inline void sub_M_fwd  (int x1, int x2, int y);

private:
    Eval& eval_;
    Function& f_;
    const ExprDomain& d_; // = eval_.d
    ExprDataAVM avm_d_;
    //int first_var_index_;
    //int new_variables_count_;
    LPSolver* solver_;

    Vector filter_variables(const Vector& solver_result) const;
    int node_index_to_first_var(int index) const;
    int node_index_to_first_lin(int index) const;
    double node_d_ub(int y) const;
    double node_d_lb(int y) const;

    struct coef_pair {
        int var;
        double coef;
    };
    void binary_linearization(int lin, coef_pair&& y, coef_pair&& x1, coef_pair&& x2, double rhs);
    void unary_linearization(int lin, coef_pair&& y, coef_pair&& x, double rhs);

    template<typename T, typename D>
    inline void unary_convex_underestimator(double x, T& func, D& deriv, double& y_coef, double& x_coef, double& rhs);
    template<typename T>
    inline void unary_convex_overestimator(Interval x, T& func, double& y_coef, double& x_coef, double& rhs);
    template<typename T, typename D>
    inline void unary_concave_overestimator(double x, T& func, D& deriv, double& y_coef, double& x_coef, double& rhs);
    template<typename T>
    inline void unary_concave_underestimator(Interval x, T& func, double& y_coef, double& x_coef, double& rhs);

};

template<typename T, typename D>
inline void AVM::unary_convex_underestimator(double x, T& func, D& deriv, double& y_coef, double& x_coef, double& rhs) {
    Interval grad = deriv(x);
    Interval value = func(x);
    y_coef = -1;
    x_coef = grad.lb();
    rhs = (grad*x - value).lb();
}

template<typename T>
inline void AVM::unary_convex_overestimator(Interval x, T& func, double& y_coef, double& x_coef, double& rhs) {
    y_coef = 1;
    Interval fub = func(x.ub());
    Interval flb = func(x.lb());
    Interval a = (fub - flb)/(x.ub()-x.lb());
    x_coef = -a.ub();
    rhs = (fub - a*x.ub()).ub();
}

template<typename T, typename D>
inline void AVM::unary_concave_overestimator(double x, T& func, D& deriv, double& y_coef, double& x_coef, double& rhs) {
    Interval grad = deriv(x);
    Interval value = func(x);
    y_coef = 1;
    x_coef = -grad.ub();
    rhs = (value - grad*x).ub();
}

template<typename T>
inline void AVM::unary_concave_underestimator(Interval x, T& func, double& y_coef, double& x_coef, double& rhs) {
    y_coef = -1;
    Interval fub = func(x.ub());
    Interval flb = func(x.lb());
    Interval a = (fub - flb)/(x.ub()-x.lb());
    x_coef = a.lb();
    rhs = (a*x.ub()-fub).lb();
}


inline void AVM::vector_fwd(int* x, int y) {
    /* nothing to do */
    not_implemented("Vector not implemented for AVM");
}

inline void AVM::apply_fwd(int* x, int y) {
    /* nothing to do */
    not_implemented("Apply not implemented for AVM");
}

inline void AVM::idx_fwd(int x, int y) {
    /* nothing to do */
}

inline void AVM::idx_cp_fwd(int x, int y) {
    /* nothing to do */
}

inline void AVM::symbol_fwd(int y) {
    /* nothing to do */
    load_node_bounds_in_solver(y);
}

inline void AVM::cst_fwd(int y) {
	/*const ExprConstant& c = (const ExprConstant&) f.node(y);
	switch (c.type()) {
	case Dim::SCALAR:       d[y].i() = c.get_value();         break;
	case Dim::ROW_VECTOR:
	case Dim::COL_VECTOR:   d[y].v() = c.get_vector_value();  break;
	case Dim::MATRIX:       d[y].m() = c.get_matrix_value();  break;
	}*/
    load_node_bounds_in_solver(y);
}

inline void AVM::chi_fwd(int x1, int x2, int x3, int y) {
    // d[y].i() = chi(d[x1].i(),d[x2].i(),d[x3].i());
    not_implemented("Chi not implemented for AVM");
}

inline void AVM::gen2_fwd(int x1, int x2, int y) {
    // d[y].i() = chi(d[x1].i(),d[x2].i(),d[x3].i());
    not_implemented("Gen2 not implemented for AVM");
}

inline void AVM::add_fwd(int x1, int x2, int y)   {
    // - y + x1 + x2 = 0
    const int yvar = node_index_to_first_var(y);
    const int x1var = node_index_to_first_var(x1);
    const int x2var = node_index_to_first_var(x2);
    const int lin = node_index_to_first_lin(y);
    binary_linearization(lin, {yvar, -1}, {x1var, 1}, {x2var, 1}, 0.0);
    solver_->set_lhs(lin, 0.0);
    load_node_bounds_in_solver(y);
}

inline void AVM::mul_fwd(int x1, int x2, int y)   {
    if(x1 == x2) {
        sqr_fwd(x1, y);
        return;
    }
    // d[y].i()=d[x1].i()*d[x2].i();
    // - y + ub(x1)*x2 + ub(x2)*x1 <= ub(x1)*ub(x2)
    // - y + lb(x1)*x2 + lb(x2)*x1 <= lb(x1)*lb(x2)

    const int yvar = node_index_to_first_var(y);
    const int x1var = node_index_to_first_var(x1);
    const int x2var = node_index_to_first_var(x2);
    int lin = node_index_to_first_lin(y);
    const double x1u = node_d_ub(x1);
    const double x1l = node_d_lb(x1);
    const double x2u = node_d_ub(x2);
    const double x2l = node_d_lb(x2);
    /*
     * Convex/Concave enveloppe for bilinear terms
     * - y + x2u x1 + x1u x2 <= x1u*x2u
     * - y + x2l x1 + x1l x2 <= x1l*x2l
     *   y - x2u x1 - x1l x2 <= -x1l*x2u
     *   y - x2l x1 - x1u x2 <= -x1u*x2l
     */
    binary_linearization(lin++, {yvar, -1}, {x1var, x2u}, {x2var, x1u}, x1u*x2u);
    binary_linearization(lin++, {yvar, -1}, {x1var, x2l}, {x2var, x1l}, x1l*x2l);
    binary_linearization(lin++, {yvar, 1}, {x1var, -x2u}, {x2var, -x1l}, -x1l*x2u);
    binary_linearization(lin, {yvar, 1}, {x1var, -x2l}, {x2var, -x1u}, -x1u*x2l);
    load_node_bounds_in_solver(y);
}
inline void AVM::sub_fwd(int x1, int x2, int y)   {
    // - y + x1 - x2 <= 0
    const int yvar = node_index_to_first_var(y);
    const int x1var = node_index_to_first_var(x1);
    const int x2var = node_index_to_first_var(x2);
    const int lin = node_index_to_first_lin(y);
    binary_linearization(lin, {yvar, -1}, {x1var, 1}, {x2var, -1}, 0.0);
    solver_->set_lhs(lin, 0.0);
    load_node_bounds_in_solver(y);
}
inline void AVM::div_fwd(int x1, int x2, int y)   {
    // d[y].i()=d[x1].i()/d[x2].i();
    not_implemented("Div not implemented for AVM");
}
inline void AVM::max_fwd(int x1, int x2, int y)   {
    // d[y].i()=max(d[x1].i(),d[x2].i());
    not_implemented("Max not implemented for AVM");
}
inline void AVM::min_fwd(int x1, int x2, int y)   {
    // d[y].i()=min(d[x1].i(),d[x2].i());
    not_implemented("Min not implemented for AVM");
}
inline void AVM::atan2_fwd(int x1, int x2, int y) {
    // d[y].i()=atan2(d[x1].i(),d[x2].i());
    not_implemented("Atan2 not implemented for AVM");
}

inline void AVM::gen1_fwd(int x, int y) {
    not_implemented("Gen1 not implemented for AVM");
}

inline void AVM::minus_fwd(int x, int y)          {
    // d[y].i()=-d[x].i();
    const int yvar = node_index_to_first_var(y);
    const int xvar = node_index_to_first_var(x);
    const int lin = node_index_to_first_lin(y);
    solver_->set_coef(lin, yvar, 1);
    solver_->set_coef(lin, xvar, 1);
    solver_->set_lhs_rhs(lin, 0, 0);
    load_node_bounds_in_solver(y);
}
inline void AVM::minus_V_fwd(int x, int y)        {
    // d[y].v()=-d[x].v();
    not_implemented("Minus_V not implemented for AVM");
}
inline void AVM::minus_M_fwd(int x, int y)        {
    // d[y].m()=-d[x].m();
    not_implemented("Minus_M not implemented for AVM");
}
inline void AVM::sign_fwd(int x, int y)           {
    // d[y].i()=sign(d[x].i());
    not_implemented("Sign not implemented for AVM");
}
inline void AVM::abs_fwd(int x, int y)            {
    // d[y].i()=abs(d[x].i());
    not_implemented("Abs not implemented for AVM");
}
inline void AVM::power_fwd(int x, int y, int p)   {
    // d[y].i()=pow(d[x].i(),p);
    not_implemented("Power not implemented for AVM");
}

inline void AVM::sqr_fwd(int x, int y)            {
    // 0 >= x^2 = y >= lin
    assert(avm_d_[y].lin_count >= 6);
    const int yvar = node_index_to_first_var(y);
    const int xvar = node_index_to_first_var(x);
    int lin = node_index_to_first_lin(y);

    auto func = [](double x_pt) { return sqr(Interval(x_pt)); };
    auto deriv = [](double x_pt) { return 2*Interval(x_pt); };

    auto linearize = [&](double x_pt) {
        double y_coef, x_coef, rhs;
        unary_convex_underestimator(x_pt, func, deriv, y_coef, x_coef, rhs);
        unary_linearization(lin++, {yvar, y_coef}, {xvar, x_coef}, rhs);
    };

    const Interval& itv = d_[x].i();
    {
        double y_coef, x_coef, rhs;
        unary_convex_overestimator(itv, func, y_coef, x_coef, rhs);
        unary_linearization(lin++, {yvar, y_coef}, {xvar, x_coef}, rhs);
    }
    if(itv.contains(0)) {
        linearize(0.0);
        linearize(Interval(0.0, itv.ub()).mid());
        linearize(Interval(itv.lb(), 0.0).mid());
    } else {
        linearize(itv.mid());
        auto pair = itv.bisect();
        linearize(pair.first.mid());
        linearize(pair.second.mid());
    }
    linearize(itv.lb());
    linearize(itv.ub());
    load_node_bounds_in_solver(y);

}
inline void AVM::sqrt_fwd(int x, int y)           {
    // if ((d[y].i()=sqrt(d[x].i())).is_empty()) throw EmptyBoxException();
    const int yvar = node_index_to_first_var(y);
    const int xvar = node_index_to_first_var(x);
    int lin = node_index_to_first_lin(y);

    auto func = [](double x_pt) { return sqrt(Interval(x_pt)); };
    auto deriv = [](double x_pt) { return 1/(2*sqrt(Interval(x_pt))); };

    auto linearize = [&](double x_pt) {
        double y_coef, x_coef, rhs;
        unary_concave_overestimator(x_pt, func, deriv, y_coef, x_coef, rhs);
        unary_linearization(lin++, {yvar, y_coef}, {xvar, x_coef}, rhs);
    };

    Interval itv = d_[x].i();
    itv = Interval(std::max(+0.0, itv.lb()), itv.ub());
    {
        double y_coef, x_coef, rhs;
        unary_concave_underestimator(itv, func, y_coef, x_coef, rhs);
        unary_linearization(lin++, {yvar, y_coef}, {xvar, x_coef}, rhs);
    }
    if(itv.lb() == 0) {
        unary_linearization(lin++, {yvar, 0.0}, {xvar, -1}, 0.0);
    } else {
        linearize(itv.lb());
    }
    linearize(itv.mid());
    linearize(itv.ub());
    load_node_bounds_in_solver(y);
}

inline void AVM::exp_fwd(int x, int y)            {
    // d[y].i()=exp(d[x].i());
    not_implemented("Exp not implemented for AVM");
}
inline void AVM::log_fwd(int x, int y)            {
    // if ((d[y].i()=log(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Log not implemented for AVM");
}
inline void AVM::cos_fwd(int x, int y)            {
    // d[y].i()=cos(d[x].i());
    not_implemented("Cos not implemented for AVM");
}
inline void AVM::sin_fwd(int x, int y)            {
    // d[y].i()=sin(d[x].i());
    not_implemented("Sin not implemented for AVM");
}
inline void AVM::tan_fwd(int x, int y)            {
    // if ((d[y].i()=tan(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Tan not implemented for AVM");
}
inline void AVM::cosh_fwd(int x, int y)           {
    // d[y].i()=cosh(d[x].i());
    not_implemented("Cosh not implemented for AVM");
}
inline void AVM::sinh_fwd(int x, int y)           {
    // d[y].i()=sinh(d[x].i());
    not_implemented("Sinh not implemented for AVM");
}
inline void AVM::tanh_fwd(int x, int y)           {
    // d[y].i()=tanh(d[x].i());
    not_implemented("Tanh not implemented for AVM");
}
inline void AVM::acos_fwd(int x, int y)           {
    // if ((d[y].i()=acos(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Acos not implemented for AVM");
}
inline void AVM::asin_fwd(int x, int y)           {
    // if ((d[y].i()=asin(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Asin not implemented for AVM");
}
inline void AVM::atan_fwd(int x, int y)           {
    // d[y].i()=atan(d[x].i());
    not_implemented("Atan not implemented for AVM");
}
inline void AVM::acosh_fwd(int x, int y)          {
    // if ((d[y].i()=acosh(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Acosh not implemented for AVM");
}
inline void AVM::asinh_fwd(int x, int y)          {
    // d[y].i()=asinh(d[x].i());
    not_implemented("Asinh not implemented for AVM");
}
inline void AVM::atanh_fwd(int x, int y)          {
    // if ((d[y].i()=atanh(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Atanh not implemented for AVM");
}
inline void AVM::floor_fwd(int x, int y)          {
    // if ((d[y].i()=floor(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Floor not implemented for AVM");
}
inline void AVM::ceil_fwd(int x, int y)           {
    // if ((d[y].i()=ceil(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Ceil not implemented for AVM");
}
inline void AVM::saw_fwd(int x, int y)            {
    // if ((d[y].i()=saw(d[x].i())).is_empty()) throw EmptyBoxException();
    not_implemented("Saw not implemented for AVM");
}

inline void AVM::trans_V_fwd(int x, int y)        {
    // d[y].v()=d[x].v();
    not_implemented("Trans_V not implemented for AVM");
}
inline void AVM::trans_M_fwd(int x, int y)        {
    // d[y].m()=d[x].m().transpose();
    not_implemented("Trans_M not implemented for AVM");
}
inline void AVM::add_V_fwd(int x1, int x2, int y) {
    // d[y].v()=d[x1].v()+d[x2].v();
    not_implemented("Add_V not implemented for AVM");
}
inline void AVM::add_M_fwd(int x1, int x2, int y) {
    // d[y].m()=d[x1].m()+d[x2].m();
    not_implemented("Add_M not implemented for AVM");
}
inline void AVM::mul_SV_fwd(int x1, int x2, int y){
    // d[y].v()=d[x1].i()*d[x2].v();
    not_implemented("Mul_SV not implemented for AVM");
}
inline void AVM::mul_SM_fwd(int x1, int x2, int y){
    // d[y].m()=d[x1].i()*d[x2].m();
    not_implemented("Mul_SM not implemented for AVM");
}
inline void AVM::mul_VV_fwd(int x1, int x2, int y){
    // d[y].i()=d[x1].v()*d[x2].v();
    not_implemented("Mul_VV not implemented for AVM");
}
inline void AVM::mul_MV_fwd(int x1, int x2, int y){
    // d[y].v()=d[x1].m()*d[x2].v();
    not_implemented("Mul_MV not implemented for AVM");
}
inline void AVM::mul_VM_fwd(int x1, int x2, int y){
    // d[y].v()=d[x1].v()*d[x2].m();
    not_implemented("Mul_VM not implemented for AVM");
}
inline void AVM::mul_MM_fwd(int x1, int x2, int y){
    // d[y].m()=d[x1].m()*d[x2].m();
    not_implemented("Mul_MM not implemented for AVM");
}
inline void AVM::sub_V_fwd(int x1, int x2, int y) {
    // d[y].v()=d[x1].v()-d[x2].v();
    not_implemented("Sub_V not implemented for AVM");
}
inline void AVM::sub_M_fwd(int x1, int x2, int y) {
    // d[y].m()=d[x1].m()-d[x2].m();
    not_implemented("Sub_M not implemented for AVM");
}


} // namespace ibex

#endif  // __IBEX_AVM_H__