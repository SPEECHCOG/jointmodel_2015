#include "mex.h"
#include "matrix.h"
#include <math.h>

void mexFunction(int nlhs, mxArray** plhs, int nrhs, const mxArray** prhs)
{
	int i=0,j=0,k=0,l=0;

	double* input_data = mxGetPr(prhs[0]);	/*the input data*/
	int dim = mxGetM(prhs[0]);		/*the dimension of the space in which the data points are scattered*/
	int npoints = mxGetN(prhs[0]);		/*the number of datapoints*/

	double* centers = mxGetPr(prhs[1]);	/*the centers of the clusters*/
	int nclu = mxGetN(prhs[1]);		/*the number of clusters*/

	plhs[0] = mxCreateDoubleMatrix(nclu,npoints,mxREAL);
	double* distances = mxGetPr(plhs[0]);

	for(i=0;i<nclu;i++)
	{
		for(j=0;j<npoints;j++)
		{
			distances[nclu*j + i] = 0;
			for(k=0;k<dim;k++)
			{
					distances[nclu*j+i] += (input_data[dim*j + k] - centers[dim*i + k])*(input_data[dim*j + k] - centers[dim*i + k]);
			}
		}
	}
}
