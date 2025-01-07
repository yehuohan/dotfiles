typedef struct node_s {
    int data;
    struct node_s* parent;
    struct node_s* left;
    struct node_s* right;
} node_t;

void traverse_preorder(node_t* root, void (*visit)(node_t*)) {
    node_t* d = root;
    std::stack<node_t*> s;
    s.push(d);
    while (!s.empty()) {
        d = s.top();
        s.pop();
        while (d) {
            visit(d);
            s.push(d->right);
            d = d->left;
        }
    }
}
