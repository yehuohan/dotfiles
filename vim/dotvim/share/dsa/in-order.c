typedef struct node_s {
    int data;
    struct node_s* parent;
    struct node_s* left;
    struct node_s* right;
}node_t;

void traverse_inorder(node_t* root, void (*visit)(node_t*)) {
    node_t* d = root;
    std::stack<node_t*> s;
    while (true) {
        while (d) {
            s.push(d);
            d = d->left;
        }
        if (s.empty()) break;
        else {
            d = s.top(); s.pop();
            visit(d);
            d = d->right;
        }
    }
}
