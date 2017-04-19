#include<bits/stdc++.h>
#include<cuda.h>
#define MAXN 8200
#define MAXC 257
using namespace std;
__global__ void fun(int *n,int *m,int source[],int dest[],int *s,int *row,int *col,unsigned dom[],bool *f)
{
    int curr=blockIdx.x*blockDim.x+threadIdx.x;
   if(curr<(*m)&&dest[curr]!=(*s))
   {
    unsigned temp[MAXC],var[MAXC];
    for(int i=0;i<(*col);i++)
    	temp[i]=dom[dest[curr]*(*col)+i];
    for(int i=0;i<(*col);i++)
    	var[i]=temp[i]&dom[source[curr]*(*col)+i];
    var[dest[curr]>>5]|=(1<<(dest[curr]&31));
    if(*f)
    {
    	for(int i=0;i<(*col);i++)
    	{
    		if(temp[i]!=var[i])
    	    {
    	    	*f=false;
    	    	break;
    	    }
    	}
    }
    //__syncthreads();
    for(int i=0;i<(*col);i++)
    	atomicAnd(&dom[dest[curr]*(*col)+i],var[i]);
   }
}
int main()
{
	freopen("input.txt","r",stdin);
  freopen("output.txt","w",stdout);
	int hn,hm;
	scanf("%d%d",&hn,&hm);
	int *dn,*dm;
	cudaMalloc((void**)&dn,sizeof(int));
	cudaMalloc((void**)&dm,sizeof(int));
	cudaMemcpy(dn,&hn,sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dm,&hm,sizeof(int),cudaMemcpyHostToDevice);
	int h_source[hm],h_dest[hm];
	for(int i=0;i<hm;i++)
    {
       scanf("%d%d",&h_source[i],&h_dest[i]);
       //h_source[i]--;
       //h_dest[i]--;
    }
    //for(int i=0;i<hm;i++)
      //  printf("%d %d\n",h_source[i]+1,h_dest[i]+1);
    int *d_source,*d_dest;
    cudaMalloc((void**)&d_source,hm*sizeof(int));
    cudaMalloc((void**)&d_dest,hm*sizeof(int));
    cudaMemcpy(d_source,&h_source,hm*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_dest,&h_dest,hm*sizeof(int),cudaMemcpyHostToDevice);
    int hs;
    scanf("%d",&hs);
    //hs--;
    int *ds;
    cudaMalloc((void**)&ds,sizeof(int));
    cudaMemcpy(ds,&hs,sizeof(int),cudaMemcpyHostToDevice);
    int hrow=hn,hcol=ceil(hn/32.0);
    int *drow,*dcol;
    cudaMalloc((void**)&drow,sizeof(int));
    cudaMalloc((void**)&dcol,sizeof(int));
    cudaMemcpy(drow,&hrow,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dcol,&hcol,sizeof(int),cudaMemcpyHostToDevice);

    unsigned dom[hrow*hcol];
    cout<<hrow<<" "<<hcol<<endl;
    for(int i=0;i<hrow;i++)
    {
    	  if(i!=hs)
    	  {
         for(int j=0;j<hcol;j++)
       	  dom[i*hcol+j]=~(dom[i*hcol+j]&0);
        }else
        {
         for(int j=0;j<hcol;j++)
       	  dom[i*hcol+j]&=0;
        }
    }
    dom[(hs*hcol)+(hs>>5)]=(1u<<(hs&31));
    /*for(int i=0;i<hcol*hrow;i++)
    	cout<<dom[i]<<" "<<endl;*/
    unsigned *d_dom;
    cudaMalloc((void**)&d_dom,hrow*hcol*sizeof(unsigned));
    cudaMemcpy(d_dom,&dom,hrow*hcol*sizeof(unsigned),cudaMemcpyHostToDevice);
    int cnt=0;
    clock_t tStart = clock();
    while(1)
    {
        cnt++;
        cout<<cnt<<endl;
    	bool hf=true;
        bool *df;
    	cudaMalloc((void**)&df,sizeof(bool));
    	cudaMemcpy(df,&hf,sizeof(bool),cudaMemcpyHostToDevice);
    	fun<<<ceil(hm/512.0),512>>>(dn,dm,d_source,d_dest,ds,drow,dcol,d_dom,df);
    	cudaMemcpy(&hf,df,sizeof(bool),cudaMemcpyDeviceToHost);
    	if(hf)
    		break;
    }
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    cout<<cnt<<endl;
    cudaMemcpy(dom,d_dom,hrow*hcol*sizeof(unsigned),cudaMemcpyDeviceToHost);
    int a[hrow+1];
    memset(a,0,sizeof(a));
    for(int i=0;i<hrow;i++)
    {
        int ans=0;
      for(int j=0;j<hcol;j++)
      {
        if(j!=hcol-1)
        {
          int val=1;
          for(int k=0;k<32;k++)
          {
           if(dom[i*hcol+j]&val)
             ans++;
           val<<=1;
          }
        }else
        {
          int val=1;
          int temp=hrow-32*(hcol-1);
          for(int k=0;k<temp;k++)
          {
            if(dom[i*hcol+j]&val)
              ans++;
            val<<=1;
          }
        }  
      }
      a[ans]++;
    }
    for(int i=1;i<=hrow;i++)
    {
      if(a[i])
        cout<<i<<" "<<a[i]<<endl;
    }
	return 0;
}
