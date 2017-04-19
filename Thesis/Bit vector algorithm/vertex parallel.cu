#include<bits/stdc++.h>
#include<cuda.h>
using namespace std;
__global__ void fun(int *n,int *m,int *v,int *e,int *s,int *col,unsigned *dom,unsigned *temp,bool *f)
{
    int curr=blockIdx.x*blockDim.x+threadIdx.x;
    if((curr!=(*s))&&(curr<(*n)))
    {
       int c=*col;
       /*unsigned int var[MAXC];
       for(int i=0;i<c;i++)
        var[i]=dom[curr*c+i];*/
       int num=(curr==(*n-1)?(*m-v[curr]):(v[curr+1]-v[curr]));
       for(int i=0;i<num;i++)
       {
       	 int pre=e[v[curr]+i];
       	 for(int k=0;k<c;k++)
       	 {
          if(i==0)
           temp[curr*c+k]=dom[pre*c+k];
          else
         	 temp[curr*c+k]&=dom[pre*c+k];
         }
       }
       temp[(curr*c)+(curr>>5)]|=(1u<<(curr&31));
       if(*f)
       {
          for(int i=0;i<c;i++)
          {
          	if(temp[curr*c+i]!=dom[curr*c+i])
          	{
          		*f=false;
          		break;
          	}
          }
       }
    }
}
int main()
{
	freopen("input.txt","r",stdin);
  freopen("output.txt","w",stdout);
  int hn,hm;
	scanf("%d%d",&hn,&hm);
	int *dn,*dm;
    cudaMalloc((void **)&dn,sizeof(int));
    cudaMalloc((void **)&dm,sizeof(int));
    cudaMemcpy(dn,&hn,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dm,&hm,sizeof(int),cudaMemcpyHostToDevice);
    //vector<int> adj[n];
    vector<int> adjR[hn];
    for(int i=0;i<hm;i++)
    {
    	int u,v;
    	scanf("%d%d",&u,&v);
    	//u--,v--;
    	//adj[u].push_back(v);
    	adjR[v].push_back(u);
    }
    //int hv[n],he[m];
   /* int k=0;
    for(int i=0;i<n;i++)
    {
    	hv[i]=k;
    	for(int j=0;j<adj[i].size();j++)
          he[k++]=adj[i][j];
    }
    int *dv,*de;
    cudaMalloc((void**)&dv,hn*sizeof(int));
    cudaMalloc((void**)&de,hm*sizeof(int));
    cudaMemcpy(dv,&hv,hn*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(de,&he,hm*sizeof(int),cudaMemcpyHostToDevice);*/
    int hvR[hn],heR[hm];
    int k=0;
    for(int i=0;i<hn;i++)
    {
    	hvR[i]=k;
    	for(int j=0;j<adjR[i].size();j++)
    		heR[k++]=adjR[i][j];
    }
   /* for(int i=0;i<hn;i++)
    	cout<<hvR[i]<<" ";
    cout<<endl;*/
    int *dvR,*deR;
    cudaMalloc((void**)&dvR,hn*sizeof(int));
    cudaMalloc((void**)&deR,hm*sizeof(int));
    cudaMemcpy(dvR,&hvR,hn*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(deR,&heR,hm*sizeof(int),cudaMemcpyHostToDevice);
    int hs;
    scanf("%d",&hs);
    //hs--;
    int *ds;
    cudaMalloc((void**)&ds,sizeof(int));
    cudaMemcpy(ds,&hs,sizeof(int),cudaMemcpyHostToDevice);
    int row=hn,col=ceil(hn/32.0);
    int *drow,*dcol;
    cudaMalloc((void **)&drow,sizeof(int));
    cudaMalloc((void **)&dcol,sizeof(int));
    cudaMemcpy(drow,&row,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dcol,&col,sizeof(int),cudaMemcpyHostToDevice);
    unsigned dom[row*col];
    //cout<<(1u<<(hs&31))<<endl;
    for(int i=0;i<row;i++)
    {
      if(i!=hs)
      {
       for(int j=0;j<col;j++)
       	dom[i*col+j]=~(dom[i*col+j]&0);
      }else
      {
        for(int j=0;j<col;j++)
          dom[i*col+j]=(dom[i*col+j]&0);
      }
    }
    dom[(hs*col)+(hs>>5)]|=(1u<<(hs&31));
    /*for(int i=0;i<col*row;i++)
    	cout<<dom[i]<<" "<<endl;*/
    unsigned *d_dom,*temp;
    cudaMalloc((void**)&d_dom,row*col*sizeof(unsigned));
    cudaMalloc((void**)&temp,row*col*sizeof(unsigned));
    int cnt=0;
    clock_t tStart = clock();
    while(1)
    {
      cnt++;
    	bool hf=true;
      //cout<<cnt<<" "<<hf<<endl;
      /*for(int i=0;i<col;i++)
        cout<<dom[hs*col+i]<<" ";
      cout<<endl;*/
    	bool *df;
    	cudaMalloc((void**)&df,sizeof(bool));
    	cudaMemcpy(df,&hf,sizeof(bool),cudaMemcpyHostToDevice);
      cudaMemcpy(d_dom,dom,row*col*sizeof(unsigned),cudaMemcpyHostToDevice);
      cudaMemcpy(temp,dom,row*col*sizeof(unsigned),cudaMemcpyHostToDevice);
    	fun<<<ceil(hn/512.0),512>>>(dn,dm,dvR,deR,ds,dcol,d_dom,temp,df);
      cudaMemcpy(dom,temp,row*col*sizeof(unsigned),cudaMemcpyDeviceToHost);
    	cudaMemcpy(&hf,df,sizeof(bool),cudaMemcpyDeviceToHost);
      //cout<<hf<<endl;
    	if(hf)
    		break;
    }
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    cout<<cnt<<endl;
    int a[row+1];
    memset(a,0,sizeof(a));
    for(int i=0;i<row;i++)
    {
      int ans=0;
      for(int j=0;j<col;j++)
      {
        if(j!=col-1)
        {
          unsigned int val=1;
          for(int k=0;k<32;k++)
          {
           if(dom[i*col+j]&val)
             ans++;
           val<<=1;
          }
        }else
        {
          unsigned int val=1;
          int temp=hn-32*(col-1);
          for(int k=0;k<temp;k++)
          {
            if(dom[i*col+j]&val)
              ans++;
            val<<=1;
          }
        }
      }
      if(i==hs)
        cout<<ans<<endl;
      a[ans]++;
    }
    for(int i=1;i<=row;i++)
    {
      if(a[i])
        cout<<i<<" "<<a[i]<<endl;
    }
    /*for(int i=0;i<col*row;i++)
    	cout<<dom[i]<<" "<<endl;*/
    /*for(int i=0;i<row;i++)
    {
    	for(int j=0;j<col;j++)
    		cout<<dom[i*col+j]<<" ";
    	cout<<endl;
    }*/
	return 0;
}
