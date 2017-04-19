#include<bits/stdc++.h>
#define MAXN 10000
using namespace std;
vector<int> adj[MAXN],dom[MAXN];
bool vis[MAXN],temp[MAXN];
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
    			q.push(v);
    			vis[v]=true;
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
    for(int i=0;i<m;i++)
    {
    	int u,v;
    	cin>>u>>v;
        //u--;
        //v--;
    	adj[u].push_back(v);
    }
    int s;
    cin>>s;
    //s--;
    bfs(s);
    for(int i=0;i<n;i++)
    {
    	if(!vis[i])
    		temp[i]=true;
    }
    dom[s].push_back(s);
    for(int i=0;i<n;i++)
    {
        if(i!=s)
        {
          dom[i].push_back(s);
          dom[i].push_back(i);
        }
    }
    clock_t tStart = clock();
    for(int i=1;i<n;i++)
    {
      if(!temp[i])
      {
        for(int j=0;j<n;j++)
        {
        	if(temp[j])
        		vis[j]=true;
        	else
        		vis[j]=false;
        }
        vis[i]=true;
        bfs(s);
        for(int j=0;j<n;j++)
        {
        	if(!vis[j]&&!temp[j])
             dom[j].push_back(i);
        }
      }
    }
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<dom[i].size();j++)
            cout<<dom[i][j]+1<<" ";
        cout<<endl;
    }
	return 0;
}
