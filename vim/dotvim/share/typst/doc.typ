// Settings
#set page("a4", margin: (x: 20pt, y: 25pt))
#set heading(numbering: "I-1.1")

#show raw.where(block: true): block.with(fill: luma(235), inset: 4pt, radius: 2pt)
#show raw.where(block: false): highlight.with(fill: luma(235), extent: 2pt, radius: 1pt)

#let title = lorem(3)


// Main body
#align(center, text(20pt)[*#title*])

= #lorem(5)

== #lorem(6)

- `Rust code`

```rust
fn main() {
}
```

=== #lorem(7)

=== #lorem(7)

= #lorem(5)
