typedef struct node_s {
    int data;
    struct node_s* parent;
    struct node_s* left;
    struct node_s* right;
}node_t;

void traverse_postorder(node_t* root, void (*visit)(node_t*)) {
    node_t* d = root;
    node_t* last = NULL;
    std::stack<node_t*> s;
    while (1) {
        while (d) {
            s.push(d);
            d = d->left;
        }
        while (!s.empty()) {
            d = s.top(); s.pop();
            if (!d->right || last == d->right) {
                visit(d);
                last = d;
            } else {
                s.push(d);
                d = d->right;
                break;
            }
        }
        if (s.empty()) break;
    }
}
