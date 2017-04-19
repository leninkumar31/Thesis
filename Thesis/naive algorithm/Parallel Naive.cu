#include<bits/stdc++.h>
#include<cuda.h>
#define MAXN 10000
using namespace std;
__global__ void pbfs(int *dn,int *dm,bool *dvis,bool *dq,int *vertex,int *dedges,bool *dflag)
{
    int u=threadIdx.x+blockDim.x*blockIdx.x;
    if(dq[u]&&u<(*dn))
    {
       dq[u]=false;
       int num=(u==(*dn-1)?(*dm-vertex[u]):(vertex[u+1]-vertex[u]));
       for(int i=0;i<num;i++)
       {
     	  int v=dedges[vertex[u]+i];
     	  if(!dvis[v])
     	  {
     		   dvis[v]=true;
     		   dq[v]=true;
     		   *dflag=true;
     	  }
       }
     }
}
vector<int> dom[MAXN],adj[MAXN];
bool vis[MAXN],temp[MAXN];
bool fvis[MAXN][MAXN];
void bfs(int s)
{
   queue<int> q;
   q.push(s);
   vis[s]=true;
   while(!q.empty())
   {
     int u=q.front();
     q.pop();
     for(int i=0;i<adj[u].size();i++)
     {
      int v=adj[u][i];
      if(!vis[v])
      {
        vis[v]=true;
        q.push(v);
      }
     }
   }
}
int main()
{
    freopen("input.txt","r",stdin);
    freopen("t1.txt","w",stdout);
    int n,m;
    cin>>n>>m;
    int *dn,*dm;
    cudaMalloc((void **)&dn,sizeof(int));
    cudaMalloc((void **)&dm,sizeof(int));
    cudaMemcpy(dn,&n,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dm,&m,sizeof(int),cudaMemcpyHostToDevice);
    for(int i=0;i<m;i++)
    {
       int u,v;
       cin>>u>>v;
       //u--;
       //v--;
       adj[u].push_back(v);
    }
    int vertexoff[n],edges[m];
    int k=0;
    for(int i=0;i<n;i++)
    {
    	vertexoff[i]=k;
    	for(int j=0;j<adj[i].size();j++)
    		edges[k++]=adj[i][j];
    }
    int *dvertexoff,*dedges;
    cudaMalloc((void**)&dvertexoff,n*sizeof(int));
    cudaMalloc((void**)&dedges,m*sizeof(int));
    cudaMemcpy(dvertexoff,&vertexoff,n*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dedges,&edges,m*sizeof(int),cudaMemcpyHostToDevice);
    int hs;
    scanf("%d",&hs);
    //hs--;
    dom[hs].push_back(hs);
    for(int i=0;i<n;i++)
    {
        if(i!=hs)
        {
          dom[i].push_back(hs);
          dom[i].push_back(i);
        }
    }
    bfs(hs);
    //cout<<hs<<endl;
    for(int i=0;i<n;i++)
    {
    	if(!vis[i])
    		temp[i]=true;
    	else
    		temp[i]=false;
      fvis[0][i]=false;
    }
    clock_t tStart = clock();
    for(int i=1;i<n;i++)
    {
    	if(!temp[i])
    	{
    		    bool q[n];
            for(int j=0;j<n;j++)
            {
            	q[j]=false;
            	if(!temp[j])
            		vis[j]=false;
            	else
            		vis[j]=true;
            }
            q[hs]=true;
            vis[hs]=true;
            vis[i]=true;
            bool *dvis,*dq;
            cudaMalloc((void**)&dvis,n*sizeof(bool));
            cudaMemcpy(dvis,&vis,n*sizeof(bool),cudaMemcpyHostToDevice);
            cudaMalloc((void**)&dq,n*sizeof(bool));
            cudaMemcpy(dq,&q,n*sizeof(bool),cudaMemcpyHostToDevice);
            bool flag;
            do
            {
              flag=false;
              bool *dflag;
              cudaMalloc((void**)&dflag,sizeof(bool));
              cudaMemcpy(dflag,&flag,sizeof(bool),cudaMemcpyHostToDevice);
    	        pbfs<<<ceil(n/512.0),512>>>(dn,dm,dvis,dq,dvertexoff,dedges,dflag);
              cudaMemcpy(&flag,dflag,sizeof(bool),cudaMemcpyDeviceToHost);
            }while(flag);
            cudaMemcpy(fvis[i],dvis,n*sizeof(bool),cudaMemcpyDeviceToHost);
            /*update<<<ceil(n/512.0),512>>>(dvis,dn);
            for(int j=0;j<n;j++)
            {
            	if(!vis[j])
            		dom[j].push_back(i);
            }*/
    	}
    }
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    for(int i=0;i<n;i++)
    {
        for(int j=1;j<n;j++)
        {
          if(!fvis[i][j])
            dom[j].push_back(i);
        }
    }
    for(int i=0;i<n;i++)
    {
      for(int j=0;j<dom[i].size();j++)
        cout<<dom[i][j]+1<<" ";
      cout<<endl;
    }
	return 0;
}
