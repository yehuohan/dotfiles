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

void graph_dijkstra(Graph* g, int s, int dist[]) {
    for (int k = 0; k < g->v_num; k ++)
        dist[k] = INT_MAX;
    dist[s] = 0;
    int v = s;
    for (int i = 0; i < g->v_num; i ++) {
        g->v[v].status = 1;
        // min(v->k)
        for (int k = 0; k < g->v_num; k ++) {
            if (g->e[v][k] != NULL && g->v[k].status == 0) {
                if (dist[k] > dist[v] + g->e[v][k]->data)
                    dist[k] = dist[v] + g->e[v][k]->data;
            }
        }
        // v = argmin(v->k)
        for (int min = INT_MAX, k = 0; k < g->v_num; k ++) {
            if (g->v[k].status == 0 && min > dist[k]) {
                min = dist[k];
                v = k;
            }
        }
    }
}
