[![Build Status](https://travis-ci.org/ibex-team/ibex-lib.svg?branch=master)](https://travis-ci.org/ibex-team/ibex-lib)
[![Build status](https://ci.appveyor.com/api/projects/status/9w1wxhvymsohs4gr/branch/master?svg=true)](https://ci.appveyor.com/project/Jordan08/ibex-lib-q0c47/branch/master)

ibex-lib
========
IBEX is a C++ library for constraint processing over real numbers.

It provides reliable algorithms for handling non-linear constraints. In particular, roundoff errors are also taken into account. It is based on interval arithmetic.

The main feature of Ibex is its ability to build strategies declaratively through the contractor programming paradigm. It can also be used as a black-box solver.

Two emblematic problems that can be addressed are:
- System solving. A guaranteed enclosure for each solution of a system of (nonlinear) equations is calculated.
- Global optimization. A global minimizer of some function under non-linear constraints is calculated with guaranteed bounds on the objective minimum.

Copyright: This software is under GNU Lesser General Public License.

Documentation
---------------

[The documentation is available here](http://ibex-team.github.io/ibex-lib/)

Credits
---------------
The Ibex project started in 2007. It grew up after various prototypes developed by Gilles Chabert during its thesis and was mainly developed by him during his tenure at IMT Atlantique in LS2N (UMR 6004) between 2008 and 2018. It is in standy-by since 2020.

Some people brought great help, in particular Luc Jaulin (UMR 6285, ENSTA Bretagne), Gilles Trombettoni (UMR 5506, Univ. Montpellier) and Alexandre Goldsztejn (UMR 6004, CNRS) for the underlying concepts and algorithms, Bertrand Neveu (UMR 8049, ENPC, Paris) for the development of global optimization routines and benchmarking, Cyril Bouvier (UMR 5506, Univ. Montpellier) for the Python installation scripts.

Some people also contributed by developing plugins, such as Jordan Ninin at UMR 6285 (affine arithmetic), Antoine Marendet at UMR 6004 (semi-infinite programming), Benjamin Martin at UMR 6004 (parametric continuation)... Plugins come as separate Github projects, see [ibex-team](https://github.com/ibex-team) for a more comprehensive list.
