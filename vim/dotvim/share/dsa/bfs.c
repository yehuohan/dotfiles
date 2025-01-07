#include <stdint.h>

typedef struct Vertex {
    int data;
    uint8_t status;
} Vertex;

typedef struct Edge {
    int data;
    uint8_t status;
} Edge;

typedef Edge* EdgePtr;

typedef struct Graph {
    Vertex* v;
    EdgePtr** e;
    int v_num;
    int e_num;
} Graph;

static void BFS(Graph* g, int v) {
    std::queue<int> q;
    q.push(v);
    while (!q.empty()) {
        v = q.front();
        q.pop();
        for (int k = 0; k < g->v_num; k++) {
            if (g->e[v][k] != NULL) {
                if (g->v[k].status == 0) {
                    g->v[v].status = 1;
                    q.push(k);
                }
            }
        }
        // TODO:visit g->v[v];
        g->v[v].status = 2;
    }
}

void graph_bfs(Graph* g, int s) {
    int v = s;
    do {
        if (g->v[v].status == 0)
            BFS(g, v);
        v = (v + 1) % g->v_num;
    } while (s != v);
}
