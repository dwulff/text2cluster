#include <RcppArmadillo.h>
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]

// [[Rcpp::export]]
arma::mat arma_cosine(const arma::mat &mat){
  arma::mat cosines = mat * mat.t();
  arma::mat square = mat % mat;
  arma::colvec b = sum(square,1);
  arma::mat denum = sqrt(b) * sqrt(b.t());
  return cosines / denum;
  }

// [[Rcpp::export]]
arma::mat pmi(const arma::mat &G){
  arma::mat pmi = G / arma::accu(G);
  pmi /= (arma::sum(pmi, 1) * arma::sum(pmi, 0));
  return arma::log2(pmi);
}

// [[Rcpp::export]]
arma::mat ppmi(const arma::mat &G){
  arma::mat pmi_mat = pmi(G);
  pmi_mat.elem( find(pmi_mat < 0.0) ).zeros();
  return pmi_mat;
}