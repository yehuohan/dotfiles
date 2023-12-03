#include <stdint.h>

typedef struct Vertex {
    int     data;
    uint8_t status;
}Vertex;

typedef struct Edge {
    int     data;
    uint8_t status;
}Edge;

typedef Edge* EdgePtr;

typedef struct Graph {
    Vertex*     v;
    EdgePtr**   e;
    int         v_num;
    int         e_num;
}Graph;

static void DFS(Graph* g, int v) {
    // TODO:visit g->v[v];
    g->v[v].status = 1;
    for (int k = 0; k < g->v_num; k ++) {
        if (g->e[v][k] != NULL) {
            if (g->v[k].status == 0)
                DFS(g, k);
        }
    }
}

void graph_dfs(Graph* g, int s) {
    int v = s;
    do {
        if (g->v[v].status == 0)
            DFS(g, v);
        v = (v+1) % g->v_num;
    }while(s != v);
}
