#include<bits/stdc++.h>
using namespace std;
const int MAXN=8200;
const int MAXC=ceil(MAXN/32.0);
vector<int> adj[MAXN];//adjacency list for directed graph
vector<int> adjR[MAXN];
unsigned int dom[MAXN][MAXC];//dominator set
int cnt=0;
void getdom(int s)
{
    dom[s][s>>5]=1<<(s&31);
    for(int i=0;i<MAXN;i++)
    {
    	if(i!=s)
    	{
         for(int j=0;j<MAXC;j++)
       	  dom[i][j]=~(dom[i][j]&0);
      }
    }
    //cout<<s<<endl;
    while(1)
    {
      cnt++;
    	bool flag=true;
    	for(int i=0;i<MAXN;i++)
    	{
    		if(i!=s)
    		{
    	      unsigned int temp[MAXC];
    	      for(int j=0;j<MAXC;j++)
    	      	temp[j]=dom[i][j];
              for(int j=0;j<adjR[i].size();j++)
              {
              	int v=adjR[i][j];
                for(int k=0;k<MAXC;k++)
                {
                    if(j==0)
                      dom[i][k]=dom[v][k];
                    else
                      dom[i][k]&=dom[v][k];
                }
              }
              dom[i][i>>5]|=(1<<(i&31));
              for(int j=0;j<MAXC;j++)
              {
              	  if(temp[j]!=dom[i][j])
              	  {
                 		flag=false;
              	  	break;
              	  }
              }
    		}
    	}
    	if(flag)
    		break;
    }
    /*for(int i=0;i<MAXN;i++)
    {
    	for(int j=0;j<MAXC;j++)
    		cout<<dom[i][j]<<" ";
    	cout<<endl;
    }*/
}
int main()
{
	freopen("input.txt","r",stdin);
  freopen("output.txt","w",stdout);
	int n,m;//n=no of nodes, m=no of edges
	scanf("%d%d",&n,&m);
  for(int i=0;i<m;i++)
  {
    	int u,v;
    	scanf("%d%d",&u,&v);
    	//u--,v--;
    	adj[u].push_back(v);
    	adjR[v].push_back(u);
  }
    int source;
    scanf("%d",&source);
    clock_t tStart = clock();
    //source--;
   // cout<<source<<endl;
    getdom(source);
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    cout<<cnt<<endl;
    int a[MAXN];
    memset(a,0,sizeof(a));
    for(int i=0;i<MAXN;i++)
    {
      int ans=0;
    	//bool flag=false;
    	for(int j=0;j<MAXC;j++)
    	{
    		if(j!=MAXC-1)
    		{
    		 int val=1;
    		 for(int k=0;k<32;k++)
    		 {
    		  if(dom[i][j]&val)
    		  {
            ans++;
    			//cout<<32*j+k+1<<" ";
    			//flag=true;
    		  }
    		  val<<=1;
    		 }
    		}else
    		{
    		 int cnt=n-32*(MAXC-1);
    		 int val=1;
    		 for(int k=0;k<cnt;k++)
    		 {
    		  if(dom[i][j]&val)
    		  {
            ans++;
    			//cout<<32*j+k+1<<" ";
    			//flag=true;
    		  }
    		  val<<=1;
    		 }
    		}
    	}
        /*if(flag)
          cout<<endl;*/
      a[ans]++;
    }
    for(int i=1;i<=n;i++)
    {
      if(a[i]>0)
       cout<<i<<" "<<a[i]<<endl;
    }
    cout<<endl;
	return 0;
}
