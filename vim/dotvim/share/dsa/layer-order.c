typedef struct node_s {
    int data;
    struct node_s* parent;
    struct node_s* left;
    struct node_s* right;
}node_t;

void traverse_layerorder(node_t* root, void (*visit)(node_t*)) {
    node_t* d = root;
    std::queue<node_t*> q;
    q.push(d);
    while (!q.empty()) {
        d = q.front(); q.pop();
        visit(d);
        if (d->left) q.push(d->left);
        if (d->right) q.push(d->right);
    }
}
